-- Hospital Management System
-- Database: MySQL

CREATE DATABASE hospital_management;
USE hospital_management;

-- ---------------------------------------------
-- TABLE CREATION
-- ---------------------------------------------

-- 1. Patients
CREATE TABLE Patients (
    patient_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    dob DATE,
    gender VARCHAR(10),
    phone_number VARCHAR(15),
    email VARCHAR(100),
    address VARCHAR(200),
    registration_date DATE
);

-- 2. Doctors
-- experience_years is added because the doctor categorization task needs it
CREATE TABLE Doctors (
    doctor_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    specialization VARCHAR(100),
    phone_number VARCHAR(15),
    email VARCHAR(100),
    available_days VARCHAR(50),
    consultation_fee DECIMAL(10,2),
    experience_years INT
);

-- 3. Appointments
-- admission_date and discharge_date are added because the hospital stay task needs them
CREATE TABLE Appointments (
    appointment_id INT PRIMARY KEY AUTO_INCREMENT,
    patient_id INT NOT NULL,
    doctor_id INT NOT NULL,
    appointment_date DATE,
    status ENUM('Scheduled', 'Completed', 'Cancelled'),
    admission_date DATE,
    discharge_date DATE,
    FOREIGN KEY (patient_id) REFERENCES Patients(patient_id),
    FOREIGN KEY (doctor_id) REFERENCES Doctors(doctor_id)
);

-- 4. Medical_Records
CREATE TABLE Medical_Records (
    record_id INT PRIMARY KEY AUTO_INCREMENT,
    patient_id INT NOT NULL,
    doctor_id INT NOT NULL,
    diagnosis VARCHAR(200),
    prescription VARCHAR(200),
    treatment_date DATE,
    FOREIGN KEY (patient_id) REFERENCES Patients(patient_id),
    FOREIGN KEY (doctor_id) REFERENCES Doctors(doctor_id)
);

-- 5. Billing
CREATE TABLE Billing (
    invoice_id INT PRIMARY KEY AUTO_INCREMENT,
    patient_id INT NOT NULL,
    appointment_id INT NOT NULL,
    amount DECIMAL(10,2),
    payment_status ENUM('Paid', 'Pending', 'Cancelled'),
    payment_date DATE,
    FOREIGN KEY (patient_id) REFERENCES Patients(patient_id),
    FOREIGN KEY (appointment_id) REFERENCES Appointments(appointment_id)
);

-- 6. Departments
CREATE TABLE Departments (
    department_id INT PRIMARY KEY AUTO_INCREMENT,
    department_name VARCHAR(100) NOT NULL
);

-- 7. Doctor_Department (mapping table)
CREATE TABLE Doctor_Department (
    doctor_id INT NOT NULL,
    department_id INT NOT NULL,
    PRIMARY KEY (doctor_id, department_id),
    FOREIGN KEY (doctor_id) REFERENCES Doctors(doctor_id),
    FOREIGN KEY (department_id) REFERENCES Departments(department_id)
);


-- ---------------------------------------------
-- 1. CRUD OPERATIONS
-- ---------------------------------------------

-- Insert new patients
INSERT INTO Patients (name, dob, gender, phone_number, email, address, registration_date)
VALUES
('Rahul Shah', '1990-05-14', 'Male', '9876543210', 'rahul@gmail.com', 'Ahmedabad', '2026-03-10'),
('Priya Patel', '1985-09-22', 'Female', NULL, 'priya@gmail.com', 'Surat', '2025-01-15'),
('Amit Mehta', '1978-12-01', 'Male', '9123456780', 'amit@gmail.com', 'Vadodara', '2026-06-20');

-- Insert new doctors
INSERT INTO Doctors (name, specialization, phone_number, email, available_days, consultation_fee, experience_years)
VALUES
('Dr. Anil Joshi', 'Cardiology', '9000000001', 'anil@hospital.com', 'Mon,Wed,Fri', 1500.00, 18),
('Dr. Sneha Rao', 'Neurology', '9000000002', 'sneha@hospital.com', 'Tue,Thu', 1200.00, 10),
('Dr. Kiran Desai', 'Dermatology', '9000000003', 'kiran@hospital.com', 'Mon,Tue,Sat', 800.00, 3);

-- Insert new appointments
INSERT INTO Appointments (patient_id, doctor_id, appointment_date, status, admission_date, discharge_date)
VALUES
(1, 1, '2026-09-10', 'Completed', '2026-09-10', '2026-09-13'),
(2, 3, '2026-10-20', 'Scheduled', NULL, NULL),
(3, 3, '2026-02-05', 'Cancelled', NULL, NULL);

-- Update patient address
UPDATE Patients
SET address = 'Gandhinagar'
WHERE patient_id = 1;

