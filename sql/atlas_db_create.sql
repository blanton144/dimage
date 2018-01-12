CREATE SCHEMA nsatlas; 

CREATE SEQUENCE nsatlas.sdss_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;

CREATE TABLE nsatlas.sdss (
    sdss_pk integer DEFAULT nextval('nsatlas.sdss_id_seq'::regclass) NOT NULL,
		isdss int NOT NULL,
		run int NOT NULL,
		camcol int NOT NULL,
		field int NOT NULL,
		id int NOT NULL,
		objc_type int NOT NULL,
		objc_prob_psf real NOT NULL,
		objc_flags int NOT NULL,
		objc_flags2 int NOT NULL,
		objc_rowc real NOT NULL,
		objc_colc real NOT NULL,
		objc_rowcerr real NOT NULL,
		objc_colcerr real NOT NULL,
		petrotheta real[5] NOT NULL,
		petrothetaerr real[5] NOT NULL,
		petroth50 real[5] NOT NULL,
		petroth50err real[5] NOT NULL,
		petroth90 real[5] NOT NULL,
		petroth90err real[5] NOT NULL,
		fracdev real[5] NOT NULL,
		psp_status int[5] NOT NULL,
		ra float NOT NULL,
		dec float NOT NULL,
		psf_fwhm float[5] NOT NULL,
		extinction float[5] NOT NULL,
		psfflux float[5] NOT NULL,
		psfflux_ivar float[5] NOT NULL,
		fiberflux float[5] NOT NULL,
		fiberflux_ivar float[5] NOT NULL,
		modelflux float[5] NOT NULL,
		modelflux_ivar float[5] NOT NULL,
		cmodelflux float[5] NOT NULL,
		cmodelflux_ivar float[5] NOT NULL,
		petroflux float[5] NOT NULL,
		petroflux_ivar float[5] NOT NULL,
		cloudcam int[5] NOT NULL,
		calib_status int[5] NOT NULL,
		resolve_status int NOT NULL,
		thing_id int NOT NULL,
		ifield int NOT NULL,
		balkan_id int NOT NULL,
		score real NOT NULL,
		survey varchar(100) NOT NULL,
		chunk varchar(100) NOT NULL,
		programname varchar(100) NOT NULL,
		platerun varchar(100) NOT NULL,
		platequality varchar(100) NOT NULL,
		platesn2 real NOT NULL,
		specprimary int NOT NULL,
		speclegacy int NOT NULL,
		run2d varchar(30) NOT NULL,
		run1d varchar(30) NOT NULL,
		plate int NOT NULL, 
		fiberid int NOT NULL, 
		mjd int NOT NULL, 
		tile int NOT NULL, 
		plug_ra float NOT NULL, 
		plug_dec float NOT NULL, 
		class varchar(100) NOT NULL,
		subclass varchar(100) NOT NULL,
		z real NOT NULL, 
		z_err real NOT NULL, 
		vdisp real NOT NULL, 
		vdisp_err real NOT NULL, 
		zwarning int NOT NULL, 
		sn_median real NOT NULL
);

ALTER TABLE ONLY nsatlas.sdss
ADD PRIMARY KEY (sdss_pk);

ALTER TABLE ONLY nsatlas.sdss
ADD CONSTRAINT uniq_sdss_isdss UNIQUE(isdss);

CREATE SEQUENCE nsatlas.zcat_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;

CREATE TABLE nsatlas.zcat (
    zcat_pk integer DEFAULT nextval('nsatlas.zcat_id_seq'::regclass) NOT NULL,
		izcat int NOT NULL,
		name varchar(100) NOT NULL, 
		ra float NOT NULL,
		dec float NOT NULL,
		bmag real NOT NULL,
		z real NOT NULL,
		z_err real NOT NULL,
		bsource varchar(10) NOT NULL,
		vsource int NOT NULL, 
		more int NOT NULL, 
		ttype int NOT NULL, 
		bartype varchar(10) NOT NULL,
		lumclass int NOT NULL, 
		struct varchar(10) NOT NULL,
		d1min real NOT NULL,
		d2min real NOT NULL,
		btmag real NOT NULL,
		dist real NOT NULL,
		rfn varchar(10) NOT NULL,
		flag varchar(10) NOT NULL,
		comments varchar(100) NOT NULL,
		index varchar(50) NOT NULL
);

