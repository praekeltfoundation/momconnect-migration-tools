from sqlalchemy import create_engine, MetaData
from sqlalchemy.sql import select
from sqlalchemy.sql.expression import null


class Database(object):

    def __init__(self, db_url):
        self.db_url = db_url
        self.engine = create_engine(self.db_url)
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


class SeedIdentity(Database):

    def _setup_tables(self, meta):
        self.identity = meta.tables['identities_identity']

    def lookup_identity_with_msdisdn(self, msisdn):
        statement = select([self.identity])\
            .where(self.identity.c.details[('addresses', 'msisdn', msisdn)]
                   != null())
        return self.connection.execute(statement).fetchone()

    def create_identity_details(self, msisdn, lang_code, consent, sa_id_no, mom_dob, source, last_mc_reg_on):
        return {
            'default_addr_type': 'msisdn',
            'addresses': {
                'msisdn': {
                    msisdn: {'default': True}
                }
            },
            'lang_code': lang_code,
            'consent': consent,
            'sa_id_no': sa_id_no,
            'mom_dob': mom_dob,
            'source': source,
            'last_mc_reg_on': last_mc_reg_on
        }

    def create_identity(self, details, operator, created_at, updated_at, created_by, updated_by):
        # version
        # communicate_through
        # operator
        # created_at
        # updated_at
        # created_by
        # updated_by
        pass


class SeedSBM(Database):

    def _setup_tables(self, meta):
        self.subscription = meta.tables['subscriptions_subscription']
        self.messageset = meta.tables['contentstore_messageset']


class SeedScheduler(Database):

    def _setup_tables(self, meta):
        self.schedule = meta.tables['scheduler_schedule']
