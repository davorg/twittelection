--
-- Created by SQL::Translator::Producer::SQLite
-- Created on Sat Apr 20 15:26:29 2024
--

BEGIN TRANSACTION;

--
-- Table: "candidate"
--
CREATE TABLE "candidate" (
  "id" INTEGER PRIMARY KEY NOT NULL,
  "yournextmp_id" int(11) NOT NULL,
  "name" varchar(200) NOT NULL,
  "twitter" varchar(200) DEFAULT NULL,
  "party_id" int(11) NOT NULL,
  "constituency_id" int(11) DEFAULT NULL,
  "current_mp" int(11) NOT NULL DEFAULT 0,
  "twitter_problem" smallint(6) NOT NULL DEFAULT 0,
  FOREIGN KEY ("party_id") REFERENCES "party"("id"),
  FOREIGN KEY ("constituency_id") REFERENCES "constituency"("id")
);

CREATE INDEX "party_id" ON "candidate" ("party_id");

CREATE INDEX "constituency_id" ON "candidate" ("constituency_id");

CREATE UNIQUE INDEX "yournextmp_id" ON "candidate" ("yournextmp_id");

--
-- Table: "constituency"
--
CREATE TABLE "constituency" (
  "id" INTEGER PRIMARY KEY NOT NULL,
  "mapit_id" int(11) NOT NULL DEFAULT 0,
  "demclub_id" varchar(20) DEFAULT NULL,
  "name" varchar(200) NOT NULL,
  "list_name" varchar(25) NOT NULL,
  "list_id" varchar(20) DEFAULT NULL,
  "candidates_updated_time" datetime NOT NULL DEFAULT '2000-01-01 00:00:00',
  "list_rebuilt_time" datetime NOT NULL DEFAULT '2000-01-01 00:00:00',
  "list_checked_time" datetime DEFAULT NULL
);

CREATE UNIQUE INDEX "mapit_id" ON "constituency" ("mapit_id");

--
-- Table: "party"
--
CREATE TABLE "party" (
  "id" INTEGER PRIMARY KEY NOT NULL,
  "yournextmp_id" int(11) NOT NULL,
  "name" varchar(200) NOT NULL,
  "list_name" varchar(25) NOT NULL DEFAULT '',
  "list_id" varchar(20) DEFAULT NULL,
  "candidates_updated_time" datetime NOT NULL DEFAULT '2000-01-01 00:00:00',
  "list_rebuilt_time" datetime NOT NULL DEFAULT '2000-01-01 00:00:00'
);

CREATE UNIQUE INDEX "yournextmp_id02" ON "party" ("yournextmp_id");

COMMIT;
