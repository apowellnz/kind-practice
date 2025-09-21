-- Migration: add_comprehensive_test_data
-- Created: Sun Sep 21 2025

-- Add more categories
INSERT INTO categories (name, description) 
VALUES 
    ('Home & Kitchen', 'Furniture, appliances, and kitchen gadgets'),
    ('Sports & Outdoors', 'Sporting goods, outdoor gear, and fitness equipment'),
    ('Beauty & Personal Care', 'Skincare, haircare, and personal hygiene products'),
    ('Toys & Games', 'Entertainment items for all ages')
ON CONFLICT (id) DO NOTHING;

-- Add more products with realistic data
INSERT INTO products (name, description, price, stock) 
VALUES
    -- Electronics (category_id = 1)
    ('Wireless Earbuds', 'True wireless earbuds with noise cancellation and 24-hour battery life', 129.99, 35),
    ('Smart Watch', 'Fitness tracker with heart rate monitor and GPS', 199.99, 20),
    ('Bluetooth Speaker', 'Portable waterproof speaker with 360-degree sound', 79.99, 40),
    ('Tablet', '10-inch tablet with high-resolution display and 128GB storage', 349.99, 15),
    ('Digital Camera', 'Mirrorless camera with 24MP sensor and 4K video capability', 699.99, 10),
    
    -- Clothing (category_id = 2)
    ('Hoodie', 'Comfortable cotton-blend hoodie with front pocket', 39.99, 50),
    ('Running Shoes', 'Lightweight running shoes with cushioned sole', 89.99, 30),
    ('Winter Jacket', 'Waterproof and insulated jacket for cold weather', 129.99, 20),
    ('Dress Shirt', 'Wrinkle-resistant button-up shirt', 59.99, 40),
    ('Sunglasses', 'Polarized UV-protection sunglasses', 24.99, 25),
    
    -- Books (category_id = 3)
    ('Science Fiction Novel', 'Bestselling sci-fi story about space exploration', 14.99, 25),
    ('Cookbook', 'Collection of easy and healthy recipes', 24.99, 20),
    ('Biography', 'Life story of a renowned historical figure', 19.99, 15),
    ('Self-Help Book', 'Guide to personal development and growth', 16.99, 30),
    ('Children\'s Book', 'Illustrated storybook for young readers', 12.99, 35),
    
    -- Home & Kitchen (category_id = 4)
    ('Coffee Maker', 'Programmable coffee machine with 12-cup capacity', 59.99, 20),
    ('Bedding Set', 'Cotton bedding set with duvet cover and pillowcases', 89.99, 15),
    ('Kitchen Knife Set', 'Professional-grade stainless steel knife set', 129.99, 10),
    ('Blender', 'High-powered blender for smoothies and food processing', 79.99, 25),
    ('Air Purifier', 'HEPA filter air purifier for allergies and dust', 149.99, 15),
    
    -- Sports & Outdoors (category_id = 5)
    ('Yoga Mat', 'Non-slip eco-friendly yoga mat', 29.99, 40),
    ('Camping Tent', '3-person waterproof tent for outdoor adventures', 149.99, 10),
    ('Basketball', 'Official size and weight basketball', 24.99, 30),
    ('Fitness Dumbbells', 'Set of adjustable dumbbells for home workouts', 119.99, 15),
    ('Hiking Backpack', 'Durable backpack with multiple compartments for hiking', 79.99, 20),
    
    -- Beauty & Personal Care (category_id = 6)
    ('Facial Cleanser', 'Gentle foaming cleanser for all skin types', 14.99, 35),
    ('Hair Dryer', 'Professional-grade hair dryer with diffuser', 49.99, 20),
    ('Perfume', 'Luxury fragrance with notes of citrus and amber', 89.99, 15),
    ('Electric Razor', 'Rechargeable razor for smooth shaving', 59.99, 25),
    ('Makeup Set', 'Complete makeup kit with eyeshadow, lipstick, and more', 39.99, 30),
    
    -- Toys & Games (category_id = 7)
    ('Board Game', 'Strategic board game for family game night', 34.99, 25),
    ('Action Figure', 'Collectible action figure from popular franchise', 19.99, 30),
    ('Building Blocks', 'Creative building set with 500+ pieces', 49.99, 15),
    ('Remote Control Car', 'High-speed RC car with rechargeable battery', 69.99, 20),
    ('Puzzle', '1000-piece jigsaw puzzle with scenic image', 17.99, 35)
ON CONFLICT (id) DO NOTHING;

