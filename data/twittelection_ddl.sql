CREATE TABLE IF NOT EXISTS "candidate" (
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
CREATE TABLE IF NOT EXISTS "constituency" (
  "id" INTEGER PRIMARY KEY NOT NULL,
  "three_code" char(3) NOT NULL DEFAULT 0,
  "name" varchar(200) NOT NULL,
  "region" varchar(50) NOT NULL,
  "nation" varchar(50) NOT NULL,
  "list_name" varchar(25) NOT NULL,
  "list_id" varchar(20) DEFAULT NULL,
  "candidates_updated_time" datetime NOT NULL DEFAULT '2000-01-01 00:00:00',
  "list_rebuilt_time" datetime NOT NULL DEFAULT '2000-01-01 00:00:00',
  "list_checked_time" datetime DEFAULT NULL
);
CREATE UNIQUE INDEX "con_three_code" ON "constituency" ("three_code");
CREATE UNIQUE INDEX "con_name" ON "constituency" ("name");
CREATE TABLE IF NOT EXISTS "party" (
  "id" INTEGER PRIMARY KEY NOT NULL,
  "yournextmp_id" int(11) NOT NULL,
  "name" varchar(200) NOT NULL,
  "list_name" varchar(25) NOT NULL DEFAULT '',
  "list_id" varchar(20) DEFAULT NULL,
  "candidates_updated_time" datetime NOT NULL DEFAULT '2000-01-01 00:00:00',
  "list_rebuilt_time" datetime NOT NULL DEFAULT '2000-01-01 00:00:00'
);
CREATE UNIQUE INDEX "yournextmp_id02" ON "party" ("yournextmp_id");