ALTER TABLE ONLY nsatlas.zcat
ADD PRIMARY KEY (zcat_pk);

ALTER TABLE ONLY nsatlas.zcat
ADD CONSTRAINT uniq_zcat_izcat UNIQUE(izcat);

CREATE SEQUENCE nsatlas.sixdf_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;

CREATE TABLE nsatlas.sixdf (
    sixdf_pk integer DEFAULT nextval('nsatlas.sixdf_id_seq'::regclass) NOT NULL,
		isixdf int NOT NULL,
		targetid varchar(30) NOT NULL,
		ra float NOT NULL, 
		dec float NOT NULL, 
		nmeas int NOT NULL,
		nquality int NOT NULL,
		bj real NOT NULL,
		progid int NOT NULL,
		rf real NOT NULL,
		sgclass int NOT NULL,
		comparison int NOT NULL,
		cz real NOT NULL,
		czerr real NOT NULL,
		czsrc int NOT NULL,
		quality int NOT NULL
);

ALTER TABLE ONLY nsatlas.sixdf
ADD PRIMARY KEY (sixdf_pk);

ALTER TABLE ONLY nsatlas.sixdf
ADD CONSTRAINT uniq_sixdf_isixdf UNIQUE(isixdf);

CREATE SEQUENCE nsatlas.ned_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;

CREATE TABLE nsatlas.ned (
    ned_pk integer DEFAULT nextval('nsatlas.ned_id_seq'::regclass) NOT NULL,
		ined int NOT NULL,
		type varchar(5) NOT NULL, 
		name1 varchar(30) NOT NULL,
		name2 varchar(30) NOT NULL,
		ra float NOT NULL,
		dec float NOT NULL,
		radecstr varchar(50) NOT NULL,
		vel real NOT NULL, 
		ref int NOT NULL, 
		morph varchar(50) NOT NULL, 
		mag real NOT NULL, 
		major real NOT NULL, 
		minor real NOT NULL, 
		vel_unc int NOT NULL, 
		pht int NOT NULL
);

ALTER TABLE ONLY nsatlas.ned
ADD PRIMARY KEY (ned_pk);

ALTER TABLE ONLY nsatlas.ned
ADD CONSTRAINT uniq_ned_ined UNIQUE(ined);

CREATE SEQUENCE nsatlas.alfalfa_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;

CREATE TABLE nsatlas.alfalfa (
    alfalfa_pk integer DEFAULT nextval('nsatlas.alfalfa_id_seq'::regclass) NOT NULL,
		ialfalfa int NOT NULL,
		agc int NOT NULL,
		catnum varchar(10) NOT NULL,
		other varchar(10) NOT NULL,
		ra float NOT NULL,
		dec float NOT NULL,
		ora float NOT NULL,
		odec float NOT NULL,
		cz real NOT NULL,
		e_cz real NOT NULL,
		w50 real NOT NULL,
		e_w50 real NOT NULL,
		fc real NOT NULL,
		e_fc real NOT NULL,
		sn real NOT NULL,
		rms real NOT NULL,
		code int NOT NULL,
		dis real NOT NULL,
		logm real NOT NULL,
		grid varchar(20) NOT NULL
);

ALTER TABLE ONLY nsatlas.alfalfa
ADD PRIMARY KEY (alfalfa_pk);

ALTER TABLE ONLY nsatlas.alfalfa
ADD CONSTRAINT uniq_alfalfa_ialfalfa UNIQUE(ialfalfa);

CREATE SEQUENCE nsatlas.twodf_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;

