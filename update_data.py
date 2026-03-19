#!/usr/bin/env python3
"""
Data Update Script for Telecom Monitoring Platform
This script changes database data to demonstrate frontend updates in real-time
"""

import psycopg2
from psycopg2 import sql
import os
import random
from datetime import datetime
import time
import argparse

# Database configuration
DB_HOST = os.getenv('DB_HOST', 'localhost')
DB_PORT = os.getenv('DB_PORT', '5432')
DB_NAME = os.getenv('DB_NAME', 'telecom_monitoring')
DB_USER = os.getenv('DB_USER', 'telecom_user')
DB_PASSWORD = os.getenv('DB_PASSWORD', 'telecom_password')

def connect_db():
    """Create database connection"""
    try:
        conn = psycopg2.connect(
            host=DB_HOST,
            port=DB_PORT,
            database=DB_NAME,
            user=DB_USER,
            password=DB_PASSWORD
        )
        return conn
    except Exception as e:
        print(f"Error connecting to database: {e}")
        return None

def update_network_metrics(conn):
    """Update network metrics with random values"""
    try:
        cursor = conn.cursor()
        
        # Get all base stations
        cursor.execute('SELECT id FROM base_stations WHERE status = %s', ('online',))
        base_stations = cursor.fetchall()
        
        for (station_id,) in base_stations:
            bandwidth = random.uniform(40, 95)
            traffic = random.uniform(1000, 3000)
            
            cursor.execute("""
                INSERT INTO network_metrics (base_station_id, metric_name, metric_value)
                VALUES (%s, %s, %s)
            """, (station_id, 'Bandwidth Usage', bandwidth))
            
            cursor.execute("""
                INSERT INTO network_metrics (base_station_id, metric_name, metric_value)
                VALUES (%s, %s, %s)
            """, (station_id, 'Data Traffic', traffic))
        
        conn.commit()
        print(f"✓ Updated network metrics for {len(base_stations)} base stations")
        return True
    except Exception as e:
        print(f"Error updating network metrics: {e}")
        conn.rollback()
        return False

def update_base_station_status(conn, station_id, new_status):
    """Update base station status"""
    try:
        cursor = conn.cursor()
        
        valid_statuses = ['online', 'offline', 'maintenance']
        if new_status not in valid_statuses:
            print(f"Invalid status. Must be one of: {', '.join(valid_statuses)}")
            return False
        
        cursor.execute("""
            UPDATE base_stations 
            SET status = %s, updated_at = CURRENT_TIMESTAMP 
            WHERE id = %s
        """, (new_status, station_id))
        
        conn.commit()
        print(f"✓ Base Station {station_id} status updated to: {new_status}")
        return True
    except Exception as e:
        print(f"Error updating base station status: {e}")
        conn.rollback()
        return False

def update_base_station_capacity(conn, station_id, new_capacity):
    """Update base station capacity"""
    try:
        cursor = conn.cursor()
        
        if not (0 <= new_capacity <= 100):
            print("Capacity must be between 0 and 100")
            return False
        
        cursor.execute("""
            UPDATE base_stations 
            SET capacity = %s 
            WHERE id = %s
        """, (new_capacity, station_id))
        
        conn.commit()
        print(f"✓ Base Station {station_id} capacity updated to: {new_capacity}%")
        return True
    except Exception as e:
        print(f"Error updating base station capacity: {e}")
        conn.rollback()
        return False

def add_alert(conn, station_id, severity, message):
    """Add a new alert"""
    try:
        cursor = conn.cursor()
        
        valid_severities = ['info', 'warning', 'critical']
        if severity not in valid_severities:
            print(f"Invalid severity. Must be one of: {', '.join(valid_severities)}")
            return False
        
        cursor.execute("""
            INSERT INTO alerts (base_station_id, severity, message)
            VALUES (%s, %s, %s)
            RETURNING id
        """, (station_id, severity, message))
        
        alert_id = cursor.fetchone()[0]
        conn.commit()
        print(f"✓ Alert created (ID: {alert_id}) - [{severity}] {message}")
        return True
    except Exception as e:
        print(f"Error adding alert: {e}")
        conn.rollback()
        return False

