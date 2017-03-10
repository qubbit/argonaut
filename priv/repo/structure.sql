/*
 Navicat Premium Data Transfer

 Source Server         : argonaut
 Source Server Type    : PostgreSQL
 Source Server Version : 90601
 Source Host           : localhost
 Source Database       : argonaut
 Source Schema         : public

 Target Server Type    : PostgreSQL
 Target Server Version : 90601
 File Encoding         : utf-8

 Date: 03/10/2017 18:46:16 PM
*/

-- ----------------------------
--  Sequence structure for applications_id_seq
-- ----------------------------
DROP SEQUENCE IF EXISTS "public"."applications_id_seq";
CREATE SEQUENCE "public"."applications_id_seq" INCREMENT 1 START 12 MAXVALUE 9223372036854775807 MINVALUE 1 CACHE 1;
ALTER TABLE "public"."applications_id_seq" OWNER TO "developer";

-- ----------------------------
--  Sequence structure for environments_id_seq
-- ----------------------------
DROP SEQUENCE IF EXISTS "public"."environments_id_seq";
CREATE SEQUENCE "public"."environments_id_seq" INCREMENT 1 START 4 MAXVALUE 9223372036854775807 MINVALUE 1 CACHE 1;
ALTER TABLE "public"."environments_id_seq" OWNER TO "developer";

-- ----------------------------
--  Sequence structure for reservations_id_seq
-- ----------------------------
DROP SEQUENCE IF EXISTS "public"."reservations_id_seq";
CREATE SEQUENCE "public"."reservations_id_seq" INCREMENT 1 START 4 MAXVALUE 9223372036854775807 MINVALUE 1 CACHE 1;
ALTER TABLE "public"."reservations_id_seq" OWNER TO "developer";

-- ----------------------------
--  Sequence structure for users_id_seq
-- ----------------------------
DROP SEQUENCE IF EXISTS "public"."users_id_seq";
CREATE SEQUENCE "public"."users_id_seq" INCREMENT 1 START 3 MAXVALUE 9223372036854775807 MINVALUE 1 CACHE 1;
ALTER TABLE "public"."users_id_seq" OWNER TO "developer";

-- ----------------------------
--  Table structure for schema_migrations
-- ----------------------------
DROP TABLE IF EXISTS "public"."schema_migrations";
CREATE TABLE "public"."schema_migrations" (
	"version" int8 NOT NULL,
	"inserted_at" timestamp(6) NULL
)
WITH (OIDS=FALSE);
ALTER TABLE "public"."schema_migrations" OWNER TO "developer";

-- ----------------------------
--  Table structure for users
-- ----------------------------
DROP TABLE IF EXISTS "public"."users";
CREATE TABLE "public"."users" (
	"id" int4 NOT NULL DEFAULT nextval('users_id_seq'::regclass),
	"first_name" varchar(255) COLLATE "default",
	"last_name" varchar(255) COLLATE "default",
	"username" varchar(255) COLLATE "default",
	"password_hash" varchar(255) COLLATE "default",
	"avatar_url" varchar(255) COLLATE "default",
	"email" varchar(255) COLLATE "default",
	"is_admin" bool DEFAULT false,
	"time_zone" varchar(255) DEFAULT 'America/New_York'::character varying COLLATE "default",
	"inserted_at" timestamp(6) NOT NULL,
	"updated_at" timestamp(6) NOT NULL
)
WITH (OIDS=FALSE);
ALTER TABLE "public"."users" OWNER TO "developer";

-- ----------------------------
--  Table structure for environments
-- ----------------------------
DROP TABLE IF EXISTS "public"."environments";
CREATE TABLE "public"."environments" (
	"id" int4 NOT NULL DEFAULT nextval('environments_id_seq'::regclass),
	"name" varchar(255) COLLATE "default",
	"description" varchar(255) COLLATE "default",
	"owning_team" varchar(255) COLLATE "default",
	"inserted_at" timestamp(6) NOT NULL,
	"updated_at" timestamp(6) NOT NULL
)
WITH (OIDS=FALSE);
ALTER TABLE "public"."environments" OWNER TO "developer";

-- ----------------------------
--  Table structure for applications
-- ----------------------------
DROP TABLE IF EXISTS "public"."applications";
CREATE TABLE "public"."applications" (
	"id" int4 NOT NULL DEFAULT nextval('applications_id_seq'::regclass),
	"name" varchar(255) COLLATE "default",
	"ping" varchar(255) COLLATE "default",
	"repo" varchar(255) COLLATE "default",
	"inserted_at" timestamp(6) NOT NULL,
	"updated_at" timestamp(6) NOT NULL
)
WITH (OIDS=FALSE);
ALTER TABLE "public"."applications" OWNER TO "developer";

