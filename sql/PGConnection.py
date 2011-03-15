#!/usr/bin/python

import sqlalchemy
from sqlalchemy.orm import sessionmaker, scoped_session
from DatabaseConnection import DatabaseConnection

# Fill in database connection information here.
pg_db = {
	'user'	: 'postgres', 
	'password'	: '', 
	'database'	: 'atlas', 
	'host'	: 'hercules', 
	'port'	: 5432
}

# For more options of SQLite connection strings, see:
# http://www.sqlalchemy.org/docs/reference/dialects/sqlite.html#connect-strings

db_connection_string = 'postgresql://%s%s@%s:%s/%s' % \
											 (pg_db["user"], pg_db["password"], \
												pg_db["host"], pg_db["port"], \
												pg_db["database"])

# This allows the file to be 'import'ed any number of times, but attempts to
# connect to the database only once.
try:
	db = DatabaseConnection() # fails if connection not yet made.
except:
	db = DatabaseConnection(database_connection_string=db_connection_string)

engine = db.engine
metadata = db.metadata
#Session = sessionmaker(bind=engine, autocommit=True, autoflush=False)
Session = scoped_session(sessionmaker(bind=engine, autocommit=True, autoflush=False))

