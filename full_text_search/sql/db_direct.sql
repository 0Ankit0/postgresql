# Create documents table
CREATE TABLE IF NOT EXISTS documents(
    id SERIAL PRIMARY KEY,
    title VARCHAR(100) NOT NULL,
    content TEXT NOT NULL,
    contents_tsv TSVECTOR GENERATED ALWAYS AS (
        to_tsvector('english',coalesce(title,'') || ' ' || coalesce(content,''))
    ) STORED
);

-- Create GIN index on the tsvector column
CREATE INDEX IF NOT EXISTS idx_content_tsv ON documents USING GIN (contents_tsv);

-- Insert sample data using copy command
COPY documents(title, content)
FROM '../documents.csv'
WITH (FORMAT csv, HEADER true);

-- if the copy command does not work, you can use the following insert statements to add sample data
 INSERT INTO documents (title, content) VALUES
('PostgreSQL Full-Text Search', 'PostgreSQL provides powerful full-text search capabilities.'),
('Introduction to SQL', 'SQL is a standard language for managing databases.'),
('Advanced SQL Queries', 'Learn how to write advanced SQL queries for data analysis.'),
('Database Indexing', 'Indexing is crucial for improving query performance in databases.'),
('Text Search in PostgreSQL', 'PostgreSQL offers various functions and operators for text search.'),
('Using tsquery and tsvector', 'Learn how to use tsquery and tsvector for full-text search in PostgreSQL.'),
('Performance Optimization', 'Tips and techniques for optimizing database performance.'),
('Data Analysis with SQL', 'Use SQL for data analysis and reporting.'),
('PostgreSQL Extensions', 'Explore the various extensions available for PostgreSQL.'),
('Best Practices for Database Design', 'Learn best practices for designing efficient databases.');

-- Example full-text search query
SELECT id, title, content
FROM documents
WHERE contents_tsv @@ to_tsquery('english', 'PostgreSQL & search');

-- Example full-text search query with ranking
SELECT id, title, content, ts_rank(contents_tsv, to_tsquery('english', 'SQL & queries')) AS rank
FROM documents
WHERE contents_tsv @@ to_tsquery('english', 'SQL & queries')
ORDER BY rank DESC;

-- using websearch_to_tsquery for more natural language search
SELECT id, title, content
FROM documents
WHERE contents_tsv @@ websearch_to_tsquery('english', 'PostgreSQL full-text search');





# Using pg_textsearch for more advanced search features

# Install the pg_textsearch extension if not already installed
# https://github.com/timescale/pg_textsearch/releases has the required binaries from which you can download and install the extension on your PostgreSQL instance. Make sure to follow the installation instructions provided in the repository.

# First of all enable the pg_textsearch extension
CREATE EXTENSION IF NOT EXISTS pg_textsearch;

# you can use the documents table above or crete a new events table for testing
CREATE TABLE IF NOT EXISTS events(
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT NOT NULL
);

# Then create bm25 index on the description column
CREATE INDEX IF NOT EXISTS idx_events_description_bm25 ON events USING bm25 (description) with (text_config = 'english');

# Insert sample data into events table
INSERT INTO events (name, description) VALUES
('Tech Conference', 'A conference about the latest in technology.'),
('Music Festival', 'A festival featuring various music artists.'),
('Art Exhibition', 'An exhibition showcasing contemporary art.'),
('Food Fair', 'A fair offering a variety of cuisines.'),
('Sports Tournament', 'A tournament featuring various sports competitions.'),
('Book Fair', 'A fair with a wide selection of books and authors.'),
('Film Festival', 'A festival showcasing independent films.'),
('Science Expo', 'An expo featuring scientific discoveries and innovations.'),
('Fashion Show', 'A show presenting the latest fashion trends.'),
('Comedy Night', 'An event featuring stand-up comedy performances.');


# run a bm25 search query
select *, description <@> 'music festival' as score
from events
order by score
limit 5;
