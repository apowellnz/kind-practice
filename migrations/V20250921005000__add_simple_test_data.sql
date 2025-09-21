-- Add some basic product data
INSERT INTO products (name, description, price, stock) 
VALUES
    ('Wireless Earbuds', 'True wireless earbuds with noise cancellation', 129.99, 35),
    ('Smart Watch', 'Fitness tracker with heart rate monitor', 199.99, 20),
    ('Bluetooth Speaker', 'Portable waterproof speaker', 79.99, 40),
    ('Tablet', '10-inch tablet with high-resolution display', 349.99, 15),
    ('Digital Camera', 'Mirrorless camera with 24MP sensor', 699.99, 10)
ON CONFLICT (id) DO NOTHING;