def simulate_network_changes(conn, duration=60):
    """Simulate continuous network changes"""
    print(f"\nStarting network simulation for {duration} seconds...")
    print("Press Ctrl+C to stop\n")
    
    try:
        start_time = time.time()
        iteration = 0
        
        while time.time() - start_time < duration:
            iteration += 1
            print(f"--- Iteration {iteration} at {datetime.now().strftime('%H:%M:%S')} ---")
            
            # Update metrics
            update_network_metrics(conn)
            
            # Randomly toggle a base station status
            if random.random() > 0.7:
                station_id = random.randint(1, 5)
                status = random.choice(['online', 'maintenance'])
                update_base_station_status(conn, station_id, status)
            
            # Randomly add an alert
            if random.random() > 0.6:
                station_id = random.randint(1, 5)
                severity = random.choice(['info', 'warning'])
                messages = [
                    'High bandwidth utilization detected',
                    'Network latency increased',
                    'Data traffic spike observed',
                    'Performance degradation detected',
                    'Maintenance scheduled'
                ]
                add_alert(conn, station_id, severity, random.choice(messages))
            
            print()
            time.sleep(5)  # Wait 5 seconds between iterations
            
    except KeyboardInterrupt:
        print("\n\nSimulation stopped.")

def show_current_status(conn):
    """Display current database status"""
    try:
        cursor = conn.cursor()
        
        print("\n" + "="*60)
        print("CURRENT DATABASE STATUS")
        print("="*60)
        
        # Base Stations
        cursor.execute('SELECT id, name, status, capacity FROM base_stations ORDER BY id')
        print("\nBase Stations:")
        for row in cursor.fetchall():
            print(f"  ID {row[0]}: {row[1]} - Status: {row[2]}, Capacity: {row[3]}%")
        
        # Latest Metrics
        cursor.execute("""
            SELECT DISTINCT ON (base_station_id) base_station_id, metric_name, metric_value, recorded_at
            FROM network_metrics
            ORDER BY base_station_id, recorded_at DESC
            LIMIT 10
        """)
        print("\nLatest Network Metrics:")
        for row in cursor.fetchall():
            print(f"  Station {row[0]}: {row[1]} = {row[2]}")
        
        # Recent Alerts
        cursor.execute('SELECT base_station_id, severity, message, created_at FROM alerts ORDER BY created_at DESC LIMIT 5')
        print("\nRecent Alerts:")
        for row in cursor.fetchall():
            print(f"  [{row[1].upper()}] Station {row[0]}: {row[2]}")
        
        print("\n" + "="*60)
        
    except Exception as e:
        print(f"Error showing status: {e}")

def main():
    parser = argparse.ArgumentParser(description='Update Telecom Monitoring Platform data')
    parser.add_argument('--action', choices=['metrics', 'status', 'alert', 'simulate', 'show'], 
                       default='show', help='Action to perform')
    parser.add_argument('--station-id', type=int, help='Base station ID')
    parser.add_argument('--status', choices=['online', 'offline', 'maintenance'], help='New status')
    parser.add_argument('--capacity', type=int, help='New capacity (0-100)')
    parser.add_argument('--severity', choices=['info', 'warning', 'critical'], help='Alert severity')
    parser.add_argument('--message', help='Alert message')
    parser.add_argument('--duration', type=int, default=60, help='Simulation duration in seconds')
    
    args = parser.parse_args()
    
    conn = connect_db()
    if not conn:
        print("Failed to connect to database")
        return
    
    try:
        if args.action == 'metrics':
            update_network_metrics(conn)
        
        elif args.action == 'status':
            if not args.station_id or not args.status:
                print("Error: --station-id and --status required for status action")
            else:
                update_base_station_status(conn, args.station_id, args.status)
        
        elif args.action == 'alert':
            if not args.station_id or not args.severity or not args.message:
                print("Error: --station-id, --severity, and --message required for alert action")
            else:
                add_alert(conn, args.station_id, args.severity, args.message)
        
        elif args.action == 'simulate':
            simulate_network_changes(conn, args.duration)
        
        elif args.action == 'show':
            show_current_status(conn)
    
    finally:
        conn.close()

if __name__ == '__main__':
    main()
