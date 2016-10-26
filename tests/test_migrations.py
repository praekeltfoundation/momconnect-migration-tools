import os.path
from datetime import datetime
import subprocess32 as subprocess

import pytest
from sqlalchemy.engine.url import make_url
from sqlalchemy.sql import select
from sqlalchemy.sql.expression import null
from sqlalchemy_utils import database_exists, create_database, drop_database

from migrationtools import migrations


def mock_echo(message, nl=False, err=False):
    # Do nothing
    pass


def import_sql_schema(path, db_name):
    _, file_name = db_name.split('test_')
    sql_file = os.path.join(path, 'schemas', file_name + '.sql')
    args = ['/usr/local/bin/psql', '-q', db_name, '-f', sql_file]
    subprocess.call(args)


@pytest.fixture(scope='module')
def config():
    class Config(object):
        DATABASES = {
            'ndoh-control': 'postgresql://postgres:test@localhost/test_ndoh',
            'ndoh-hub': 'postgresql://postgres:test@localhost/test_ndoh_hub',
            'seed-identity-store': 'postgresql://postgres:test@localhost/test_seed_identity_store',
            'seed-stage-based-messaging': 'postgresql://postgres:test@localhost/test_seed_stage_based_messaging',
            'seed-scheduler': 'postgresql://postgres:test@localhost/test_seed_scheduler',
        }
    return Config()


@pytest.fixture(scope='module')
def migrator(config, request):
    # Create all the test DBs if they don't already exist.
    for db_url in config.DATABASES.values():
        if not database_exists(db_url):
            create_database(db_url)
            url = make_url(db_url)
            import_sql_schema(request.fspath.dirname, url.database)
    yield migrations.Migrator(config, echo=mock_echo)
    # Drop the test DBs on teardown.
    for db_url in config.DATABASES.values():
        if database_exists(db_url):
            drop_database(db_url)


@pytest.fixture(scope='module')
def dummy_initial_data(migrator):
    now = datetime.utcnow()
    vumi_user = migrator.ndoh_control.get_or_create_user(migrator.ndoh_control.user, 'Vumi')
    source_id = migrator.ndoh_control.create_source(name='Vumi Go', user_id=vumi_user['id'],
                                                    created_at=now, updated_at=now)
    # Create required ndoh-hub sources.
    vumi_hub_user = migrator.ndoh_hub.get_or_create_user(migrator.ndoh_hub.user, 'Vumi')
    migrator.ndoh_hub.create_source(name='CLINIC USSD App', authority='hw_full',
                                    user_id=vumi_hub_user['id'], created_at=now, updated_at=now)
    migrator.ndoh_hub.create_source(name='CHW USSD App', authority='hw_limited',
                                    user_id=vumi_hub_user['id'], created_at=now, updated_at=now)
    migrator.ndoh_hub.create_source(name='PUBLIC USSD App', authority='patient',
                                    user_id=vumi_hub_user['id'], created_at=now, updated_at=now)
    yield {
        'control_source_id': source_id,
    }


@pytest.fixture(scope='module')
def dummy_clinic_registration(migrator, dummy_initial_data):
    now = datetime.utcnow()
    migrator.ndoh_control.create_registration(
        hcw_msisdn='+27825550000',
        mom_msisdn='+27825550100',
        mom_id_type='sa_id',
        mom_lang='en',
        mom_edd='2016-11-16',
        mom_id_no='7001015550000',
        mom_dob='1970-01-01',
        clinic_code='357751',
        authority='clinic',
        source_id=dummy_initial_data['control_source_id'],
        created_at=now,
        updated_at=now,
        mom_passport_origin=None,
        consent=True
    )


def test_migrator__clinic_registrations(migrator, dummy_clinic_registration):
    # Migrate registrations.
    migrator.migrate_registrations()

    # Check HCW Identities.
    results = migrator.seed_identity.execute(
        select([migrator.seed_identity.identity])
        .where(
            (migrator.seed_identity.identity.c.details[('addresses', 'msisdn', '+27825550000')] != null())
            & (migrator.seed_identity.identity.c.details['role'].astext == 'hcw')
        )
    )
    hcws = results.fetchall()
    assert len(hcws) == 1
    hcw_ident = hcws[0]
    assert hcw_ident['details'] == {
        "role": "hcw",
        "addresses": {"msisdn": {"+27825550000": {"default": True}}},
        "default_addr_type": "msisdn"
    }

    # Check mom Identities.
    results = migrator.seed_identity.execute(
        select([migrator.seed_identity.identity])
        .where(
            (migrator.seed_identity.identity.c.details[('addresses', 'msisdn', '+27825550100')] != null())
            & (migrator.seed_identity.identity.c.details['role'].astext == 'mom')
        )
    )
    moms = results.fetchall()
    assert len(moms) == 1
    mom_ident = moms[0]
    assert mom_ident['details'] == {
        "role": "mom",
        "source": "clinic",
        "consent": True,
        "mom_dob": '1970-01-01',
        "sa_id_no": '7001015550000',
        "addresses": {"msisdn": {"+27825550100": {"default": True}}},
        "lang_code": "eng_ZA",
        "last_mc_reg_on": "clinic",
        "default_addr_type": "msisdn"
    }

    # Check Hub Registration.
