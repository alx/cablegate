# Add timestamps

ALTER TABLE cables ADD COLUMN created_at timestamp;
ALTER TABLE cables ADD COLUMN updated_at timestamp;

ALTER TABLE fragments ADD COLUMN created_at timestamp;
ALTER TABLE fragments ADD COLUMN updated_at timestamp;

ALTER TABLE metadatum ADD COLUMN created_at timestamp;
ALTER TABLE metadatum ADD COLUMN updated_at timestamp;

ALTER TABLE questions ADD COLUMN created_at timestamp;
ALTER TABLE questions ADD COLUMN updated_at timestamp;

# Add question type column

ALTER TABLE questions ADD COLUMN type integer;
UPDATE questions SET type=1 WHERE metatada NOT LIKE 'peoeple';
UPDATE questions SET type=2 WHERE metatada LIKE 'peoeple';