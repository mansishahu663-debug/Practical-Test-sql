# Hospital Management System

## Objective

A MySQL database for managing patient records, doctor schedules, appointments, billing, and medical records. It supports CRUD operations, filtering, sorting, aggregation, joins, subqueries, and advanced SQL functions.

## Database Schema

| Table | Description |
|-------|-------------|
| Patients | Patient details (name, dob, gender, contact, address, registration date) |
| Doctors | Doctor details (specialization, available days, consultation fee, experience) |
| Appointments | Appointments between patients and doctors, with status |
| Medical_Records | Diagnosis and prescription for each patient treated by a doctor |
| Billing | Invoices for appointments with amount and payment status |
| Departments | List of hospital departments |
| Doctor_Department | Mapping table between doctors and departments |

### Relationships

- Appointments.patient_id references Patients.patient_id
- Appointments.doctor_id references Doctors.doctor_id
- Medical_Records.patient_id references Patients.patient_id
- Medical_Records.doctor_id references Doctors.doctor_id
- Billing.patient_id references Patients.patient_id
- Billing.appointment_id references Appointments.appointment_id
- Doctor_Department.doctor_id references Doctors.doctor_id
- Doctor_Department.department_id references Departments.department_id

### Added Columns

The assignment tasks use data that is not in the given schema, so these columns were added:

- Doctors.experience_years (for doctor categorization)
- Appointments.admission_date and Appointments.discharge_date (for hospital stay duration)

## SQL Concepts Implemented

- CRUD operations (INSERT, UPDATE, DELETE)
- WHERE, HAVING, LIMIT
- AND, OR, NOT
- ORDER BY, GROUP BY
- Aggregate functions (SUM, AVG, MAX, MIN, COUNT)
- Primary keys and foreign keys
- INNER JOIN, LEFT JOIN, RIGHT JOIN, FULL OUTER JOIN equivalent (using UNION)
- Subqueries
- Date and time functions
- String functions
- Window functions (RANK, running and cumulative totals)
- CASE expressions

## How to Run

1. Open MySQL Workbench and connect to your MySQL server.
2. Go to File > Open SQL Script and select `hospital_management.sql`.
3. Click the Execute (lightning) button to run the whole script.
4. The database `hospital_management` will be created and all queries will run in order.
