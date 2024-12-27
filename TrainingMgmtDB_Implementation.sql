/* 

FILE STRUCTURE:
	A - Creating database and tables
	B - Triggers
	C - Constraints
	D - Types
	E - Functions
	F - Procedures
	G - Views and indexes
	H - Roles and access
	I - Data insert and testing
	

*/


/* ************************************************************************************************************************************************************* */
-- A - create database and its structure
/* ************************************************************************************************************************************************************* */


-- create database

IF DB_ID('TrainingMgntBD') IS NOT NULL
BEGIN
	DROP DATABASE TrainingMgmtDB
END

GO

IF DB_ID('TrainingMgmtDB') IS NULL
BEGIN
	CREATE DATABASE TrainingMgmtDB
END

USE TrainingMgmtDB 

-- create tables
IF NOT EXISTS(SELECT * FROM dbo.sysobjects WHERE ID = OBJECT_ID(N'dbo. Participants') AND OBJECTPROPERTY(ID, N'IsTable') = 1)
BEGIN
	CREATE TABLE  Participants(
		 participantID		INT PRIMARY KEY IDENTITY(1, 1),
		 first_name			nvarchar(50)	NOT NULL,
		 last_name			nvarchar(50)	NOT NULL,
		 email				nvarchar(50)	NOT NULL,
		 phone_number		nvarchar(15)	NOT NULL,
		 birth_date			date			NOT NULL,
		 modified_date		datetime		DEFAULT (GETDATE()),
		 rowguid			UNIQUEIDENTIFIER DEFAULT NEWID() UNIQUE NOT NULL
	)
END

-- add mail confirmation of joining functionality


IF NOT EXISTS(SELECT * FROM dbo.sysobjects WHERE ID = OBJECT_ID(N'dbo.Plans') AND OBJECTPROPERTY(ID, N'IsTable') = 1)
BEGIN 
	CREATE TABLE Plans(
		planID				INT PRIMARY KEY IDENTITY(1, 1),
		type				nvarchar(50)	 NOT NULL,
		difficulty_level	int				 NOT NULL,
		description			nvarchar(500)	 NOT NULL,
		modified_date		datetime		 DEFAULT (GETDATE()),
		rowguid				UNIQUEIDENTIFIER DEFAULT NEWID() UNIQUE NOT NULL
	)
END



IF NOT EXISTS(SELECT * FROM dbo.sysobjects WHERE ID = OBJECT_ID(N'dbo.Trainers') AND OBJECTPROPERTY(ID, N'IsTable') = 1)
BEGIN
	CREATE TABLE Trainers(
		trainerID		INT PRIMARY KEY IDENTITY(1, 1),
		first_name		nvarchar(50)	 NOT NULL,
		last_name		nvarchar(50)	 NOT NULL,
		email			nvarchar(50)	 NOT NULL,
		phone_number	nvarchar(15)	 NOT NULL,
		specialization	nvarchar(100)	 NOT NULL,
		birth_date		date			 NOT NULL,
		modified_date	datetime		 DEFAULT (GETDATE()),
		rowguid			UNIQUEIDENTIFIER DEFAULT NEWID() UNIQUE NOT NULL
	)
END

-- add mail confirmation of joining functionality


IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE ID = OBJECT_ID(N'dbo.Places') AND OBJECTPROPERTY(ID, N'IsTable') =1)
BEGIN
	CREATE TABLE Places(
		placeID			INT PRIMARY KEY IDENTITY(1, 1),
		name			nvarchar(50)	 NOT NULL,
		address			nvarchar(100)	 NOT NULL,
		type			nvarchar(50)	 NOT NULL,
		modified_date	datetime		 DEFAULT (GETDATE()),
		rowguid			UNIQUEIDENTIFIER DEFAULT NEWID() UNIQUE NOT NULL
	)
END



IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE ID = OBJECT_ID(N'dbo.Trainings') AND OBJECTPROPERTY(ID, N'IsTable') = 1)
BEGIN
	CREATE TABLE Trainings(
		trainingID			INT PRIMARY KEY IDENTITY(1, 1),
		planID				INT FOREIGN KEY REFERENCES Plans(planID)		ON UPDATE CASCADE,
		placeID				INT FOREIGN KEY REFERENCES Places(placeID)		ON UPDATE CASCADE,
		trainerID			INT FOREIGN KEY REFERENCES Trainers(trainerID)	ON UPDATE CASCADE,
		date				datetime		 NOT NULL,
		type				nvarchar(50)	 NOT NULL,
		max_capacity		tinyint			 NOT NULL,
		available_slots		tinyint			 NOT NULL,
		modified_date		datetime		 DEFAULT (GETDATE()),
		rowguid				UNIQUEIDENTIFIER DEFAULT NEWID() UNIQUE NOT NULL
	)
END


IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE ID = OBJECT_ID(N'dbo.Participant_Trainings') AND OBJECTPROPERTY(ID, N'IsTable') =1)
BEGIN
	CREATE TABLE Participant_Trainings(
		ptID					INT PRIMARY KEY IDENTITY(1, 1),
		trainingID				INT FOREIGN KEY REFERENCES Trainings(trainingID)		ON UPDATE CASCADE,
		participantID			INT FOREIGN KEY REFERENCES Participants(participantID)	ON UPDATE CASCADE,
		registration_date		date DEFAULT (GETDATE()) NOT NULL,  -- please work here
		modified_date			datetime		 DEFAULT (GETDATE()),
		rowguid					UNIQUEIDENTIFIER DEFAULT NEWID() UNIQUE NOT NULL
	)
END



IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE ID = OBJECT_ID(N'dbo.Reviews') AND OBJECTPROPERTY(ID, N'IsTable') = 1)
BEGIN 
	CREATE TABLE Reviews(
		reviewID			INT PRIMARY KEY IDENTITY(1, 1),
		trainingID			INT FOREIGN KEY REFERENCES Trainings(trainingID)		ON UPDATE CASCADE,
		participantID		INT FOREIGN KEY REFERENCES Participants(participantID)	ON UPDATE CASCADE,
		rating				tinyint			 NOT NULL,
		comment				NVARCHAR(500),
		modified_date		datetime		 DEFAULT (GETDATE()),
		rowguid				UNIQUEIDENTIFIER DEFAULT NEWID() UNIQUE NOT NULL
	)
END



IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE ID = OBJECT_ID(N'dbo.Memberships') AND OBJECTPROPERTY(ID, N'IsTable') = 1)
BEGIN
	CREATE TABLE Memberships(
		membershipID		INT PRIMARY KEY IDENTITY(1, 1),
		participantID		INT FOREIGN KEY REFERENCES Participants(participantID) ON UPDATE CASCADE,
		type				nvarchar(50)				NOT NULL,
		purchase_date		date DEFAULT (GETDATE())	NOT NULL,
		validity_date		date						NOT NULL,
		price				smallmoney					NOT NULL,
		modified_date		datetime		 DEFAULT (GETDATE()),
		rowguid				UNIQUEIDENTIFIER DEFAULT NEWID() UNIQUE NOT NULL
	)
END


IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE ID = OBJECT_ID(N'Logs') AND OBJECTPROPERTY(ID, N'IsTable') = 1)
BEGIN
	CREATE TABLE Logs(
		logID				INT PRIMARY KEY IDENTITY(1, 1),
		userGUID			UNIQUEIDENTIFIER FOREIGN KEY REFERENCES Participants(rowguid) ON UPDATE CASCADE,
		password			varbinary(64)	 NOT NULL,
		salt				varbinary(32)	 NOT NULL,
		modified_date		datetime		 DEFAULT (GETDATE()),
		rowguid				UNIQUEIDENTIFIER DEFAULT NEWID() UNIQUE NOT NULL
	)
