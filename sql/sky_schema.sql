--
-- PostgreSQL database dump
--

SET client_encoding = 'UTF8';
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON SCHEMA public IS 'Standard public schema';


--
-- Name: plpgsql; Type: PROCEDURAL LANGUAGE; Schema: -; Owner: 
--

CREATE PROCEDURAL LANGUAGE plpgsql;


SET search_path = public, pg_catalog;

--
-- Name: completed_png(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION completed_png(integer) RETURNS void
    AS $_$
BEGIN
   UPDATE png SET timestamp_completed = CURRENT_TIMESTAMP WHERE id = $1;
   UPDATE png SET done = true WHERE id = $1;
   RETURN;
END;

$_$
    LANGUAGE plpgsql;


ALTER FUNCTION public.completed_png(integer) OWNER TO postgres;

--
-- Name: completed_sky(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION completed_sky(integer) RETURNS void
    AS $_$
BEGIN
   UPDATE sky SET timestamp_completed = CURRENT_TIMESTAMP WHERE id = $1;
   UPDATE sky SET done = true WHERE id = $1;
   RETURN;
END;

$_$
    LANGUAGE plpgsql;


ALTER FUNCTION public.completed_sky(integer) OWNER TO postgres;

--
-- Name: png_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE png_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE public.png_id_seq OWNER TO postgres;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: png; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE png (
    id integer DEFAULT nextval('png_id_seq'::regclass) NOT NULL,
    sky_id integer,
    processed text,
    done boolean DEFAULT false NOT NULL,
    timestamp_completed timestamp with time zone,
    timestamp_requested timestamp with time zone
);


ALTER TABLE public.png OWNER TO postgres;

--
-- Name: get_png_to_process(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION get_png_to_process() RETURNS png
    AS $$
DECLARE
   png_rec RECORD;
BEGIN

   -- This lock may not actually be necessary! (But it doesn't seem to hurt.)
   LOCK TABLE png; -- takes exclusive access, unlocked when the function returns

   SELECT * INTO png_rec FROM png WHERE
       in_progress_png(id) = false AND done = false LIMIT 1; 

   IF NOT FOUND THEN
       COMMIT WORK;
       RETURN NULL;
   END IF;

   UPDATE png SET timestamp_requested = CURRENT_TIMESTAMP WHERE id = png_rec.id;

   RETURN png_rec; -- if none found, could return NULL, but that's happening anyway

END;

$$
    LANGUAGE plpgsql;


ALTER FUNCTION public.get_png_to_process() OWNER TO postgres;

--
-- Name: get_sky_to_process(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION get_sky_to_process() RETURNS record
    AS $$
DECLARE
   sky_rec RECORD;
BEGIN

   -- This lock may not actually be necessary! (But it doesn't seem to hurt.)
   LOCK TABLE sky; -- takes exclusive access, unlocked when the function returns

   SELECT * INTO sky_rec FROM sky WHERE
       in_progress(id) = false AND done = false LIMIT 1; 

   IF NOT FOUND THEN
       COMMIT WORK;
       RETURN NULL;
   END IF;

   UPDATE sky SET timestamp_requested = CURRENT_TIMESTAMP WHERE id = sky_rec.id;

   RETURN sky_rec; -- if none found, could return NULL, but that's happening anyway

END;

$$
    LANGUAGE plpgsql;


ALTER FUNCTION public.get_sky_to_process() OWNER TO postgres;

--
-- Name: in_progress(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION in_progress(integer) RETURNS boolean
    AS $_$
    SELECT (timestamp_requested IS NOT NULL) AND (timestamp_completed IS NULL)
    FROM sky WHERE id = $1
$_$
    LANGUAGE sql STABLE;


ALTER FUNCTION public.in_progress(integer) OWNER TO postgres;

--
-- Name: in_progress_png(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION in_progress_png(integer) RETURNS boolean
    AS $_$
    SELECT (timestamp_requested IS NOT NULL) AND (timestamp_completed IS NULL)
    FROM png WHERE id = $1
$_$
    LANGUAGE sql STABLE;


ALTER FUNCTION public.in_progress_png(integer) OWNER TO postgres;

--
-- Name: png_rec; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE png_rec (
    id integer,
    sky_id integer,
    processed text,
    done boolean,
    timestamp_completed timestamp with time zone,
    timestamp_requested timestamp with time zone
);


ALTER TABLE public.png_rec OWNER TO postgres;

--
-- Name: sky_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE sky_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE public.sky_id_seq OWNER TO postgres;

--
-- Name: sky; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE sky (
    id integer DEFAULT nextval('sky_id_seq'::regclass) NOT NULL,
    ra numeric,
    "dec" numeric,
    size numeric,
    processed text,
    done boolean DEFAULT false NOT NULL,
    timestamp_completed timestamp with time zone,
    timestamp_requested timestamp with time zone
);


ALTER TABLE public.sky OWNER TO postgres;

--
-- Name: skyview; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW skyview AS
    SELECT sky.id, sky.ra, sky."dec", sky.size, sky.processed, sky.done, to_char(sky.timestamp_completed, 'YYYY-MM-DD HH24:MI:SS'::text) AS completed, to_char(sky.timestamp_requested, 'YYYY-MM-DD HH24:MI:SS'::text) AS requested, in_progress(sky.id) AS in_progress, to_char((sky.timestamp_completed - sky.timestamp_requested), 'HH24:MI:SS'::text) AS runtime FROM sky;


ALTER TABLE public.skyview OWNER TO postgres;

--
-- Name: png_pk; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY png
    ADD CONSTRAINT png_pk PRIMARY KEY (id);


--
-- Name: sky_pk; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY sky
    ADD CONSTRAINT sky_pk PRIMARY KEY (id);


--
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- PostgreSQL database dump complete
--

