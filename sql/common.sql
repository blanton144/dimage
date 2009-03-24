# resetting PNG list
delete from png;
insert into png (sky_id) select id as sky_id from sky;

# setting all png as not started
update png set timestamp_requested = NULL;
update png set timestamp_completed = NULL;
update png set done = false;

# setting png that aren't done as not started
update png set timestamp_requested = NULL where not done;

# to create a dump file
pg_dump -h hercules -U postgres sky -s >! $DIMAGE_DIR/sql/sky_schema.sql