-- Delete cancelled appointments older than 6 months
SET SQL_SAFE_UPDATES = 0;
DELETE FROM Appointments
WHERE status = 'Cancelled'
AND appointment_date < DATE_SUB(CURDATE(), INTERVAL 6 MONTH);


-- ---------------------------------------------
-- 2. SQL CLAUSES (WHERE, HAVING, LIMIT)
-- ---------------------------------------------

-- Patients registered in the last year
SELECT * FROM Patients
WHERE registration_date >= DATE_SUB(CURDATE(), INTERVAL 1 YEAR);

-- Top 5 highest paying patients
SELECT p.name, SUM(b.amount) AS total_paid
FROM Patients p
INNER JOIN Billing b ON p.patient_id = b.patient_id
WHERE b.payment_status = 'Paid'
GROUP BY p.patient_id, p.name
HAVING total_paid > 0
ORDER BY total_paid DESC
LIMIT 5;

-- Doctors who charge more than 1000
SELECT * FROM Doctors
WHERE consultation_fee > 1000;


-- ---------------------------------------------
-- 3. SQL OPERATORS (AND, OR, NOT)
-- ---------------------------------------------

-- Scheduled appointments of doctor 3
SELECT * FROM Appointments
WHERE status = 'Scheduled' AND doctor_id = 3;

-- Doctors in Cardiology or Neurology
SELECT * FROM Doctors
WHERE specialization = 'Cardiology' OR specialization = 'Neurology';

-- Patients who have not visited in the past year
SELECT * FROM Patients
WHERE patient_id NOT IN (
    SELECT patient_id FROM Appointments
    WHERE appointment_date >= DATE_SUB(CURDATE(), INTERVAL 1 YEAR)
);


-- ---------------------------------------------
-- 4. SORTING AND GROUPING (ORDER BY, GROUP BY)
-- ---------------------------------------------

-- Doctors sorted by specialization
SELECT * FROM Doctors
ORDER BY specialization;

-- Number of patients assigned to each doctor
SELECT d.name AS doctor_name, COUNT(DISTINCT a.patient_id) AS total_patients
FROM Doctors d
LEFT JOIN Appointments a ON d.doctor_id = a.doctor_id
GROUP BY d.doctor_id, d.name;

-- Total revenue per department
SELECT dep.department_name, SUM(b.amount) AS total_revenue
FROM Departments dep
INNER JOIN Doctor_Department dd ON dep.department_id = dd.department_id
INNER JOIN Appointments a ON dd.doctor_id = a.doctor_id
INNER JOIN Billing b ON a.appointment_id = b.appointment_id
WHERE b.payment_status = 'Paid'
GROUP BY dep.department_id, dep.department_name;


-- ---------------------------------------------
-- 5. AGGREGATE FUNCTIONS (SUM, AVG, MAX, MIN, COUNT)
-- ---------------------------------------------

-- Total revenue collected
SELECT SUM(amount) AS total_revenue
FROM Billing
WHERE payment_status = 'Paid';

-- Most visited doctor
SELECT d.name AS doctor_name, COUNT(a.appointment_id) AS total_visits
FROM Doctors d
INNER JOIN Appointments a ON d.doctor_id = a.doctor_id
GROUP BY d.doctor_id, d.name
ORDER BY total_visits DESC
LIMIT 1;

-- Average consultation fee
SELECT AVG(consultation_fee) AS average_fee
FROM Doctors;

-- Highest and lowest consultation fee
SELECT MAX(consultation_fee) AS highest_fee, MIN(consultation_fee) AS lowest_fee
FROM Doctors;


-- ---------------------------------------------
-- 6. PRIMARY KEY AND FOREIGN KEY RELATIONSHIPS
-- ---------------------------------------------

-- Medical_Records is linked to Patients and Doctors using patient_id and doctor_id.
-- Billing is linked to Appointments using appointment_id.
-- These keys are defined in the CREATE TABLE statements above.


-- ---------------------------------------------
-- 7. JOINS
-- ---------------------------------------------

-- INNER JOIN: doctors with their department names
SELECT d.name AS doctor_name, dep.department_name
FROM Doctors d
INNER JOIN Doctor_Department dd ON d.doctor_id = dd.doctor_id
INNER JOIN Departments dep ON dd.department_id = dep.department_id;

-- LEFT JOIN: patients who have completed appointments
SELECT p.name AS patient_name, a.appointment_id, a.appointment_date
FROM Patients p
LEFT JOIN Appointments a ON p.patient_id = a.patient_id
WHERE a.status = 'Completed';

