create table if not exists party_guest (
	id serial primary key not null,
	name varchar(50) not null check(name <> ''),
	email varchar(50) not null unique,
	is_came boolean default false
	);

create user manager;
grant usage on schema public to manager;
grant select on table party_guest to manager;
grant insert on table party_guest to manager;
grant usage, select on all sequences in schema public TO manager;

create or replace view party_guest_name as (
	select name
	from party_guest
);

create user guard;
grant usage on schema public to manager;
grant select on table party_guest_name to guard;

insert into party_guest (name, email)
values ('Charles', 'charles_ny@yahoo.com'),
	('Charles', 'mix_tape_charles@google.com'),
	('Teona', 'miss_teona_99@yahoo.com');

create or replace procedure party_end()
	language plpgsql
	as $$
		begin
			create table if not exists black_list (
				id serial,
				email varchar(50)
			);
			insert into black_list (email)
			select email from party_guest
			where is_came is false;
			delete from party_guest;
		end;
	$$;

create or replace function register_to_party(_name varchar, _email varchar)
	returns boolean
	language plpgsql
	as $$
		declare
		result_row record;
		begin
			if (select to_regclass('public.black_list') is not null) is true 
			then
				for result_row in (select distinct email from black_list)
				loop
					if result_row.email = _email then
						return false;
					else 
						insert into party_guest (name, email)
						values (_name, _email);
						return true;
					end if;
				end loop;
			else
				insert into party_guest (name, email)
				values (_name, _email);
				return true;
			end if;
		end;
	$$;

Select register_to_party('Petr', 'korol_party@yandex.ru');

update party_guest
set is_came = true
where email = 'mix_tape_charles@google.com' or email = 'miss_teona_99@yahoo.com';

call party_end();


set role postgres;
set role manager;
set role guard;
select * from party_guest;
select * from party_guest_name;
select * from black_list;
