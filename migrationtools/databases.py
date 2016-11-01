import base64
import json
import os
import uuid
from datetime import datetime

from django.core.serializers.json import DjangoJSONEncoder
from sqlalchemy import create_engine, MetaData
from sqlalchemy.exc import StatementError, IntegrityError, DataError
from sqlalchemy.sql import select
from sqlalchemy.sql.expression import false


def generate_random_string(length):
    return base64.urlsafe_b64encode(os.urandom(length))[:length]


def json_serializer(obj):
    return json.dumps(obj, cls=DjangoJSONEncoder)


class DatabaseError(Exception):
    """Raised when an SQL level error occurs."""


class Database(object):

    # The username of the account to create and update records as
    MIGRATION_USERNAME = 'app_migration'

    def __init__(self, db_url):
        self.db_url = db_url
        self.engine = create_engine(self.db_url, json_serializer=json_serializer)
        self._connection = None
        self.meta = MetaData()
        self.meta.reflect(bind=self.engine)
        self._setup_tables(self.meta)

    def _setup_tables(self, meta):
        raise NotImplementedError("Subclasses must define this method.")

    @property
    def connection(self):
        if self._connection is None:
            self._connection = self.engine.connect()
        return self._connection

    def execute(self, statement):
        try:
            return self.connection.execute(statement)
        except (StatementError, IntegrityError, DataError) as error:
            raise DatabaseError(error.message)

    def start_transaction(self):
        return self.connection.begin()

    def get_or_create_user(self, table, username):
        statement = select([table]).where(table.c.username == username)
        result = self.execute(statement)
        user = result.first()
        unusable_password = '!{0}'.format(generate_random_string(40))
        if user is None:
            insert_statement = table.insert()\
                .values(username=username, email='', first_name='',
                        last_name='', password=unusable_password, is_staff=False,
                        is_active=False, is_superuser=False, date_joined=datetime.utcnow(),
                        last_login=datetime.utcnow())
            user_id = self.execute(insert_statement).inserted_primary_key[0]
            statement = select([table]).where(table.c.id == user_id)
            result = self.execute(statement)
            user = result.first()
        return user

    @property
    def migration_user(self):
        if hasattr(self, 'user'):
            return self.get_or_create_user(self.user, self.MIGRATION_USERNAME)


class NDOHControl(Database):

    def _setup_tables(self, meta):
        self.subscription = meta.tables['subscription_subscription']
        self.registration = meta.tables['registration_registration']
        self.source = meta.tables['registration_source']
        self.messageset = meta.tables['subscription_messageset']
        self.crontabschedule = meta.tables['djcelery_crontabschedule']
        self.periodtask = meta.tables['djcelery_periodictask']
        self.ncregistration = meta.tables['nursereg_nursereg']
        self.ncsource = meta.tables['nursereg_nursesource']
        self.user = meta.tables['auth_user']

    def create_source(self, **kwargs):
        """Creates a source record. Used only for testing."""
        statement = self.source.insert().values(**kwargs)
        return self.execute(statement).inserted_primary_key[0]

    def create_registration(self, **kwargs):
        """Creates a registration record. Used only for testing."""
        statement = self.registration.insert().values(**kwargs)
        return self.execute(statement).inserted_primary_key[0]

    def get_registrations(self, start_id=None, end_id=None, limit=None):
        """Get all the current registration records order by pk (id) in
        ascending order.

        start_id and end_id can be given as inclusive boundries of which rows
        to select.

        limit can be given has a hard cutoff on the number of rows to select.
        """
        statement = select([self.registration, self.source])\
            .select_from(self.registration.join(self.source))
        where = None
        if start_id is not None:
            where = (self.registration.c.id >= start_id)
        if end_id is not None:
            if where is not None:
                where = (where & (self.registration.c.id <= end_id))
            else:
                where = (self.registration.c.id <= end_id)
        if where is not None:
            statement = statement.where(where)

        statement = statement.order_by(self.registration.c.id)
        if limit is not None:
            statement = statement.limit(limit)
        return self.connection.execute(statement)

    def get_nc_registrations(self, start_id=None, end_id=None, limit=None):
        """Get all the current nurseconnect registration records order
        by pk (id) in ascending order. Does not include opted out records.

        start_id and end_id can be given as inclusive boundries of which rows
        to select.

        limit can be given has a hard cutoff on the number of rows to select.
        """
        statement = select([self.ncregistration, self.ncsource])\
            .select_from(self.ncregistration.join(self.ncsource))
        where = (self.ncregistration.c.opted_out == false())
        if start_id is not None:
            where = (where & (self.ncregistration.c.id >= start_id))
        if end_id is not None:
            where = (where & (self.ncregistration.c.id <= end_id))
        if where is not None:
            statement = statement.where(where)

        statement = statement.order_by(self.ncregistration.c.id)
        if limit is not None:
            statement = statement.limit(limit)
        return self.connection.execute(statement)

    def get_subscriptions(self, active_only=True, start_id=None, end_id=None, limit=None):
        statement = select([self.subscription, self.messageset])\
            .select_from(self.subscription.join(self.messageset))
        where = (self.subscription.c.active == active_only)
        if start_id is not None:
            where = (where & (self.subscription.c.id >= start_id))
        if end_id is not None:
            where = (where & (self.subscription.c.id <= end_id))
        statement = statement.where(where)

        statement = statement.order_by(self.subscription.c.id)
        if limit is not None:
            statement = statement.limit(limit)
        return self.connection.execute(statement)


