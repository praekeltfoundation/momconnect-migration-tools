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
            self.vumi_contacts = databases.VumiContacts(
                self.config.DATABASES['vumi-contacts'])
        except AttributeError:
            raise ImproperlyConfigured("Invalid or missing database configs.")

    @staticmethod
    def rollback_all_transactions(transaction_dict):
        for transaction in transaction_dict.values():
            transaction.rollback()

    @staticmethod
    def commit_all_transactions(transaction_dict):
        for transaction in transaction_dict.values():
            transaction.commit()

    def get_or_create_identity(
                self, msisdn, lang_code=None, consent=None, sa_id_no=None,
                mom_dob=None, source=None, last_mc_reg_on=None,
                operator_id=None, created_at=None, updated_at=None):
        identity = self.seed_identity.lookup_identity_with_msdisdn(msisdn)

        if identity is not None:
            return identity, False

        else:
            # No existing Identity, so create it.
            details = self.seed_identity.create_identity_details(
                msisdn=msisdn, lang_code=lang_code, consent=consent,
                sa_id_no=sa_id_no, mom_dob=mom_dob,
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

    def migrate_registrations(self, start=None, stop=None, limit=None):
        for registration in self.ndoh_control.get_registrations(start, stop, limit=limit):
            # Keep a record of all transactions started so they can all be rolled back on any error.
            transactions = {}

            # Use these shortcuts to make the code a bit more readable.
            reg_cols = self.ndoh_control.registration.c
            ident_cols = self.seed_identity.identity.c

            # TODO: Query the Vumi Go contact for this msisdn to get more details.

            reg_id = registration[reg_cols.id]
            self.echo("Starting migration of {id} ...".format(id=reg_id), nl=False)
            mom_msisdn = registration[reg_cols.mom_msisdn]
            hcw_msisdn = registration[reg_cols.hcw_msisdn]
            lang = transform_language_code(registration[reg_cols.mom_lang])
            source = registration[reg_cols.authority]
            consent = registration[reg_cols.consent]
            if consent is None:
                consent = False

            # Setup a seed identity transaction:
            transactions['seed_identity'] = self.seed_identity.start_transaction()

            # Get or create Seed Identity for the hcw_msisdn. There is no difference
            # for roles when creating an Identity. A HCW may also be a mom or a nurse
            # in the system so there is no role flag.
            if hcw_msisdn is not None:
                try:
                    hcw_identity, hcw_created = self.get_or_create_identity(hcw_msisdn)
                except databases.DatabaseError as error:
                    self.echo(" Failed")
                    self.echo("Failed to get/create Seed Identity for HCW due to a database error:", err=True)
                    self.echo(error.message, err=True)
                    Migrator.rollback_all_transactions(transactions)
                    break

                operator_id = hcw_identity[ident_cols.id]
            else:
                operator_id = None

            # Get or create Seed Identity for the mom_msisdn:
            try:
                identity, created = self.get_or_create_identity(
                    mom_msisdn, lang_code=lang, consent=consent, sa_id_no=registration[reg_cols.mom_id_no],
                    mom_dob=registration[reg_cols.mom_dob], source=source,  last_mc_reg_on=source,
                    operator_id=operator_id, created_at=registration[reg_cols.created_at],
                    updated_at=registration[reg_cols.updated_at])
            except databases.DatabaseError as error:
                self.echo(" Failed")
                self.echo("Failed to get/create Seed Identity for Mom due to a database error:", err=True)
                self.echo(error.message, err=True)
                Migrator.rollback_all_transactions(transactions)
                break

            if not created:
                # Update the details.
                current_details = identity[ident_cols.details]
                try:
                    new_details = self.seed_identity.update_identity_details(
                            current_details=current_details, lang_code=lang, consent=consent,
                            sa_id_no=registration[reg_cols.mom_id_no],
                            mom_dob=registration[reg_cols.mom_dob], source=source, last_mc_reg_on=source)
                    self.seed_identity.update_identity(identity[ident_cols.id], new_details,
                                                       updated_at=registration[reg_cols.updated_at])
                except databases.DatabaseError as error:
                    self.echo(" Failed")
                    self.echo("Failed to update Seed Identity for Mom due to a database error:", err=True)
                    self.echo(error.message, err=True)
                    Migrator.rollback_all_transactions(transactions)
                    break

            # Create ndoh-hub Registration.
            reg_type = 'momconnect_prebirth'
            if hcw_msisdn is not None:
                msisdn_device = hcw_msisdn
            else:
                # If the user registered themselves we record the device msisdn as their msisdn.
                msisdn_device = mom_msisdn

            reg_data = self.ndoh_hub.create_registration_data(
                operator_id=operator_id, msisdn_registrant=mom_msisdn, msisdn_device=msisdn_device,
                id_type=registration[reg_cols.mom_id_type], language=lang, consent=consent,
                edd=registration[reg_cols.mom_edd], faccode=registration[reg_cols.clinic_code],
                any_id_no=registration[reg_cols.mom_id_no],
                passport_origin=registration[reg_cols.mom_passport_origin],
                mom_dob=registration[reg_cols.mom_dob])

            # Setup a ndoh hub transaction:
            transactions['ndoh_hub'] = self.ndoh_hub.start_transaction()
            try:
                self.ndoh_hub.create_registration(
                    registrant_id=identity[ident_cols.id], reg_type=reg_type, data=reg_data,
                    source=source, created_at=registration[reg_cols.created_at],
                    updated_at=registration[reg_cols.updated_at])
            except databases.DatabaseError as error:
                    self.echo(" Failed")
                    self.echo("Failed to create NDOH Hub registration for Mom due to a database error:", err=True)
                    self.echo(error.message, err=True)
                    Migrator.rollback_all_transactions(transactions)
                    break

            # No errors have occured so commit all transactions now.
            Migrator.commit_all_transactions(transactions)
            self.echo(" Completed")

    def full_migration(self, limit=None):
        # Migrate registrations
        self.migrate_registrations(limit=10)
        # Migrate subscriptions
        # Migrate nurseconnect
