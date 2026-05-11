-- ============================================================
-- Community Aid Hub — Database Schema
-- Author: Nevin Nelson (Q1071615)
-- Programme: BSc Computer Science and Digitization
-- ============================================================

CREATE DATABASE IF NOT EXISTS community_aid_hub;
USE community_aid_hub;

-- ------------------------------------------------------------
-- Table: Donors
-- Stores donor profiles, contact info, and activity status
-- ------------------------------------------------------------
CREATE TABLE Donors (
    donor_id          VARCHAR(10)  PRIMARY KEY,
    first_name        VARCHAR(50)  NOT NULL,
    last_name         VARCHAR(50)  NOT NULL,
    email             VARCHAR(100) UNIQUE,
    phone             VARCHAR(15),
    address           TEXT,
    donation_preference VARCHAR(50),
    registration_date DATE         NOT NULL,
    last_donation_date DATE,
    status            VARCHAR(20)  DEFAULT 'Active',
    CONSTRAINT chk_donor_status CHECK (status IN ('Active', 'Inactive', 'Suspended'))
);

-- ------------------------------------------------------------
-- Table: Donations
-- Tracks each donation event linked to a donor
-- ------------------------------------------------------------
CREATE TABLE Donations (
    donation_id    VARCHAR(10)   PRIMARY KEY,
    donor_id       VARCHAR(10),
    donation_date  DATE          NOT NULL,
    type           VARCHAR(50)   NOT NULL,
    value          DECIMAL(10,2),
    description    TEXT,
    receipt_number VARCHAR(20)   UNIQUE,
    status         VARCHAR(20)   DEFAULT 'Received',
    FOREIGN KEY (donor_id) REFERENCES Donors(donor_id),
    CONSTRAINT chk_donation_status CHECK (status IN ('Received', 'Processed', 'Distributed'))
);

-- ------------------------------------------------------------
-- Table: InventoryItems
-- Food bank and resource inventory with expiry tracking
-- ------------------------------------------------------------
CREATE TABLE InventoryItems (
    item_id          VARCHAR(10)  PRIMARY KEY,
    donation_id      VARCHAR(10),
    name             VARCHAR(100) NOT NULL,
    category         VARCHAR(50)  NOT NULL,
    quantity         INTEGER      NOT NULL,
    unit             VARCHAR(20),
    expiry_date      DATE,
    storage_location VARCHAR(50),
    condition        VARCHAR(20),
    FOREIGN KEY (donation_id) REFERENCES Donations(donation_id),
    CONSTRAINT chk_quantity CHECK (quantity >= 0)
);

-- ------------------------------------------------------------
-- Table: Beneficiaries
-- Families and individuals receiving services
-- ------------------------------------------------------------
CREATE TABLE Beneficiaries (
    beneficiary_id    VARCHAR(10)  PRIMARY KEY,
    family_name       VARCHAR(100) NOT NULL,
    family_size       INTEGER,
    address           TEXT,
    phone             VARCHAR(15),
    registration_date DATE         NOT NULL,
    needs_status      TEXT,
    last_service_date DATE,
    CONSTRAINT chk_family_size CHECK (family_size > 0)
);

-- ------------------------------------------------------------
-- Table: Volunteers
-- Volunteer profiles, skills, and availability
-- ------------------------------------------------------------
CREATE TABLE Volunteers (
    volunteer_id         VARCHAR(10)  PRIMARY KEY,
    first_name           VARCHAR(50)  NOT NULL,
    last_name            VARCHAR(50)  NOT NULL,
    email                VARCHAR(100) UNIQUE,
    phone                VARCHAR(15),
    skills               TEXT,
    availability         TEXT,
    status               VARCHAR(20)  DEFAULT 'Active',
    background_check_date DATE,
    CONSTRAINT chk_volunteer_status CHECK (status IN ('Active', 'Inactive', 'Suspended'))
);

-- ------------------------------------------------------------
-- Table: Distributions
-- Service delivery events linking beneficiaries and volunteers
-- ------------------------------------------------------------
CREATE TABLE Distributions (
    distribution_id   VARCHAR(10)  PRIMARY KEY,
    beneficiary_id    VARCHAR(10),
    distribution_date DATE         NOT NULL,
    status            VARCHAR(20)  DEFAULT 'Pending',
    distributed_by    VARCHAR(10),
    notes             TEXT,
    FOREIGN KEY (beneficiary_id) REFERENCES Beneficiaries(beneficiary_id),
    FOREIGN KEY (distributed_by) REFERENCES Volunteers(volunteer_id),
    CONSTRAINT chk_distribution_status CHECK (status IN ('Pending', 'In Progress', 'Completed'))
);

-- ------------------------------------------------------------
-- Table: DistributionDetails
-- Line-item breakdown of items in each distribution
-- ------------------------------------------------------------
CREATE TABLE DistributionDetails (
    distribution_detail_id VARCHAR(10) PRIMARY KEY,
    distribution_id        VARCHAR(10),
    item_id                VARCHAR(10),
    quantity               INTEGER     NOT NULL,
    notes                  TEXT,
    FOREIGN KEY (distribution_id) REFERENCES Distributions(distribution_id),
    FOREIGN KEY (item_id)         REFERENCES InventoryItems(item_id),
    CONSTRAINT chk_detail_quantity CHECK (quantity > 0)
);

-- ------------------------------------------------------------
-- Basic Performance Indexes
-- ------------------------------------------------------------
CREATE INDEX idx_donor_email       ON Donors(email);
CREATE INDEX idx_donation_date     ON Donations(donation_date);
CREATE INDEX idx_item_category     ON InventoryItems(category);
CREATE INDEX idx_distribution_date ON Distributions(distribution_date);
CREATE INDEX idx_volunteer_status  ON Volunteers(status);
