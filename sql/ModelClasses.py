#!/usr/bin/python

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

class galaxy(Base):
	__tablename__ = 'galaxy'
	__table_args__ = {'autoload' : True}

# =========================
# Define relationships here
# =========================