CREATE TABLE nsatlas.twodf (
    twodf_pk integer DEFAULT nextval('nsatlas.twodf_id_seq'::regclass) NOT NULL,
		itwodf int NOT NULL,
		serial int NOT NULL,
		spectra int NOT NULL,
		name varchar(30) NOT NULL,
		ukst varchar(10) NOT NULL,
		rahr varchar(10) NOT NULL,
		ramin varchar(10) NOT NULL,
		rasec varchar(10) NOT NULL,
		decdeg varchar(10) NOT NULL,
		decmin varchar(10) NOT NULL,
		decsrc varchar(10) NOT NULL,
		ra2000hr varchar(10) NOT NULL,
		ra2000min varchar(10) NOT NULL,
		ra2000sec varchar(10) NOT NULL,
		dec2000deg varchar(10) NOT NULL,
		dec2000min varchar(10) NOT NULL,
		dec2000src varchar(10) NOT NULL,
		bjg real NOT NULL,
		bjsel real NOT NULL,
		bjg_old real NOT NULL,
		bjselold real NOT NULL,
		galext real NOT NULL,
		sb_bj real NOT NULL,
		sr_r real NOT NULL,
		z real NOT NULL,
		z_helio real NOT NULL,
		obsrun varchar(10) NOT NULL,
		quality int NOT NULL,
		abemma int NOT NULL,
		z_abs real NOT NULL,
		kbestr int NOT NULL,
		r_crcor real NOT NULL,
		z_emi real NOT NULL,
		nmbest int NOT NULL,
		snr real NOT NULL,
		eta_type real NOT NULL,
		ra float NOT NULL,
		dec float NOT NULL
);

ALTER TABLE ONLY nsatlas.twodf
ADD PRIMARY KEY (twodf_pk);

ALTER TABLE ONLY nsatlas.twodf
ADD CONSTRAINT uniq_twodf_itwodf UNIQUE(itwodf);

CREATE SEQUENCE nsatlas.atlas_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;

