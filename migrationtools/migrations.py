from datetime import datetime

from . import databases


class ImproperlyConfigured(Exception):
    """Raised when a required config option is missing or misconfigured."""


def transform_language_code(lang):
    return {
        "zu": "zul_ZA",
        "xh": "xho_ZA",
        "af": "afr_ZA",
        "en": "eng_ZA",
        "nso": "nso_ZA",
        "tn": "tsn_ZA",
        "st": "sot_ZA",
        "ts": "tso_ZA",
        "ss": "ssw_ZA",
        "ve": "ven_ZA",
        "nr": "nbl_ZA"
    }[lang]


class Migrator(object):

    def __init__(self, config, echo, debug=False):
        self.config = config
        self.echo = echo
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

    def get_or_create_identity(
                self, msisdn, role='mom', lang_code=None, consent=None,
                sa_id_no=None, mom_dob=None, source=None, last_mc_reg_on=None,
                operator_id=None, created_at=None, updated_at=None):
        identity = self.seed_identity.lookup_identity_with_msdisdn(msisdn, role)

        if identity is not None:
            return identity, False

        else:
            # No existing Identity, so create it.
            details = self.seed_identity.create_identity_details(
                msisdn=msisdn, role=role, lang_code=lang_code,
                consent=consent, sa_id_no=sa_id_no, mom_dob=mom_dob,
                source=source, last_mc_reg_on=source)

            if created_at is None:
                created_at = datetime.utcnow()
            if updated_at is None:
                updated_at = datetime.utcnow()
            identity_id = self.seed_identity.create_identity(
                details=details, operator_id=operator_id, created_at=created_at,
                updated_at=updated_at)
            identity = self.seed_identity.lookup_identity(identity_id)
            return identity, True

    def migrate_registrations(self, limit=None):
        for registration in self.ndoh_control.get_registrations(limit=limit):
            # Use these shortcuts to make the code a bit more readable.
            reg_cols = self.ndoh_control.registration.c
            ident_cols = self.seed_identity.identity.c

            # TODO: Query the Vumi Go contact for this msisdn to get more details.

            reg_id = registration[reg_cols.id]
            self.echo('Starting migration of {id} ...'.format(id=reg_id), nl=False)
            mom_msisdn = registration[reg_cols.mom_msisdn]
            hcw_msisdn = registration[reg_cols.hcw_msisdn]
            lang = transform_language_code(registration[reg_cols.mom_lang])
            source = registration[reg_cols.authority]
            consent = registration[reg_cols.consent]
            if consent is None:
                consent = False

            # Get or create Seed Identity for the hcw_msisdn:
            if hcw_msisdn is not None:
                hcw_identity, hcw_created = self.get_or_create_identity(hcw_msisdn, role='hcw')
                operator_id = hcw_identity[ident_cols.id]
            else:
                operator_id = None

            # Get or create Seed Identity for the mom_msisdn:
            identity, created = self.get_or_create_identity(
                mom_msisdn, lang_code=lang, consent=consent, sa_id_no=registration[reg_cols.mom_id_no],
                mom_dob=registration[reg_cols.mom_dob], source=source,  last_mc_reg_on=source,
                operator_id=operator_id, created_at=registration[reg_cols.created_at],
                updated_at=registration[reg_cols.updated_at])
            if not created:
                # Update the details.
                current_details = identity[ident_cols.details]
                self.seed_identity.update_identity_details(
                        current_details=current_details, lang_code=lang, consent=consent,
                        sa_id_no=registration[reg_cols.mom_id_no],
                        mom_dob=registration[reg_cols.mom_dob], source=source, last_mc_reg_on=source)

            # Create ndoh-hub Registration.
            self.echo(' Completed')

    def full_migration(self, limit=None):
        # Migrate registrations
        self.migrate_registrations(limit=10)
        # Migrate subscriptions
        # Migrate nurseconnect
