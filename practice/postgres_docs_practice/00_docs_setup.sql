-- PostgreSQL docs-based practice setup
-- Run this after ../custom_practice/00_schema_and_data.sql

BEGIN;

DROP TABLE IF EXISTS docs_graph CASCADE;
DROP TABLE IF EXISTS docs_json_feed CASCADE;

CREATE TABLE docs_graph (
    id INT NOT NULL,
    link INT NULL,
    label TEXT NOT NULL,
    PRIMARY KEY (id, label)
);

INSERT INTO docs_graph (id, link, label) VALUES
(1, 2, 'root-a'),
(2, 3, 'mid-a'),
(3, 4, 'mid-b'),
(4, 2, 'cycle-back'),
(5, NULL, 'root-b'),
(6, 5, 'leaf-b');

CREATE TABLE docs_json_feed (
    feed_id INT PRIMARY KEY,
    payload JSONB NOT NULL
);

INSERT INTO docs_json_feed (feed_id, payload) VALUES
(
    1,
    '{
      "track": {
        "segments": [
          {"location": [47.763, 13.4034], "start_time": "2018-10-14 10:05:14", "HR": 73},
          {"location": [47.706, 13.2635], "start_time": "2018-10-14 10:39:21", "HR": 135}
        ]
      }
    }'::jsonb
),
(
    2,
    '{
      "favorites": [
        {"kind": "comedy", "films": [{"title": "Bananas", "director": "Woody Allen"}]},
        {"kind": "thriller", "films": [{"title": "Vertigo", "director": "Alfred Hitchcock"}]}
      ]
    }'::jsonb
);

COMMIT;
