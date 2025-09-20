CREATE TABLE IF NOT EXISTS Products (
    Id SERIAL PRIMARY KEY,
    Name VARCHAR(100) NOT NULL,
    Description TEXT,
    Price DECIMAL(18,2) NOT NULL,
    CreatedAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt TIMESTAMP NULL
);

-- Add some test data
INSERT INTO Products (Name, Description, Price, CreatedAt)
VALUES ('Test Product 1', 'Description for test product 1', 19.99, CURRENT_TIMESTAMP),
       ('Test Product 2', 'Description for test product 2', 29.99, CURRENT_TIMESTAMP)
ON CONFLICT (Id) DO NOTHING;