class NDOHHub(Database):

    def _setup_tables(self, meta):
        self.source = meta.tables['registrations_source']
        self.registration = meta.tables['registrations_registration']
        self.user = meta.tables['auth_user']

    def create_source(self, **kwargs):
        """Creates a source record. Used only for testing."""
        statement = self.source.insert().values(**kwargs)
        return self.execute(statement).inserted_primary_key[0]

    def get_source_from_authority(self, authority):
        if authority == 'clinic':
            name = 'CLINIC USSD App'
        elif authority == 'personal':
            name = 'PUBLIC USSD App'
        elif authority == 'chw':
            name = 'CHW USSD App'
        elif authority == 'nurseconnect':
            name = 'NURSE USSD App'
        else:
            name = 'Migration App'
        statement = select([self.source])\
            .where(self.source.c.name == name)
        return self.execute(statement).fetchone()

    def create_registration_data(
            self, operator_id, msisdn_registrant, msisdn_device, id_type,
            language, consent, edd=None, faccode=None,
            any_id_no=None, passport_origin=None, mom_dob=None):
        data = {
            'operator_id': operator_id,
            'msisdn_registrant': msisdn_registrant,
            'msisdn_device': msisdn_device,  # this will be the same as registrant when a user registers themselves.
            'id_type': id_type,
            'language': language,
            'consent': consent
        }
        if id_type == 'sa_id':
            data['sa_id_no'] = any_id_no
        elif id_type == 'passport':
            data['passport_no'] = any_id_no
            data['passport_origin'] = passport_origin

        if mom_dob is not None:
            data['mom_dob'] = mom_dob
        if edd is not None:
            data['edd'] = edd
        if faccode is not None:
            data['faccode'] = faccode
        return data

    def create_registration(self, registrant_id, reg_type, data, source, created_at, updated_at):
        uid = str(uuid.uuid4())
        source_obj = self.get_source_from_authority(source)
        if source_obj is None:
            raise DatabaseError("Could not locate source ({0}) for ndoh-hub registration".format(source_obj))
        statement = self.registration.insert()\
            .values(id=uid, registrant_id=registrant_id, reg_type=reg_type, data=data,
                    validated=True, created_at=created_at, source_id=source_obj['id'],
                    updated_at=updated_at, created_by_id=self.migration_user['id'],
                    updated_by_id=self.migration_user['id'])
        return self.execute(statement).inserted_primary_key[0]


class SeedIdentity(Database):

    def _setup_tables(self, meta):
        self.identity = meta.tables['identities_identity']
        self.user = meta.tables['auth_user']

    def lookup_identity(self, uid):
        statement = select([self.identity])\
            .where(self.identity.c.id == uid)
        return self.execute(statement).fetchone()

    def lookup_identity_with_msdisdn(self, msisdn):
        # This isn't great because it assumes addresses is always this object where
        # in practice it might have other, inactive or non default addresses.
        msisdn_obj = {"addresses": {"msisdn": {msisdn: {"default": True}}}}
        statement = select([self.identity])\
            .where(self.identity.c.details.contains(msisdn_obj))
        result = self.execute(statement)
        rows = result.fetchall()
        count = len(rows)
        if count > 1:
            msg = "lookup_identity_with_msdisdn returned more than one row for '{0}'. It returned {1}"
            msg = msg.format(msisdn, count)
            self.echo(msg, err=True)
            return rows[0]
        elif count == 1:
            return rows[0]
        else:
            return None

    def create_identity(self, identity_data):
        uid = str(uuid.uuid4())
        identity_data['id'] = uid
        identity_data['created_by_id'] = self.migration_user['id']
        identity_data['updated_by_id'] = self.migration_user['id']
        statement = self.identity.insert().values(**identity_data)
        return self.execute(statement).inserted_primary_key[0]

    def update_identity(self, uid, identity_data):
        identity_data['updated_by_id'] = self.migration_user['id']
        statement = self.identity.update()\
            .where(self.identity.c.id == uid)\
            .values(**identity_data)
        return self.execute(statement)

    def get_all_identities(self):
        statement = select([self.identity]).order_by(self.identity.c.created_at)
        return self.connection.execute(statement)


