-- Up Migration
-- Which of the boss cast a boss is drawn as (app schema v10). Nullable like
-- every payload column; old rows stay null and the app picks from the id.
ALTER TABLE bosses ADD COLUMN design integer;

-- Down Migration
ALTER TABLE bosses DROP COLUMN design;
