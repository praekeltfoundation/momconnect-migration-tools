from profilehooks import profile
from . import databases


class ImproperlyConfigured(Exception):
    """Raised when a required config option is missing or misconfigured."""


class Migrator(object):

    def __init__(self, config, debug=False):
        self.config = config
        self.debug = debug
        try:
            self.ndoh = databases.NDOHControl(
                self.config.DATABASES['ndoh-control'])
        except AttributeError:
            raise ImproperlyConfigured("Invalid or missing database configs.")

    @profile
    def migrate_subscriptions(self, start_id=None, end_id=None, limit=None):
        subscriptions = self.ndoh.get_subscriptions(start_id, end_id, limit)
        for subscription in subscriptions:
            # Create Seed Identity
            # - lookup subscription.user_account in Vumi contact DB
            # - consolidate data and save Identity
            # Link to existing message set from old message set
            # Create Seed Subscription
            # Transform current schedule format to Seed format
            # Create Seed Schedule
            # click.echo(subscription)
            pass
