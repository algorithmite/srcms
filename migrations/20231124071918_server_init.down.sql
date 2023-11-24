-- Add down migration script here
DROP TABLE "content_references";

DROP TABLE "sets";

DROP TABLE "files";

DROP TABLE "pages";

DROP TABLE "content";

DROP TABLE "paths";

DROP TABLE "role_permissions";

DROP TABLE "permissions";

DROP TABLE "users";

DROP TABLE "roles";

DROP FUNCTION manage_modified;

DROP FUNCTION update_modified;

DROP TYPE "content_type";

DROP TYPE "content_reference_type";

DROP TYPE "path_type";