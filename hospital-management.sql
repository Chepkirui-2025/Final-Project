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


-- TABLE: STAFF
-- All hospital staff (doctors, nurses, admin, etc.)
-- Self-referencing for supervisor relationship
CREATE TABLE staff (
    staff_id INT AUTO_INCREMENT PRIMARY KEY,
    employee_id VARCHAR(20) NOT NULL UNIQUE,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    date_of_birth DATE NOT NULL,
    gender ENUM('Male', 'Female', 'Other', 'Prefer not to say') NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(20) NOT NULL,
    emergency_contact VARCHAR(100),
    emergency_phone VARCHAR(20),
    address TEXT,
    role_id INT NOT NULL,
    hire_date DATE NOT NULL,
    termination_date DATE,
    salary DECIMAL(12, 2),
    supervisor_id INT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_staff_role 
        FOREIGN KEY (role_id) 
        REFERENCES staff_roles(role_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    
    -- Self-referencing foreign key for supervisor
    CONSTRAINT fk_staff_supervisor 
        FOREIGN KEY (supervisor_id) 
        REFERENCES staff(staff_id)
        ON DELETE SET NULL
        ON UPDATE CASCADE,
    
    CONSTRAINT chk_staff_email CHECK (email LIKE '%_@__%.__%'),
    CONSTRAINT chk_staff_salary CHECK (salary >= 0),
    CONSTRAINT chk_termination_date 
        CHECK (termination_date IS NULL OR termination_date >= hire_date)
);

-- TABLE: DOCTORS
-- Extended information specific to doctors
-- One-to-One relationship with Staff
CREATE TABLE doctors (
    doctor_id INT AUTO_INCREMENT PRIMARY KEY,
    staff_id INT NOT NULL UNIQUE,
    license_number VARCHAR(50) NOT NULL UNIQUE,
    specialization_id INT NOT NULL,
    qualification VARCHAR(200) NOT NULL,
    years_of_experience INT NOT NULL,
    consultation_fee DECIMAL(10, 2) NOT NULL,
    max_patients_per_day INT DEFAULT 20,
    is_accepting_patients BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_doctor_staff 
        FOREIGN KEY (staff_id) 
        REFERENCES staff(staff_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    
    CONSTRAINT fk_doctor_specialization 
        FOREIGN KEY (specialization_id) 
        REFERENCES specializations(specialization_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    
    CONSTRAINT chk_experience CHECK (years_of_experience >= 0),
    CONSTRAINT chk_consultation_fee CHECK (consultation_fee >= 0),
    CONSTRAINT chk_max_patients CHECK (max_patients_per_day > 0)
);

-- TABLE: DOCTOR_DEPARTMENTS
-- Many-to-Many: Doctors can work in multiple departments
CREATE TABLE doctor_departments (
    doctor_department_id INT AUTO_INCREMENT PRIMARY KEY,
    doctor_id INT NOT NULL,
    department_id INT NOT NULL,
    assignment_date DATE NOT NULL,
    is_primary_department BOOLEAN DEFAULT FALSE,
    
    CONSTRAINT fk_dd_doctor 
        FOREIGN KEY (doctor_id) 
        REFERENCES doctors(doctor_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    
    CONSTRAINT fk_dd_department 
        FOREIGN KEY (department_id) 
        REFERENCES departments(department_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    
    CONSTRAINT unique_doctor_department 
        UNIQUE (doctor_id, department_id)
);

-- TABLE: DOCTOR_SCHEDULE
-- Doctor availability and working hours
CREATE TABLE doctor_schedule (
    schedule_id INT AUTO_INCREMENT PRIMARY KEY,
    doctor_id INT NOT NULL,
    day_of_week ENUM('Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday') NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    is_available BOOLEAN DEFAULT TRUE,
    
    CONSTRAINT fk_schedule_doctor 
        FOREIGN KEY (doctor_id) 
        REFERENCES doctors(doctor_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    
    CONSTRAINT chk_schedule_time CHECK (end_time > start_time),
    CONSTRAINT unique_doctor_day_time 
        UNIQUE (doctor_id, day_of_week, start_time)
);


-- SECTION 2: PATIENT MANAGEMENT

-- TABLE: BLOOD_GROUPS
-- Reference table for blood types
CREATE TABLE blood_groups (
    blood_group_id INT AUTO_INCREMENT PRIMARY KEY,
    blood_type VARCHAR(5) NOT NULL UNIQUE,
    description VARCHAR(50)
);

-- TABLE: PATIENTS
-- Patient registration and demographic information
CREATE TABLE patients (
    patient_id INT AUTO_INCREMENT PRIMARY KEY,
    patient_number VARCHAR(20) NOT NULL UNIQUE,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    date_of_birth DATE NOT NULL,
    gender ENUM('Male', 'Female', 'Other', 'Prefer not to say') NOT NULL,
    blood_group_id INT,
    email VARCHAR(100),
    phone VARCHAR(20) NOT NULL,
    address TEXT,
    city VARCHAR(100),
    state VARCHAR(100),
    zip_code VARCHAR(20),
    country VARCHAR(100) DEFAULT 'USA',
    emergency_contact_name VARCHAR(100) NOT NULL,
    emergency_contact_phone VARCHAR(20) NOT NULL,
    emergency_contact_relation VARCHAR(50),
    registration_date DATE NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_patient_blood_group 
        FOREIGN KEY (blood_group_id) 
        REFERENCES blood_groups(blood_group_id)
        ON DELETE SET NULL
        ON UPDATE CASCADE,
    
    CONSTRAINT chk_patient_dob CHECK (date_of_birth < CURDATE()),
    CONSTRAINT chk_patient_email CHECK (email IS NULL OR email LIKE '%_@__%.__%')
);

-- TABLE: PATIENT_ALLERGIES
-- Track patient allergies
CREATE TABLE patient_allergies (
    allergy_id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT NOT NULL,
    allergen VARCHAR(100) NOT NULL,
    reaction TEXT,
    severity ENUM('Mild', 'Moderate', 'Severe', 'Life-threatening') NOT NULL,
    diagnosed_date DATE,
    notes TEXT,
    
    CONSTRAINT fk_allergy_patient 
        FOREIGN KEY (patient_id) 
        REFERENCES patients(patient_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- TABLE: PATIENT_MEDICAL_HISTORY
-- Patient's medical history
CREATE TABLE patient_medical_history (
    history_id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT NOT NULL,
    condition_name VARCHAR(200) NOT NULL,
    diagnosis_date DATE NOT NULL,
    status ENUM('Active', 'Resolved', 'Chronic', 'Under Treatment') NOT NULL,
    notes TEXT,
    recorded_by_staff_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_history_patient 
        FOREIGN KEY (patient_id) 
        REFERENCES patients(patient_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    
    CONSTRAINT fk_history_staff 
        FOREIGN KEY (recorded_by_staff_id) 
        REFERENCES staff(staff_id)
        ON DELETE SET NULL
        ON UPDATE CASCADE
);

-- ============================================
-- SECTION 3: APPOINTMENTS & VISITS
-- ============================================

-- TABLE: APPOINTMENT_TYPES
-- Different types of appointments
CREATE TABLE appointment_types (
    appointment_type_id INT AUTO_INCREMENT PRIMARY KEY,
    type_name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    default_duration_minutes INT NOT NULL,
    
    CONSTRAINT chk_duration CHECK (default_duration_minutes > 0)
);

-- TABLE: APPOINTMENTS
-- Patient appointments with doctors
CREATE TABLE appointments (
    appointment_id INT AUTO_INCREMENT PRIMARY KEY,
    appointment_number VARCHAR(20) NOT NULL UNIQUE,
    patient_id INT NOT NULL,
    doctor_id INT NOT NULL,
    department_id INT NOT NULL,
    appointment_type_id INT NOT NULL,
    appointment_date DATE NOT NULL,
    appointment_time TIME NOT NULL,
    duration_minutes INT NOT NULL,
    status ENUM('Scheduled', 'Confirmed', 'In Progress', 'Completed', 'Cancelled', 'No Show') DEFAULT 'Scheduled',
    reason_for_visit TEXT,
    cancellation_reason TEXT,
    scheduled_by_staff_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_appointment_patient 
        FOREIGN KEY (patient_id) 
        REFERENCES patients(patient_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    
    CONSTRAINT fk_appointment_doctor 
        FOREIGN KEY (doctor_id) 
        REFERENCES doctors(doctor_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    
    CONSTRAINT fk_appointment_department 
        FOREIGN KEY (department_id) 
        REFERENCES departments(department_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    
    CONSTRAINT fk_appointment_type 
        FOREIGN KEY (appointment_type_id) 
        REFERENCES appointment_types(appointment_type_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    
    CONSTRAINT fk_appointment_staff 
        FOREIGN KEY (scheduled_by_staff_id) 
        REFERENCES staff(staff_id)
        ON DELETE SET NULL
        ON UPDATE CASCADE,
    
    CONSTRAINT chk_appointment_duration CHECK (duration_minutes > 0)
);

-- TABLE: CONSULTATIONS
-- Detailed consultation records for completed appointments
CREATE TABLE consultations (
    consultation_id INT AUTO_INCREMENT PRIMARY KEY,
    appointment_id INT NOT NULL UNIQUE,
    chief_complaint TEXT NOT NULL,
    symptoms TEXT,
    vital_signs_temperature DECIMAL(4, 2),
    vital_signs_blood_pressure VARCHAR(20),
    vital_signs_pulse INT,
    vital_signs_respiratory_rate INT,
    vital_signs_weight DECIMAL(5, 2),
    vital_signs_height DECIMAL(5, 2),
    examination_notes TEXT,
    diagnosis TEXT,
    treatment_plan TEXT,
    follow_up_required BOOLEAN DEFAULT FALSE,
    follow_up_date DATE,
    consultation_start_time DATETIME NOT NULL,
    consultation_end_time DATETIME,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_consultation_appointment 
        FOREIGN KEY (appointment_id) 
        REFERENCES appointments(appointment_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    
    CONSTRAINT chk_consultation_time 
        CHECK (consultation_end_time IS NULL OR consultation_end_time > consultation_start_time),
    CONSTRAINT chk_temperature 
        CHECK (vital_signs_temperature IS NULL OR vital_signs_temperature BETWEEN 95 AND 110),
    CONSTRAINT chk_pulse 
        CHECK (vital_signs_pulse IS NULL OR vital_signs_pulse BETWEEN 40 AND 200),
    CONSTRAINT chk_weight 
        CHECK (vital_signs_weight IS NULL OR vital_signs_weight > 0)
);
