begin;

create table party (
  id integer primary key auto_increment,
  yournextmp_id integer not null unique,
  name varchar(200) not null
);

create table constituency (
  id integer primary key auto_increment,
  mapit_id integer not null default 0 unique,
  name varchar(200) not null,
  list_name varchar(200) not null,
  list_id varchar(20),
  candidates_updated_time datetime not null default '2000-01-01 00:00:00',
  list_rebuilt_time datetime not null default '2000-01-01 00:00:00'
);

create table candidate (
  id integer primary key auto_increment,
  yournextmp_id integer not null unique,
  name varchar(200) not null,
  twitter varchar(200),
  party_id integer not null,
  constituency_id integer,
  current_mp integer not null default 0,
  foreign key (party_id) references party(id),
  foreign key (constituency_id) references constituency(id)
);

commit;
