-- Create daily_costs table to store historical cost explorer records
CREATE TABLE IF NOT EXISTS daily_costs (
    id SERIAL PRIMARY KEY,
    usage_date DATE NOT NULL,
    service VARCHAR(100) NOT NULL,
    region VARCHAR(50) NOT NULL,
    usage_type VARCHAR(255) NOT NULL,
    unblended_cost NUMERIC(12, 4) NOT NULL DEFAULT 0.0000,
    amortized_cost NUMERIC(12, 4) NOT NULL DEFAULT 0.0000,
    currency VARCHAR(10) NOT NULL DEFAULT 'USD',
    tags JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Unique index to prevent duplicate ingestion records and support UPSERT (ON CONFLICT)
CREATE UNIQUE INDEX IF NOT EXISTS idx_daily_costs_unique 
ON daily_costs (usage_date, service, region, usage_type);

-- Query performance indexes
CREATE INDEX IF NOT EXISTS idx_daily_costs_date ON daily_costs (usage_date);
CREATE INDEX IF NOT EXISTS idx_daily_costs_service ON daily_costs (service);
CREATE INDEX IF NOT EXISTS idx_daily_costs_tags ON daily_costs USING gin (tags);

-- Create recommendations table to store rule-based optimization suggestions
CREATE TABLE IF NOT EXISTS recommendations (
    id SERIAL PRIMARY KEY,
    resource_id VARCHAR(255) NOT NULL,
    resource_type VARCHAR(100) NOT NULL,
    service VARCHAR(100) NOT NULL,
    current_config JSONB,
    recommended_config JSONB,
    estimated_savings NUMERIC(12, 4) NOT NULL DEFAULT 0.0000,
    rule_name VARCHAR(100) NOT NULL,
    status VARCHAR(50) NOT NULL DEFAULT 'active',
    details JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Query performance indexes
CREATE INDEX IF NOT EXISTS idx_recommendations_resource ON recommendations (resource_id);
CREATE INDEX IF NOT EXISTS idx_recommendations_status ON recommendations (status);
CREATE INDEX IF NOT EXISTS idx_recommendations_savings ON recommendations (estimated_savings DESC);

-- Create anomalies table to store cost deviation alerts
CREATE TABLE IF NOT EXISTS anomalies (
    id SERIAL PRIMARY KEY,
    detection_date DATE NOT NULL,
    service VARCHAR(100) NOT NULL,
    expected_cost NUMERIC(12, 4) NOT NULL,
    actual_cost NUMERIC(12, 4) NOT NULL,
    deviation_percentage NUMERIC(6, 2) NOT NULL,
    anomaly_score NUMERIC(5, 2),
    status VARCHAR(50) NOT NULL DEFAULT 'open',
    details JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Query performance indexes
CREATE INDEX IF NOT EXISTS idx_anomalies_date ON anomalies (detection_date);
CREATE INDEX IF NOT EXISTS idx_anomalies_status ON anomalies (status);
