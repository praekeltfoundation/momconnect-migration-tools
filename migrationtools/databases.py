import base64
import json
import os
import uuid
from datetime import datetime

from django.core.serializers.json import DjangoJSONEncoder
from sqlalchemy import create_engine, MetaData
from sqlalchemy.exc import StatementError, IntegrityError, DataError
from sqlalchemy.sql import select
from sqlalchemy.sql.expression import null


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

    def get_or_create_user(self, table, username):
        statement = select([table]).where(table.c.username == username)
        result = self.execute(statement)
        user = result.first()
        unusable_password = '!{0}'.format(generate_random_string(40))
        if user is None:
            insert_statement = table.insert()\
                .values(username=username, email='', first_name='',
                        last_name='', password=unusable_password, is_staff=False,
                        is_active=False, is_superuser=False, date_joined=datetime.utcnow())
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
                where = where & (self.registration.c.id <= end_id)
            else:
                where = (self.registration.c.id <= end_id)
        if where is not None:
            statement = statement.where(where)

        statement = statement.order_by(self.registration.c.id)
        if limit is not None:
            statement = statement.limit(limit)
        return self.connection.execute(statement)


class NDOHHub(Database):

    def _setup_tables(self, meta):
        self.source = meta.tables['registrations_source']
        self.registration = meta.tables['registrations_registration']
        self.user = meta.tables['auth_user']


class SeedIdentity(Database):

    def _setup_tables(self, meta):
        self.identity = meta.tables['identities_identity']
        self.user = meta.tables['auth_user']

    def lookup_identity(self, uid):
        statement = select([self.identity])\
            .where(self.identity.c.id == uid)
        return self.execute(statement).fetchone()

    def lookup_identity_with_msdisdn(self, msisdn, role):
        statement = select([self.identity])\
            .where(
                (self.identity.c.details[('addresses', 'msisdn', msisdn)] != null())
                & (self.identity.c.details['role'].astext == role))
        return self.execute(statement).fetchone()

    def create_identity_details(self, msisdn, role, lang_code, consent, sa_id_no, mom_dob, source, last_mc_reg_on):
        details = {
            'default_addr_type': 'msisdn',
            'addresses': {
                'msisdn': {
                    msisdn: {'default': True}
                }
            },
            'role': role
        }
        if lang_code is not None:
            details['lang_code'] = lang_code
        if consent is not None:
            details['consent'] = consent
        if sa_id_no is not None:
            details['sa_id_no'] = sa_id_no
        if mom_dob is not None:
            details['mom_dob'] = mom_dob
        if source is not None:
            details['source'] = source
        if last_mc_reg_on is not None:
            details['last_mc_reg_on'] = last_mc_reg_on

        return details

    def update_identity_details(self, current_details, lang_code, consent, sa_id_no, mom_dob, source, last_mc_reg_on):
        """Mutates the given dictionary `current_details` with the other values provided."""
        current_details['lang_code'] = lang_code
        current_details['consent'] = consent
        current_details['sa_id_no'] = sa_id_no
        current_details['mom_dob'] = mom_dob
        current_details['source'] = source
        current_details['last_ms_reg_on'] = last_mc_reg_on

    def create_identity(self, details, operator_id, created_at, updated_at):
        uid = str(uuid.uuid4())
        statement = self.identity.insert()\
            .values(
                id=uid, details=details, version=1, communicate_through_id=None,
                operator_id=operator_id, created_at=created_at, updated_at=updated_at,
                created_by_id=self.migration_user['id'], updated_by_id=self.migration_user['id'])
        return self.execute(statement).inserted_primary_key[0]

    def update_identity(self, uid, details, updated_at=None):
        statement = self.identity.update()\
            .where(self.identity.c.id == uid)\
            .values(details=details, updated_at=updated_at, updated_by_id=self.migration_user['id'])
        return self.execute(statement)


class SeedSBM(Database):

    def _setup_tables(self, meta):
        self.subscription = meta.tables['subscriptions_subscription']
        self.messageset = meta.tables['contentstore_messageset']
        self.user = meta.tables['auth_user']


class SeedScheduler(Database):

    def _setup_tables(self, meta):
        self.schedule = meta.tables['scheduler_schedule']
        self.user = meta.tables['auth_user']
