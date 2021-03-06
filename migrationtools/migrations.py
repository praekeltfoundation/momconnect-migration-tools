import uuid
from datetime import datetime

from crontab import CronTab

from . import databases


class ImproperlyConfigured(Exception):
    """Raised when a required config option is missing or misconfigured."""


def transform_language_code(lang):
    return {
        'zu': 'zul_ZA',
        'xh': 'xho_ZA',
        'af': 'afr_ZA',
        'en': 'eng_ZA',
        'nso': 'nso_ZA',
        'tn': 'tsn_ZA',
        'so': 'sot_ZA',  # Nurseconnect ran with a broken language code for a while, support it here.
        'st': 'sot_ZA',
        'ts': 'tso_ZA',
        'ss': 'ssw_ZA',
        've': 'ven_ZA',
        'nr': 'nbl_ZA'
    }[lang]


def transform_messageset_name(name, schedule=None):
    if name == 'accelerated':
        if schedule == 1:
            # old schedule id 1 = 7 times a week
            return 'momconnect_prebirth.hw_full.6'
        elif schedule == 3:
            # old schedule id 3 = 2 times a week
            return 'momconnect_prebirth.hw_full.1'
        elif schedule == 4:
            # old schedule id 4 = 3 times a week
            return 'momconnect_prebirth.hw_full.3'
        elif schedule == 5:
            # old schedule id 5 = 4 times a week
            return 'momconnect_prebirth.hw_full.4'
        elif schedule == 6:
            # old schedule id 6 = 5 times a week
            return 'momconnect_prebirth.hw_full.5'

    return {
        'standard': 'momconnect_prebirth.hw_full.1',
        'later': 'momconnect_prebirth.hw_full.2',
        'baby1': 'momconnect_postbirth.hw_full.1',
        'baby2': 'momconnect_postbirth.hw_full.2',
        'miscarriage': 'loss_miscarriage.patient.1',
        'stillbirth': 'loss_stillbirth.patient.1',
        'subscription': 'momconnect_prebirth.patient.1',
        'chw': 'momconnect_prebirth.hw_partial.1',
        'babyloss': 'loss_babyloss.patient.1',
        'nurseconnect': 'nurseconnect.hw_full.1',
    }[name]


