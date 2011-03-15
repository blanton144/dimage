#!/usr/local/python-2.7/bin/python
#

import os
import sqlalchemy
from sqlalchemy import create_engine, MetaData
from sqlalchemy.orm import sessionmaker, scoped_session

class DatabaseConnection(object):
	'''This class defines an object that makes a connection to a database.
	   The "DatabaseConnection" object takes as its parameter the SQLAlchemy
	   database connection string.

	   This class is best called from another class that contains the
	   actual connection information (so that it can be reused for different
	   connections).
	   
	   This class implements the singleton design pattern. The first time the
	   object is created, it *requires* a valid database connection string.
	   Every time it is called via:
	   
	   db = DatabaseConnection()
	   
	   the same object is returned and contains the connection information.
	'''
	_singletons = dict()
	
	def __new__(cls, database_connection_string=None):
		"""This overrides the object's usual creation mechanism."""

		if not cls._singletons.has_key(cls):
			assert database_connection_string is not None, "A database connection string must be specified!"
			cls._singletons[cls] = object.__new__(cls)
			
			# ------------------------------------------------
			# This is the custom initialization
			# ------------------------------------------------
			me = cls._singletons[cls] # just for convenience
			
			me.database_connection_string = database_connection_string
			
			# change 'echo' to print each SQL query (for debugging/optimizing/the curious)
			me.engine = create_engine(me.database_connection_string, echo=False)	

			me.metadata = MetaData()
			me.metadata.bind = me.engine
			# ------------------------------------------------
		
		return cls._singletons[cls]


'''
Reference: http://www.sqlalchemy.org/docs/05/reference/orm/sessions.html#sqlalchemy.orm.sessionmaker

autocommit = True : this prevents postgres from deadlocking on long-lived session processes (e.g. a background daemon), that produces 'idle in transaction' processes in PostgreSQL.
autoflush = False: prevents flushing (i.e. commiting) objects when only performing a SELECT statement, i.e. when not modifying the db

Sample code to account for different cases (if things change for whatever reason):

if session.autocommit:
	session.begin()
<do stuff>
session.commit()

Try to minimise the work done in between session.begin() and session.commit().
'''
