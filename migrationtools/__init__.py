import os.path
import ConfigParser

import click

from . import migrations


APP_NAME = "MomConnect Migration Tools"


class Config(object):
    default_file = os.path.join(click.get_app_dir(APP_NAME, force_posix=True),
                                'config.ini')

    def __init__(self, override_file=None):
        if override_file is not None:
            self.config_file = override_file
        else:
            self.config_file = self.default_file

        self.load()

    def load(self):
        parser = ConfigParser.RawConfigParser()
        if not os.path.exists(self.config_file):
            return

        parser.read([self.config_file])
        for section in parser.sections():
            options = {}
            for option in parser.options(section):
                options[option] = parser.get(section, option)
            if options:
                object.__setattr__(self, section.upper(), options)


class Context(object):
    def __init__(self, config_file, debug=False):
        self.config = Config(config_file)
        self.debug = debug
        self._migrator = None
        self.migrator_options = {}

    @property
    def migrator(self):
        if self._migrator is None:
            self._migrator = migrations.Migrator(self.config, echo=click.echo, debug=self.debug)
        return self._migrator

pass_context = click.make_pass_decorator(Context)


@click.group()
@click.option('--config', 'config_file', default=None,
              type=click.Path(exists=True, dir_okay=False),
              help="Config file to use instead of the default.")
@click.option('--debug', default=False, type=click.BOOL,
              help="Output debugging info to the console.")
@click.pass_context
def cli(ctx, config_file, debug):
    click.echo("MomConnect Migration tool")
    ctx.obj = Context(config_file, debug=debug)


@cli.group(short_help="Migrate old records to Seed.")
@click.option('--limit', default=None, type=click.INT,
              help="The total number of records to limit each migration to")
@pass_context
def migrate(ctx, limit):
    """This command goes through existing records in the ndoh-control
    database and migrates them to the Seed services.
    """
    ctx.migrator_options['limit'] = limit


@migrate.command(short_help="Migrate registration records to Seed.")
@click.argument('start', type=click.INT, default=None, required=False)
@click.argument('stop', type=click.INT, default=None, required=False)
@pass_context
def registrations(ctx, start, stop):
    """This command goes through existing registration records in the
    ndoh-control database and migrates them to the Seed services.

    You can provide two optional arguments:

    \b
    START - the registration ID to start the migration from (inclusive).
    STOP - the registration ID to stop the migration at (inclusive).
    """
    ctx.migrator.migrate_registrations(start=start, stop=stop, limit=ctx.migrator_options['limit'])
