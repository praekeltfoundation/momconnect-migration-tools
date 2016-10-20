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


@cli.command(short_help="Migrate old records to Seed.")
@click.argument('start_id', required=False)
@click.argument('end_id', required=False)
@click.option('--limit', default=None, type=click.INT,
              help="The total number of records to limit this migration to.")
@pass_context
def migrate(ctx, limit, start_id, end_id):
    """This command goes through existing subscription records in the
    ndoh-control database and migrates them to the Seed services. It takes two
    optional arguments START_ID and END_ID which are integer IDs in the
    subscriptions table of the ndoh-control database to start the migration
    from.
    """
    migrator = migrations.Migrator(ctx.config, debug=ctx.debug)
    migrator.migrate_subscriptions(start_id, end_id, limit)
