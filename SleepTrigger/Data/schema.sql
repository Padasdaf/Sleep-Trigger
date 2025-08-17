-- Simple schema; extend later.
CREATE TABLE IF NOT EXISTS sleep_onset (
  id      TEXT PRIMARY KEY,
  ts      REAL NOT NULL,     -- unix time seconds
  notes   TEXT
);

CREATE INDEX IF NOT EXISTS idx_onset_ts ON sleep_onset(ts);