END



IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE ID = OBJECT_ID(N'AuditLog') AND OBJECTPROPERTY(ID, N'IsTable') = 1)
BEGIN
	CREATE TABLE AuditLog (
    auditID				INT PRIMARY KEY IDENTITY(1,1),
    tableModified		NVARCHAR(50),
    actionType			NVARCHAR(20),
    modifiedBy			UNIQUEIDENTIFIER,
    modifiedDate		DATETIME DEFAULT GETDATE(),
    oldValue			NVARCHAR(MAX),
    newValue			NVARCHAR(MAX),
	modified_date		datetime		 DEFAULT (GETDATE()),
	rowguid				UNIQUEIDENTIFIER DEFAULT NEWID() UNIQUE NOT NULL
);
END

/* ************************************************************************************************************************************************************* */
-- B - triggers
/* ************************************************************************************************************************************************************* */

-- drop triggers if already exist
DROP TRIGGER IF EXISTS trg_UpdateModifiedDate_Logs;
DROP TRIGGER IF EXISTS trg_UpdateModifiedDate_Memberships;
DROP TRIGGER IF EXISTS trg_UpdateModifiedDate_Participant_Trainings;
DROP TRIGGER IF EXISTS trg_UpdateModifiedDate_Participants;
DROP TRIGGER IF EXISTS trg_UpdateModifiedDate_Places;
DROP TRIGGER IF EXISTS trg_UpdateModifiedDate_Plans;
DROP TRIGGER IF EXISTS trg_UpdateModifiedDate_Reviews;
DROP TRIGGER IF EXISTS trg_UpdateModifiedDate_Trainers;
DROP TRIGGER IF EXISTS trg_UpdateModifiedDate_Trainings;
DROP TRIGGER IF EXISTS trg_Validate_Places;
DROP TRIGGER IF EXISTS trg_Validate_Plans;
DROP TRIGGER IF EXISTS trg_Validate_Trainings;
DROP TRIGGER IF EXISTS trg_Validate_Memberships;

----------------------------------------------------------------------------------------------------------------------------------------------------------------


-- automated trigger generation for each table in database to update 'modified_date' column
GO
DECLARE @SQL NVARCHAR(MAX) = '';
DECLARE @TableName NVARCHAR(255), @PrimaryKeyColumn NVARCHAR(255);

DECLARE TableCursor CURSOR FOR
SELECT t.TABLE_NAME, k.COLUMN_NAME
FROM INFORMATION_SCHEMA.TABLES t
INNER JOIN INFORMATION_SCHEMA.COLUMNS c ON t.TABLE_NAME = c.TABLE_NAME
LEFT JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE k ON t.TABLE_NAME = k.TABLE_NAME
WHERE c.COLUMN_NAME = 'modified_date' 
  AND t.TABLE_TYPE = 'BASE TABLE'; 

OPEN TableCursor;
FETCH NEXT FROM TableCursor INTO @TableName, @PrimaryKeyColumn;

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @SQL += '
     EXEC(''CREATE TRIGGER trg_UpdateModifiedDate_' + @TableName + '
        ON ' + @TableName + '
        AFTER UPDATE
        AS
        BEGIN
            SET NOCOUNT ON;
            UPDATE ' + @TableName + '
            SET modified_date = GETDATE()
            FROM ' + @TableName + ' t
            INNER JOIN inserted i ON t.' + @PrimaryKeyColumn + ' = i.' + @PrimaryKeyColumn + ';
        END;'');
    ';

    FETCH NEXT FROM TableCursor INTO @TableName, @PrimaryKeyColumn;
END

CLOSE TableCursor;
DEALLOCATE TableCursor;

PRINT @SQL
EXEC sp_executesql @SQL;

GO
-- test on data
insert into Participants(first_name, last_name, email, phone_number, birth_date) values ('test_name', 'test_surname', '----', '----', '2000-01-01')
select * from Participants -- before trigger

update Participants
set last_name = 'test_surname_updated' where participantID = 2

select * from Participants -- after trigger, modified_date should be updated

