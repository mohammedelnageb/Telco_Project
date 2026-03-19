-- Create database schema for Telecom Monitoring Platform

-- Base Stations Table
CREATE TABLE IF NOT EXISTS base_stations (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    location VARCHAR(200) NOT NULL,
    status VARCHAR(50) DEFAULT 'online',
    capacity INTEGER DEFAULT 0,
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Network Metrics Table
CREATE TABLE IF NOT EXISTS network_metrics (
    id SERIAL PRIMARY KEY,
    base_station_id INTEGER REFERENCES base_stations(id),
    metric_name VARCHAR(100) NOT NULL,
    metric_value DECIMAL(10, 2) NOT NULL,
    recorded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Alerts Table
CREATE TABLE IF NOT EXISTS alerts (
    id SERIAL PRIMARY KEY,
    base_station_id INTEGER REFERENCES base_stations(id),
    severity VARCHAR(50) NOT NULL,
    message TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Service Status Table
CREATE TABLE IF NOT EXISTS service_status (
    id SERIAL PRIMARY KEY,
    service_name VARCHAR(100) NOT NULL,
    status VARCHAR(50) DEFAULT 'active',
    availability DECIMAL(5, 2) DEFAULT 100.00,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert sample data
INSERT INTO base_stations (name, location, status, capacity, latitude, longitude) VALUES
('Base Station 1', 'Downtown District', 'online', 85, 40.7128, -74.0060),
('Base Station 2', 'North Zone', 'online', 72, 40.7282, -73.7949),
('Base Station 3', 'South Zone', 'offline', 0, 40.6892, -74.0445),
('Base Station 4', 'East Terminal', 'online', 90, 40.6413, -73.7781),
('Base Station 5', 'West Industrial', 'maintenance', 0, 40.7614, -74.0045);

INSERT INTO network_metrics (base_station_id, metric_name, metric_value, recorded_at) VALUES
(1, 'Bandwidth Usage', 85.5, CURRENT_TIMESTAMP),
(1, 'Data Traffic', 2450.75, CURRENT_TIMESTAMP),
(2, 'Bandwidth Usage', 72.3, CURRENT_TIMESTAMP),
(2, 'Data Traffic', 1820.50, CURRENT_TIMESTAMP),
(4, 'Bandwidth Usage', 90.2, CURRENT_TIMESTAMP),
(4, 'Data Traffic', 2890.30, CURRENT_TIMESTAMP);

INSERT INTO alerts (base_station_id, severity, message, created_at) VALUES
(1, 'warning', 'High bandwidth utilization detected', CURRENT_TIMESTAMP),
(3, 'critical', 'Base station offline - investigating service disruption', CURRENT_TIMESTAMP),
(4, 'info', 'Scheduled maintenance completed successfully', CURRENT_TIMESTAMP);

INSERT INTO service_status (service_name, status, availability) VALUES
('Voice Services', 'active', 99.95),
('Data Services', 'active', 99.87),
('SMS Services', 'active', 99.99),
('Internet Services', 'active', 99.92);
