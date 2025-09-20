-- Add Users table for authentication

CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(100) NOT NULL UNIQUE,
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP
);

-- Create UserRoles table
CREATE TABLE IF NOT EXISTS user_roles (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT
);

-- Create UserToRoles join table
CREATE TABLE IF NOT EXISTS user_to_roles (
    user_id INT NOT NULL,
    role_id INT NOT NULL,
    PRIMARY KEY (user_id, role_id),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (role_id) REFERENCES user_roles(id) ON DELETE CASCADE
);

-- Insert default roles
INSERT INTO user_roles (name, description) VALUES 
    ('Admin', 'System administrator with full access'),
    ('User', 'Regular user with standard access'),
    ('Manager', 'Manager with elevated access');

-- Insert a test admin user (password: admin123)
INSERT INTO users (username, email, password_hash, first_name, last_name, is_active) 
VALUES ('admin', 'admin@example.com', '$2a$12$6AOX5rkQYWJwPKrfmOMlI.UBnMSjaiR7ZcF5YQ5nzQYeVTlHQ4HN6', 'Admin', 'User', true);

-- Assign admin role to admin user
INSERT INTO user_to_roles (user_id, role_id) 
VALUES (1, 1);