GO
-- additional triggers
CREATE TRIGGER trg_Validate_Plans
ON Plans
AFTER INSERT, UPDATE
AS
BEGIN
    -- check if difficulty_level is between 1 and 5
    IF EXISTS (
        SELECT 1
        FROM inserted
        WHERE difficulty_level NOT BETWEEN 1 AND 5
    )
    BEGIN
        RAISERROR('Difficulty level must be between 1 and 5.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END

    -- check if type is one of the allowed options
    IF EXISTS (
        SELECT 1
        FROM inserted
        WHERE type NOT IN ('Strength', 'Cardio', 'Yoga', 'Pilates', 'HIIT')
    )
    BEGIN
        RAISERROR('Invalid type. Allowed values: Strength, Cardio, Yoga, Pilates, HIIT.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END
END;
GO


CREATE TRIGGER trg_Validate_Places
ON Places
AFTER INSERT, UPDATE
AS BEGIN
	-- check if type is one of the allowed options
	IF EXISTS (
		SELECT 1
		FROM inserted
		WHERE type NOT IN ('Studio', 'Pool', 'Field', 'Court')
	)
	BEGIN
		RAISERROR('Invalid type. Allowed values: Studio, Pool, Field, Court.', 16, 1);
		ROLLBACK TRANSACTION;
		RETURN;
	END
END;
GO


CREATE TRIGGER trg_Validate_Trainings
ON Trainings
AFTER INSERT, UPDATE
AS BEGIN
	IF EXISTS (
		SELECT 1
		FROM inserted
		WHERE available_slots > max_capacity
	)
	BEGIN
		RAISERROR('Available slots cannot exceed training capacity', 16, 1);
		ROLLBACK TRANSACTION;
		RETURN;
	END
END
GO



CREATE TRIGGER trg_Validate_Memberships
ON Memberships
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @errorMessage NVARCHAR(255);

    -- insert valid rows with automatic calculation of validity_date
    INSERT INTO Memberships (
        participantID, 
        type, 
        purchase_date, 
        validity_date, 
        price, 
        modified_date, 
        rowguid
    )
    SELECT 
        i.participantID,
        i.type,
        i.purchase_date,
        -- calculate validity_date based on type
        CASE 
            WHEN i.type = '1 month' THEN DATEADD(MONTH, 1, i.purchase_date)
            WHEN i.type = '3 months' THEN DATEADD(MONTH, 3, i.purchase_date)
            WHEN i.type = '6 months' THEN DATEADD(MONTH, 6, i.purchase_date)
            WHEN i.type = '1 year' THEN DATEADD(YEAR, 1, i.purchase_date)
            ELSE NULL -- invalid type
        END,
        i.price,
        i.modified_date,
        i.rowguid
    FROM inserted i
    WHERE i.type IN ('1 month', '3 months', '6 months', '1 year');

    IF EXISTS (
        SELECT 1
        FROM inserted i
        WHERE i.type NOT IN ('1 month', '3 months', '6 months', '1 year')
    )
    BEGIN
        SET @errorMessage = 'Invalid membership type. Allowed types: 1 month, 3 months, 6 months, 1 year.';

        RAISERROR(@errorMessage, 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END
END
GO


-- Create triggers for key tables
-- Participants Audit Trigger
CREATE OR ALTER TRIGGER trg_Audit_Participants
ON Participants
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @result TINYINT;

    -- Handle INSERT
    IF EXISTS (SELECT * FROM inserted) AND NOT EXISTS (SELECT * FROM deleted)
    BEGIN
        INSERT INTO AuditLog (
            tableModified,
            actionType,
            modifiedBy,
            oldValue,
            newValue
        )
        SELECT 
            'Participants',
            'INSERT',
            i.rowguid,
            NULL,
            (SELECT i.* FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)
        FROM inserted i;
    END

    -- Handle UPDATE
    IF EXISTS (SELECT * FROM inserted) AND EXISTS (SELECT * FROM deleted)
    BEGIN
        INSERT INTO AuditLog (
            tableModified,
            actionType,
            modifiedBy,
            oldValue,
            newValue
        )
        SELECT 
            'Participants',
            'UPDATE',
            i.rowguid,
            (SELECT d.* FOR JSON PATH, WITHOUT_ARRAY_WRAPPER),
            (SELECT i.* FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)
        FROM deleted d
        JOIN inserted i ON d.participantID = i.participantID;
    END

    -- Handle DELETE
    IF EXISTS (SELECT * FROM deleted) AND NOT EXISTS (SELECT * FROM inserted)
    BEGIN
        INSERT INTO AuditLog (
            tableModified,
            actionType,
            modifiedBy,
            oldValue,
            newValue
        )
        SELECT 
            'Participants',
            'DELETE',
            d.rowguid,
            (SELECT d.* FOR JSON PATH, WITHOUT_ARRAY_WRAPPER),
            NULL
        FROM deleted d;
    END
END;
GO

-- audit triggers

CREATE OR ALTER TRIGGER trg_Audit_Trainings
ON Trainings
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @result TINYINT;

	-- handle INSERT
    IF EXISTS (SELECT * FROM inserted) AND NOT EXISTS (SELECT * FROM deleted)
    BEGIN
        INSERT INTO AuditLog (tableModified, actionType, modifiedBy, oldValue, newValue)
        SELECT 'Trainings','INSERT', i.rowguid, NULL,
            (SELECT i.* FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)
        FROM inserted i;
    END

    -- handle UPDATE
    IF EXISTS (SELECT * FROM inserted) AND EXISTS (SELECT * FROM deleted)
    BEGIN
        INSERT INTO AuditLog (tableModified, actionType, modifiedBy,oldValue,newValue)
        SELECT 'Trainings', 'UPDATE', i.rowguid,
            (SELECT d.* FOR JSON PATH, WITHOUT_ARRAY_WRAPPER),
            (SELECT i.* FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)
        FROM deleted d
        JOIN inserted i ON d.trainingID = i.trainingID;
    END

    -- handle DELETE
    IF EXISTS (SELECT * FROM deleted) AND NOT EXISTS (SELECT * FROM inserted)
    BEGIN
        INSERT INTO AuditLog (tableModified, actionType, modifiedBy, oldValue, newValue)
        SELECT 'Trainings', 'DELETE', d.rowguid,
            (SELECT d.* FOR JSON PATH, WITHOUT_ARRAY_WRAPPER), NULL
        FROM deleted d;
    END
END;
GO


-- check if triggers generated successfully
SELECT t.name AS Table_Name, tr.name AS Trigger_Name
FROM sys.tables t
INNER JOIN sys.triggers tr ON t.object_id = tr.parent_id
WHERE tr.name LIKE 'trg_%';


/* ************************************************************************************************************************************************************* */
-- C - constraints
/* ************************************************************************************************************************************************************* */


-- drop constraints if already exist
ALTER TABLE Participants DROP CONSTRAINT CHK_Participants_Age;
ALTER TABLE Trainers DROP CONSTRAINT CHK_Trainers_Age;
ALTER TABLE Reviews DROP CONSTRAINT CHK_Rating
ALTER TABLE Participants DROP CONSTRAINT UQ_Participant_Email
ALTER TABLE Trainers DROP CONSTRAINT UQ_Trainer_Email
----------------------------------------------------------------------------------------------------------------------------------------------------------------

ALTER TABLE Reviews ADD CONSTRAINT CHK_Rating CHECK (rating BETWEEN 1 AND 5);
ALTER TABLE Participants ADD CONSTRAINT UQ_Participant_Email UNIQUE (email);
ALTER TABLE Trainers ADD CONSTRAINT UQ_Trainer_Email UNIQUE (email);

GO
ALTER TABLE Participants
ADD CONSTRAINT CHK_Participants_Age
CHECK (DATEDIFF(YEAR, birth_date, GETDATE()) >= 12)

-- testing check constraint
INSERT INTO Participants(first_name, last_name, email, phone_number, birth_date) VALUES ('test_name', 'test_surname', '----', '----', GETDATE())

GO

ALTER TABLE Trainers
ADD CONSTRAINT CHK_Trainers_Age
CHECK (DATEDIFF(YEAR, birth_date, GETDATE()) >= 18)

-- testing check constraint
INSERT INTO Trainers(first_name, last_name, email, phone_number,specialization,  birth_date) VALUES ('test_name', 'test_surname','----', '----', '----', GETDATE())
GO


/* ************************************************************************************************************************************************************* */
-- D - types
/* ************************************************************************************************************************************************************* */
GO
-- custom type for operation results
IF EXISTS (SELECT * FROM sys.types WHERE name = 'OperationResult')
    DROP TYPE OperationResult;
GO

CREATE TYPE OperationResult AS TABLE(
    ResultCode INT,
    Severity VARCHAR(20),
    Message VARCHAR(200)
);
GO

/* ************************************************************************************************************************************************************* */
-- E - functions
/* ************************************************************************************************************************************************************* */

-- function to standardize operation results
CREATE OR ALTER FUNCTION fn_GetOperationResult(
    @procedureName VARCHAR(100),
    @resultCode INT
) RETURNS @Result TABLE(
    ResultCode INT,
    Severity VARCHAR(20),
    Message VARCHAR(200)
)
AS
BEGIN
    INSERT INTO @Result
    SELECT 
        @resultCode,
        CASE 
            WHEN @resultCode = 0 THEN 'Success'
            WHEN @resultCode BETWEEN 1 AND 3 THEN 'Warning'
            ELSE 'Error'
        END,
        CASE 
            -- generic results
            WHEN @resultCode = 0 THEN 'Operation completed successfully'
            WHEN @resultCode = 1 AND @procedureName LIKE '%Register%' THEN 'User already exists'
            WHEN @resultCode = 1 AND @procedureName = 'sp_Add_Participant_To_Training' THEN 'Participant does not exist'
            
            -- login specific results
            WHEN @procedureName = 'sp_Validate_Participant_OnLogIn' THEN
                CASE @resultCode
                    WHEN 1 THEN 'User does not exist'
                    WHEN 2 THEN 'No password set for this user'
                    WHEN 3 THEN 'Incorrect password'
                    ELSE 'Unknown login error'
                END

            -- training registration specific results
            WHEN @procedureName = 'sp_Add_Participant_To_Training' THEN
                CASE @resultCode
                    WHEN 2 THEN 'Training does not exist'
                    WHEN 3 THEN 'Already registered for this training'
                    WHEN 4 THEN 'No available slots'
                    WHEN 5 THEN 'No valid membership for training date'
                    WHEN 6 THEN 'Transaction error occurred'
                    ELSE 'Unknown training registration error'
                END

            -- review specific results
            WHEN @procedureName = 'sp_Add_Review' THEN
                CASE @resultCode
                    WHEN 1 THEN 'Invalid rating value. Must be between 1 and 5'
                    ELSE 'Unknown review error'
                END

            -- membership specific results
            WHEN @procedureName = 'sp_Add_Membership' THEN
                CASE @resultCode
                    WHEN 1 THEN 'Invalid membership type'
                    ELSE 'Unknown membership error'
                END

            -- plan specific results
            WHEN @procedureName = 'sp_Add_Plan' THEN
                CASE @resultCode
                    WHEN 1 THEN 'Invalid difficulty level. Must be between 1 and 5'
                    ELSE 'Unknown plan error'
                END

			WHEN @procedureName LIKE '%Audit%' THEN
                CASE @resultCode
                    WHEN 0 THEN 'Audit record created successfully'
                    WHEN 1 THEN 'Failed to create audit record'
                    WHEN 2 THEN 'Invalid audit parameters'
                    ELSE 'Unknown audit error'
                END
            -- default case
            ELSE 'Unspecified error'
        END;

    RETURN;
END;

/* ************************************************************************************************************************************************************* */
-- F - procedures
/* ************************************************************************************************************************************************************* */
GO
CREATE OR ALTER PROCEDURE sp_Hash_Password
	@password nvarchar(50),
    @hashed_password BINARY(64) OUTPUT,
    @salt BINARY(32) OUTPUT
	WITH ENCRYPTION
AS
BEGIN
    SET NOCOUNT ON;
    SET @salt = CRYPT_GEN_RANDOM(32);

    DECLARE @combined NVARCHAR(355); 
    SET @combined = @password + CONVERT(NVARCHAR(100), @salt, 1);

    SET @hashed_password = HASHBYTES('SHA2_512', @combined);
END;
GO


GO
CREATE OR ALTER PROCEDURE sp_Check_User -- checks if user already exists
	@first_name nvarchar(50),
	@last_name nvarchar(50),
	@email nvarchar(50),
	@result tinyint OUTPUT
	WITH ENCRYPTION
AS
BEGIN
	SET NOCOUNT ON
	IF EXISTS(
		SELECT * FROM Participants WHERE 
			@first_name = first_name AND
			@last_name = last_name AND
			@email = email
	)
	BEGIN
		SET @result = 1
		SELECT * FROM fn_GetOperationResult('sp_Check_User', @result);
		RETURN
	END
	ELSE
	IF EXISTS (
		SELECT * FROM Trainers WHERE 
			@first_name = first_name AND
			@last_name = last_name AND
			@email = email
	)
	BEGIN
		SET @result = 1
		SELECT * FROM fn_GetOperationResult('sp_Check_User', @result);
		RETURN
	END

	SET @result = 0
	SELECT * FROM fn_GetOperationResult('sp_Check_User', @result);
END


GO
CREATE OR ALTER PROCEDURE sp_Register_Participants
	@first_name nvarchar(50),
	@last_name nvarchar(50),
	@email nvarchar(50),
	@phone_number nvarchar(15),
	@birth_date date,
	@password nvarchar(50),
	@result tinyint OUTPUT
	WITH ENCRYPTION
AS
BEGIN
	SET NOCOUNT ON
	DECLARE @user_exists TINYINT
	EXEC sp_Check_User @first_name, @last_name, @email, @user_exists
	IF @user_exists = 1
	BEGIN
		SET @result = 1; 
		SELECT * FROM fn_GetOperationResult('sp_Register_Participants', @result);
		RETURN
	END

	-- password hashing
	DECLARE @hashed_password binary(64)
	DECLARE @salt binary(32)

	EXEC sp_Hash_Password @password, @hashed_password OUTPUT, @salt OUTPUT
	INSERT INTO Participants(first_name, last_name, email, phone_number, birth_date) 
		VALUES (@first_name, @last_name, @email, @phone_number, @birth_date)

	DECLARE @userGUID UNIQUEIDENTIFIER
	SET @userGUID = (SELECT TOP 1 rowguid FROM Participants WHERE 
		first_name = @first_name AND
		last_name = @last_name AND 
		email = @email)

	INSERT INTO Logs(userGUID, password, salt) VALUES(@userGUID, @hashed_password, @salt)
	SET @result = 0
	SELECT * FROM fn_GetOperationResult('sp_Register_Participants', @result);
END
GO


CREATE OR ALTER PROCEDURE sp_Register_Trainers
	@first_name nvarchar(50),
	@last_name nvarchar(50),
	@email nvarchar(50),
	@phone_number nvarchar(15),
	@specialization	nvarchar(100),
	@birth_date date,
	@password nvarchar(50),
	@result tinyint OUTPUT
	WITH ENCRYPTION
AS
BEGIN
	SET NOCOUNT ON
	DECLARE @user_exists TINYINT
	EXEC sp_Check_User @first_name, @last_name, @email, @user_exists
	IF @user_exists = 1
	BEGIN
		SET @result = 1; 
		SELECT * FROM fn_GetOperationResult('sp_Register_Trainers', @result);
		RETURN
	END

	-- password hashing
	DECLARE @hashed_password binary(64)
	DECLARE @salt binary(32)

	EXEC sp_Hash_Password @password, @hashed_password OUTPUT, @salt OUTPUT
	INSERT INTO Trainers(first_name, last_name, email, phone_number, specialization, birth_date) 
		VALUES (@first_name, @last_name, @email, @phone_number, @specialization, @birth_date)

	/*DECLARE @userGUID UNIQUEIDENTIFIER
	SET @userGUID = (SELECT rowguid FROM Trainers WHERE 
		first_name = @first_name AND
		last_name = @last_name AND 
		email = @email)*/

	--INSERT INTO Logs(userGUID, password, salt) VALUES(@userGUID, @hashed_password, @salt)
	SET @result = 0
	SELECT * FROM fn_GetOperationResult('sp_Register_Trainers', @result);
END


GO
CREATE OR ALTER PROCEDURE sp_Validate_Participant_OnLogIn
	@participantID int,
	@password nvarchar(50),
	@result tinyint OUTPUT
	WITH ENCRYPTION
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @first_name varchar(50), @last_name varchar(50), @email varchar(50)
	DECLARE @userGUID UNIQUEIDENTIFIER
	SELECT @first_name = first_name, @last_name = last_name, @email = email, @userGUID = rowguid FROM Participants WHERE participantID = @participantID;

	DECLARE @user_exists TINYINT
	EXEC sp_Check_User @first_name, @last_name, @email, @user_exists
	IF @user_exists = 0
	BEGIN
		SET @result = 1; 
		SELECT * FROM fn_GetOperationResult('sp_Validate_Participant_OnLogIn', @result);
		RETURN
	END

	DECLARE @stored_password varbinary(64)
	DECLARE @salt varbinary(32)

	SELECT @stored_password = password, @salt = salt FROM Logs
	WHERE userGUID = @userGUID

	IF @stored_password IS NULL OR @salt IS NULL
	BEGIN
		SET @result = 2
		SELECT * FROM fn_GetOperationResult('sp_Validate_Participant_OnLogIn', @result);
		RETURN;
	END
	-- hash gived password with stored salt and validate
	DECLARE @combined nvarchar(355), @hashed_password varbinary(64)
	SET @combined = @password + CONVERT(nvarchar(100), @salt, 1)
	SET @hashed_password = HASHBYTES('SHA_512', @combined)

	IF @hashed_password = @stored_password
	BEGIN
		SET @result = 0
		SELECT * FROM fn_GetOperationResult('sp_Validate_Participant_OnLogIn', @result);
		RETURN
	END
	SET @result = 3
	SELECT * FROM fn_GetOperationResult('sp_Validate_Participant_OnLogIn', @result);
END


GO
CREATE OR ALTER PROCEDURE sp_Add_Review
	@trainingID int,
	@participantID int,
	@rating int,
	@comment nvarchar(500) = NULL,
	@result tinyint OUTPUT
	WITH ENCRYPTION
AS
BEGIN
	SET NOCOUNT ON
	IF @rating NOT BETWEEN 1 AND 5
	BEGIN
		SET @result = 1
		SELECT * FROM fn_GetOperationResult('sp_Add_Review', @result);
		RETURN
	END

	INSERT INTO Reviews(trainingID, participantID, rating, comment)
				VALUES(@trainingID, @participantID, @rating, @comment)
	SET @result = 0
	SELECT * FROM fn_GetOperationResult('sp_Add_Review', @result);
END


GO
CREATE OR ALTER PROCEDURE sp_Add_Place
	@name nvarchar(50),
	@address nvarchar(50),
	@type nvarchar(50),
	@result tinyint OUTPUT
	WITH ENCRYPTION
AS
BEGIN
	SET NOCOUNT ON
	INSERT INTO Places(name, address, type) VALUES(@name, @address, @type)
	SET @result = 0
	SELECT * FROM fn_GetOperationResult('sp_Add_Place', @result);
END


GO
CREATE OR ALTER PROCEDURE sp_Add_Plan
	@type nvarchar(50),
	@difficulty_level int,
	@description nvarchar(500),
	@result tinyint OUTPUT
	WITH ENCRYPTION
AS
BEGIN
	SET NOCOUNT ON
	IF @difficulty_level NOT BETWEEN 1 AND 5
	BEGIN
		SET @result = 1
		SELECT * FROM fn_GetOperationResult('sp_Add_Plan', @result);
		RETURN
	END

	INSERT INTO Plans(type, difficulty_level, description) VALUES(@type, @difficulty_level, @description)
	SET @result = 0
	SELECT * FROM fn_GetOperationResult('sp_Add_Plan', @result);
END


GO
CREATE OR ALTER PROCEDURE sp_Add_Membership
	@participantID int,
	@type nvarchar(50),
	@purchase_date date,
	@price smallmoney,
	@result tinyint
	WITH ENCRYPTION
AS
BEGIN
	SET NOCOUNT ON
	-- depending on type of membership it may have different validity date
	DECLARE @validity_date date
	IF @type = '1 month'
		SET @validity_date = DATEADD(m, 1, GETDATE())
	ELSE IF @type = '3 months'
		SET @validity_date = DATEADD(m, 3, GETDATE())
	ELSE IF @type = '6 months'
		SET @validity_date = DATEADD(m, 6, GETDATE())
	ELSE IF @type = '1 year'
		SET @validity_date = DATEADD(y, 1, GETDATE())
	ELSE
		BEGIN
			SET @result = 1
			SELECT * FROM fn_GetOperationResult('sp_Add_Membership', @result);
			RETURN
		END

	INSERT INTO Memberships(participantID, type, purchase_date, validity_date, price) 
		VALUES(@participantID, @type, @purchase_date, @validity_date, @price)
	SET @result = 0
	SELECT * FROM fn_GetOperationResult('sp_Add_Membership', @result);
END


GO
CREATE OR ALTER PROCEDURE sp_Add_Participant_To_Training
    @participantID int,
    @trainingID int,
    @result tinyint OUTPUT
	WITH ENCRYPTION
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT EXISTS (SELECT 1 FROM Participants WHERE participantID = @participantID)
    BEGIN
        SET @result = 1;
		SELECT * FROM fn_GetOperationResult('sp_Add_Participant_To_Training', @result);
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM Trainings WHERE trainingID = @trainingID)
    BEGIN
        SET @result = 2;
		SELECT * FROM fn_GetOperationResult('sp_Add_Participant_To_Training', @result);
        RETURN;
    END

    -- check if participant is already registered for this training
    IF EXISTS (
        SELECT 1 
        FROM Participant_Trainings 
        WHERE participantID = @participantID 
        AND trainingID = @trainingID
    )
    BEGIN
        SET @result = 3; 
		SELECT * FROM fn_GetOperationResult('sp_Add_Participant_To_Training', @result);
        RETURN;
    END

    DECLARE @availableSlots tinyint;
    SELECT @availableSlots = available_slots 
    FROM Trainings 
    WHERE trainingID = @trainingID;

    IF @availableSlots <= 0
    BEGIN
        SET @result = 4; 
		SELECT * FROM fn_GetOperationResult('sp_Add_Participant_To_Training', @result);
        RETURN;
    END

    -- check if participant has valid membership for training date
    DECLARE @trainingDate datetime;
    SELECT @trainingDate = date FROM Trainings WHERE trainingID = @trainingID;

    IF NOT EXISTS (
        SELECT 1 
        FROM Memberships 
        WHERE participantID = @participantID 
        AND purchase_date <= @trainingDate 
        AND validity_date >= @trainingDate
    )
    BEGIN
        SET @result = 5; 
		SELECT * FROM fn_GetOperationResult('sp_Add_Participant_To_Training', @result);
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;
            -- add participant to training
            INSERT INTO Participant_Trainings (trainingID, participantID)
            VALUES (@trainingID, @participantID);

            -- update available slots
            UPDATE Trainings
            SET available_slots = available_slots - 1
            WHERE trainingID = @trainingID;

        COMMIT TRANSACTION;
        SET @result = 0; 
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        SET @result = 6; -- unknown error during transaction
    END CATCH
	SELECT * FROM fn_GetOperationResult('sp_Add_Participant_To_Training', @result);
END;
	

	GO
-- helper procedure to insert audit records
CREATE OR ALTER PROCEDURE sp_Insert_Audit_Record
    @tableModified nvarchar(50),
    @actionType nvarchar(20),
    @modifiedBy UNIQUEIDENTIFIER,
    @oldValue nvarchar(MAX),
    @newValue nvarchar(MAX),
    @result tinyint output
WITH ENCRYPTION
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        INSERT INTO AuditLog(tableModified, actionType, modifiedBy, oldValue, newValue)
        VALUES (@tableModified, @actionType, @modifiedBy, @oldValue, @newValue)
        SET @result = 0;
    END TRY
    BEGIN CATCH
        SET @result = 1;
    END CATCH
    SELECT * FROM fn_GetOperationResult('sp_Insert_Audit_Record', @result);
END;
GO

/* ************************************************************************************************************************************************************* */
-- G - views and indexes
/* ************************************************************************************************************************************************************* */

-- indexes for performance pptimization

CREATE NONCLUSTERED INDEX IX_Participants_Email 
ON Participants(email);

CREATE NONCLUSTERED INDEX IX_Participants_Names
ON Participants(last_name, first_name);

CREATE NONCLUSTERED INDEX IX_Trainings_Date 
ON Trainings(date);

CREATE NONCLUSTERED INDEX IX_Trainings_TrainerID 
ON Trainings(trainerID) INCLUDE (date, type, available_slots);

CREATE NONCLUSTERED INDEX IX_Trainings_Availability 
ON Trainings(available_slots) INCLUDE (date, type, placeID);

CREATE NONCLUSTERED INDEX IX_Memberships_Validity 
ON Memberships(validity_date);

CREATE NONCLUSTERED INDEX IX_Memberships_Participant 
ON Memberships(participantID) INCLUDE (type, validity_date);

CREATE NONCLUSTERED INDEX IX_Reviews_Training 
ON Reviews(trainingID) INCLUDE (rating, comment);


GO
-- general user views
CREATE VIEW vw_PublicTrainings
AS
SELECT 
    t.trainingID, t.date, t.type, t.available_slots,
    p.name AS place_name, p.address,
    tr.first_name + ' ' + tr.last_name AS trainer_name,tr.specialization,
    pl.type AS plan_type, pl.difficulty_level
FROM Trainings AS T
JOIN Places AS P ON t.placeID = p.placeID
JOIN Trainers AS Tr ON t.trainerID = tr.trainerID
JOIN Plans AS Pl ON t.planID = pl.planID
WHERE t.date >= GETDATE()
GO

CREATE VIEW vw_PublicTrainersList
AS
SELECT 
    first_name,
    last_name,
    specialization
FROM Trainers
GO

-- registered user views
CREATE VIEW vw_UserMemberships
AS
SELECT 
    m.membershipID, m.type, m.purchase_date,
    m.validity_date, m.price,
    p.first_name, p.last_name
FROM Memberships AS M
JOIN Participants AS P ON m.participantID = p.participantID
GO

CREATE VIEW vw_UserTrainingHistory
AS
SELECT 
    pt.registration_date,
    t.date AS training_date, t.type AS training_type,
    pl.type AS plan_type,
    tr.first_name + ' ' + tr.last_name AS trainer_name,
    p.name AS place_name
FROM Participant_Trainings AS Pt
JOIN Trainings AS T ON pt.trainingID = t.trainingID
JOIN Places AS P ON t.placeID = p.placeID
JOIN Trainers AS Tr ON t.trainerID = tr.trainerID
JOIN Plans AS Pl ON t.planID = pl.planID
GO

-- trainer views
CREATE VIEW vw_TrainerSchedule
AS
SELECT 
    t.trainingID, t.date, t.type,
    t.max_capacity, t.available_slots,
    p.name AS place_name, p.address,
    pl.type AS plan_type, pl.difficulty_level,
    COUNT(pt.participantID) AS current_participants
FROM Trainings AS T
JOIN Places AS P ON t.placeID = p.placeID
JOIN Plans AS Pl ON t.planID = pl.planID
LEFT JOIN Participant_Trainings pt ON t.trainingID = pt.trainingID
GROUP BY 
    t.trainingID, t.date, t.type, t.max_capacity, 
    t.available_slots, p.name, p.address, 
    pl.type, pl.difficulty_level
GO

-- employee views
CREATE VIEW vw_ParticipantDetails
AS
SELECT 
    p.participantID, p.first_name, p.last_name, p.email, p.phone_number, p.birth_date,
    COUNT(pt.trainingID) AS total_trainings,
    COUNT(DISTINCT m.membershipID) AS total_memberships
FROM Participants AS P
LEFT JOIN Participant_Trainings AS Pt ON p.participantID = pt.participantID
LEFT JOIN Memberships AS M ON p.participantID = m.participantID
GROUP BY 
    p.participantID, p.first_name, p.last_name, 
    p.email, p.phone_number, p.birth_date
GO

CREATE VIEW vw_TrainerPerformance
AS
SELECT 
    tr.trainerID, tr.first_name, tr.last_name, tr.specialization,
    COUNT(t.trainingID) AS total_trainings,
    AVG(CAST(r.rating AS FLOAT)) AS avg_rating,
    COUNT(DISTINCT pt.participantID) AS total_participants
FROM Trainers AS Tr
LEFT JOIN Trainings AS T ON tr.trainerID = t.trainerID
LEFT JOIN Reviews AS R ON t.trainingID = r.trainingID
LEFT JOIN Participant_Trainings AS Pt ON t.trainingID = pt.trainingID
GROUP BY 
    tr.trainerID, tr.first_name, tr.last_name, tr.specialization
GO

CREATE OR ALTER VIEW vw_AuditLog
AS
SELECT auditID, tableModified, actionType, modifiedBy, modifiedDate, ISNULL(oldValue, 'N/A') as oldValue, ISNULL(newValue, 'N/A') as newValu FROM AuditLog;
GO

/* ************************************************************************************************************************************************************* */
-- H - roles and security measures
/* ************************************************************************************************************************************************************* */

-- create database roles
CREATE ROLE GeneralUser;
CREATE ROLE Participant;
CREATE ROLE Trainer;
CREATE ROLE Employee;
CREATE ROLE Administrator;

-- general user permissions
GRANT SELECT ON vw_PublicTrainings TO GeneralUser;
GRANT SELECT ON vw_PublicTrainersList TO GeneralUser;

-- participant permissions
GRANT SELECT ON vw_PublicTrainings TO Participant;
GRANT SELECT ON vw_PublicTrainersList TO Participant;
GRANT SELECT ON vw_UserMemberships TO Participant;
GRANT SELECT ON vw_UserTrainingHistory TO Participant;

-- allow participants to sign up for trainings and purchase memberships
GRANT INSERT ON Participant_Trainings TO Participant;
GRANT INSERT ON Memberships TO Participant;
GRANT INSERT ON Reviews TO Participant;
GRANT UPDATE ON Reviews TO Participant;

-- trainer permissions
GRANT SELECT ON vw_TrainerSchedule TO Trainer;
GRANT SELECT ON Participant_Trainings TO Trainer;
GRANT SELECT ON vw_PublicTrainings TO Trainer;

-- employee permissions
GRANT SELECT ON vw_ParticipantDetails TO Employee;
GRANT SELECT ON vw_TrainerPerformance TO Employee;
GRANT SELECT, INSERT, UPDATE ON Participants TO Employee;
GRANT SELECT, INSERT, UPDATE ON Trainers TO Employee;
GRANT SELECT, INSERT, UPDATE ON Trainings TO Employee;
GRANT SELECT, INSERT, UPDATE ON Places TO Employee;
GRANT SELECT, INSERT, UPDATE ON Plans TO Employee;
GRANT SELECT, INSERT, UPDATE ON Memberships TO Employee;

GRANT SELECT ON vw_AuditLog TO Administrator;
GRANT EXECUTE ON sp_Insert_Audit_Record TO Administrator;
-- admin permissions (full access)
GRANT CONTROL ON DATABASE::TrainingMgmtDB TO Administrator;


GO
-- create procedure to add new users
CREATE OR ALTER PROCEDURE sp_Create_User
    @username nvarchar(50),
    @password nvarchar(100),
    @email nvarchar(50),
    @first_name nvarchar(50),
    @last_name nvarchar(50),
    @phone_number nvarchar(15),
	@specialization nvarchar(50) = NULL,
    @birth_date date,
    @user_type nvarchar(20)
	WITH ENCRYPTION
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRANSACTION;
    
    BEGIN TRY
        DECLARE @SQL NVARCHAR(MAX);
        SET @SQL = 'CREATE LOGIN ' + QUOTENAME(@username) + 
                   ' WITH PASSWORD = ''' + @password + '''';
        EXEC(@SQL);
        
        SET @SQL = 'CREATE USER ' + QUOTENAME(@username) + 
                   ' FOR LOGIN ' + QUOTENAME(@username);
        EXEC(@SQL);
        
        -- add user to appropriate role
		DECLARE @result tinyint
        IF @user_type = 'GENERAL'
            SET @SQL = 'ALTER ROLE GeneralUser ADD MEMBER ' + QUOTENAME(@username);
        ELSE IF @user_type = 'REGISTERED'
        BEGIN
            -- insert into participants table
			EXEC sp_Register_Participants @first_name, @last_name, @email, @phone_number, @birth_date, @password, @result
            SET @SQL = 'ALTER ROLE Participant ADD MEMBER ' + QUOTENAME(@username);
        END
        ELSE IF @user_type = 'TRAINER'
        BEGIN
			EXEC sp_Register_Trainers @first_name, @last_name, @email, @phone_number, @specialization, @birth_date, @password, @result
            SET @SQL = 'ALTER ROLE Trainer ADD MEMBER ' + QUOTENAME(@username);
        END
        ELSE IF @user_type = 'EMPLOYEE'
            SET @SQL = 'ALTER ROLE Employee ADD MEMBER ' + QUOTENAME(@username);
        ELSE IF @user_type = 'ADMIN'
            SET @SQL = 'ALTER ROLE Administrator ADD MEMBER ' + QUOTENAME(@username);
            
        EXEC(@SQL);
        
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

-- Create procedure to remove users
CREATE  OR ALTER PROCEDURE sp_Remove_User
    @username NVARCHAR(50),
    @user_type NVARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRANSACTION;
    
    BEGIN TRY
        -- Remove user from role
        DECLARE @SQL NVARCHAR(MAX);
        IF @user_type = 'REGISTERED'
        BEGIN
            -- delete from participants and related tables
            DECLARE @participantID INT;
            SELECT @participantID = participantID 
            FROM Participants 
            WHERE email = (SELECT email FROM sys.database_principals WHERE name = @username);
            
            DELETE FROM Participant_Trainings WHERE participantID = @participantID;
            DELETE FROM Reviews WHERE participantID = @participantID;
            DELETE FROM Memberships WHERE participantID = @participantID;
            DELETE FROM Participants WHERE participantID = @participantID;
        END
        
        -- Drop user and login
        SET @SQL = 'DROP USER ' + QUOTENAME(@username);
        EXEC(@SQL);
        
        SET @SQL = 'DROP LOGIN ' + QUOTENAME(@username);
        EXEC(@SQL);
        
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

-- example usage of creating users:
-- general user
EXEC sp_Create_User 
    @username = 'general_user1',
    @password = 'SecurePass123!',
    @email = 'general1@example.com',
    @first_name = 'John',
    @last_name = 'Doe',
    @phone_number = '1234567890',
	@specialization = NULL,
    @birth_date = '1990-01-01',
    @user_type = 'GENERAL';

-- registered user
EXEC sp_Create_User 
    @username = 'registered_user1',
    @password = 'SecurePass123!',
    @email = 'registered1@example.com',
    @first_name = 'Jane',
    @last_name = 'Smith',
    @phone_number = '1234567891',
	@specialization = NULL,
    @birth_date = '1992-02-02',
    @user_type = 'REGISTERED';

-- trainer
EXEC sp_Create_User 
    @username = 'trainer1',
    @password = 'SecurePass123!',
    @email = 'trainer1@example.com',
    @first_name = 'John',
    @last_name = 'Speller',
    @phone_number = '1234567891',
	@specialization = 'judo',
    @birth_date = '1992-02-02',
    @user_type = 'REGISTERED';

-- admin user
EXEC sp_Create_User 
    @username = 'admin_user1',
    @password = 'AdminPass123!',
    @email = 'admin1@example.com',
    @first_name = 'Admin',
    @last_name = 'User',
    @phone_number = '1234567892',
	@specialization = NULL,
    @birth_date = '1985-03-03',
    @user_type = 'ADMIN';

-- to run procedure etc. with full access:
EXECUTE AS user = 'admin_user1' 



/* ************************************************************************************************************************************************************* */
-- H - Data insert and testing
/* ************************************************************************************************************************************************************* */

INSERT INTO Plans (type, difficulty_level, description)
    VALUES 
        ('Strength', 3, 'Full body strength training program focusing on compound movements'),
        ('Cardio', 2, 'High-intensity cardio workout for fat burning'),
        ('Yoga', 1, 'Beginner-friendly yoga flow for flexibility'),
        ('Pilates', 4, 'Advanced Pilates workout focusing on core strength'),
        ('HIIT', 5, 'Intense interval training for maximum calorie burn'),
        ('Strength', 4, 'Upper body strength focus with progressive overload'),
        ('Cardio', 3, 'Endurance-building cardio circuit'),
        ('Yoga', 2, 'Intermediate yoga flow with balance poses'),
        ('HIIT', 4, 'Boxing-inspired HIIT workout'),
        ('Pilates', 3, 'Core and flexibility focused Pilates session');

    -- Insert Places
    INSERT INTO Places (name, address, type)
    VALUES 
        ('Main Studio', '123 Fitness St', 'Studio'),
        ('Olympic Pool', '456 Sport Ave', 'Pool'),
        ('East Field', '789 Training Rd', 'Field'),
        ('West Court', '321 Game Blvd', 'Court'),
        ('Zen Studio', '654 Wellness Way', 'Studio'),
        ('Indoor Pool', '987 Aqua Lane', 'Pool'),
        ('South Field', '147 Exercise Dr', 'Field'),
        ('North Court', '258 Activity St', 'Court'),
        ('Flow Studio', '369 Health Ave', 'Studio'),
        ('Training Field', '741 Fitness Rd', 'Field');

	
    -- Register Trainers
    /*
	EXEC sp_Register_Trainers 'John', 'Smith', 'john.smith@gym.com', '1234567890', 'Strength Training', '1985-03-15', 'Pass123!', @result;
    EXEC sp_Register_Trainers 'Sarah', 'Johnson', 'sarah.j@gym.com', '2345678901', 'Yoga', '1990-06-22', 'Pass123!', @result;
    EXEC sp_Register_Trainers 'Mike', 'Brown', 'mike.b@gym.com', '3456789012', 'HIIT', '1988-09-10', 'Pass123!', @result;
    EXEC sp_Register_Trainers 'Emma', 'Davis', 'emma.d@gym.com', '4567890123', 'Pilates', '1992-12-05', 'Pass123!', @result;
    EXEC sp_Register_Trainers 'James', 'Wilson', 'james.w@gym.com', '5678901234', 'Cardio', '1987-04-18', 'Pass123!', @result;
    EXEC sp_Register_Trainers 'Lisa', 'Anderson', 'lisa.a@gym.com', '6789012345', 'Strength Training', '1991-07-25', 'Pass123!', @result;
    EXEC sp_Register_Trainers 'David', 'Taylor', 'david.t@gym.com', '7890123456', 'HIIT', '1989-10-30', 'Pass123!', @result;
    EXEC sp_Register_Trainers 'Amy', 'Martin', 'amy.m@gym.com', '8901234567', 'Yoga', '1993-01-15', 'Pass123!', @result;
    EXEC sp_Register_Trainers 'Chris', 'Clark', 'chris.c@gym.com', '9012345678', 'Pilates', '1986-05-20', 'Pass123!', @result;
    EXEC sp_Register_Trainers 'Rachel', 'White', 'rachel.w@gym.com', '0123456789', 'Cardio', '1990-08-12', 'Pass123!', @result;
	*/

    -- Register Participants
    /*EXEC sp_Register_Participants 'Alice', 'Cooper', 'alice.c@email.com', '1122334455', '1995-02-10', 'Pass123!', @result;
    EXEC sp_Register_Participants 'Bob', 'Mitchell', 'bob.m@email.com', '2233445566', '1988-07-15', 'Pass123!', @result;
    EXEC sp_Register_Participants 'Carol', 'Hayes', 'carol.h@email.com', '3344556677', '1992-11-20', 'Pass123!', @result;
    EXEC sp_Register_Participants 'Daniel', 'Foster', 'daniel.f@email.com', '4455667788', '1990-04-25', 'Pass123!', @result;
    EXEC sp_Register_Participants 'Eve', 'Graham', 'eve.g@email.com', '5566778899', '1993-09-30', 'Pass123!', @result;
    EXEC sp_Register_Participants 'Frank', 'Peters', 'frank.p@email.com', '6677889900', '1987-03-05', 'Pass123!', @result;
    EXEC sp_Register_Participants 'Grace', 'Murray', 'grace.m@email.com', '7788990011', '1991-08-10', 'Pass123!', @result;
    EXEC sp_Register_Participants 'Henry', 'Wells', 'henry.w@email.com', '8899001122', '1994-01-15', 'Pass123!', @result;
    EXEC sp_Register_Participants 'Iris', 'Butler', 'iris.b@email.com', '9900112233', '1989-06-20', 'Pass123!', @result;
    EXEC sp_Register_Participants 'Jack', 'Rogers', 'jack.r@email.com', '0011223344', '1992-11-25', 'Pass123!', @result;
	*/
    -- Insert Trainings
    -- Get trainer IDs
    DECLARE @trainerID1 INT, @trainerID2 INT;
    SELECT TOP 2 @trainerID1 = trainerID, @trainerID2 = trainerID 
    FROM Trainers ORDER BY trainerID;

    INSERT INTO Trainings (planID, placeID, trainerID, date, type, max_capacity, available_slots)
    VALUES 
        (1, 1, @trainerID1, DATEADD(day, 1, GETDATE()), 'Group', 15, 15),
        (2, 2, @trainerID2, DATEADD(day, 2, GETDATE()), 'Individual', 1, 1),
        (3, 3, @trainerID1, DATEADD(day, 3, GETDATE()), 'Group', 20, 20),
        (4, 4, @trainerID2, DATEADD(day, 4, GETDATE()), 'Group', 12, 12),
        (5, 5, @trainerID1, DATEADD(day, 5, GETDATE()), 'Individual', 1, 1),
        (6, 6, @trainerID2, DATEADD(day, 6, GETDATE()), 'Group', 15, 15),
        (7, 7, @trainerID1, DATEADD(day, 7, GETDATE()), 'Group', 18, 18),
        (8, 8, @trainerID2, DATEADD(day, 8, GETDATE()), 'Individual', 1, 1),
        (9, 9, @trainerID1, DATEADD(day, 9, GETDATE()), 'Group', 25, 25),
        (10, 10, @trainerID2, DATEADD(day, 10, GETDATE()), 'Group', 20, 20);

    -- Add participants to trainings and create memberships
    DECLARE @participantID INT;
    SELECT TOP 1 @participantID = participantID FROM Participants ORDER BY participantID;
	DECLARE @result tinyint
    -- Add memberships for participants
    --EXEC sp_Add_Membership @participantID, '1 month', '2024-12-27', 50.00, @result;
    
    -- Register participants for trainings
    DECLARE @trainingID INT;
    SELECT TOP 1 @trainingID = trainingID FROM Trainings ORDER BY trainingID;
    
    --EXEC sp_Add_Participant_To_Training @participantID, @trainingID, @result;

    -- Add reviews
    INSERT INTO Reviews (trainingID, participantID, rating, comment)
    VALUES 
        (@trainingID, @participantID, 5, 'Excellent training session!'),
        (@trainingID, @participantID, 4, 'Great workout, very challenging'),
        (@trainingID, @participantID, 5, 'Amazing instructor and facility'),
        (@trainingID, @participantID, 4, 'Really enjoyed the class'),
        (@trainingID, @participantID, 5, 'Best training session ever'),
        (@trainingID, @participantID, 4, 'Very professional and motivating'),
        (@trainingID, @participantID, 5, 'Will definitely come back'),
        (@trainingID, @participantID, 4, 'Good energy and atmosphere'),
        (@trainingID, @participantID, 5, 'Exceeded my expectations'),
        (@trainingID, @participantID, 4, 'Well-structured training program');
GO


SELECT * FROM Participants
SELECT * FROM Participant_Trainings
SELECT * FROM Trainings
SELECT * FROM Trainers
SELECT * FROM Places
SELECT * FROM Plans
SELECT * FROM Memberships
SELECT * FROM Logs
SELECT * FROM AuditLog
SELECT * FROM Reviews

GO
-- Now let's create some verification views
CREATE OR ALTER VIEW vw_CompleteTrainingSchedule
AS
SELECT 
    t.trainingID,
    t.date,
    t.type AS training_type,
    t.max_capacity,
    t.available_slots,
    p.name AS place_name,
    p.type AS place_type,
    tr.first_name + ' ' + tr.last_name AS trainer_name,
    tr.specialization AS trainer_specialization,
    pl.type AS plan_type,
    pl.difficulty_level
FROM Trainings t
JOIN Places p ON t.placeID = p.placeID
JOIN Trainers tr ON t.trainerID = tr.trainerID
JOIN Plans pl ON t.planID = pl.planID;
GO

CREATE OR ALTER VIEW vw_ParticipantMembershipStatus
AS
SELECT 
    p.participantID,
    p.first_name + ' ' + p.last_name AS participant_name,
    m.type AS membership_type,
    m.purchase_date,
    m.validity_date,
    m.price,
    CASE 
        WHEN m.validity_date >= GETDATE() THEN 'Active'
        ELSE 'Expired'
    END AS membership_status
FROM Participants p
LEFT JOIN Memberships m ON p.participantID = m.participantID;
GO

CREATE OR ALTER VIEW vw_TrainingReviews
AS
SELECT 
    t.trainingID,
    t.date AS training_date,
    t.type AS training_type,
    tr.first_name + ' ' + tr.last_name AS trainer_name,
    p.name AS place_name,
    r.rating,
    r.comment,
    part.first_name + ' ' + part.last_name AS reviewer_name
FROM Trainings t
JOIN Reviews r ON t.trainingID = r.trainingID
JOIN Trainers tr ON t.trainerID = tr.trainerID
JOIN Places p ON t.placeID = p.placeID
JOIN Participants part ON r.participantID = part.participantID;
GO

-- Queries to verify the data
SELECT 'Trainers' AS DataSet, COUNT(*) AS RecordCount FROM Trainers
UNION ALL
SELECT 'Participants', COUNT(*) FROM Participants
UNION ALL
SELECT 'Places', COUNT(*) FROM Places
UNION ALL
SELECT 'Plans', COUNT(*) FROM Plans
UNION ALL
SELECT 'Trainings', COUNT(*) FROM Trainings
UNION ALL
SELECT 'Reviews', COUNT(*) FROM Reviews
UNION ALL
SELECT 'Memberships', COUNT(*) FROM Memberships;

-- View the complete training schedule
SELECT * FROM vw_CompleteTrainingSchedule;

-- View participant membership status
SELECT * FROM vw_ParticipantMembershipStatus;

-- View training reviews
SELECT * FROM vw_TrainingReviews;
