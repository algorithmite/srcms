-- Add up migration script here
CREATE TYPE "content_type" AS ENUM('pages', 'files', 'sets');

CREATE TYPE "content_reference_type" AS ENUM('link', 'embed', 'resource', 'download');

CREATE TYPE "path_type" AS ENUM('root', 'library', 'page', 'misc');

CREATE TABLE
    "roles" (
        "id" UUID PRIMARY KEY,
        "display_name" VARCHAR NOT NULL,
        "modified" TIMESTAMP NOT NULL DEFAULT NOW(),
        "created" TIMESTAMP NOT NULL DEFAULT NOW(),
        "deleted" TIMESTAMP
    );

CREATE TABLE
    "users" (
        "id" UUID PRIMARY KEY,
        "role_id" UUID NOT NULL REFERENCES "roles",
        "email" VARCHAR NOT NULL,
        "username" VARCHAR NOT NULL,
        "hash" VARCHAR NOT NULL,
        "modified" TIMESTAMP NOT NULL DEFAULT NOW(),
        "created" TIMESTAMP NOT NULL DEFAULT NOW(),
        "deleted" TIMESTAMP
    );

CREATE TABLE
    "permissions" (
        "id" UUID PRIMARY KEY,
        "name" VARCHAR NOT NULL,
        "modified" TIMESTAMP NOT NULL DEFAULT NOW(),
        "created" TIMESTAMP NOT NULL DEFAULT NOW(),
        "deleted" TIMESTAMP
    );

CREATE TABLE
    "role_permissions" (
        "id" UUID PRIMARY KEY,
        "role_id" UUID NOT NULL REFERENCES "roles",
        "permission_id" UUID NOT NULL REFERENCES "permissions",
        "modified" TIMESTAMP NOT NULL DEFAULT NOW(),
        "created" TIMESTAMP NOT NULL DEFAULT NOW(),
        "deleted" TIMESTAMP
    );

CREATE TABLE
    "paths" (
        "id" UUID PRIMARY KEY,
        "parent" UUID REFERENCES "paths",
        "slug" VARCHAR NOT NULL,
        "type" path_type NOT NULL DEFAULT 'misc',
        "modified" TIMESTAMP NOT NULL DEFAULT NOW(),
        "created" TIMESTAMP NOT NULL DEFAULT NOW(),
        "deleted" TIMESTAMP
    );

CREATE TABLE
    "content" (
        "id" UUID PRIMARY KEY,
        "type" content_type NOT NULL,
        "author_id" UUID NOT NULL REFERENCES "users",
        "path_id" UUID NOT NULL REFERENCES "paths",
        "view_permission_key" UUID NOT NULL REFERENCES "permissions",
        "comment_permission_key" UUID NOT NULL REFERENCES "permissions",
        "edit_permission_key" UUID NOT NULL REFERENCES "permissions",
        "commentable" BOOLEAN NOT NULL DEFAULT false,
        "modified" TIMESTAMP NOT NULL DEFAULT NOW(),
        "created" TIMESTAMP NOT NULL DEFAULT NOW(),
        "deleted" TIMESTAMP
    );

CREATE TABLE
    "pages" (
        "id" UUID PRIMARY KEY,
        "content_id" UUID NOT NULL REFERENCES "content",
        "title" VARCHAR NOT NULL,
        "body" VARCHAR NOT NULL,
        "publish_at" TIMESTAMP,
        "modified" TIMESTAMP NOT NULL DEFAULT NOW(),
        "created" TIMESTAMP NOT NULL DEFAULT NOW(),
        "deleted" TIMESTAMP
    );

CREATE TABLE
    "files" (
        "id" UUID PRIMARY KEY,
        "content_id" UUID NOT NULL REFERENCES "content",
        "name" VARCHAR NOT NULL,
        "extension" VARCHAR NOT NULL,
        "modified" TIMESTAMP NOT NULL DEFAULT NOW(),
        "created" TIMESTAMP NOT NULL DEFAULT NOW(),
        "deleted" TIMESTAMP
    );

CREATE TABLE
    "sets" (
        "id" UUID PRIMARY KEY,
        "content_id" UUID NOT NULL REFERENCES "content",
        "name" VARCHAR NOT NULL,
        "modified" TIMESTAMP NOT NULL DEFAULT NOW(),
        "created" TIMESTAMP NOT NULL DEFAULT NOW(),
        "deleted" TIMESTAMP
    );

CREATE TABLE
    "content_references" (
        "id" UUID PRIMARY KEY,
        "referencer_id" UUID NOT NULL REFERENCES "content",
        "referencing_id" UUID NOT NULL REFERENCES "content",
        "type" content_reference_type NOT NULL,
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
    manage_modified ('"users"');

SELECT
    manage_modified ('"roles"');

SELECT
    manage_modified ('"role_permissions"');

SELECT
    manage_modified ('"permissions"');

SELECT
    manage_modified ('"content"');

SELECT
    manage_modified ('"pages"');

SELECT
    manage_modified ('"files"');

SELECT
    manage_modified ('"sets"');

SELECT
    manage_modified ('"content_references"');

SELECT
    manage_modified ('"paths"');