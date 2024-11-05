-- Create the users table with common fields
CREATE TABLE users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP,
    is_active BOOLEAN DEFAULT 1
);

-- Insert sample users
INSERT INTO users (username, email, password_hash, first_name, last_name) VALUES
    ('john_doe', 'john@example.com', '$2y$10$abcdefghijklmnopqrstuv', 'John', 'Doe'),
    ('jane_smith', 'jane@example.com', '$2y$10$vwxyzabcdefghijklmnopq', 'Jane', 'Smith'),
    ('bob_wilson', 'bob@example.com', '$2y$10$rstuvwxyzabcdefghijklm', 'Bob', 'Wilson'),
    ('alice_jones', 'alice@example.com', '$2y$10$nopqrstuvwxyzabcdefghi', 'Alice', 'Jones'),
    ('charlie_brown', 'charlie@example.com', '$2y$10$hijklmnopqrstuvwxyzabc', 'Charlie', 'Brown');
