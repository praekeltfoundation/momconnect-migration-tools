import os.path
import subprocess32 as subprocess

import click
import pytest
from sqlalchemy.engine.url import make_url
from sqlalchemy_utils import database_exists, create_database, drop_database

from migrationtools import migrations


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
    yield migrations.Migrator(config, echo=click.echo)
    # Drop the test DBs on teardown.
    for db_url in config.DATABASES.values():
        if database_exists(db_url):
            drop_database(db_url)


def test_migrator(migrator):
    assert 1 == 0
# populat test ndoh-control DB with test data

# connection fixtures for all DBS
