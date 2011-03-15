CREATE SEQUENCE atlas_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;

CREATE TABLE atlas (
    atlas_pk integer DEFAULT nextval('atlas_id_seq'::regclass) NOT NULL,
    nsaid int NOT NULL,
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

ALTER TABLE ONLY atlas
ADD PRIMARY KEY (atlas_pk);

CREATE SEQUENCE measure_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;

CREATE TABLE measure (
    measure_pk integer DEFAULT nextval('measure_id_seq'::regclass) NOT NULL,
    nsaid int NOT NULL,
    racen float NOT NULL,
    deccen float NOT NULL,
    xcen real NOT NULL,
    ycen real NOT NULL,
		petroflux real[5] NOT NULL,
		petroflux_ivar real[5] NOT NULL,
		fiberflux real[5] NOT NULL,
		fiberflux_ivar real[5] NOT NULL,
		petrorad real NOT NULL, 
		petror50 real NOT NULL, 
		petror90 real NOT NULL, 
		ba50 real NOT NULL, 
		phi50 real NOT NULL, 
		ba90 real NOT NULL, 
		phi90 real NOT NULL, 
		sersicflux real[5] NOT NULL,
		sersic_r50 real NOT NULL,
		sersic_n real NOT NULL, 
		sersic_ba real NOT NULL, 
		sersic_phi real NOT NULL, 
		asymmetry real[5] NOT NULL, 
		clumpy real[5] NOT NULL, 
		dflags int[5] NOT NULL, 
		aid int NOT NULL
);

ALTER TABLE ONLY measure
ADD PRIMARY KEY (measure_pk);
		
