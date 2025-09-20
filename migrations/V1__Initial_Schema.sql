-- Initial database schema

-- Create Products table
CREATE TABLE IF NOT EXISTS products (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price DECIMAL(10, 2) NOT NULL,
    stock INT NOT NULL DEFAULT 0,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP
);

-- Create Categories table
CREATE TABLE IF NOT EXISTS categories (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Create Product_Categories join table
CREATE TABLE IF NOT EXISTS product_categories (
    product_id INT NOT NULL,
    category_id INT NOT NULL,
    PRIMARY KEY (product_id, category_id),
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
    FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE CASCADE
);

-- Create sample data
INSERT INTO categories (name, description) VALUES 
    ('Electronics', 'Electronic devices and accessories'),
    ('Clothing', 'Apparel and fashion items'),
    ('Books', 'Reading materials and publications');

INSERT INTO products (name, description, price, stock) VALUES
    ('Smartphone', 'Latest model smartphone with high-resolution camera', 799.99, 50),
    ('Laptop', 'Powerful laptop for work and gaming', 1299.99, 25),
    ('T-Shirt', 'Cotton t-shirt with logo', 19.99, 100),
    ('Jeans', 'Classic blue jeans', 49.99, 75),
    ('Programming Book', 'Learn C# programming', 39.99, 30);

-- Link products to categories
INSERT INTO product_categories (product_id, category_id) VALUES
    (1, 1), -- Smartphone in Electronics
    (2, 1), -- Laptop in Electronics
    (3, 2), -- T-Shirt in Clothing
    (4, 2), -- Jeans in Clothing
    (5, 3); -- Programming Book in Books