-- RIGHT JOIN: appointments that have no payments
SELECT a.appointment_id, a.appointment_date
FROM Billing b
RIGHT JOIN Appointments a ON b.appointment_id = a.appointment_id
WHERE b.invoice_id IS NULL;

-- FULL OUTER JOIN (LEFT JOIN + UNION + RIGHT JOIN): patients who never booked an appointment
SELECT p.patient_id, p.name
FROM Patients p
LEFT JOIN Appointments a ON p.patient_id = a.patient_id
WHERE a.appointment_id IS NULL
UNION
SELECT p.patient_id, p.name
FROM Patients p
RIGHT JOIN Appointments a ON p.patient_id = a.patient_id
WHERE p.patient_id IS NULL;


-- ---------------------------------------------
-- 8. SUBQUERIES
-- ---------------------------------------------

-- Doctors who handled more than 50 patients
SELECT * FROM Doctors
WHERE doctor_id IN (
    SELECT doctor_id
    FROM Appointments
    GROUP BY doctor_id
    HAVING COUNT(DISTINCT patient_id) > 50
);

-- Patient who spent the most on treatments
SELECT * FROM Patients
WHERE patient_id = (
    SELECT patient_id
    FROM Billing
    GROUP BY patient_id
    ORDER BY SUM(amount) DESC
    LIMIT 1
);

-- Appointments where the doctor specializes in Dermatology
SELECT * FROM Appointments
WHERE doctor_id IN (
    SELECT doctor_id FROM Doctors
    WHERE specialization = 'Dermatology'
);


-- ---------------------------------------------
-- 9. DATE AND TIME FUNCTIONS
-- ---------------------------------------------

-- Visits per month
SELECT MONTH(appointment_date) AS month_number, COUNT(*) AS total_visits
FROM Appointments
GROUP BY MONTH(appointment_date)
ORDER BY month_number;

-- Hospital stay duration in days
SELECT appointment_id, DATEDIFF(discharge_date, admission_date) AS stay_days
FROM Appointments
WHERE admission_date IS NOT NULL AND discharge_date IS NOT NULL;

-- Treatment date in DD-MM-YYYY format
SELECT record_id, DATE_FORMAT(treatment_date, '%d-%m-%Y') AS treatment_date
FROM Medical_Records;


-- ---------------------------------------------
-- 10. STRING MANIPULATION FUNCTIONS
-- ---------------------------------------------

-- Patient names in uppercase
SELECT UPPER(name) AS patient_name
FROM Patients;

-- Trim whitespace from doctor names
SELECT TRIM(name) AS doctor_name
FROM Doctors;

-- Replace missing phone numbers
SELECT name,
       IF(phone_number IS NULL OR phone_number = '', 'Not Available', phone_number) AS phone_number
FROM Patients;


-- ---------------------------------------------
-- 11. WINDOW FUNCTIONS
-- ---------------------------------------------

-- Rank doctors by number of patients treated
SELECT d.name AS doctor_name,
       COUNT(DISTINCT a.patient_id) AS total_patients,
       RANK() OVER (ORDER BY COUNT(DISTINCT a.patient_id) DESC) AS doctor_rank
FROM Doctors d
LEFT JOIN Appointments a ON d.doctor_id = a.doctor_id AND a.status = 'Completed'
GROUP BY d.doctor_id, d.name;

-- Cumulative revenue per month
SELECT MONTH(payment_date) AS month_number,
       SUM(amount) AS monthly_revenue,
       SUM(SUM(amount)) OVER (ORDER BY MONTH(payment_date)) AS cumulative_revenue
FROM Billing
WHERE payment_status = 'Paid'
GROUP BY MONTH(payment_date);

-- Running total of appointments made
SELECT appointment_id, appointment_date,
       COUNT(*) OVER (ORDER BY appointment_date, appointment_id) AS running_total
FROM Appointments;


-- ---------------------------------------------
-- 12. CASE EXPRESSIONS
-- ---------------------------------------------

-- Patient risk level based on number of medical records
SELECT p.patient_id, p.name,
       COUNT(m.record_id) AS total_records,
       CASE
           WHEN COUNT(m.record_id) > 5 THEN 'High'
           WHEN COUNT(m.record_id) BETWEEN 3 AND 5 THEN 'Medium'
           ELSE 'Low'
       END AS Patient_Risk_Level
FROM Patients p
LEFT JOIN Medical_Records m ON p.patient_id = m.patient_id
GROUP BY p.patient_id, p.name;

-- Doctor category based on experience
SELECT name, experience_years,
       CASE
           WHEN experience_years > 15 THEN 'Senior'
           WHEN experience_years BETWEEN 5 AND 15 THEN 'Mid-Level'
           ELSE 'Junior'
       END AS doctor_category
FROM Doctors;
