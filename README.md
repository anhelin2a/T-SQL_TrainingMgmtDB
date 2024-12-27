# Training Management Database System
## Overview
A comprehensive SQL Server database system designed for managing training facilities. The system handles participant registrations, training sessions, memberships, trainer management, and facility bookings with robust security features and audit logging.
## Features
User Management

- Multiple user roles: General User, Participant, Trainer, Employee, Administrator
- Secure password hashing with salt
- Role-based access control
- Email-based user identification

## Core Functionalities

1. Training session management
2. Membership tracking
3. Facility/Place management
4. Review and rating system
5. Comprehensive audit logging
6. Automated data validation

## Security Features

- Encrypted stored procedures
- Password hashing with salt using SHA2_512
- Role-based access control
- Audit logging for sensitive operations

## Database Structure
### Core Tables

Participants

- Stores member information
- Includes email validation and age restrictions
- Age verification (minimum 12 years)
- Tracks modification dates


### Trainers

- Manages trainer profiles
- Specialization tracking
- Age verification (minimum 18 years)


### Trainings

- Training session management
- Capacity tracking
- Automated slot management


### Memberships

- Different membership types (1 month, 3 months, 6 months, 1 year)
- Automatic validity calculation
- Price tracking


### Places

- Facility management
- Type categorization (Studio, Pool, Field, Court)



### Support Tables

- Plans: Training plan definitions
- Reviews: Rating and feedback system
- Participant_Trainings: Training registration tracking
- Logs: Security and authentication data
- AuditLog: System activity tracking

## Technical Implementation
### Stored Procedures
User Management

- ```sp_Register_Participants```: New participant registration
- ```sp_Register_Trainers```: New trainer registration
- ```sp_Validate_Participant_OnLogIn```: Login authentication
- ```sp_Create_User```: User creation with role assignment
- ```sp_Remove_User```: User removal and cleanup

Business Logic

- ```sp_Add_Participant_To_Training```: Training registration with validation
- ```sp_Add_Membership```: Membership creation with validity calculation
- ```sp_Add_Review```: Review submission with rating validation
- ```sp_Add_Plan```: Training plan creation
- ```sp_Add_Place```: Facility registration

Views
Public Views

- ```vw_PublicTrainings```: Available training sessions
- ```vw_PublicTrainersList```: Trainer directory

User-Specific Views

- ```vw_UserMemberships```: Member's subscription details
- ```vw_UserTrainingHistory```: Training attendance history
- ```vw_TrainerSchedule```: Trainer's schedule
- ```vw_ParticipantDetails```: Detailed member information
- ```vw_TrainerPerformance```: Trainer performance metrics

### Triggers

- Automatic modification date updates
- Data validation for plans and places
- Membership validity enforcement
- Training capacity management
- Audit logging for key operations


### Indexes
Optimized for common queries:

- Email lookups
- Date-based searches
- Membership validity checks
- Training availability checks

### Security Model
Roles and Permissions

- GeneralUser

  - View public training schedule
  - View trainer list


- Participant

  - All GeneralUser permissions
  - Training registration
  - Membership purchase
  - Review submission


- Trainer

  - Schedule viewing
  - Participant list access
  - Training management


- Employee

  - Member management
  - Training scheduling
  - Facility management


- Administrator

  - Full system access
  - Audit log viewing
  - User management



### Data Protection

- Encrypted stored procedures
- Salted password hashing
- Audit logging
- Role-based access control

## Setup Instructions

Execute the script in SQL Server Management Studio
Create initial administrator account:
``` sql 
sqlCopyEXEC sp_Create_User 
    @username = 'admin_user',
    @password = 'SecurePassword123!',
    @email = 'admin@domain.com',
    @first_name = 'Admin',
    @last_name = 'User',
    @phone_number = '1234567890',
    @birth_date = '1990-01-01',
    @user_type = 'ADMIN';
```
### Best Practices

Use parameterized queries for all dynamic SQL
Regularly backup the audit log
Monitor failed login attempts
Regular password rotation for administrative accounts
Periodic review of user access levels

### Error Handling
The system uses standardized error codes and messages through the fn_GetOperationResult function:

- 0: Success
- 1-3: Warnings
- 4+: Errors

Each operation returns detailed status information for proper error handling and user feedback.
