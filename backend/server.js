const express = require('express');
const { Pool } = require('pg');
const cors = require('cors');
const bodyParser = require('body-parser');
require('dotenv').config();

const app = express();

// Middleware
app.use(cors());
app.use(bodyParser.json());

// PostgreSQL Connection Pool
const pool = new Pool({
  user: process.env.DB_USER || 'telecom_user',
  password: process.env.DB_PASSWORD || 'telecom_password',
  host: process.env.DB_HOST || 'postgres',
  port: process.env.DB_PORT || 5432,
  database: process.env.DB_NAME || 'telecom_monitoring'
});

// Health check
app.get('/api/health', (req, res) => {
  res.json({ status: 'Backend API is running' });
});

// Get all base stations
app.get('/api/base-stations', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM base_stations ORDER BY id');
    res.json(result.rows);
  } catch (err) {
    console.error('Database error:', err);
    res.status(500).json({ error: 'Database error' });
  }
});

// Get base station by ID
app.get('/api/base-stations/:id', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM base_stations WHERE id = $1', [req.params.id]);
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Base station not found' });
    }
    res.json(result.rows[0]);
  } catch (err) {
    console.error('Database error:', err);
    res.status(500).json({ error: 'Database error' });
  }
});

// Get network metrics
app.get('/api/network-metrics', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM network_metrics ORDER BY recorded_at DESC LIMIT 100');
    res.json(result.rows);
  } catch (err) {
    console.error('Database error:', err);
    res.status(500).json({ error: 'Database error' });
  }
});

// Get alerts
app.get('/api/alerts', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM alerts ORDER BY created_at DESC LIMIT 50');
    res.json(result.rows);
  } catch (err) {
    console.error('Database error:', err);
    res.status(500).json({ error: 'Database error' });
  }
});

// Create new alert
app.post('/api/alerts', async (req, res) => {
  const { base_station_id, severity, message } = req.body;
  try {
    const result = await pool.query(
      'INSERT INTO alerts (base_station_id, severity, message, created_at) VALUES ($1, $2, $3, NOW()) RETURNING *',
      [base_station_id, severity, message]
    );
    res.status(201).json(result.rows[0]);
  } catch (err) {
    console.error('Database error:', err);
    res.status(500).json({ error: 'Database error' });
  }
});

// Get service status
app.get('/api/service-status', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM service_status');
    res.json(result.rows);
  } catch (err) {
    console.error('Database error:', err);
    res.status(500).json({ error: 'Database error' });
  }
});

const PORT = process.env.PORT || 5000;

// Database connection test
pool.query('SELECT NOW()', (err, result) => {
  if (err) {
    console.error('Database connection failed:', err);
  } else {
    console.log('Connected to PostgreSQL database at:', result.rows[0].now);
  }
});

app.listen(PORT, () => {
  console.log(`Backend API server running on port ${PORT}`);
});
