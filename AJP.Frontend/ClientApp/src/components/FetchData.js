import React, { useState, useEffect, useCallback } from 'react';

export function FetchData() {
  const [products, setProducts] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [statusMessage, setStatusMessage] = useState('');
  const [selectedProduct, setSelectedProduct] = useState(null);
  const [formMode, setFormMode] = useState(''); // 'create', 'edit', or ''

  // Form state
  const emptyProduct = { name: '', description: '', price: '', stock: '' };
  const [formData, setFormData] = useState(emptyProduct);

  // Define fetchProducts with useCallback to memoize it
  const fetchProducts = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      // In development, we might need to use a different URL for local testing
      const apiUrl = process.env.NODE_ENV === 'development'
        ? 'http://localhost:5000/products' // API URL via port-forwarding
        : 'api/Products/GetProducts';      // URL when running in containerized environment

      console.log('Fetching products from:', apiUrl);

      const response = await fetch(apiUrl);
      if (!response.ok) {
        throw new Error(`HTTP error! Status: ${response.status}`);
      }
      const data = await response.json();
      console.log('Received data:', data);
      setProducts(data);
      setLoading(false);
    } catch (error) {
      console.error('Error fetching products:', error);
      setError('Failed to load products. Please try again later.');
      setLoading(false);

      // For demo/development purposes - if API connection fails, use mock data
      if (process.env.NODE_ENV === 'development') {
        console.log('Using mock product data for development');
        console.error('API Error details:', error);
        setProducts(getMockProducts());
        setError(`API Connection issue: ${error.message}. The API responded but could not connect to the PostgreSQL database. Using mock data.`);
      }
    }
  }, []); // Empty dependency array since it doesn't depend on props or state that change  // Load products on component mount
  useEffect(() => {
    fetchProducts();
  }, [fetchProducts]); // Now fetchProducts is properly included in the dependency array

  // Mock API functions for development
  async function mockCreateProduct(product) {
    // Simulate API delay
    await new Promise(resolve => setTimeout(resolve, 500));

    // Create a new product with a generated ID
    const newProduct = {
      ...product,
      id: Math.max(0, ...products.map(p => p.id)) + 1,
      price: parseFloat(product.price),
      stock: parseInt(product.stock, 10)
    };

    setProducts([...products, newProduct]);
    return newProduct;
  }

  async function mockUpdateProduct(product) {
    // Simulate API delay
    await new Promise(resolve => setTimeout(resolve, 500));

    const updatedProducts = products.map(p =>
      p.id === product.id ? {
        ...product,
        price: parseFloat(product.price),
        stock: parseInt(product.stock, 10)
      } : p
    );

    setProducts(updatedProducts);
    return product;
  }

  async function mockDeleteProduct(id) {
    // Simulate API delay
    await new Promise(resolve => setTimeout(resolve, 500));

    setProducts(products.filter(p => p.id !== id));
    return true;
  }

  // Real API functions (using real endpoints)
  async function apiCreateProduct(product) {
    try {
      const apiUrl = process.env.NODE_ENV === 'development'
        ? 'http://localhost:31481/products'
        : 'api/Products/CreateProduct';

      const response = await fetch(apiUrl, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(product),
      });

      if (!response.ok) throw new Error('Failed to create product');

      const newId = await response.json();
      await fetchProducts(); // Refresh the list
      return newId;
    } catch (error) {
      console.error('Error creating product:', error);
      throw error;
    }
  }

  async function apiUpdateProduct(product) {
    try {
      const apiUrl = process.env.NODE_ENV === 'development'
        ? `http://localhost:31481/products/${product.id}`
        : `api/Products/UpdateProduct/${product.id}`;

      const response = await fetch(apiUrl, {
        method: 'PUT',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(product),
      });

      if (!response.ok) throw new Error('Failed to update product');

      await fetchProducts(); // Refresh the list
      return true;
    } catch (error) {
      console.error('Error updating product:', error);
      throw error;
    }
  }

  async function apiDeleteProduct(id) {
    try {
      const apiUrl = process.env.NODE_ENV === 'development'
        ? `http://localhost:31481/products/${id}`
        : `api/Products/DeleteProduct/${id}`;

      const response = await fetch(apiUrl, {
        method: 'DELETE',
      });

      if (!response.ok) throw new Error('Failed to delete product');

      await fetchProducts(); // Refresh the list
      return true;
    } catch (error) {
      console.error('Error deleting product:', error);
      throw error;
    }
  }

  // Handler functions for CRUD operations
  async function handleCreateProduct(e) {
    e.preventDefault();
    try {
      setStatusMessage('Creating product...');

      // Validate form
      if (!formData.name || !formData.price) {
        setStatusMessage('Name and price are required!');
        return;
      }

      // Use mock function for development, real API for production
      if (error && process.env.NODE_ENV === 'development') {
        await mockCreateProduct(formData);
      } else {
        await apiCreateProduct(formData);
      }

      setStatusMessage('Product created successfully!');
      setFormMode('');
      setFormData(emptyProduct);
    } catch (error) {
      setStatusMessage(`Error creating product: ${error.message}`);
    }
  }

  async function handleUpdateProduct(e) {
    e.preventDefault();
    try {
      setStatusMessage('Updating product...');

      // Validate form
      if (!formData.name || !formData.price) {
        setStatusMessage('Name and price are required!');
        return;
      }

      // Use mock function for development, real API for production
      if (error && process.env.NODE_ENV === 'development') {
        await mockUpdateProduct(formData);
      } else {
        await apiUpdateProduct(formData);
      }

      setStatusMessage('Product updated successfully!');
      setFormMode('');
      setFormData(emptyProduct);
      setSelectedProduct(null);
    } catch (error) {
      setStatusMessage(`Error updating product: ${error.message}`);
    }
  }

  async function handleDeleteProduct(id) {
    if (!window.confirm('Are you sure you want to delete this product?')) {
      return;
    }

    try {
      setStatusMessage('Deleting product...');

      // Use mock function for development, real API for production
      if (error && process.env.NODE_ENV === 'development') {
        await mockDeleteProduct(id);
      } else {
        await apiDeleteProduct(id);
      }

      setStatusMessage('Product deleted successfully!');
      if (selectedProduct?.id === id) {
        setSelectedProduct(null);
        setFormMode('');
        setFormData(emptyProduct);
      }
    } catch (error) {
      setStatusMessage(`Error deleting product: ${error.message}`);
    }
  }

  // Form change handler
  function handleFormChange(e) {
    const { name, value } = e.target;
    setFormData({
      ...formData,
      [name]: value
    });
  }

  // Set up edit mode
  function startEditMode(product) {
    setSelectedProduct(product);
    setFormData({
      id: product.id,
      name: product.name,
      description: product.description || '',
      price: product.price.toString(),
      stock: product.stock.toString()
    });
    setFormMode('edit');
  }

  // Start create mode
  function startCreateMode() {
    setSelectedProduct(null);
    setFormData(emptyProduct);
    setFormMode('create');
  }

  // Cancel form
  function cancelForm() {
    setFormMode('');
    setFormData(emptyProduct);
    setSelectedProduct(null);
  }

  // Mock data for development/testing when API is unavailable
  function getMockProducts() {
    return [
      { id: 1, name: 'Smartphone', description: 'Latest model smartphone with high-resolution camera', price: 799.99, stock: 50 },
      { id: 2, name: 'Laptop', description: 'Powerful laptop for work and gaming', price: 1299.99, stock: 25 },
      { id: 3, name: 'T-Shirt', description: 'Cotton t-shirt with logo', price: 19.99, stock: 100 },
      { id: 4, name: 'Jeans', description: 'Classic blue jeans', price: 49.99, stock: 75 },
      { id: 5, name: 'Programming Book', description: 'Learn C# programming', price: 39.99, stock: 30 }
    ];
  }

  function formatPrice(price) {
    return new Intl.NumberFormat('en-US', {
      style: 'currency',
      currency: 'USD'
    }).format(price);
  }

  // Render the product form
  function renderProductForm() {
    return (
      <div className="card mb-4">
        <div className="card-header">
          {formMode === 'create' ? 'Add New Product' : 'Edit Product'}
        </div>
        <div className="card-body">
          <form onSubmit={formMode === 'create' ? handleCreateProduct : handleUpdateProduct}>
            <div className="mb-3">
              <label htmlFor="name" className="form-label">Name</label>
              <input
                type="text"
                className="form-control"
                id="name"
                name="name"
                value={formData.name}
                onChange={handleFormChange}
                required
              />
            </div>
            <div className="mb-3">
              <label htmlFor="description" className="form-label">Description</label>
              <textarea
                className="form-control"
                id="description"
                name="description"
                value={formData.description}
                onChange={handleFormChange}
                rows="3"
              ></textarea>
            </div>
            <div className="mb-3">
              <label htmlFor="price" className="form-label">Price</label>
              <input
                type="number"
                className="form-control"
                id="price"
                name="price"
                value={formData.price}
                onChange={handleFormChange}
                min="0.01"
                step="0.01"
                required
              />
            </div>
            <div className="mb-3">
              <label htmlFor="stock" className="form-label">Stock</label>
              <input
                type="number"
                className="form-control"
                id="stock"
                name="stock"
                value={formData.stock}
                onChange={handleFormChange}
                min="0"
                step="1"
              />
            </div>
            <div className="d-flex gap-2">
              <button type="submit" className="btn btn-primary">
                {formMode === 'create' ? 'Create' : 'Update'} Product
              </button>
              <button type="button" className="btn btn-secondary" onClick={cancelForm}>
                Cancel
              </button>
            </div>
          </form>
        </div>
      </div>
    );
  }

  // Render the products table
  function renderProductsTable(products) {
    return (
      <table className='table table-striped'>
        <thead>
          <tr>
            <th>ID</th>
            <th>Name</th>
            <th>Description</th>
            <th>Price</th>
            <th>Stock</th>
            <th>Actions</th>
          </tr>
        </thead>
        <tbody>
          {products.map(product =>
            <tr key={product.id}>
              <td>{product.id}</td>
              <td>{product.name}</td>
              <td>{product.description}</td>
              <td>{formatPrice(product.price)}</td>
              <td>{product.stock}</td>
              <td>
                <div className="d-flex gap-2">
                  <button
                    className="btn btn-sm btn-outline-primary"
                    onClick={() => startEditMode(product)}
                  >
                    Edit
                  </button>
                  <button
                    className="btn btn-sm btn-outline-danger"
                    onClick={() => handleDeleteProduct(product.id)}
                  >
                    Delete
                  </button>
                </div>
              </td>
            </tr>
          )}
        </tbody>
      </table>
    );
  }

  let contents = loading
    ? <p><em>Loading...</em></p>
    : (
      <>
        {!formMode && (
          <div className="mb-3">
            <button
              className="btn btn-success"
              onClick={startCreateMode}
            >
              Add New Product
            </button>
          </div>
        )}
        {formMode && renderProductForm()}
        {renderProductsTable(products)}
      </>
    );

  return (
    <div>
      <h1>Product Catalog</h1>
      <p>This component demonstrates CRUD operations for products.</p>

      {error && <div className="alert alert-warning">{error}</div>}
      {statusMessage && <div className="alert alert-info">{statusMessage}</div>}

      {contents}
    </div>
  );
}
