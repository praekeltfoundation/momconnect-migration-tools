from sqlalchemy import create_engine, MetaData
from sqlalchemy.sql import select
from sqlalchemy.sql.expression import true


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

    def get_subscriptions(self, start_id=None, end_id=None, limit=None):
        join_condition = self.subscription.outerjoin(
            self.registration,
            self.subscription.c.to_addr == self.registration.c.mom_msisdn
        )
        statement = select([self.subscription, self.registration])\
            .select_from(join_condition)\
            .where(self.subscription.c.active == true())
        statement = statement.order_by(self.subscription.c.id)
        if limit is not None:
            statement = statement.limit(limit)
        return self.connection.execute(statement)
