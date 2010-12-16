CREATE SEQUENCE galaxy_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;

CREATE TABLE galaxy (
    id integer DEFAULT nextval('galaxy_id_seq'::regclass) NOT NULL,
    ra float NOT NULL,
    "dec" float NOT NULL,
		isdss int NOT NULL,
		ined int NOT NULL,
		isixdf int NOT NULL,
		ialfalfa int NOT NULL,
		izcat int NOT NULL,
		mag real NOT NULL,
		z real NOT NULL,
		zsrc varchar(100) NOT NULL,
		size real NOT NULL,
		run int NOT NULL,
		camcol int NOT NULL,
		field int NOT NULL,
		rerun varchar(5) NOT NULL,
		xpos real NOT NULL,
		ypos real NOT NULL,
		zlg real NOT NULL,
		zdist real NOT NULL,
		zdist_err real NOT NULL
);

ALTER TABLE ONLY galaxy
ADD CONSTRAINT galaxy_pk PRIMARY KEY (id);
