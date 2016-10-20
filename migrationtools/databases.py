from sqlalchemy import create_engine, MetaData


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
        self.messageset = meta.tables['subscription_messageset']
        self.crontabschedule = meta.tables['djcelery_crontabschedule']
        self.periodtask = meta.tables['djcelery_periodictask']


class NDOHHub(Database):

    def _setup_tables(self, meta):
        self.source = meta.tables['registrations_source']
        self.registration = meta.tables['registrations_registration']


class SeedIdentity(Database):

    def _setup_tables(self, meta):
        self.identity = meta.tables['identities_identity']


class SeedSBM(Database):

    def _setup_tables(self, meta):
        self.subscription = meta.tables['subscriptions_subscription']
        self.messageset = meta.tables['contentstore_messageset']


class SeedScheduler(Database):

    def _setup_tables(self, meta):
        self.schedule = meta.tables['scheduler_schedule']