def transform_schedule_to_cron(minute, hour, day_of_month, month_of_year, day_of_week):
    return "%s %s %s %s %s" % (
        minute,
        hour,
        day_of_month,
        month_of_year,
        day_of_week
    )


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
            self.helpdesk = databases.Helpdesk(
                self.config.DATABASES['helpdesk'])
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

    def prepare_new_identity_data(
            self, msisdn, migration_id, migration_type,
            operator_id, created_at, updated_at, **kwargs):
        # Required global data.
        details = {
            'default_addr_type': 'msisdn',
            'addresses': {
                'msisdn': {
                    msisdn: {'default': True}
                }
            },
            'migrations': {
                migration_id: {
                    'type': migration_type,
                    'migrated_on': datetime.utcnow()
                }
            }
        }
        identity = {
            'version': 1,
            'operator_id': operator_id,
            'created_at': created_at,
            'updated_at': updated_at,
        }

        # Mom data:
        if 'lang_code' in kwargs:
            details['lang_code'] = kwargs['lang_code']
        if 'consent' in kwargs:
            details['consent'] = kwargs['consent']
        if 'sa_id_no' in kwargs:
            details['sa_id_no'] = kwargs['sa_id_no']
        if 'mom_dob' in kwargs:
            details['mom_dob'] = kwargs['mom_dob']
        if 'source' in kwargs:
            details['source'] = kwargs['source']
        if 'last_mc_reg_on' in kwargs:
            details['last_mc_reg_on'] = kwargs['last_mc_reg_on']

        # Nurse data:
        if 'nurseconnect' in kwargs and kwargs['nurseconnect']:
            nc = {}
            if 'faccode' in kwargs:
                nc['faccode'] = kwargs['faccode']
            if 'facname' in kwargs:
                nc['facname'] = kwargs['facname']
            if 'id_type' in kwargs:
                nc['id_type'] = kwargs['id_type']
                if kwargs['id_type'] == 'sa_id':
                    if 'sa_id_no' in kwargs:
                        # duplicate of above mom data, but it is clearer here.
                        nc['sa_id_no'] = kwargs['sa_id_no']
                elif kwargs['id_type'] == 'passport':
                    if 'sa_id_no' in kwargs:
                        nc['passport_no'] = kwargs['sa_id_no']
                    if 'passport_origin' in kwargs:
                        nc['passport_origin'] = kwargs['passport_origin']
            if 'mom_dob' in kwargs:
                # duplicate of above mom data, but it is clearer here.
                nc['dob'] = kwargs['mom_dob']
            if 'redial_sms_sent' in kwargs:
                nc['redial_sms_sent'] = kwargs['redial_sms_sent']
            details['nurseconnect'] = nc

        identity['details'] = details
        return identity

    def prepare_updated_identity_data(
            self, current_identity, migration_id, migration_type,
            operator_id, updated_at, **kwargs):
        details = current_identity['details']
        migtation_tag = {'type': migration_type, 'migrated_on': datetime.utcnow()}
        if 'migrations' in details:
            details['migrations'][migration_id] = migtation_tag
        else:
            details['migtations'] = {migration_id: migtation_tag}

        identity = {
            'version': current_identity['version'],
            'operator_id': operator_id,
            'updated_at': updated_at,
        }

        # Mom data. Only replace with new data if not currently present.
        if 'lang_code' in kwargs:
            details['lang_code'] = details.get('lang_code', None) or kwargs['lang_code']
        if 'consent' in kwargs:
            details['consent'] = details.get('consent', None) or kwargs['consent']
        if 'sa_id_no' in kwargs:
            details['sa_id_no'] = details.get('sa_id_no', None) or kwargs['sa_id_no']
        if 'mom_dob' in kwargs:
            details['mom_dob'] = details.get('mom_dob', None) or kwargs['mom_dob']
        if 'source' in kwargs:
            details['source'] = details.get('source', None) or kwargs['source']
        if 'last_mc_reg_on' in kwargs:
            details['last_mc_reg_on'] = details.get('last_mc_reg_on', None) or kwargs['last_mc_reg_on']

        # Nurse data. Only replace with new data if not currently present.
        if 'nurseconnect' in kwargs and kwargs['nurseconnect']:
            nc = details.get('nurseconnect', {})
            if 'faccode' in kwargs:
                nc['faccode'] = nc.get('faccode', None) or kwargs['faccode']
            if 'facname' in kwargs:
                nc['facname'] = nc.get('facname', None) or kwargs['facname']
            if 'id_type' in kwargs:
                nc['id_type'] = nc.get('id_type', None) or kwargs['id_type']
                if kwargs['id_type'] == 'sa_id':
                    if 'sa_id_no' in kwargs:
                        nc['sa_id_no'] = nc.get('sa_id_no', None) or kwargs['sa_id_no']
                elif kwargs['id_type'] == 'passport':
                    if 'sa_id_no' in kwargs:
                        nc['passport_no'] = nc.get('passport_no', None) or kwargs['sa_id_no']
                    if 'passport_origin' in kwargs:
                        nc['passport_origin'] = nc.get('passport_origin', None) or kwargs['passport_origin']
            if 'mom_dob' in kwargs:
                # duplicate of above mom data, but it is clearer here.
                nc['dob'] = nc.get('dob', None) or kwargs['mom_dob']
            if 'redial_sms_sent' in kwargs:
                nc['redial_sms_sent'] = nc.get('redial_sms_sent', None) or kwargs['redial_sms_sent']
            details['nurseconnect'] = nc

        identity['details'] = details
        return identity

    def migrate_registrations(self, start=None, stop=None, limit=None):
        # Use these shortcuts to make the code a bit more readable.
        reg_cols = self.ndoh_control.registration.c
        ident_cols = self.seed_identity.identity.c

        migration_id = str(uuid.uuid4())
        migration_type = 'registration'
        self.echo('Starting registration migration ({0})'.format(migration_id))
        for registration in self.ndoh_control.get_registrations(start, stop, limit=limit):
            # Keep a record of all transactions started so they can all be rolled back on any error.
            transactions = {}

            registration_id = registration[reg_cols.id]
            self.echo("Migrating registration: {id} ...".format(id=registration_id), nl=False)

            mom_msisdn = registration[reg_cols.mom_msisdn]
            hcw_msisdn = registration[reg_cols.hcw_msisdn]
            created_at = registration[reg_cols.created_at]

            # Setup a seed identity transaction:
            transactions['seed_identity'] = self.seed_identity.start_transaction()

            if hcw_msisdn is not None:
                # This person was registered by a HCW, check if they are already in the system.
                hcw_identity = self.seed_identity.lookup_identity_with_msdisdn(hcw_msisdn)
                if hcw_identity is None:
                    # Create a basic Identity record for the HCW.
                    ident_data = self.prepare_new_identity_data(
                        hcw_msisdn, migration_id, migration_type, operator_id=None,
                        created_at=created_at, updated_at=datetime.utcnow())
                    try:
                        operator_id = self.seed_identity.create_identity(ident_data)
                    except databases.DatabaseError as error:
                        self.echo(" Failed")
                        self.echo("Failed to create Seed Identity for HCW due to a database error:", err=True)
                        self.echo(error.message, err=True)
                        Migrator.rollback_all_transactions(transactions)
                        break
                else:
                    operator_id = hcw_identity['id']
            else:
                operator_id = None

            lang = transform_language_code(registration[reg_cols.mom_lang])
            source = registration[reg_cols.authority]
            consent = registration[reg_cols.consent]
            if consent is None:
                consent = False

            # Check if an Identity already exists for this person.
            mom_identity = self.seed_identity.lookup_identity_with_msdisdn(mom_msisdn)
            if mom_identity is None:
                # Create a full Identity record for the mom.
                ident_data = self.prepare_new_identity_data(
                    mom_msisdn, migration_id, migration_type, operator_id=operator_id,
                    lang_code=lang, consent=consent, sa_id_no=registration[reg_cols.mom_id_no],
                    mom_dob=registration[reg_cols.mom_dob], source=source,  last_mc_reg_on=source,
                    created_at=created_at, updated_at=datetime.utcnow())
                try:
                    mom_identity_id = self.seed_identity.create_identity(ident_data)
                except databases.DatabaseError as error:
                    self.echo(" Failed")
                    self.echo("Failed to create Seed Identity for Mom due to a database error:", err=True)
                    self.echo(error.message, err=True)
                    Migrator.rollback_all_transactions(transactions)
                    break
            else:
                # The Identity already exists but may not have all the required details.
                ident_data = self.prepare_updated_identity_data(
                    mom_identity, migration_id, migration_type, operator_id=operator_id,
                    lang_code=lang, consent=consent, sa_id_no=registration[reg_cols.mom_id_no],
                    mom_dob=registration[reg_cols.mom_dob], source=source,  last_mc_reg_on=source,
                    updated_at=datetime.utcnow())
                try:
                    self.seed_identity.update_identity(mom_identity[ident_cols.id], ident_data)
                except databases.DatabaseError as error:
                    self.echo(" Failed")
                    self.echo("Failed to update Seed Identity for Mom due to a database error:", err=True)
                    self.echo(error.message, err=True)
                    Migrator.rollback_all_transactions(transactions)
                    break
                mom_identity_id = mom_identity[ident_cols.id]

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
                    registrant_id=mom_identity_id, reg_type=reg_type, data=reg_data,
                    source=source, created_at=created_at,
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
        self.echo('Registation Migration completed')

    def migrate_nurseconnect_registrations(self, start=None, stop=None, limit=None):
        # Use these shortcuts to make the code a bit more readable.
        nc_cols = self.ndoh_control.ncregistration.c
        ident_cols = self.seed_identity.identity.c

        migration_id = str(uuid.uuid4())
        migration_type = 'nurseconnect'
        self.echo('Starting nurseconnect migration ({0})'.format(migration_id))
        for registration in self.ndoh_control.get_nc_registrations(start, stop, limit=limit):
            # Keep a record of all transactions started so they can all be rolled back on any error.
            transactions = {}

            registration_id = registration[nc_cols.id]
            self.echo("Migrating nurseconnect registration: {id} ...".format(id=registration_id), nl=False)

            cmsisdn = registration[nc_cols.cmsisdn]  # contact
            dmsisdn = registration[nc_cols.dmsisdn]  # device
            created_at = registration[nc_cols.created_at]

            # Setup a seed identity transaction:
            transactions['seed_identity'] = self.seed_identity.start_transaction()

            if dmsisdn is not None and cmsisdn != dmsisdn:
                # This person was registered by a 3rdparty, check if they are already in the system.
                device_identity = self.seed_identity.lookup_identity_with_msdisdn(dmsisdn)
                if device_identity is None:
                    # Create a basic Identity record for the HCW.
                    ident_data = self.prepare_new_identity_data(
                        dmsisdn, migration_id, migration_type, operator_id=None,
                        created_at=created_at, updated_at=datetime.utcnow())
                    try:
                        operator_id = self.seed_identity.create_identity(ident_data)
                    except databases.DatabaseError as error:
                        self.echo(" Failed")
                        self.echo("Failed to create Seed Identity for NC device due to a database error:", err=True)
                        self.echo(error.message, err=True)
                        Migrator.rollback_all_transactions(transactions)
                        break
                else:
                    operator_id = device_identity['id']
            else:
                operator_id = None

            # Lookup Vumi Contact info for this msisdn.
            vumi_contact = self.vumi_contacts.lookup_contact_with_msisdn(cmsisdn)
            if vumi_contact is None:
                self.echo(" Failed")
                msg = "Failed get vumi contact for nurse ref: {0}, msisdn {1}:".format(registration_id, cmsisdn)
                self.echo(msg, err=True)
                Migrator.rollback_all_transactions(transactions)
                continue

            consent = vumi_contact['json']['extra'].get('consent', False)
            vumi_lang = vumi_contact['json']['extra'].get('language_choice', None)

            if vumi_lang is None:
                # We didn't find a language.
                self.echo("Could not find any language for nurse ref: {0}, default to English".format(registration_id))
                vumi_lang = 'en'

            lang = transform_language_code(vumi_lang)

            # Check if an Identity already exists for this person.
            contact_identity = self.seed_identity.lookup_identity_with_msdisdn(cmsisdn)
            if contact_identity is None:
                # Create a full Identity record for the mom.
                ident_data = self.prepare_new_identity_data(
                    cmsisdn, migration_id, migration_type, operator_id=operator_id,
                    lang_code=lang, consent=consent, mom_dob=registration[nc_cols.dob],
                    nurseconnect=True, faccode=registration[nc_cols.faccode],
                    id_type=registration[nc_cols.id_type], sa_id_no=registration[nc_cols.id_no],
                    passport_origin=registration[nc_cols.passport_origin],
                    created_at=created_at, updated_at=datetime.utcnow())
                try:
                    contact_identity_id = self.seed_identity.create_identity(ident_data)
                except databases.DatabaseError as error:
                    self.echo(" Failed")
                    self.echo("Failed to create Seed Identity for Nurse due to a database error:", err=True)
                    self.echo(error.message, err=True)
                    Migrator.rollback_all_transactions(transactions)
                    break
            else:
                # The Identity already exists but may not have all the required details.
                ident_data = self.prepare_updated_identity_data(
                    contact_identity, migration_id, migration_type, operator_id=operator_id,
                    lang_code=lang, consent=consent, mom_dob=registration[nc_cols.dob],
                    nurseconnect=True, faccode=registration[nc_cols.faccode],
                    id_type=registration[nc_cols.id_type], sa_id_no=registration[nc_cols.id_no],
                    passport_origin=registration[nc_cols.passport_origin],
                    updated_at=datetime.utcnow())
                try:
                    self.seed_identity.update_identity(contact_identity[ident_cols.id], ident_data)
                except databases.DatabaseError as error:
                    self.echo(" Failed")
                    self.echo("Failed to update Seed Identity for Nurse due to a database error:", err=True)
                    self.echo(error.message, err=True)
                    Migrator.rollback_all_transactions(transactions)
                    break
                contact_identity_id = contact_identity[ident_cols.id]

            # Create ndoh-hub Registration.
            reg_type = source = 'nurseconnect'
            if dmsisdn is not None:
                msisdn_device = dmsisdn
            else:
                # If the user registered themselves we record the device msisdn as their msisdn.
                msisdn_device = cmsisdn

            reg_data = self.ndoh_hub.create_registration_data(
                operator_id=operator_id, msisdn_registrant=cmsisdn, msisdn_device=msisdn_device,
                id_type=registration[nc_cols.id_type], language=lang, consent=consent,
                faccode=registration[nc_cols.faccode], any_id_no=registration[nc_cols.id_no],
                passport_origin=registration[nc_cols.passport_origin],
                mom_dob=registration[nc_cols.dob])

            # Setup a ndoh hub transaction:
            transactions['ndoh_hub'] = self.ndoh_hub.start_transaction()
            try:
                self.ndoh_hub.create_registration(
                    registrant_id=contact_identity_id, reg_type=reg_type, data=reg_data,
                    source=source, created_at=created_at,
                    updated_at=registration[nc_cols.updated_at])
            except databases.DatabaseError as error:
                    self.echo(" Failed")
                    self.echo("Failed to create NDOH Hub registration for Nurse due to a database error:", err=True)
                    self.echo(error.message, err=True)
                    Migrator.rollback_all_transactions(transactions)
                    break

            # No errors have occured so commit all transactions now.
            Migrator.commit_all_transactions(transactions)
            self.echo(" Completed")
        self.echo('Nurseconnect migration completed')

    def migrate_subscriptions(self, active_only=True, start=None, stop=None, limit=None):
        # Use these shortcuts to make the code a bit more readable.
        sub_cols = self.ndoh_control.subscription.c
        ms_cols = self.ndoh_control.messageset.c
        ident_cols = self.seed_identity.identity.c
        sched_cols = self.seed_sbm.schedule.c

        migration_id = str(uuid.uuid4())
        migration_type = 'registration'
        self.echo('Starting registration migration ({0})'.format(migration_id))
        for subscription in self.ndoh_control.get_subscriptions(active_only, start, stop, limit=limit):
            # Keep a record of all transactions started so they can all be rolled back on any error.
            transactions = {}

            sub_id = subscription[sub_cols.id]
            self.echo("Starting migration of {id} ...".format(id=sub_id), nl=False)

            # Get basic details from the sub record
            msisdn = subscription[sub_cols.to_addr]
            lang = subscription[sub_cols.lang]
            old_messageset_name = subscription[ms_cols.short_name]
            created_at = subscription[sub_cols.created_at]
            updated_at = subscription[sub_cols.updated_at]
            existing_schedule_id = subscription[sub_cols.schedule_id]
            active = subscription[sub_cols.active]

            # Lookup if there is an existing Seed Identity for this msisdn.
            identity = self.seed_identity.lookup_identity_with_msdisdn(msisdn)

            # Setup a seed identity transaction:
            transactions['seed_identity'] = self.seed_identity.start_transaction()

            if identity is None:
                ident_lang = None
                # Lookup Vumi Contact info for this msisdn.
                vumi_id = subscription[sub_cols.contact_key]
                vumi_contact = self.vumi_contacts.lookup_contact(vumi_id)

                if vumi_contact is None:
                    consent = False
                    sa_id_no = None
                    mom_dob = None
                    source = None
                    vumi_lang = None
                else:
                    consent = vumi_contact['json']['extra'].get('consent', False)
                    sa_id_no = vumi_contact['json']['extra'].get('sa_id', False)
                    mom_dob = vumi_contact['json']['extra'].get('dob', False)
                    vumi_lang = vumi_contact['json']['extra'].get('language_choice', None)
                    source = None

                if not lang:
                    # There was no language set for this sub, check other venues.
                    if vumi_lang is not None:
                        lang_code = transform_language_code(vumi_lang)
                    else:
                        # We didn't find a fallback language.
                        self.echo("Could not find any language for sub: {0}, default to English".format(sub_id))
                        lang_code = transform_language_code('en')
                else:
                    lang_code = transform_language_code(lang)

                # Create the Identity using the Vumi Data if available.
                ident_data = self.prepare_new_identity_data(
                    msisdn, migration_id, migration_type, operator_id=None, lang_code=lang_code,
                    consent=consent, sa_id_no=sa_id_no, mom_dob=mom_dob, source=source,
                    created_at=created_at, updated_at=datetime.utcnow())
                try:
                    identity_id = self.seed_identity.create_identity(ident_data)
                except databases.DatabaseError as error:
                    self.echo(" Failed")
                    self.echo("Failed to create Seed Identity due to a database error:", err=True)
                    self.echo(error.message, err=True)
                    Migrator.rollback_all_transactions(transactions)
                    break
            else:
                vumi_lang = None
                ident_lang = identity[ident_cols.details].get('lang_code', None)
                identity_id = identity[ident_cols.id]

            if not lang:
                # There was no language set for this sub, check other venues.
                if vumi_lang is not None:
                    lang = transform_language_code(vumi_lang)
                if ident_lang is not None:
                    # Identity language code should take preference.
                    lang = ident_lang
                if not lang:
                    # We didn't find a fallback language.
                    self.echo("Could not find any language for sub: {0}, default to English".format(sub_id))
                    lang_code = transform_language_code('en')
            else:
                lang = transform_language_code(lang)

            # Lookup the messageset needed by this Subscription.
            new_messageset_name = transform_messageset_name(old_messageset_name, existing_schedule_id)
            messageset = self.seed_sbm.lookup_messageset_with_name(new_messageset_name)
            if messageset is None:
                # We didn't find the required message set.
                self.echo(" Failed")
                msg = "Could not load the required MessageSet ({0}) for this subscription"
                msg = msg.format(new_messageset_name)
                self.echo(msg, err=True)
                Migrator.rollback_all_transactions(transactions)
                break

            ms_schedule = self.seed_sbm.lookup_schedule(messageset['default_schedule_id'])
            if ms_schedule is None:
                # We didn't find the required message set schedule.
                self.echo(" Failed")
                msg = "Could not load the required MessageSet Schedule (ID: {0}) for this subscription"
                msg = msg.format(messageset['default_schedule_id'])
                self.echo(msg, err=True)
                Migrator.rollback_all_transactions(transactions)
                break

            # Setup subscription data.
            metadata = {
                'migrations': {
                    migration_id: {
                        'type': migration_type,
                        'migrated_on': datetime.utcnow()
                    }
                }
            }
            subscription_data = {
                'identity': identity_id,
                'version': 1,
                'next_sequence_number': subscription[sub_cols.next_sequence_number],
                'lang': lang,
                'active': active,
                'completed': subscription[sub_cols.completed],
                'schedule_id': ms_schedule['id'],
                'process_status': subscription[sub_cols.process_status],
                'metadata': metadata,
                'messageset_id': messageset['id'],
                'created_at': created_at,
                'updated_at': updated_at,
            }

            cron_definition = transform_schedule_to_cron(
                ms_schedule[sched_cols.minute], ms_schedule[sched_cols.hour],
                ms_schedule[sched_cols.day_of_week], ms_schedule[sched_cols.month_of_year],
                ms_schedule[sched_cols.day_of_week])

            # Setup a Seed SBM transaction.
            transactions['seed_sbm'] = self.seed_sbm.start_transaction()

            # Create Seed Subscription.
            try:
                subscription_id = self.seed_sbm.create_subscription(subscription_data)
            except databases.DatabaseError as error:
                self.echo(" Failed")
                self.echo("Failed to create Seed Subscription due to a database error:", err=True)
                self.echo(error.message, err=True)
                Migrator.rollback_all_transactions(transactions)
                break

            # Setup a Seed Scheduler transaction:
            transactions['seed_scheduler'] = self.seed_scheduler.start_transaction()

            # Create DJCelery CrontabSchedule.
            entry = CronTab(cron_definition)
            crontabschedule_data = {
                'minute': entry.matchers.minute.input,
                'hour': entry.matchers.hour.input,
                'day_of_week': entry.matchers.weekday.input,
                'day_of_month': entry.matchers.day.input,
                'month_of_year': entry.matchers.month.input
            }
            try:
                crontabschedule_id, cs_created = self.seed_scheduler.get_or_create_crontabschedule(crontabschedule_data)
            except databases.DatabaseError as error:
                self.echo(" Failed")
                self.echo("Failed to create CrontabSchedule due to a database error:", err=True)
                self.echo(error.message, err=True)
                Migrator.rollback_all_transactions(transactions)
                break

            if cs_created:
                # Create DJCelery PeriodicTask only if CrontabSchedule was created.
                periodictask_data = {
                    'name': "Run %s" % cron_definition,
                    'task': 'seed_scheduler.scheduler.tasks.queue_tasks',
                    'crontab_id': crontabschedule_id,
                    'enabled': True,
                    'args': '["crontab", %s]' % crontabschedule_id,
                    'kwargs': '{}',
                    'total_run_count': 0,
                    'date_changed': datetime.utcnow(),
                    'description': '',
                }
                try:
                    self.seed_scheduler.create_periodictask(periodictask_data)
                except databases.DatabaseError as error:
                    self.echo(" Failed")
                    self.echo("Failed to create PeriodicTask due to a database error:", err=True)
                    self.echo(error.message, err=True)
                    Migrator.rollback_all_transactions(transactions)
                    break

            # Setup Schedule data.
            schedule_data = {
                'frequency': None,
                'triggered': 0,
                'cron_definition': cron_definition,
                'interval_definition': None,
                'endpoint': '{base_url}/{subscription_id}/send'.format(
                    base_url=self.config.SYSTEM['sbm-api-url'], subscription_id=subscription_id),
                'auth_token': self.config.SYSTEM['scheduler-inbound-token'],
                'payload': {},
                'next_send_at': None,
                'enabled': active,
                'celery_cron_definition_id': crontabschedule_id,
                'celery_interval_definition_id': None,
                'created_at': created_at,
                'updated_at': updated_at,
            }

            # Create Seed Schedule.
            try:
                schedule_id = self.seed_scheduler.create_schedule(schedule_data)
            except databases.DatabaseError as error:
                self.echo(" Failed")
                self.echo("Failed to create Seed Schedule due to a database error:", err=True)
                self.echo(error.message, err=True)
                Migrator.rollback_all_transactions(transactions)
                break

            # Update Seed Subscription.
            metadata['scheduler_schedule_id'] = schedule_id
            try:
                self.seed_sbm.update_subscription(subscription_id, metadata)
            except databases.DatabaseError as error:
                self.echo(" Failed")
                self.echo("Failed to update Seed Subscription due to a database error:", err=True)
                self.echo(error.message, err=True)
                Migrator.rollback_all_transactions(transactions)
                break

            # No errors have occured so commit all transactions now.
            Migrator.commit_all_transactions(transactions)
            self.echo(" Completed")

    def migrate_helpdesk(self):
        ident_cols = self.seed_identity.identity.c

        for identity in self.seed_identity.get_all_identities():
            # Keep a record of all transactions started so they can all be rolled back on any error.
            transactions = {}

            uuid = identity[ident_cols.id]
            self.echo("Starting migration of {id} ...".format(id=uuid), nl=False)

            lang = identity[ident_cols.details].get('lang_code', 'eng_ZA')
            # casepro is expecting 639-2 code
            lang, _, _ = lang.partition('_')
            addresses = identity[ident_cols.details]['addresses']
            urns = []
            for scheme, address in addresses.items():
                scheme_addresses = []
                for urn, details in address.items():
                    if 'optedout' in details and details['optedout'] is True:
                        # Skip opted out URNs
                        continue
                    if 'default' in details and details['default'] is True:
                        # If a default is set for the scheme then only store the default
                        scheme_addresses = [urn]
                        break
                    scheme_addresses.append(urn)
                for value in scheme_addresses:
                    if scheme == "msisdn":
                        scheme = "tel"
                    urns.append("%s:%s" % (scheme, value))

            contact_details = {
                'uuid': uuid,
                'language': lang,
                'org_id': 1,  # hard default to 1
                'name': None,
                'fields': {},
                'urns': urns,
                'is_blocked': False,
                'is_stub': False,
                'is_active': True,
                'is_stopped': False,
                'created_on': datetime.utcnow(),
            }

            # Setup a Helpdesk transaction.
            transactions['helpdesk'] = self.helpdesk.start_transaction()

            try:
                self.helpdesk.create_contact(**contact_details)
            except databases.DatabaseError as error:
                if 'duplicate key value violates unique constraint "contacts_contact_uuid_key"' in error.message:
                    self.echo('Exists already')
                    Migrator.rollback_all_transactions(transactions)
                    continue

                else:
                    self.echo(" Failed")
                    self.echo("Failed to create Contact due to a database error:", err=True)
                    self.echo(error.message, err=True)
                    Migrator.rollback_all_transactions(transactions)
                    break

            # No errors have occured so commit all transactions now.
            Migrator.commit_all_transactions(transactions)
            self.echo(" Completed")

        task_time = datetime.utcnow()
        task_data = {
            'started_on': task_time,
            'last_successfully_started_on': task_time,
            'ended_on': task_time,
        }
        self.helpdesk.update_taskstate('contact-pull', task_data)

    def migrate_helpdesk_stubbed(self):
        ident_cols = self.seed_identity.identity.c
        cont_cols = self.helpdesk.contact.c

        for contact in self.helpdesk.get_stubbed_contacts():
            # Keep a record of all transactions started so they can all be rolled back on any error.
            transactions = {}

            uid = contact[cont_cols.id]
            self.echo("Starting fix of {id} ...".format(id=uid), nl=False)

            uuid = contact[cont_cols.uuid]
            identity = self.seed_identity.lookup_identity(uuid)
            if identity is None:
                self.echo(" Failed")
                self.echo("Could not load identity for uuid : {0}".format(uuid), err=True)
                continue

            lang = identity[ident_cols.details].get('lang_code', 'eng_ZA')
            # casepro is expecting 639-2 code
            lang, _, _ = lang.partition('_')
            addresses = identity[ident_cols.details]['addresses']
            urns = []
            for scheme, address in addresses.items():
                scheme_addresses = []
                for urn, details in address.items():
                    if 'optedout' in details and details['optedout'] is True:
                        # Skip opted out URNs
                        continue
                    if 'default' in details and details['default'] is True:
                        # If a default is set for the scheme then only store the default
                        scheme_addresses = [urn]
                        break
                    scheme_addresses.append(urn)
                for value in scheme_addresses:
                    if scheme == "msisdn":
                        scheme = "tel"
                    urns.append("%s:%s" % (scheme, value))

            contact_details = {
                'uuid': uuid,
                'language': lang,
                'org_id': 1,  # hard default to 1
                'name': None,
                'fields': {},
                'urns': urns,
                'is_blocked': False,
                'is_stub': False,
                'is_active': True,
                'is_stopped': False,
            }

            # Setup a Helpdesk transaction.
            transactions['helpdesk'] = self.helpdesk.start_transaction()

            try:
                self.helpdesk.update_contact(uid, contact_details)
            except databases.DatabaseError as error:
                self.echo(" Failed")
                self.echo("Failed to create Contact due to a database error:", err=True)
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
