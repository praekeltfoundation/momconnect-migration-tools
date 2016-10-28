import os
from setuptools import setup, find_packages


def read(*paths):
    """Build a file path from *paths* and return the contents."""
    with open(os.path.join(*paths), 'r') as f:
        return f.read()

setup(
    name="momconnect-migration-tools",
    version="0.1",
    description="Tools for migrating MomConnect system data",
    long_description=read('README.md'),
    author="Praekelt.org",
    author_email="dev@praekelt.org",
    license="BSD",
    packages=find_packages(exclude=["tests*"]),
    include_package_data=True,
    zip_safe=False,
    install_requires=[
        "Click",
        "SQLAlchemy",
        "crontab",
        "Django",
        "psycopg2"
    ],
    entry_points='''
        [console_scripts]
        migration-tool=migrationtools:cli
    ''',
    classifiers=[
        "Development Status :: 3 - Alpha",
        "Intended Audience :: Developers",
        "License :: OSI Approved :: BSD License",
        "Natural Language :: English",
        "Operating System :: OS Independent",
        "Programming Language :: Python :: 2.7",
    ],
)
