from . import databases


class ImproperlyConfigured(Exception):
    """Raised when a required config option is missing or misconfigured."""


class Migrator(object):

    def __init__(self, config, debug=False):
        self.config = config
        self.debug = debug
        try:
            self.ndoh_control = databases.NDOHControl(
                self.config.DATABASES['ndoh-control'])
            self.ndoh_hub = databases.NDOHHub(
                self.config.DATABASES['ndoh-hub'])
            self.seed_identity = databases.SeedIdentity(
                self.config.DATABASES['seed-identity-store'])
            self.seed_sbm = databases.SeedSBM(
                self.config.DATABASES['seed-stage-based-messaging'])
            self.seed_scheduler = databases.SeedScheduler(
                self.config.DATABASES['seed-scheduler'])
        except AttributeError:
            raise ImproperlyConfigured("Invalid or missing database configs.")

    def full_migration(self):
        # Migrate registrations
        # Migrate subscriptions
        pass