class SeedSBM(Database):

    def _setup_tables(self, meta):
        self.subscription = meta.tables['subscriptions_subscription']
        self.messageset = meta.tables['contentstore_messageset']
        self.schedule = meta.tables['contentstore_schedule']
        self.user = meta.tables['auth_user']

    def lookup_messageset_with_name(self, name):
        statement = select([self.messageset])\
            .where(self.messageset.c.short_name == name)
        return self.execute(statement).fetchone()

    def lookup_schedule(self, uid):
        statement = select([self.schedule])\
            .where(self.schedule.c.id == uid)
        return self.execute(statement).fetchone()

    def create_subscription(self, subscription_data):
        subscription_data['id'] = str(uuid.uuid4())
        subscription_data['created_by_id'] = self.migration_user['id']
        subscription_data['updated_by_id'] = self.migration_user['id']
        statement = self.subscription.insert().values(**subscription_data)
        return self.execute(statement).inserted_primary_key[0]

    def update_subscription(self, uid, metadata):
        statement = self.subscription.update()\
            .where(self.subscription.c.id == uid)\
            .values(metadata=metadata)
        return self.execute(statement)


class SeedScheduler(Database):

    def _setup_tables(self, meta):
        self.schedule = meta.tables['scheduler_schedule']
        self.periodictask = meta.tables['djcelery_periodictask']
        self.crontabschedule = meta.tables['djcelery_crontabschedule']
        self.user = meta.tables['auth_user']

    def get_or_create_crontabschedule(self, schedule_data):
        statement = select([self.crontabschedule])\
            .where(
                (self.crontabschedule.c.minute == schedule_data['minute']) &
                (self.crontabschedule.c.hour == schedule_data['hour']) &
                (self.crontabschedule.c.day_of_week == schedule_data['day_of_week']) &
                (self.crontabschedule.c.day_of_month == schedule_data['day_of_month']) &
                (self.crontabschedule.c.month_of_year == schedule_data['month_of_year']))
        cs = self.execute(statement).fetchone()
        if cs is not None:
            return cs[self.crontabschedule.c.id], False

        statement = self.crontabschedule.insert().values(**schedule_data)
        return self.execute(statement).inserted_primary_key[0], True

    def create_periodictask(self, task_data):
        statement = self.periodictask.insert().values(**task_data)
        return self.execute(statement).inserted_primary_key[0]

    def create_schedule(self, subscription_data):
        subscription_data['id'] = str(uuid.uuid4())
        subscription_data['created_by_id'] = self.migration_user['id']
        subscription_data['updated_by_id'] = self.migration_user['id']
        statement = self.schedule.insert().values(**subscription_data)
        return self.execute(statement).inserted_primary_key[0]


class VumiContacts(Database):

    def _setup_tables(self, meta):
        self.contact = meta.tables['contacts']

    def lookup_contact(self, key):
        statement = select([self.contact])\
            .where(self.contact.c.key == key)
        return self.execute(statement).fetchone()

    def lookup_contact_with_msisdn(self, msisdn):
        statement = select([self.contact])\
            .where(self.contact.c.msisdn == msisdn)
        return self.execute(statement).fetchone()


class Helpdesk(Database):

    def _setup_tables(self, meta):
        self.contact = meta.tables['contacts_contact']
        self.taskstate = meta.tables['orgs_taskstate']

    def update_taskstate(self, name, task_data):
        statement = self.taskstate.update()\
            .where(self.taskstate.c.task_key == name)\
            .values(**task_data)
        return self.execute(statement)

    def create_contact(self, **kwargs):
        statement = self.contact.insert().values(**kwargs)
        return self.execute(statement).inserted_primary_key[0]
