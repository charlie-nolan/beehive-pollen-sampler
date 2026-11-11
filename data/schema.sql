-- Draft SQLite schema for the export that ships with each cassette.
-- Status: design draft; column names may change once the firmware exists.
-- Times are UTC ISO 8601. One database per cassette run.

CREATE TABLE cassette (
    cassette_id     TEXT PRIMARY KEY,      -- QR run ID printed on the cassette
    device_id       TEXT NOT NULL,
    started_at      TEXT NOT NULL,
    ended_at        TEXT,
    tape_type       TEXT,                  -- e.g. acrylic 12 mm, forensic lifting tape
    clearing_fluid  TEXT,                  -- e.g. PG + ethanol ratio
    notes           TEXT
);

-- Every time the trap grid swings in, whether or not a pellet is caught (sampling effort).
CREATE TABLE trap_deployment (
    deployment_id   INTEGER PRIMARY KEY,
    cassette_id     TEXT NOT NULL REFERENCES cassette(cassette_id),
    deployed_at     TEXT NOT NULL,
    retracted_at    TEXT,
    reason_skipped  TEXT,                  -- e.g. low traffic, fault; NULL if it ran
    pellet_caught   INTEGER NOT NULL DEFAULT 0
);

-- One row per sample cycle, including blank cycles.
CREATE TABLE pellet (
    pellet_id       INTEGER PRIMARY KEY,
    cassette_id     TEXT NOT NULL REFERENCES cassette(cassette_id),
    deployment_id   INTEGER REFERENCES trap_deployment(deployment_id),
    frame_start     INTEGER NOT NULL,      -- sprocket frame on the tape
    sampled_at      TEXT NOT NULL,
    is_blank        INTEGER NOT NULL DEFAULT 0,   -- 1 = blank cycle for carryover checks
    bee_tag         TEXT,                  -- tagged forager ID, NULL for whole-hive samples
    colour_rgb      TEXT,
    size_mm         REAL,
    uv_brightness   REAL,
    press_recipe    TEXT,
    drawer_rh       REAL,
    image_white     TEXT,                  -- file path in the image archive
    image_uv        TEXT,
    fault           TEXT
);

-- Microscope IDs (phase 2). Several rows per pellet when it's mixed.
CREATE TABLE pollen_id (
    pellet_id       INTEGER NOT NULL REFERENCES pellet(pellet_id),
    taxon_family    TEXT,
    taxon_genus     TEXT,
    pollen_type     TEXT,
    grain_count     INTEGER,
    confidence      REAL,
    is_mixed        INTEGER,
    flagged_unknown INTEGER NOT NULL DEFAULT 0,
    model_version   TEXT NOT NULL
);

-- Tagged forager trips from the entrance camera (phase 2). Every trip, sampled or not.
CREATE TABLE forager_trip (
    trip_id         INTEGER PRIMARY KEY,
    bee_tag         TEXT NOT NULL,
    left_at         TEXT,
    returned_at     TEXT,
    sampling_rate   TEXT,                  -- every_trip, every_4th, never (control)
    stripped        INTEGER NOT NULL DEFAULT 0,
    pellet_id       INTEGER REFERENCES pellet(pellet_id)
);

-- Hive and weather telemetry, long format.
CREATE TABLE telemetry (
    recorded_at     TEXT NOT NULL,
    sensor          TEXT NOT NULL,         -- e.g. weight_kg, brood_temp_c, outside_rh, traffic_in, sound_band_250hz
    value           REAL NOT NULL,
    PRIMARY KEY (recorded_at, sensor)
);