CREATE TABLE nsatlas.atlas (
    atlas_pk integer DEFAULT nextval('nsatlas.atlas_id_seq'::regclass) NOT NULL,
		iauname  varchar(20)  NOT NULL,   
		subdir  varchar(20)  NOT NULL,   
		ra  float  NOT NULL,   
		dec  float  NOT NULL,  
		isdss  int  NOT NULL,  
		ined  int  NOT NULL,   
		isixdf  int  NOT NULL, 
		ialfalfa  int  NOT NULL,   
		izcat  int  NOT NULL,   
		itwodf  int  NOT NULL,   
		mag  real  NOT NULL,   
		z  real  NOT NULL,   
		zsrc  varchar(20)  NOT NULL,   
		size  real  NOT NULL,   
		run  smallint  NOT NULL,   
		camcol  bool  NOT NULL,   
		field  smallint  NOT NULL,   
		rerun  varchar(20)  NOT NULL,   
		xpos  real  NOT NULL,   
		ypos  real  NOT NULL,   
		nsaid  int  NOT NULL,   
		zdist  real  NOT NULL,   
		sersic_nmgy  real[7]  NOT NULL,   
    sersic_nmgy_ivar  real[7]  NOT NULL,   
    sersic_ok  smallint  NOT NULL,   
    sersic_rnmgy  real[7]  NOT NULL,   
    sersic_absmag  real[7]  NOT NULL,   
    sersic_amivar  real[7]  NOT NULL,   
    extinction  real[7]  NOT NULL,   
    sersic_kcorrect  real[7]  NOT NULL,   
    sersic_kcoeff real[5]  NOT NULL,   
    sersic_mtol  real[7]  NOT NULL,   
    sersic_b300  real  NOT NULL,   
    sersic_b1000  real  NOT NULL,   
    sersic_mets  real  NOT NULL,   
    sersic_mass  real  NOT NULL,   
    xcen  float  NOT NULL,   
    ycen  float  NOT NULL,   
    petro_flux  real[7]  NOT NULL,   
    petro_flux_ivar  real[7]  NOT NULL,   
    fiber_flux  real[7]  NOT NULL,   
    fiber_flux_ivar  real[7]  NOT NULL,   
    petro_ba50  real  NOT NULL,   
    petro_phi50  real  NOT NULL,   
    petro_ba90  real  NOT NULL,   
    petro_phi90  real  NOT NULL,   
    sersic_flux  real[7]  NOT NULL,   
    sersic_flux_ivar  real[7]  NOT NULL,   
    sersic_n  real  NOT NULL,   
    sersic_ba  real  NOT NULL,   
    sersic_phi  real  NOT NULL,   
    asymmetry  real[7]  NOT NULL,   
    clumpy  real[7]  NOT NULL,   
    dflags  int  NOT NULL,   
    aid  int  NOT NULL,   
    pid  int  NOT NULL,   
    dversion  varchar(20)  NOT NULL,   
    proftheta  real  NOT NULL,   
    petro_theta  real  NOT NULL,   
    petro_th50  real  NOT NULL,   
    petro_th90  real  NOT NULL,   
    sersic_th50  real  NOT NULL,   
    plate  int  NOT NULL,   
    fiberid  smallint  NOT NULL,   
    mjd  int  NOT NULL,   
    racat  float  NOT NULL,   
    deccat  float  NOT NULL,   
    zsdssline  real  NOT NULL,   
    survey  varchar(20)  NOT NULL,   
    programname  varchar(20)  NOT NULL,   
    platequality  varchar(20)  NOT NULL,   
    tile  int  NOT NULL,   
    plug_ra  float  NOT NULL,   
    plug_dec  float  NOT NULL,   
    elpetro_ba  real  NOT NULL,   
    elpetro_phi  real  NOT NULL,   
    elpetro_flux_r  real  NOT NULL,   
    elpetro_flux_ivar_r  real  NOT NULL,   
    elpetro_theta_r  real  NOT NULL,   
    elpetro_th50_r  real  NOT NULL,   
    elpetro_th90_r  real  NOT NULL,   
    elpetro_theta  real  NOT NULL,   
    elpetro_flux  real  NOT NULL,   
    elpetro_flux_ivar  real[7]  NOT NULL,   
    elpetro_th50  real[7]  NOT NULL,   
    elpetro_th90  real[7]  NOT NULL,   
    elpetro_apcorr_r  real  NOT NULL,   
    elpetro_apcorr  real[7]  NOT NULL,   
    elpetro_apcorr_self  real[7]  NOT NULL,   
    elpetro_nmgy  real[7]  NOT NULL,   
    elpetro_nmgy_ivar  real[7]  NOT NULL,   
    elpetro_ok  smallint  NOT NULL,   
    elpetro_rnmgy  real[7]  NOT NULL,   
    elpetro_absmag  real[7]  NOT NULL,   
    elpetro_amivar  real[7]  NOT NULL,   
    elpetro_kcorrect  real[7]  NOT NULL,   
    elpetro_kcoeff  real[5]  NOT NULL,   
    elpetro_mass  real  NOT NULL,   
    elpetro_mtol  real[7]  NOT NULL,   
    elpetro_b300  real  NOT NULL,   
    elpetro_b1000  real  NOT NULL,   
    elpetro_mets  real  NOT NULL,   
    in_dr7_lss  bool  NOT NULL   
);

ALTER TABLE ONLY nsatlas.atlas
ADD PRIMARY KEY (atlas_pk);

ALTER TABLE ONLY nsatlas.atlas
ADD CONSTRAINT uniq_atlas_nsaid UNIQUE(nsaid);

ALTER TABLE ONLY nsatlas.atlas
ADD CONSTRAINT uniq_atlas_isdss UNIQUE(isdss);

ALTER TABLE ONLY nsatlas.atlas
ADD CONSTRAINT uniq_atlas_ined UNIQUE(ined);

