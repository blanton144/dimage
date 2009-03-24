# resetting PNG list
delete from png;
insert into png (sky_id) select id as sky_id from sky;


# to create a dump file
pg_dump -h hercules -U postgres sky -s > sky_schema.sql
