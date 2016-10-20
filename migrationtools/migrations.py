import click
from profilehooks import profile

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

    @profile
    def migrate_registrations(self):
        for registration in self.ndoh_control.get_registrations():
            # Check for existing Seed Identity for mom_msisdn:
            mom_msisdn = registration[self.ndoh_control.registration.c.mom_msisdn]
            identity = self.seed_identity.lookup_identity_with_msdisdn(mom_msisdn)
            if identity is not None:
                # No existing Identity, so create it.
                lang = registration[self.ndoh_control.registration.c.mom_lang]
                source = registration[self.ndoh_control.registration.c.source_id]
                details = self.seed_identity.create_identity_details(
                    mom_msisdn, lang, registration[self.ndoh_control.registration.c.consent],
                    registration[self.ndoh_control.registration.c.mom_id_no],
                    registration[self.ndoh_control.registration.c.mom_dob],
                    source, source)
                identity = self.seed_identity.create_identity(
                    details, None, registration[self.ndoh_control.registration.c.created_at],
                    registration[self.ndoh_control.registration.c.updated_at], None, None)

                click.echo(identity)

            # Create ndoh-hub Registration.

    def full_migration(self):
        # Migrate registrations
        self.migrate_registrations()
        # Migrate subscriptions
        # Migrate nurseconnect
