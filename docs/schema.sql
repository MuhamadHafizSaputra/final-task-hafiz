-- PostgreSQL DDL for the IoT livestock weighing system
-- Generated from docs/database.dbml (27 tables, 54 references)
-- Run: psql -d your_db -f docs/schema.sql

CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- ============================================================
-- Core: organization and users
-- ============================================================

CREATE TABLE organizations (
    organization_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(150) NOT NULL,
    address TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE users (
    user_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id UUID NOT NULL REFERENCES organizations(organization_id),
    full_name VARCHAR(150) NOT NULL,
    role VARCHAR(20) NOT NULL CHECK (role IN ('owner', 'staff', 'veterinarian', 'admin')),
    phone VARCHAR(30),
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_users_organization ON users(organization_id);

-- ============================================================
-- Animal master data
-- ============================================================

CREATE TABLE animals (
    animal_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id UUID NOT NULL REFERENCES organizations(organization_id),
    species VARCHAR(20) NOT NULL CHECK (species IN ('goat', 'sheep')),
    name VARCHAR(100),
    breed VARCHAR(100),
    sex VARCHAR(10) NOT NULL CHECK (sex IN ('male', 'female', 'unknown')),
    birth_date DATE,
    birth_date_precision VARCHAR(10) NOT NULL DEFAULT 'unknown'
        CHECK (birth_date_precision IN ('exact', 'estimated', 'unknown')),
    color VARCHAR(100),
    facial_pattern TEXT,
    leg_pattern TEXT,
    horn_status VARCHAR(10) DEFAULT 'unknown'
        CHECK (horn_status IN ('horned', 'polled', 'unknown')),
    sire_id UUID REFERENCES animals(animal_id),
    dam_id UUID REFERENCES animals(animal_id),
    status VARCHAR(10) NOT NULL DEFAULT 'active'
        CHECK (status IN ('active', 'sold', 'dead', 'culled')),
    status_date DATE,
    status_reason TEXT,
    notes TEXT,
    created_by UUID REFERENCES users(user_id),
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    CONSTRAINT chk_animal_not_own_parent CHECK (
        sire_id IS DISTINCT FROM animal_id AND dam_id IS DISTINCT FROM animal_id
    )
);

CREATE INDEX idx_animals_organization ON animals(organization_id);
CREATE INDEX idx_animals_org_status ON animals(organization_id, status);
CREATE INDEX idx_animals_sire ON animals(sire_id);
CREATE INDEX idx_animals_dam ON animals(dam_id);

CREATE TABLE animal_tags (
    tag_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    animal_id UUID NOT NULL REFERENCES animals(animal_id),
    tag_code VARCHAR(100) NOT NULL UNIQUE,
    tag_type VARCHAR(20) NOT NULL CHECK (tag_type IN ('rfid', 'ear_tag', 'visual')),
    is_primary BOOLEAN NOT NULL DEFAULT FALSE,
    assigned_at TIMESTAMP NOT NULL DEFAULT NOW(),
    removed_at TIMESTAMP,
    removal_reason TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_animal_tags_animal ON animal_tags(animal_id);
CREATE INDEX idx_animal_tags_primary ON animal_tags(animal_id, is_primary);

-- One active primary tag per animal
CREATE UNIQUE INDEX uq_animal_primary_tag
    ON animal_tags(animal_id)
    WHERE is_primary AND removed_at IS NULL;

CREATE TABLE animal_photos (
    photo_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    animal_id UUID NOT NULL REFERENCES animals(animal_id),
    storage_path TEXT NOT NULL,
    photo_type VARCHAR(30) NOT NULL DEFAULT 'profile',
    is_primary BOOLEAN NOT NULL DEFAULT FALSE,
    captured_at TIMESTAMP,
    created_by UUID REFERENCES users(user_id),
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_animal_photos_animal ON animal_photos(animal_id);
CREATE INDEX idx_animal_photos_primary ON animal_photos(animal_id, is_primary);

-- ============================================================
-- Devices and calibration
-- ============================================================

CREATE TABLE devices (
    device_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id UUID NOT NULL REFERENCES organizations(organization_id),
    device_code VARCHAR(100) NOT NULL UNIQUE,
    device_type VARCHAR(20) NOT NULL
        CHECK (device_type IN ('iot_scale', 'mobile', 'reference_scale')),
    manufacturer VARCHAR(100),
    model VARCHAR(100),
    firmware_version VARCHAR(50),
    capacity_kg DECIMAL(8,3),
    accuracy_kg DECIMAL(8,3),
    status VARCHAR(10) NOT NULL DEFAULT 'active'
        CHECK (status IN ('active', 'inactive', 'maintenance')),
    last_seen_at TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_devices_organization ON devices(organization_id);

CREATE TABLE device_calibrations (
    calibration_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    device_id UUID NOT NULL REFERENCES devices(device_id),
    calibrated_at TIMESTAMP NOT NULL,
    calibrated_by UUID REFERENCES users(user_id),
    reference_weight_kg DECIMAL(8,3),
    measured_weight_kg DECIMAL(8,3),
    offset_value DECIMAL(12,6),
    scale_factor DECIMAL(12,6),
    certificate_path TEXT,
    notes TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_device_calibrations_device ON device_calibrations(device_id);
CREATE INDEX idx_device_calibrations_date ON device_calibrations(calibrated_at);

-- ============================================================
-- Weighing sessions and finalized weighings
-- ============================================================

CREATE TABLE weighing_sessions (
    session_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    device_id UUID NOT NULL REFERENCES devices(device_id),
    animal_id UUID REFERENCES animals(animal_id),
    started_at TIMESTAMP NOT NULL,
    ended_at TIMESTAMP,
    status VARCHAR(20) NOT NULL DEFAULT 'collecting'
        CHECK (status IN ('collecting', 'processing', 'accepted', 'rejected', 'timeout')),
    sample_count INTEGER NOT NULL DEFAULT 0,
    finalized_at TIMESTAMP,
    finalized_weight_kg DECIMAL(8,3),
    finalization_algorithm_version VARCHAR(50),
    finalization_threshold_version VARCHAR(50),
    rejection_reason TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_weighing_sessions_device ON weighing_sessions(device_id);
CREATE INDEX idx_weighing_sessions_animal ON weighing_sessions(animal_id);
CREATE INDEX idx_weighing_sessions_status ON weighing_sessions(status);

-- ============================================================
-- Weighing, samples, quality
-- ============================================================

CREATE TABLE weighings (
    weighing_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    session_id UUID NOT NULL UNIQUE REFERENCES weighing_sessions(session_id),
    animal_id UUID NOT NULL REFERENCES animals(animal_id),
    device_id UUID REFERENCES devices(device_id),
    performed_by UUID REFERENCES users(user_id),
    measured_at TIMESTAMP NOT NULL,
    weight_kg DECIMAL(8,3) NOT NULL CHECK (weight_kg > 0),
    measurement_source VARCHAR(20) NOT NULL
        CHECK (measurement_source IN ('manual', 'iot', 'reference')),
    measurement_method VARCHAR(20) NOT NULL
        CHECK (measurement_method IN ('walk_over', 'stationary', 'manual_entry')),
    stable_weight_detected BOOLEAN,
    quality_score DECIMAL(5,2),
    quality_status VARCHAR(10) NOT NULL DEFAULT 'review'
        CHECK (quality_status IN ('accepted', 'rejected', 'review')),
    is_reference_measurement BOOLEAN NOT NULL DEFAULT FALSE,
    offline_created_at TIMESTAMP,
    synced_at TIMESTAMP,
    client_id VARCHAR(100),
    client_record_id VARCHAR(150),
    notes TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_weighings_client_record UNIQUE (client_id, client_record_id)
);

CREATE INDEX idx_weighings_animal ON weighings(animal_id);
CREATE INDEX idx_weighings_device ON weighings(device_id);
CREATE INDEX idx_weighings_measured_at ON weighings(measured_at);
CREATE INDEX idx_weighings_animal_time ON weighings(animal_id, measured_at);

CREATE TABLE weighing_samples (
    sample_id BIGSERIAL PRIMARY KEY,
    session_id UUID NOT NULL REFERENCES weighing_sessions(session_id),
    recorded_at TIMESTAMP NOT NULL,
    raw_weight_kg DECIMAL(8,3) NOT NULL,
    filtered_weight_kg DECIMAL(8,3),
    sample_number INTEGER NOT NULL,
    CONSTRAINT uq_weighing_sample UNIQUE (session_id, sample_number)
);

CREATE INDEX idx_weighing_samples_session ON weighing_samples(session_id);

CREATE TABLE weighing_quality (
    quality_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    session_id UUID NOT NULL UNIQUE REFERENCES weighing_sessions(session_id) ON DELETE CASCADE,
    window_duration_ms INTEGER,
    sample_count INTEGER,
    window_median_kg DECIMAL(8,3),
    window_mean_kg DECIMAL(8,3),
    window_variance DECIMAL(12,6),
    window_stddev_kg DECIMAL(8,3),
    min_weight_kg DECIMAL(8,3),
    max_weight_kg DECIMAL(8,3),
    rejection_reason TEXT,
    algorithm_version VARCHAR(50),
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE animal_measurements (
    measurement_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    animal_id UUID NOT NULL REFERENCES animals(animal_id),
    measured_at TIMESTAMP NOT NULL,
    height_cm DECIMAL(6,2),
    body_length_cm DECIMAL(6,2),
    heart_girth_cm DECIMAL(6,2),
    body_condition_score DECIMAL(2,1)
        CHECK (body_condition_score BETWEEN 1 AND 5),
    performed_by UUID REFERENCES users(user_id),
    notes TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_animal_measurements_animal ON animal_measurements(animal_id);
CREATE INDEX idx_animal_measurements_date ON animal_measurements(measured_at);

-- ============================================================
-- Locations and groups
-- ============================================================

CREATE TABLE locations (
    location_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id UUID NOT NULL REFERENCES organizations(organization_id),
    name VARCHAR(100) NOT NULL,
    location_type VARCHAR(20) NOT NULL
        CHECK (location_type IN ('barn', 'pen', 'paddock', 'pasture', 'other')),
    description TEXT,
    latitude DECIMAL(10,7),
    longitude DECIMAL(10,7),
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_locations_org_name UNIQUE (organization_id, name)
);

CREATE TABLE animal_groups (
    group_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id UUID NOT NULL REFERENCES organizations(organization_id),
    name VARCHAR(100) NOT NULL,
    purpose VARCHAR(100),
    notes TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_animal_groups_org_name UNIQUE (organization_id, name)
);

CREATE TABLE animal_group_memberships (
    membership_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    group_id UUID NOT NULL REFERENCES animal_groups(group_id),
    animal_id UUID NOT NULL REFERENCES animals(animal_id),
    started_at DATE NOT NULL,
    ended_at DATE,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_group_membership UNIQUE (group_id, animal_id, started_at),
    CONSTRAINT chk_membership_dates CHECK (ended_at IS NULL OR ended_at >= started_at)
);

CREATE INDEX idx_group_memberships_group ON animal_group_memberships(group_id);
CREATE INDEX idx_group_memberships_animal ON animal_group_memberships(animal_id);

-- ============================================================
-- Health and medication
-- ============================================================

CREATE TABLE health_events (
    health_event_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    animal_id UUID NOT NULL REFERENCES animals(animal_id),
    event_type VARCHAR(20) NOT NULL
        CHECK (event_type IN ('illness', 'injury', 'diagnosis', 'vet_visit', 'recovery', 'death')),
    event_date DATE NOT NULL,
    diagnosis TEXT,
    symptoms TEXT,
    treatment_summary TEXT,
    veterinarian_name VARCHAR(150),
    outcome TEXT,
    notes TEXT,
    created_by UUID REFERENCES users(user_id),
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_health_events_animal ON health_events(animal_id);
CREATE INDEX idx_health_events_date ON health_events(event_date);

CREATE TABLE medications (
    medication_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id UUID NOT NULL REFERENCES organizations(organization_id),
    name VARCHAR(150) NOT NULL,
    medication_type VARCHAR(20) NOT NULL
        CHECK (medication_type IN ('vaccine', 'dewormer', 'antibiotic', 'other')),
    default_unit VARCHAR(30),
    description TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_medications_org_name UNIQUE (organization_id, name)
);

CREATE TABLE treatments (
    treatment_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    animal_id UUID NOT NULL REFERENCES animals(animal_id),
    medication_id UUID NOT NULL REFERENCES medications(medication_id),
    health_event_id UUID REFERENCES health_events(health_event_id),
    administered_at TIMESTAMP NOT NULL,
    dose_value DECIMAL(10,3),
    dose_unit VARCHAR(30),
    batch_number VARCHAR(100),
    administered_by VARCHAR(150),
    withdrawal_until DATE,
    next_due_date DATE,
    notes TEXT,
    created_by UUID REFERENCES users(user_id),
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_treatments_animal ON treatments(animal_id);
CREATE INDEX idx_treatments_medication ON treatments(medication_id);
CREATE INDEX idx_treatments_date ON treatments(administered_at);
CREATE INDEX idx_treatments_due ON treatments(next_due_date);

-- ============================================================
-- Breeding and pedigree
-- ============================================================

CREATE TABLE breeding_events (
    breeding_event_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    dam_id UUID NOT NULL REFERENCES animals(animal_id),
    sire_id UUID REFERENCES animals(animal_id),
    event_type VARCHAR(20) NOT NULL
        CHECK (event_type IN ('mating', 'pregnancy_check', 'birth')),
    event_date DATE NOT NULL,
    mating_method VARCHAR(30)
        CHECK (mating_method IN ('natural', 'artificial_insemination')),
    pregnancy_result VARCHAR(10)
        CHECK (pregnancy_result IN ('positive', 'negative', 'unknown')),
    expected_birth_date DATE,
    actual_birth_date DATE,
    birth_count INTEGER,
    live_birth_count INTEGER,
    notes TEXT,
    created_by UUID REFERENCES users(user_id),
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    CONSTRAINT chk_breeding_dam_sire CHECK (sire_id IS DISTINCT FROM dam_id),
    CONSTRAINT chk_birth_counts CHECK (
        live_birth_count IS NULL OR birth_count IS NULL OR live_birth_count <= birth_count
    )
);

CREATE INDEX idx_breeding_events_dam ON breeding_events(dam_id);
CREATE INDEX idx_breeding_events_sire ON breeding_events(sire_id);
CREATE INDEX idx_breeding_events_date ON breeding_events(event_date);
CREATE INDEX idx_breeding_events_dam_type_date ON breeding_events(dam_id, event_type, event_date);

CREATE TABLE offspring_records (
    offspring_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    breeding_event_id UUID NOT NULL REFERENCES breeding_events(breeding_event_id),
    animal_id UUID NOT NULL REFERENCES animals(animal_id),
    birth_weight_kg DECIMAL(6,3),
    weaning_date DATE,
    weaning_weight_kg DECIMAL(6,3),
    notes TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_offspring_event_animal UNIQUE (breeding_event_id, animal_id)
);

CREATE INDEX idx_offspring_records_animal ON offspring_records(animal_id);

CREATE TABLE animal_milestones (
    milestone_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    animal_id UUID NOT NULL REFERENCES animals(animal_id),
    milestone_type VARCHAR(50) NOT NULL,
    milestone_date DATE,
    numeric_value DECIMAL(10,3),
    text_value TEXT,
    notes TEXT,
    created_by UUID REFERENCES users(user_id),
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_animal_milestones_animal ON animal_milestones(animal_id);
CREATE INDEX idx_animal_milestones_lookup
    ON animal_milestones(animal_id, milestone_type, milestone_date);

-- ============================================================
-- Feed and pasture
-- ============================================================

CREATE TABLE feed_types (
    feed_type_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id UUID NOT NULL REFERENCES organizations(organization_id),
    name VARCHAR(100) NOT NULL,
    unit VARCHAR(30) NOT NULL CHECK (unit IN ('kg', 'gram', 'liter', 'portion')),
    notes TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_feed_types_org_name UNIQUE (organization_id, name)
);

CREATE TABLE feed_records (
    feed_record_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    feed_type_id UUID NOT NULL REFERENCES feed_types(feed_type_id),
    animal_id UUID REFERENCES animals(animal_id),
    group_id UUID REFERENCES animal_groups(group_id),
    fed_at TIMESTAMP NOT NULL,
    quantity DECIMAL(10,3) NOT NULL CHECK (quantity > 0),
    unit VARCHAR(30) NOT NULL CHECK (unit IN ('kg', 'gram', 'liter', 'portion')),
    recorded_by UUID REFERENCES users(user_id),
    notes TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    CONSTRAINT chk_feed_target CHECK (
        (animal_id IS NOT NULL AND group_id IS NULL)
        OR (animal_id IS NULL AND group_id IS NOT NULL)
    )
);

CREATE INDEX idx_feed_records_feed_type ON feed_records(feed_type_id);
CREATE INDEX idx_feed_records_animal ON feed_records(animal_id);
CREATE INDEX idx_feed_records_group ON feed_records(group_id);
CREATE INDEX idx_feed_records_date ON feed_records(fed_at);

CREATE TABLE pasture_rotations (
    rotation_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    group_id UUID REFERENCES animal_groups(group_id),
    location_id UUID NOT NULL REFERENCES locations(location_id),
    started_at DATE NOT NULL,
    ended_at DATE,
    notes TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    CONSTRAINT chk_rotation_dates CHECK (ended_at IS NULL OR ended_at >= started_at)
);

CREATE INDEX idx_pasture_rotations_group ON pasture_rotations(group_id);
CREATE INDEX idx_pasture_rotations_location ON pasture_rotations(location_id);
CREATE INDEX idx_pasture_rotations_date ON pasture_rotations(started_at);

-- ============================================================
-- Movement and finance
-- ============================================================

CREATE TABLE location_movements (
    movement_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    animal_id UUID NOT NULL REFERENCES animals(animal_id),
    from_location_id UUID REFERENCES locations(location_id),
    to_location_id UUID REFERENCES locations(location_id),
    movement_type VARCHAR(20) NOT NULL
        CHECK (movement_type IN ('transfer', 'sale', 'death', 'culling', 'birth')),
    movement_date TIMESTAMP NOT NULL,
    reason TEXT,
    destination_name VARCHAR(150),
    recorded_by UUID REFERENCES users(user_id),
    notes TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_location_movements_animal ON location_movements(animal_id);
CREATE INDEX idx_location_movements_from ON location_movements(from_location_id);
CREATE INDEX idx_location_movements_to ON location_movements(to_location_id);
CREATE INDEX idx_location_movements_date ON location_movements(movement_date);

CREATE TABLE financial_records (
    financial_record_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id UUID NOT NULL REFERENCES organizations(organization_id),
    animal_id UUID REFERENCES animals(animal_id),
    movement_id UUID REFERENCES location_movements(movement_id),
    transaction_type VARCHAR(20) NOT NULL
        CHECK (transaction_type IN ('purchase', 'sale', 'feed_cost', 'medical_cost', 'other')),
    transaction_date DATE NOT NULL,
    amount DECIMAL(14,2) NOT NULL,
    currency CHAR(3) NOT NULL DEFAULT 'IDR',
    description TEXT,
    recorded_by UUID REFERENCES users(user_id),
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_financial_records_org ON financial_records(organization_id);
CREATE INDEX idx_financial_records_animal ON financial_records(animal_id);
CREATE INDEX idx_financial_records_movement ON financial_records(movement_id);
CREATE INDEX idx_financial_records_date ON financial_records(transaction_date);

-- ============================================================
-- Offline-first sync and audit
-- ============================================================

CREATE TABLE sync_operations (
    sync_operation_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id UUID NOT NULL REFERENCES organizations(organization_id),
    client_id VARCHAR(100) NOT NULL,
    client_record_id VARCHAR(150) NOT NULL,
    entity_type VARCHAR(100) NOT NULL,
    entity_id UUID,
    operation_type VARCHAR(20) NOT NULL CHECK (operation_type IN ('create', 'update', 'delete')),
    payload_hash VARCHAR(128),
    status VARCHAR(20) NOT NULL DEFAULT 'pending'
        CHECK (status IN ('pending', 'synced', 'failed', 'conflict')),
    attempt_count INTEGER NOT NULL DEFAULT 0,
    last_attempt_at TIMESTAMP,
    synced_at TIMESTAMP,
    error_message TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_sync_operation UNIQUE (organization_id, client_id, client_record_id)
);

CREATE INDEX idx_sync_operations_status ON sync_operations(status);
CREATE INDEX idx_sync_operations_entity_type ON sync_operations(entity_type);

CREATE TABLE audit_logs (
    audit_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id UUID NOT NULL REFERENCES organizations(organization_id),
    user_id UUID REFERENCES users(user_id),
    entity_type VARCHAR(100) NOT NULL,
    entity_id UUID,
    action VARCHAR(20) NOT NULL CHECK (action IN ('create', 'update', 'delete', 'sync', 'login')),
    old_data JSONB,
    new_data JSONB,
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_audit_logs_org ON audit_logs(organization_id);
CREATE INDEX idx_audit_logs_entity ON audit_logs(entity_type, entity_id);
CREATE INDEX idx_audit_logs_created ON audit_logs(created_at);