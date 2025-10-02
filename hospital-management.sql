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

-- SECTION 4: PHARMACY & MEDICATIONS

-- TABLE: MEDICATION_CATEGORIES
-- Categories of medications
CREATE TABLE medication_categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT
);

-- TABLE: MEDICATIONS
-- Hospital pharmacy inventory
CREATE TABLE medications (
    medication_id INT AUTO_INCREMENT PRIMARY KEY,
    medication_name VARCHAR(200) NOT NULL,
    generic_name VARCHAR(200),
    category_id INT NOT NULL,
    manufacturer VARCHAR(100),
    dosage_form VARCHAR(50),
    strength VARCHAR(50),
    unit_price DECIMAL(10, 2) NOT NULL,
    stock_quantity INT NOT NULL DEFAULT 0,
    reorder_level INT NOT NULL,
    storage_conditions TEXT,
    requires_prescription BOOLEAN DEFAULT TRUE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_medication_category 
        FOREIGN KEY (category_id) 
        REFERENCES medication_categories(category_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    
    CONSTRAINT chk_unit_price CHECK (unit_price >= 0),
    CONSTRAINT chk_stock_quantity CHECK (stock_quantity >= 0),
    CONSTRAINT chk_reorder_level CHECK (reorder_level >= 0)
);

-- TABLE: MEDICATION_BATCHES
-- Track medication batches with expiry dates
CREATE TABLE medication_batches (
    batch_id INT AUTO_INCREMENT PRIMARY KEY,
    medication_id INT NOT NULL,
    batch_number VARCHAR(50) NOT NULL UNIQUE,
    manufacture_date DATE NOT NULL,
    expiry_date DATE NOT NULL,
    quantity INT NOT NULL,
    supplier VARCHAR(100),
    purchase_price DECIMAL(10, 2) NOT NULL,
    received_date DATE NOT NULL,
    
    CONSTRAINT fk_batch_medication 
        FOREIGN KEY (medication_id) 
        REFERENCES medications(medication_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    
    CONSTRAINT chk_expiry_date CHECK (expiry_date > manufacture_date),
    CONSTRAINT chk_batch_quantity CHECK (quantity > 0),
    CONSTRAINT chk_purchase_price CHECK (purchase_price >= 0)
);

-- TABLE: PRESCRIPTIONS
-- Doctor prescriptions for patients
CREATE TABLE prescriptions (
    prescription_id INT AUTO_INCREMENT PRIMARY KEY,
    prescription_number VARCHAR(20) NOT NULL UNIQUE,
    consultation_id INT NOT NULL,
    patient_id INT NOT NULL,
    doctor_id INT NOT NULL,
    prescription_date DATE NOT NULL,
    status ENUM('Active', 'Dispensed', 'Partially Dispensed', 'Cancelled', 'Expired') DEFAULT 'Active',
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_prescription_consultation 
        FOREIGN KEY (consultation_id) 
        REFERENCES consultations(consultation_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    
    CONSTRAINT fk_prescription_patient 
        FOREIGN KEY (patient_id) 
        REFERENCES patients(patient_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    
    CONSTRAINT fk_prescription_doctor 
        FOREIGN KEY (doctor_id) 
        REFERENCES doctors(doctor_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

-- TABLE: PRESCRIPTION_DETAILS
-- Individual medications in a prescription
-- Many-to-Many: Prescriptions ↔ Medications
CREATE TABLE prescription_details (
    prescription_detail_id INT AUTO_INCREMENT PRIMARY KEY,
    prescription_id INT NOT NULL,
    medication_id INT NOT NULL,
    dosage VARCHAR(100) NOT NULL,
    frequency VARCHAR(100) NOT NULL,
    duration_days INT NOT NULL,
    quantity INT NOT NULL,
    instructions TEXT,
    
    CONSTRAINT fk_pd_prescription 
        FOREIGN KEY (prescription_id) 
        REFERENCES prescriptions(prescription_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    
    CONSTRAINT fk_pd_medication 
        FOREIGN KEY (medication_id) 
        REFERENCES medications(medication_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    
    CONSTRAINT chk_duration CHECK (duration_days > 0),
    CONSTRAINT chk_quantity CHECK (quantity > 0)
);

-- SECTION 5: LABORATORY & DIAGNOSTICS

-- TABLE: LAB_TEST_TYPES
-- Types of laboratory tests available
CREATE TABLE lab_test_types (
    test_type_id INT AUTO_INCREMENT PRIMARY KEY,
    test_name VARCHAR(200) NOT NULL UNIQUE,
    test_code VARCHAR(20) NOT NULL UNIQUE,
    description TEXT,
    department_id INT,
    standard_price DECIMAL(10, 2) NOT NULL,
    typical_turnaround_hours INT,
    preparation_instructions TEXT,
    
    CONSTRAINT fk_test_department 
        FOREIGN KEY (department_id) 
        REFERENCES departments(department_id)
        ON DELETE SET NULL
        ON UPDATE CASCADE,
    
    CONSTRAINT chk_test_price CHECK (standard_price >= 0),
    CONSTRAINT chk_turnaround CHECK (typical_turnaround_hours IS NULL OR typical_turnaround_hours > 0)
);

-- TABLE: LAB_TESTS
-- Laboratory test orders
CREATE TABLE lab_tests (
    lab_test_id INT AUTO_INCREMENT PRIMARY KEY,
    test_number VARCHAR(20) NOT NULL UNIQUE,
    patient_id INT NOT NULL,
    doctor_id INT NOT NULL,
    consultation_id INT,
    test_type_id INT NOT NULL,
    order_date DATETIME NOT NULL,
    sample_collected_date DATETIME,
    result_date DATETIME,
    status ENUM('Ordered', 'Sample Collected', 'In Progress', 'Completed', 'Cancelled') DEFAULT 'Ordered',
    priority ENUM('Routine', 'Urgent', 'STAT') DEFAULT 'Routine',
    results TEXT,
    normal_range VARCHAR(100),
    is_abnormal BOOLEAN DEFAULT FALSE,
    notes TEXT,
    technician_staff_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_lab_patient 
        FOREIGN KEY (patient_id) 
        REFERENCES patients(patient_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    
    CONSTRAINT fk_lab_doctor 
        FOREIGN KEY (doctor_id) 
        REFERENCES doctors(doctor_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    
    CONSTRAINT fk_lab_consultation 
        FOREIGN KEY (consultation_id) 
        REFERENCES consultations(consultation_id)
        ON DELETE SET NULL
        ON UPDATE CASCADE,
    
    CONSTRAINT fk_lab_test_type 
        FOREIGN KEY (test_type_id) 
        REFERENCES lab_test_types(test_type_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    
    CONSTRAINT fk_lab_technician 
        FOREIGN KEY (technician_staff_id) 
        REFERENCES staff(staff_id)
        ON DELETE SET NULL
        ON UPDATE CASCADE
);
-- TABLE: IMAGING_TYPES
-- Types of imaging procedures (X-ray, MRI, CT, etc.)
CREATE TABLE imaging_types (
    imaging_type_id INT AUTO_INCREMENT PRIMARY KEY,
    imaging_name VARCHAR(100) NOT NULL UNIQUE,
    imaging_code VARCHAR(20) NOT NULL UNIQUE,
    description TEXT,
    department_id INT,
    standard_price DECIMAL(10, 2) NOT NULL,
    preparation_required BOOLEAN DEFAULT FALSE,
    preparation_instructions TEXT,
    
    CONSTRAINT fk_imaging_department 
        FOREIGN KEY (department_id) 
        REFERENCES departments(department_id)
        ON DELETE SET NULL
        ON UPDATE CASCADE,
    
    CONSTRAINT chk_imaging_price CHECK (standard_price >= 0)
);

-- TABLE: IMAGING_ORDERS
-- Radiology and imaging orders
CREATE TABLE imaging_orders (
    imaging_order_id INT AUTO_INCREMENT PRIMARY KEY,
    order_number VARCHAR(20) NOT NULL UNIQUE,
    patient_id INT NOT NULL,
    doctor_id INT NOT NULL,
    consultation_id INT,
    imaging_type_id INT NOT NULL,
    order_date DATETIME NOT NULL,
    scheduled_date DATETIME,
    completed_date DATETIME,
    status ENUM('Ordered', 'Scheduled', 'In Progress', 'Completed', 'Cancelled') DEFAULT 'Ordered',
    body_part VARCHAR(100),
    clinical_indication TEXT,
    findings TEXT,
    impression TEXT,
    radiologist_staff_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_imaging_patient 
        FOREIGN KEY (patient_id) 
        REFERENCES patients(patient_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    
    CONSTRAINT fk_imaging_doctor 
        FOREIGN KEY (doctor_id) 
        REFERENCES doctors(doctor_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    
    CONSTRAINT fk_imaging_consultation 
        FOREIGN KEY (consultation_id) 
        REFERENCES consultations(consultation_id)
        ON DELETE SET NULL
        ON UPDATE CASCADE,
    
    CONSTRAINT fk_imaging_type 
        FOREIGN KEY (imaging_type_id) 
        REFERENCES imaging_types(imaging_type_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    
    CONSTRAINT fk_imaging_radiologist 
        FOREIGN KEY (radiologist_staff_id) 
        REFERENCES staff(staff_id)
        ON DELETE SET NULL
        ON UPDATE CASCADE
);

-- ============================================
-- SECTION 6: FACILITY MANAGEMENT
-- ============================================

-- TABLE: WARDS
-- Hospital wards (ICU, General Ward, etc.)
CREATE TABLE wards (
    ward_id INT AUTO_INCREMENT PRIMARY KEY,
    ward_name VARCHAR(100) NOT NULL UNIQUE,
    ward_code VARCHAR(20) NOT NULL UNIQUE,
    department_id INT NOT NULL,
    floor_number INT,
    total_beds INT NOT NULL,
    available_beds INT NOT NULL,
    ward_type ENUM('General', 'Private', 'Semi-Private', 'ICU', 'Emergency', 'Pediatric', 'Maternity') NOT NULL,
    charge_per_day DECIMAL(10, 2) NOT NULL,
    
    CONSTRAINT fk_ward_department 
        FOREIGN KEY (department_id) 
        REFERENCES departments(department_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    
    CONSTRAINT chk_total_beds CHECK (total_beds > 0),
    CONSTRAINT chk_available_beds CHECK (available_beds >= 0 AND available_beds <= total_beds),
    CONSTRAINT chk_ward_charge CHECK (charge_per_day >= 0)
);

-- TABLE: BEDS
-- Individual hospital beds
CREATE TABLE beds (
    bed_id INT AUTO_INCREMENT PRIMARY KEY,
    bed_number VARCHAR(20) NOT NULL UNIQUE,
    ward_id INT NOT NULL,
    bed_type ENUM('Standard', 'ICU', 'Electric', 'Pediatric', 'Maternity') NOT NULL,
    is_available BOOLEAN DEFAULT TRUE,
    is_operational BOOLEAN DEFAULT TRUE,
    last_maintenance_date DATE,
    
    CONSTRAINT fk_bed_ward 
        FOREIGN KEY (ward_id) 
        REFERENCES wards(ward_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- TABLE: ADMISSIONS
-- Patient hospital admissions
CREATE TABLE admissions (
    admission_id INT AUTO_INCREMENT PRIMARY KEY,
    admission_number VARCHAR(20) NOT NULL UNIQUE,
    patient_id INT NOT NULL,
    doctor_id INT NOT NULL,
    department_id INT NOT NULL,
    bed_id INT NOT NULL,
    admission_date DATETIME NOT NULL,
    discharge_date DATETIME,
    admission_type ENUM('Emergency', 'Elective', 'Transfer', 'Observation') NOT NULL,
    admission_reason TEXT NOT NULL,
    status ENUM('Admitted', 'Under Treatment', 'Discharged', 'Transferred', 'Deceased') DEFAULT 'Admitted',
    discharge_summary TEXT,
    discharge_instructions TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_admission_patient 
        FOREIGN KEY (patient_id) 
        REFERENCES patients(patient_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    
    CONSTRAINT fk_admission_doctor 
        FOREIGN KEY (doctor_id) 
        REFERENCES doctors(doctor_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    
    CONSTRAINT fk_admission_department 
        FOREIGN KEY (department_id) 
        REFERENCES departments(department_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    
    CONSTRAINT fk_admission_bed 
        FOREIGN KEY (bed_id) 
        REFERENCES beds(bed_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    
    CONSTRAINT chk_discharge_date 
        CHECK (discharge_date IS NULL OR discharge_date >= admission_date)
);

-- ============================================
-- SECTION 7: BILLING & INSURANCE
-- ============================================

-- TABLE: INSURANCE_PROVIDERS
-- Insurance companies
CREATE TABLE insurance_providers (
    provider_id INT AUTO_INCREMENT PRIMARY KEY,
    provider_name VARCHAR(200) NOT NULL UNIQUE,
    provider_code VARCHAR(20) NOT NULL UNIQUE,
    contact_person VARCHAR(100),
    phone VARCHAR(20),
    email VARCHAR(100),
    address TEXT,
    payment_terms_days INT DEFAULT 30,
    is_active BOOLEAN DEFAULT TRUE,
    
    CONSTRAINT chk_payment_terms CHECK (payment_terms_days > 0)
);

-- TABLE: PATIENT_INSURANCE
-- Patient insurance information
CREATE TABLE patient_insurance (
    patient_insurance_id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT NOT NULL,
    provider_id INT NOT NULL,
    policy_number VARCHAR(50) NOT NULL,
    group_number VARCHAR(50),
    policy_holder_name VARCHAR(100) NOT NULL,
    policy_holder_relation VARCHAR(50),
    coverage_start_date DATE NOT NULL,
    coverage_end_date DATE,
    is_primary BOOLEAN DEFAULT TRUE,
    is_active BOOLEAN DEFAULT TRUE,
    
    CONSTRAINT fk_pi_patient 
        FOREIGN KEY (patient_id) 
        REFERENCES patients(patient_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    
    CONSTRAINT fk_pi_provider 
        FOREIGN KEY (provider_id) 
        REFERENCES insurance_providers(provider_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    
    CONSTRAINT chk_coverage_dates 
        CHECK (coverage_end_date IS NULL OR coverage_end_date >= coverage_start_date),
    
    CONSTRAINT unique_patient_policy 
        UNIQUE (patient_id, provider_id, policy_number)
);

-- TABLE: BILLING_CATEGORIES
-- Categories for billing items
CREATE TABLE billing_categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT
);

-- TABLE: INVOICES
-- Patient invoices
CREATE TABLE invoices (
    invoice_id INT AUTO_INCREMENT PRIMARY KEY,
    invoice_number VARCHAR(20) NOT NULL UNIQUE,
    patient_id INT NOT NULL,
    appointment_id INT,
    admission_id INT,
    invoice_date DATE NOT NULL,
    due_date DATE NOT NULL,
    subtotal DECIMAL(12, 2) NOT NULL,
    tax_amount DECIMAL(10, 2) DEFAULT 0.00,
    discount_amount DECIMAL(10, 2) DEFAULT 0.00,
    total_amount DECIMAL(12, 2) NOT NULL,
    paid_amount DECIMAL(12, 2) DEFAULT 0.00,
    balance_amount DECIMAL(12, 2) NOT NULL,
    status ENUM('Draft', 'Pending', 'Partially Paid', 'Paid', 'Overdue', 'Cancelled') DEFAULT 'Pending',
    notes TEXT,
    created_by_staff_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_invoice_patient 
        FOREIGN KEY (patient_id) 
        REFERENCES patients(patient_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    
    CONSTRAINT fk_invoice_appointment 
        FOREIGN KEY (appointment_id) 
        REFERENCES appointments(appointment_id)
        ON DELETE SET NULL
        ON UPDATE CASCADE,
    
    CONSTRAINT fk_invoice_admission 
        FOREIGN KEY (admission_id) 
        REFERENCES admissions(admission_id)
        ON DELETE SET NULL
        ON UPDATE CASCADE,
    
    CONSTRAINT fk_invoice_staff 
        FOREIGN KEY (created_by_staff_id) 
        REFERENCES staff(staff_id)
        ON DELETE SET NULL
        ON UPDATE CASCADE,
    
    CONSTRAINT chk_due_date CHECK (due_date >= invoice_date),
    CONSTRAINT chk_subtotal CHECK (subtotal >= 0),
    CONSTRAINT chk_tax CHECK (tax_amount >= 0),
    CONSTRAINT chk_discount CHECK (discount_amount >= 0),
    CONSTRAINT chk_total CHECK (total_amount >= 0),
    CONSTRAINT chk_paid CHECK (paid_amount >= 0),
    CONSTRAINT chk_balance CHECK (balance_amount >= 0)
);

-- TABLE: INVOICE_ITEMS
-- Line items on invoices
CREATE TABLE invoice_items (
    invoice_item_id INT AUTO_INCREMENT PRIMARY KEY,
    invoice_id INT NOT NULL,
    category_id INT NOT NULL,
    description VARCHAR(500) NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(10, 2) NOT NULL,
    total_price DECIMAL(12, 2) NOT NULL,
    
    CONSTRAINT fk_item_invoice 
        FOREIGN KEY (invoice_id) 
        REFERENCES invoices(invoice_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    
    CONSTRAINT fk_item_category 
        FOREIGN KEY (category_id) 
        REFERENCES billing_categories(category_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    
    CONSTRAINT chk_item_quantity CHECK (quantity > 0),
    CONSTRAINT chk_item_unit_price CHECK (unit_price >= 0),
    CONSTRAINT chk_item_total_price CHECK (total_price >= 0)
);

-- TABLE: PAYMENTS
-- Payment records
CREATE TABLE payments (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    payment_number VARCHAR(20) NOT NULL UNIQUE,
    invoice_id INT NOT NULL,
    patient_id INT NOT NULL,
    payment_date DATETIME NOT NULL,
    amount DECIMAL(12, 2) NOT NULL,
    payment_method ENUM('Cash', 'Credit Card', 'Debit Card', 'Check', 'Bank Transfer', 'Insurance', 'Other') NOT NULL,
    transaction_reference VARCHAR(100),
    status ENUM('Pending', 'Completed', 'Failed', 'Refunded') DEFAULT 'Completed',
    notes TEXT,
    received_by_staff_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_payment_invoice 
        FOREIGN KEY (invoice_id) 
        REFERENCES invoices(invoice_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    
    CONSTRAINT fk_payment_patient 
        FOREIGN KEY (patient_id) 
        REFERENCES patients(patient_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    
    CONSTRAINT fk_payment_staff 
        FOREIGN KEY (received_by_staff_id) 
        REFERENCES staff(staff_id)
        ON DELETE SET NULL
        ON UPDATE CASCADE,
    
    CONSTRAINT chk_payment_amount CHECK (amount > 0)
);

-- TABLE: INSURANCE_CLAIMS
-- Insurance claim submissions
CREATE TABLE insurance_claims (
    claim_id INT AUTO_INCREMENT PRIMARY KEY,
    claim_number VARCHAR(20) NOT NULL UNIQUE,
    invoice_id INT NOT NULL,
    patient_insurance_id INT NOT NULL,
    claim_date DATE NOT NULL,
    claim_amount DECIMAL(12, 2) NOT NULL,
    approved_amount DECIMAL(12, 2),
    status ENUM('Submitted', 'Under Review', 'Approved', 'Partially Approved', 'Rejected', 'Paid') DEFAULT 'Submitted',
    submission_date DATE NOT NULL,
    review_date DATE,
    payment_date DATE,
    rejection_reason TEXT,
    notes TEXT,
    processed_by_staff_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_claim_invoice 
        FOREIGN KEY (invoice_id) 
        REFERENCES invoices(invoice_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    
    CONSTRAINT fk_claim_insurance 
        FOREIGN KEY (patient_insurance_id) 
        REFERENCES patient_insurance(patient_insurance_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    
    CONSTRAINT fk_claim_staff 
        FOREIGN KEY (processed_by_staff_id) 
        REFERENCES staff(staff_id)
        ON DELETE SET NULL
        ON UPDATE CASCADE,
    
    CONSTRAINT chk_claim_amount CHECK (claim_amount > 0),
    CONSTRAINT chk_approved_amount CHECK (approved_amount IS NULL OR approved_amount >= 0)
);
