-- COMPREHENSIVE HOSPITAL MANAGEMENT SYSTEM
-- Enterprise-level relational database for complete
-- hospital operations management


-- Create the database
DROP DATABASE IF EXISTS hospital_management_system;
CREATE DATABASE hospital_management_system;
USE hospital_management_system;

-- SECTION 1: ORGANIZATIONAL STRUCTURE

-- TABLE: DEPARTMENTS
-- Hospital departments and their hierarchy
CREATE TABLE departments (
    department_id INT AUTO_INCREMENT PRIMARY KEY,
    department_name VARCHAR(100) NOT NULL UNIQUE,
    department_code VARCHAR(20) NOT NULL UNIQUE,
    description TEXT,
    location VARCHAR(100),
    phone VARCHAR(20),
    head_doctor_id INT,
    budget DECIMAL(15, 2),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    CONSTRAINT chk_budget CHECK (budget >= 0)
);

-- TABLE: SPECIALIZATIONS
-- Medical specializations (Cardiology, Neurology, etc.)
CREATE TABLE specializations (
    specialization_id INT AUTO_INCREMENT PRIMARY KEY,
    specialization_name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    requires_certification BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- TABLE: STAFF_ROLES
-- Different staff roles in the hospital
CREATE TABLE staff_roles (
    role_id INT AUTO_INCREMENT PRIMARY KEY,
    role_name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    access_level INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT chk_access_level CHECK (access_level BETWEEN 1 AND 10)
);
