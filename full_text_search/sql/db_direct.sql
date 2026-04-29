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
('Advanced SQL Queries', 'Learn how to write advanced SQL queries for data analysis.');

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