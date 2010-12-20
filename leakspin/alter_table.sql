ALTER TABLE cables ADD COLUMN created_at timestamp;
ALTER TABLE cables ADD COLUMN updated_at timestamp;

ALTER TABLE fragments ADD COLUMN created_at timestamp;
ALTER TABLE fragments ADD COLUMN updated_at timestamp;

ALTER TABLE metadatum ADD COLUMN created_at timestamp;
ALTER TABLE metadatum ADD COLUMN updated_at timestamp;

ALTER TABLE questions ADD COLUMN created_at timestamp;
ALTER TABLE questions ADD COLUMN updated_at timestamp;
