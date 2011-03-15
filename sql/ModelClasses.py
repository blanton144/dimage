#!/usr/local/python-2.7/bin/python

from DatabaseConnection import DatabaseConnection

import sqlalchemy
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import mapper, relation, exc, column_property, validates
from sqlalchemy import orm
from sqlalchemy.orm.session import Session

dbc = DatabaseConnection()

# ========================
# Define database classes
# ========================
Base = declarative_base(bind=dbc.engine)

class atlas(Base):
	__tablename__ = 'atlas'
	__table_args__ = {'autoload' : True}

class measure(Base):
	__tablename__ = 'measure'
	__table_args__ = {'autoload' : True}

# =========================
# Define relationships here
# =========================




