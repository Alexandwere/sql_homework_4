create table if not exists party_guest (
	id serial primary key not null,
	name varchar(50) not null check(name <> ''),
	email varchar(50) not null unique,
	is_came boolean default false,
	);

create user manager;
grant usage on schema public to manager;
grant select on table party_guest to manager;
grant create on table party_guest to manager;

create or replace view party_guest_name as (
	select name
	from party_guest
);

create user guard;
grant usage on schema public to manager;
grant select on view party_guest_name to guard;

