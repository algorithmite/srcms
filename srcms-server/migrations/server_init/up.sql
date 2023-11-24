CREATE TYPE "content_type" AS ENUM('pages', 'files', 'sets');

CREATE TYPE "content_reference_type" AS ENUM('link', 'embed', 'resource', 'download');

CREATE TYPE "path_type" AS ENUM('root', 'library', 'page', 'misc');

CREATE TABLE
    "users" (
        "id" VARCHAR(40) PRIMARY KEY,
        "role_id" VARCHAR(40) REFERENCES "roles",
        "email" VARCHAR,
        "username" VARCHAR,
        "auth_token" VARCHAR,
        "hash" VARCHAR,
        "modified" TIMESTAMP NOT NULL DEFAULT NOW(),
        "created" TIMESTAMP NOT NULL DEFAULT NOW(),
        "deleted" TIMESTAMP
    );

CREATE TABLE
    "roles" (
        "id" VARCHAR(40) PRIMARY KEY,
        "display_name" VARCHAR,
        "modified" TIMESTAMP NOT NULL DEFAULT NOW(),
        "created" TIMESTAMP NOT NULL DEFAULT NOW(),
        "deleted" TIMESTAMP
    );

CREATE TABLE
    "role_permissions" (
        "id" VARCHAR(40) PRIMARY KEY,
        "role_id" VARCHAR(40) REFERENCES "roles",
        "permission_id" VARCHAR(40) REFERENCES "permissions",
        "modified" TIMESTAMP NOT NULL DEFAULT NOW(),
        "created" TIMESTAMP NOT NULL DEFAULT NOW(),
        "deleted" TIMESTAMP
    );

CREATE TABLE
    "permissions" (
        "id" VARCHAR(40) PRIMARY KEY,
        "name" VARCHAR,
        "modified" TIMESTAMP NOT NULL DEFAULT NOW(),
        "created" TIMESTAMP NOT NULL DEFAULT NOW(),
        "deleted" TIMESTAMP
    );

CREATE TABLE
    "content" (
        "id" VARCHAR(40) PRIMARY KEY,
        "type" content_type,
        "author_id" VARCHAR(40) REFERENCES "users",
        "path_id" VARCHAR(40) REFERENCES "paths",
        "view_permission_key" VARCHAR(40) REFERENCES "permissions",
        "comment_permission_key" VARCHAR(40) REFERENCES "permissions",
        "edit_permission_key" VARCHAR(40) REFERENCES "permissions",
        "commentable" BOOLEAN,
        "modified" TIMESTAMP NOT NULL DEFAULT NOW(),
        "created" TIMESTAMP NOT NULL DEFAULT NOW(),
        "deleted" TIMESTAMP
    );

CREATE TABLE
    "pages" (
        "id" VARCHAR(40) PRIMARY KEY,
        "content_id" VARCHAR(40) REFERENCES "paths",
        "title" VARCHAR,
        "body" VARCHAR,
        "publish_at" TIMESTAMP,
        "modified" TIMESTAMP NOT NULL DEFAULT NOW(),
        "created" TIMESTAMP NOT NULL DEFAULT NOW(),
        "deleted" TIMESTAMP
    );

CREATE TABLE
    "files" (
        "id" VARCHAR(40) PRIMARY KEY,
        "content_id" VARCHAR(40) REFERENCES "content",
        "name" VARCHAR,
        "extension" VARCHAR,
        "location" VARCHAR,
        "modified" TIMESTAMP NOT NULL DEFAULT NOW(),
        "created" TIMESTAMP NOT NULL DEFAULT NOW(),
        "deleted" TIMESTAMP
    );

CREATE TABLE
    "sets" (
        "id" VARCHAR(40) PRIMARY KEY,
        "content_id" VARCHAR(40) REFERENCES "content",
        "name" VARCHAR,
        "modified" TIMESTAMP NOT NULL DEFAULT NOW(),
        "created" TIMESTAMP NOT NULL DEFAULT NOW(),
        "deleted" TIMESTAMP
    );

CREATE TABLE
    "content_references" (
        "id" VARCHAR(40) PRIMARY KEY,
        "referencer_id" VARCHAR(40) REFERENCES "content",
        "referencing_id" VARCHAR(40) REFERENCES "content",
        "type" content_reference_type,
        "modified" TIMESTAMP NOT NULL DEFAULT NOW(),
        "created" TIMESTAMP NOT NULL DEFAULT NOW(),
        "deleted" TIMESTAMP
    );

CREATE TABLE
    "paths" (
        "id" VARCHAR(40) PRIMARY KEY,
        "parent" VARCHAR(40) REFERENCES "paths",
        "slug" VARCHAR,
        "type" path_type DEFAULT 'path_type.misc',
        "modified" TIMESTAMP NOT NULL DEFAULT NOW(),
        "created" TIMESTAMP NOT NULL DEFAULT NOW(),
        "deleted" TIMESTAMP
    );

CREATE
OR REPLACE FUNCTION manage_modified (_tbl regclass) RETURNS VOID AS $$ BEGIN EXECUTE format(
        'CREATE TRIGGER set_modified BEFORE UPDATE ON %s
                    FOR EACH ROW EXECUTE PROCEDURE update_modified()',
        _tbl
    );
END;
$$ LANGUAGE plpgsql;

CREATE
OR REPLACE FUNCTION update_modified () RETURNS trigger AS $$ BEGIN IF (
        NEW IS DISTINCT
        FROM OLD
            AND NEW.modified IS NOT DISTINCT
        FROM OLD.modified
    ) THEN NEW.modified := current_timestamp;
END IF;
RETURN NEW;
END;
$$ LANGUAGE plpgsql;

SELECT
    manage_modified ("users");

SELECT
    manage_modified ("roles");

SELECT
    manage_modified ("role_permissions");

SELECT
    manage_modified ("permissions");

SELECT
    manage_modified ("content");

SELECT
    manage_modified ("pages");

SELECT
    manage_modified ("files");

SELECT
    manage_modified ("sets");

SELECT
    manage_modified ("content_references");

SELECT
    manage_modified ("paths");