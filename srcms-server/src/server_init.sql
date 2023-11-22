CREATE OR REPLACE FUNCTION manage_modified(_tbl regclass) RETURNS VOID AS $$
BEGIN
    EXECUTE format('CREATE TRIGGER set_modified BEFORE UPDATE ON %s
                    FOR EACH ROW EXECUTE PROCEDURE update_modified()', _tbl);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION update_modified() RETURNS trigger AS $$
BEGIN
    IF (
        NEW IS DISTINCT FROM OLD AND
        NEW.modified IS NOT DISTINCT FROM OLD.modified
    ) THEN
        NEW.modified := current_timestamp;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TYPE "content_type" AS ENUM (
  'pages',
  'files',
  'sets'
);

CREATE TYPE "content_reference_type" AS ENUM (
  'link',
  'embed',
  'resource',
  'download'
);

CREATE TYPE "path_type" AS ENUM (
  'root',
  'library',
  'page',
  'misc'
);

CREATE TABLE "users" (
  "id" INTEGER PRIMARY KEY,
  "role_id" INTEGER,
  "email" VARCHAR,
  "username" VARCHAR,
  "auth_token" VARCHAR,
  "hash" VARCHAR,
  "modified" TIMESTAMP NOT NULL DEFAULT NOW(),
  "created" TIMESTAMP NOT NULL DEFAULT NOW()
);
SELECT manage_modified("users");

CREATE TABLE "roles" (
  "id" INTEGER PRIMARY KEY,
  "display_name" VARCHAR,
  "modified" TIMESTAMP NOT NULL DEFAULT NOW(),
  "created" TIMESTAMP NOT NULL DEFAULT NOW()
);
SELECT manage_modified("roles");

CREATE TABLE "role_permissions" (
  "id" INTEGER PRIMARY KEY,
  "role_id" INTEGER,
  "permission_id" INTEGER,
  "modified" TIMESTAMP NOT NULL DEFAULT NOW(),
  "created" TIMESTAMP NOT NULL DEFAULT NOW()
);
SELECT manage_modified("role_permissions");

CREATE TABLE "permissions" (
  "id" INTEGER PRIMARY KEY,
  "edit_permission_key" INTEGER,
  "name" VARCHAR,
  "modified" TIMESTAMP NOT NULL DEFAULT NOW(),
  "created" TIMESTAMP NOT NULL DEFAULT NOW()
);
SELECT manage_modified("permissions");

CREATE TABLE "content" (
  "id" INTEGER PRIMARY KEY,
  "type" content_type,
  "author_id" INTEGER,
  "path_id" INTEGER,
  "view_permission_key" INTEGER,
  "comment_permission_key" INTEGER,
  "edit_permission_key" INTEGER,
  "commentable" BOOLEAN,
  "modified" TIMESTAMP NOT NULL DEFAULT NOW(),
  "created" TIMESTAMP NOT NULL DEFAULT NOW()
);
SELECT manage_modified("content");

CREATE TABLE "pages" (
  "id" INTEGER PRIMARY KEY,
  "content_id" INTEGER,
  "title" VARCHAR,
  "body" VARCHAR,
  "publish_at" TIMESTAMP,
  "modified" TIMESTAMP NOT NULL DEFAULT NOW(),
  "created" TIMESTAMP NOT NULL DEFAULT NOW()
);
SELECT manage_modified("pages");

CREATE TABLE "files" (
  "id" INTEGER PRIMARY KEY,
  "content_id" INTEGER,
  "name" VARCHAR,
  "extension" VARCHAR,
  "location" VARCHAR,
  "modified" TIMESTAMP NOT NULL DEFAULT NOW(),
  "created" TIMESTAMP NOT NULL DEFAULT NOW()
);
SELECT manage_modified("files");

CREATE TABLE "sets" (
  "id" INTEGER PRIMARY KEY,
  "content_id" INTEGER,
  "name" VARCHAR,
  "modified" TIMESTAMP NOT NULL DEFAULT NOW(),
  "created" TIMESTAMP NOT NULL DEFAULT NOW()
);
SELECT manage_modified("sets");

CREATE TABLE "content_references" (
  "id" INTEGER PRIMARY KEY,
  "referencer_id" INTEGER,
  "referencing_id" INTEGER,
  "type" content_reference_type,
  "modified" TIMESTAMP NOT NULL DEFAULT NOW(),
  "created" TIMESTAMP NOT NULL DEFAULT NOW()
);
SELECT manage_modified("content_references");

CREATE TABLE "paths" (
  "id" INTEGER PRIMARY KEY,
  "parent" INTEGER,
  "slug" VARCHAR,
  "type" path_type DEFAULT 'path_type.misc',
  "modified" TIMESTAMP NOT NULL DEFAULT NOW(),
  "created" TIMESTAMP NOT NULL DEFAULT NOW()
);
SELECT manage_modified("paths");

ALTER TABLE "content" ADD FOREIGN KEY ("author_id") REFERENCES "users" ("id");

ALTER TABLE "content_references" ADD FOREIGN KEY ("referencer_id") REFERENCES "content" ("id");

ALTER TABLE "content_references" ADD FOREIGN KEY ("referencing_id") REFERENCES "content" ("id");

ALTER TABLE "users" ADD FOREIGN KEY ("role_id") REFERENCES "roles" ("id");

ALTER TABLE "role_permissions" ADD FOREIGN KEY ("role_id") REFERENCES "roles" ("id");

ALTER TABLE "role_permissions" ADD FOREIGN KEY ("permission_id") REFERENCES "permissions" ("id");

ALTER TABLE "paths" ADD FOREIGN KEY ("parent") REFERENCES "paths" ("id");

ALTER TABLE "content" ADD FOREIGN KEY ("path_id") REFERENCES "paths" ("id");

ALTER TABLE "pages" ADD FOREIGN KEY ("content_id") REFERENCES "content" ("id");

ALTER TABLE "files" ADD FOREIGN KEY ("content_id") REFERENCES "content" ("id");

ALTER TABLE "sets" ADD FOREIGN KEY ("content_id") REFERENCES "content" ("id");

ALTER TABLE "content" ADD FOREIGN KEY ("view_permission_key") REFERENCES "permissions" ("id");

ALTER TABLE "content" ADD FOREIGN KEY ("comment_permission_key") REFERENCES "permissions" ("id");

ALTER TABLE "content" ADD FOREIGN KEY ("edit_permission_key") REFERENCES "permissions" ("id");

ALTER TABLE "permissions" ADD FOREIGN KEY ("edit_permission_key") REFERENCES "permissions" ("id");
