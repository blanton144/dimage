CREATE SEQUENCE ned_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;

CREATE TABLE ned (
    id integer DEFAULT nextval('ned_id_seq'::regclass) NOT NULL,
    ra float NOT NULL,
    "dec" float NOT NULL,
		name1 varchar(100) NOT NULL,
		name2 varchar(100) NOT NULL,
		radecstr varchar(100) NOT NULL,
		vel float NOT NULL,
		ref int NOT NULL,
		morph varchar(100) NOT NULL,
		mag float NOT NULL,
		major float NOT NULL,
		minor float NOT NULL,
		vel_unc int NOT NULL,
		pht int NOT NULL
);

ALTER TABLE ONLY ned
ADD CONSTRAINT ned_pk PRIMARY KEY (id);