-- ----------------------------
--  Table structure for reservations
-- ----------------------------
DROP TABLE IF EXISTS "public"."reservations";
CREATE TABLE "public"."reservations" (
	"id" int4 NOT NULL DEFAULT nextval('reservations_id_seq'::regclass),
	"user_id" int4,
	"environment_id" int4,
	"application_id" int4,
	"reserved_at" timestamp(6) NULL DEFAULT '2017-03-10 18:44:37.722445'::timestamp without time zone,
	"inserted_at" timestamp(6) NOT NULL,
	"updated_at" timestamp(6) NOT NULL
)
WITH (OIDS=FALSE);
ALTER TABLE "public"."reservations" OWNER TO "developer";


-- ----------------------------
--  Alter sequences owned by
-- ----------------------------
ALTER SEQUENCE "public"."applications_id_seq" RESTART 13 OWNED BY "applications"."id";
ALTER SEQUENCE "public"."environments_id_seq" RESTART 5 OWNED BY "environments"."id";
ALTER SEQUENCE "public"."reservations_id_seq" RESTART 5 OWNED BY "reservations"."id";
ALTER SEQUENCE "public"."users_id_seq" RESTART 4 OWNED BY "users"."id";
-- ----------------------------
--  Primary key structure for table schema_migrations
-- ----------------------------
ALTER TABLE "public"."schema_migrations" ADD PRIMARY KEY ("version") NOT DEFERRABLE INITIALLY IMMEDIATE;

-- ----------------------------
--  Primary key structure for table users
-- ----------------------------
ALTER TABLE "public"."users" ADD PRIMARY KEY ("id") NOT DEFERRABLE INITIALLY IMMEDIATE;

-- ----------------------------
--  Indexes structure for table users
-- ----------------------------
CREATE UNIQUE INDEX  "users_email_index" ON "public"."users" USING btree(email COLLATE "default" ASC NULLS LAST);
CREATE UNIQUE INDEX  "users_username_index" ON "public"."users" USING btree(username COLLATE "default" ASC NULLS LAST);

-- ----------------------------
--  Primary key structure for table environments
-- ----------------------------
ALTER TABLE "public"."environments" ADD PRIMARY KEY ("id") NOT DEFERRABLE INITIALLY IMMEDIATE;

-- ----------------------------
--  Primary key structure for table applications
-- ----------------------------
ALTER TABLE "public"."applications" ADD PRIMARY KEY ("id") NOT DEFERRABLE INITIALLY IMMEDIATE;

-- ----------------------------
--  Primary key structure for table reservations
-- ----------------------------
ALTER TABLE "public"."reservations" ADD PRIMARY KEY ("id") NOT DEFERRABLE INITIALLY IMMEDIATE;

-- ----------------------------
--  Indexes structure for table reservations
-- ----------------------------
CREATE INDEX  "reservations_application_id_index" ON "public"."reservations" USING btree(application_id ASC NULLS LAST);
CREATE INDEX  "reservations_environment_id_index" ON "public"."reservations" USING btree(environment_id ASC NULLS LAST);
CREATE UNIQUE INDEX  "reservations_user_id_environment_id_application_id_index" ON "public"."reservations" USING btree(user_id ASC NULLS LAST, environment_id ASC NULLS LAST, application_id ASC NULLS LAST);
CREATE INDEX  "reservations_user_id_index" ON "public"."reservations" USING btree(user_id ASC NULLS LAST);

-- ----------------------------
--  Foreign keys structure for table reservations
-- ----------------------------
ALTER TABLE "public"."reservations" ADD CONSTRAINT "reservations_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."users" ("id") ON UPDATE NO ACTION ON DELETE CASCADE NOT DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE "public"."reservations" ADD CONSTRAINT "reservations_application_id_fkey" FOREIGN KEY ("application_id") REFERENCES "public"."applications" ("id") ON UPDATE NO ACTION ON DELETE CASCADE NOT DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE "public"."reservations" ADD CONSTRAINT "reservations_environment_id_fkey" FOREIGN KEY ("environment_id") REFERENCES "public"."environments" ("id") ON UPDATE NO ACTION ON DELETE CASCADE NOT DEFERRABLE INITIALLY IMMEDIATE;

