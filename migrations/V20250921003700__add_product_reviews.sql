-- Migration: add_product_reviews
-- Created: Sun Sep 21 00:37:00 NZST 2025

-- Create the product_reviews table
CREATE TABLE IF NOT EXISTS product_reviews (
    id SERIAL PRIMARY KEY,
    product_id INT NOT NULL,
    user_id INT NOT NULL,
    rating INT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    title VARCHAR(100),
    content TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Create index for faster lookups by product
CREATE INDEX idx_product_reviews_product_id ON product_reviews(product_id);

-- Add some sample reviews
INSERT INTO product_reviews (product_id, user_id, rating, title, content) VALUES
    (1, 1, 5, 'Amazing smartphone!', 'This smartphone exceeded my expectations. Great camera and battery life.'),
    (1, 1, 4, 'Good but pricey', 'Very good product but a bit expensive compared to similar models.'),
    (2, 1, 5, 'Perfect laptop', 'This laptop is fast and has great build quality. Perfect for work and gaming.'),
    (3, 1, 3, 'Average quality', 'The t-shirt is comfortable but the fabric quality could be better.'),
    (5, 1, 5, 'Best programming book', 'This book made learning C# so much easier. Highly recommended!');

-- Create a view for product ratings
CREATE VIEW product_rating_summary AS
SELECT 
    p.id AS product_id,
    p.name AS product_name,
    COUNT(pr.id) AS review_count,
    ROUND(AVG(pr.rating), 1) AS average_rating
FROM 
    products p
LEFT JOIN 
    product_reviews pr ON p.id = pr.product_id
GROUP BY 
    p.id, p.name;