-- Link new products to categories
INSERT INTO product_categories (product_id, category_id)
VALUES
    -- Electronics products (6-10)
    (6, 1), (7, 1), (8, 1), (9, 1), (10, 1),
    
    -- Clothing products (11-15)
    (11, 2), (12, 2), (13, 2), (14, 2), (15, 2),
    
    -- Books products (16-20)
    (16, 3), (17, 3), (18, 3), (19, 3), (20, 3),
    
    -- Home & Kitchen products (21-25)
    (21, 4), (22, 4), (23, 4), (24, 4), (25, 4),
    
    -- Sports & Outdoors products (26-30)
    (26, 5), (27, 5), (28, 5), (29, 5), (30, 5),
    
    -- Beauty & Personal Care products (31-35)
    (31, 6), (32, 6), (33, 6), (34, 6), (35, 6),
    
    -- Toys & Games products (36-40)
    (36, 7), (37, 7), (38, 7), (39, 7), (40, 7)
ON CONFLICT (product_id, category_id) DO NOTHING;

-- Add more user accounts (password: testuser123)
INSERT INTO users (username, email, password_hash, first_name, last_name, is_active)
VALUES
    ('customer1', 'customer1@example.com', '$2a$12$6AOX5rkQYWJwPKrfmOMlI.UBnMSjaiR7ZcF5YQ5nzQYeVTlHQ4HN6', 'John', 'Doe', true),
    ('customer2', 'customer2@example.com', '$2a$12$6AOX5rkQYWJwPKrfmOMlI.UBnMSjaiR7ZcF5YQ5nzQYeVTlHQ4HN6', 'Jane', 'Smith', true),
    ('employee1', 'employee1@example.com', '$2a$12$6AOX5rkQYWJwPKrfmOMlI.UBnMSjaiR7ZcF5YQ5nzQYeVTlHQ4HN6', 'Robert', 'Johnson', true)
ON CONFLICT (username) DO NOTHING;

-- Assign roles to users
INSERT INTO user_to_roles (user_id, role_id)
VALUES
    (2, 2), -- customer1 as User
    (3, 2), -- customer2 as User
    (4, 3)  -- employee1 as Manager
ON CONFLICT (user_id, role_id) DO NOTHING;

-- Add more product reviews
INSERT INTO product_reviews (product_id, user_id, rating, title, content)
VALUES
    -- Reviews for new electronics products
    (6, 2, 5, 'Best earbuds ever!', 'The noise cancellation is incredible. Battery lasts even longer than advertised.'),
    (7, 3, 4, 'Great fitness companion', 'Tracks my workouts accurately and battery life is decent.'),
    (8, 2, 3, 'Good sound but connectivity issues', 'Sound quality is good, but sometimes disconnects from my phone.'),
    (9, 4, 5, 'Perfect for work and entertainment', 'Screen is beautiful and performance is snappy.'),
    (10, 3, 4, 'Great for beginners', 'Easy to use and takes good photos, but limited in low light.'),
    
    -- Reviews for clothing products
    (11, 4, 5, 'Very comfortable', 'Soft material and perfect fit. Will buy again!'),
    (12, 2, 4, 'Good for daily runs', 'Comfortable and supportive, but run a bit small.'),
    
    -- Reviews for books
    (16, 3, 5, 'Couldn\'t put it down!', 'Amazing story with unexpected twists.'),
    (17, 4, 4, 'Great recipes', 'Many delicious options, but some ingredients are hard to find.'),
    
    -- Reviews for home products
    (21, 2, 5, 'Makes perfect coffee', 'Easy to program and clean. Coffee tastes great!'),
    
    -- Reviews for sports products
    (26, 3, 4, 'Good yoga mat', 'Provides good grip but could be a bit thicker.'),
    
    -- Reviews for beauty products
    (31, 4, 5, 'Gentle on skin', 'Removes makeup well without drying out my skin.'),
    
    -- Reviews for toys
    (36, 2, 5, 'Fun for the whole family', 'We play this game every weekend. Highly recommended!')
ON CONFLICT DO NOTHING;

-- Add orders for testing
INSERT INTO orders (user_id, status, total_price, shipping_address)
VALUES
    (2, 'Delivered', 249.98, '123 Main St, Apt 4B, New York, NY 10001'),
    (2, 'Shipped', 79.99, '123 Main St, Apt 4B, New York, NY 10001'),
    (3, 'Processing', 389.97, '456 Oak Ave, Chicago, IL 60007'),
    (3, 'Pending', 14.99, '456 Oak Ave, Chicago, IL 60007'),
    (4, 'Delivered', 179.98, '789 Pine Rd, San Francisco, CA 94016')
ON CONFLICT DO NOTHING;

-- Add order items
INSERT INTO order_items (order_id, product_id, quantity, price)
VALUES
    -- First order (customer1)
    (1, 6, 1, 129.99),
    (1, 12, 1, 89.99),
    
    -- Second order (customer1)
    (2, 8, 1, 79.99),
    
    -- Third order (customer2)
    (3, 9, 1, 349.99),
    (3, 31, 1, 14.99),
    (3, 36, 1, 34.99),
    
    -- Fourth order (customer2)
    (4, 16, 1, 14.99),
    
    -- Fifth order (employee1)
    (5, 21, 1, 59.99),
    (5, 26, 4, 29.99)
ON CONFLICT DO NOTHING;
