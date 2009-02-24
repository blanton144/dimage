CREATE OR REPLACE VIEW skyview AS
   SELECT id, ra, dec, size, processed, done,
   to_char(timestamp_completed, 'YYYY-MM-DD HH24:MI:SS') AS completed,
   to_char(timestamp_requested, 'YYYY-MM-DD HH24:MI:SS') AS requested,
   in_progress(id) as in_progress,
   to_char(timestamp_completed - timestamp_requested, 'HH24:MI:SS') AS runtime
   FROM sky;

---

CREATE OR REPLACE FUNCTION get_sky_to_process() RETURNS record
   AS $_$
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

$_$ LANGUAGE 'plpgsql' VOLATILE;

---

CREATE OR REPLACE FUNCTION completed_sky(integer) RETURNS void
   AS $_$
BEGIN
   UPDATE sky SET timestamp_completed = CURRENT_TIMESTAMP WHERE id = $1;
   UPDATE sky SET done = true WHERE id = $1;
   RETURN;
END;

$_$ LANGUAGE 'plpgsql' VOLATILE;
