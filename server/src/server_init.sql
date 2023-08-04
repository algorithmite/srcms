/* As created by the rust diesel cli */
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