ALTER TABLE ONLY nsatlas.atlas
ADD CONSTRAINT uniq_atlas_isixdf UNIQUE(isixdf);

ALTER TABLE ONLY nsatlas.atlas
ADD CONSTRAINT uniq_atlas_itwodf UNIQUE(itwodf);

ALTER TABLE ONLY nsatlas.atlas
ADD CONSTRAINT uniq_atlas_ialfalfa UNIQUE(ialfalfa);

ALTER TABLE ONLY nsatlas.atlas
ADD CONSTRAINT uniq_atlas_izcat UNIQUE(izcat);

ALTER TABLE ONLY nsatlas.atlas
ADD CONSTRAINT atlas_itwodf_fk FOREIGN KEY (itwodf) REFERENCES nsatlas.twodf (itwodf);

ALTER TABLE ONLY nsatlas.atlas
ADD CONSTRAINT atlas_isdss_fk FOREIGN KEY (isdss) REFERENCES nsatlas.sdss (isdss);

ALTER TABLE ONLY nsatlas.atlas
ADD CONSTRAINT atlas_izcat_fk FOREIGN KEY (izcat) REFERENCES nsatlas.zcat (izcat);

ALTER TABLE ONLY nsatlas.atlas
ADD CONSTRAINT atlas_isixdf_fk FOREIGN KEY (isixdf) REFERENCES nsatlas.sixdf (isixdf);

ALTER TABLE ONLY nsatlas.atlas
ADD CONSTRAINT atlas_ined_fk FOREIGN KEY (ined) REFERENCES nsatlas.ned (ined);

ALTER TABLE ONLY nsatlas.atlas
ADD CONSTRAINT atlas_ialfalfa_fk FOREIGN KEY (ialfalfa) REFERENCES nsatlas.alfalfa (ialfalfa);


CREATE SEQUENCE nsatlas.comment_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;

CREATE TABLE nsatlas.comment (
    comment_pk integer DEFAULT nextval('nsatlas.comment_id_seq'::regclass) NOT NULL,
		nsaid int NOT NULL,
		nsauser text NOT NULL,
		comment text, 
		time timestamp with time zone NOT NULL
);

ALTER TABLE ONLY nsatlas.comment
ADD PRIMARY KEY (comment_pk);

CREATE PROCEDURAL LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION nsatlas.add_comment(integer, text, text) RETURNS boolean
    AS $$
DECLARE 
		 current RECORD;
BEGIN
   LOCK TABLE nsatlas.comment; 

   SELECT * INTO current FROM nsatlas.comment WHERE
	   nsaid = $1 and nsauser = $2;

   IF NOT FOUND THEN
  	   INSERT INTO nsatlas.comment (nsaid, nsauser, comment, time) 
				VALUES ($1, $2, $3, CURRENT_TIMESTAMP);
       RETURN TRUE;
   END IF;

	UPDATE nsatlas.comment SET time = CURRENT_TIMESTAMP, 
								 nsaid = $1,
								 nsauser = $2,
								 comment = $3
												 WHERE nsaid = $1 and nsauser = $2;

   RETURN TRUE; 
END;
$$ LANGUAGE plpgsql;


CREATE USER webuser WITH PASSWORD 'daedalus';
GRANT SELECT ON nsatlas.atlas, nsatlas.ned, nsatlas.sdss, nsatlas.sixdf, nsatlas.twodf, nsatlas.zcat, nsatlas.alfalfa, nsatlas.comment TO webuser;

CREATE USER loginuser WITH PASSWORD 'icarus';
GRANT SELECT ON nsatlas.atlas, nsatlas.ned, nsatlas.sdss, nsatlas.sixdf, nsatlas.twodf, nsatlas.zcat, nsatlas.alfalfa, nsatlas.comment TO loginuser;
GRANT ALL ON nsatlas.comment TO loginuser;
GRANT ALL ON nsatlas.comment_id_seq TO loginuser;
