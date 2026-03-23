const express = require('express');
const path = require('path');
const os = require('os');
require('dotenv').config();

const app = express();
const containerId = process.env.HOSTNAME || os.hostname();

// Middleware
app.use(express.static(path.join(__dirname, 'public')));
app.use(express.json());

// Expose the container handling each request (useful for load-balancing demos)
app.use((req, res, next) => {
  res.setHeader('X-Frontend-Container', containerId);
  next();
});

// Set view engine
app.set('view engine', 'ejs');
app.set('views', path.join(__dirname, 'views'));

// Backend API URL
const backendAPI = process.env.BACKEND_API_URL || 'http://backend:5000';

// Health check
app.get('/health', (req, res) => {
  res.json({ status: 'Frontend is running', container: containerId });
});

// Main dashboard
app.get('/', (req, res) => {
  res.render('dashboard', {
    backendAPI,
    frontendContainer: containerId,
  });
});

// API proxy endpoints (for CORS compatibility)
app.get('/api/proxy/base-stations', async (req, res) => {
  try {
    const response = await require('axios').get(`${backendAPI}/api/base-stations`);
    const backendContainer = response.headers['x-backend-container'];
    if (backendContainer) {
      res.setHeader('X-Backend-Container', backendContainer);
    }
    res.json(response.data);
  } catch (err) {
    console.error('Backend error:', err.message);
    res.status(500).json({ error: 'Failed to fetch base stations' });
  }
});

app.get('/api/proxy/network-metrics', async (req, res) => {
  try {
    const response = await require('axios').get(`${backendAPI}/api/network-metrics`);
    const backendContainer = response.headers['x-backend-container'];
    if (backendContainer) {
      res.setHeader('X-Backend-Container', backendContainer);
    }
    res.json(response.data);
  } catch (err) {
    console.error('Backend error:', err.message);
    res.status(500).json({ error: 'Failed to fetch metrics' });
  }
});

app.get('/api/proxy/alerts', async (req, res) => {
  try {
    const response = await require('axios').get(`${backendAPI}/api/alerts`);
    const backendContainer = response.headers['x-backend-container'];
    if (backendContainer) {
      res.setHeader('X-Backend-Container', backendContainer);
    }
    res.json(response.data);
  } catch (err) {
    console.error('Backend error:', err.message);
    res.status(500).json({ error: 'Failed to fetch alerts' });
  }
});

app.get('/api/proxy/service-status', async (req, res) => {
  try {
    const response = await require('axios').get(`${backendAPI}/api/service-status`);
    const backendContainer = response.headers['x-backend-container'];
    if (backendContainer) {
      res.setHeader('X-Backend-Container', backendContainer);
    }
    res.json(response.data);
  } catch (err) {
    console.error('Backend error:', err.message);
    res.status(500).json({ error: 'Failed to fetch service status' });
  }
});

const PORT = process.env.PORT || 3000;

app.listen(PORT, () => {
  console.log(`Frontend server running on port ${PORT}`);
  console.log(`Backend API: ${backendAPI}`);
});
