begin;

create table party (
  id integer primary key auto_increment,
  name varchar(200) not null
);

create table constituency (
  id integer primary key auto_increment,
  name varchar(200) not null,
  list_name varchar(200) not null
);

create table candidate (
  id integer primary key auto_increment,
  name varchar(200) not null,
  twitter varchar(200),
  party_id integer not null,
  constituency_id integer,
  current_mp integer not null default 0,
  foreign key (party_id) references party(id),
  foreign key (constituency_id) references constituency(id)
);

commit;
