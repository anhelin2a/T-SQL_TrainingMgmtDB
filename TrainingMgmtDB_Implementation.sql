/* 

FILE STRUCTURE:
	A - Creating database and tables
	B - Triggers
	C - Constraints
	D - Procedures
	E - Functions
	F - Roles and access

*/


/* ************************************************************************************************************************************************************* */
-- A 
/* ************************************************************************************************************************************************************* */
-- create database and its structure


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
		price				float						NOT NULL,
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

/* ************************************************************************************************************************************************************* */
-- B
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
insert into Participants(first_name, last_name, email, phone_number, birth_date) values ('test_name', 'test_surname', '----', '----', '----')
select * from Participants -- before trigger

update Participants
set last_name = 'test_surname_updated' where participantID = 1

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



-- check if triggers generated successfully
SELECT t.name AS Table_Name, tr.name AS Trigger_Name
FROM sys.tables t
INNER JOIN sys.triggers tr ON t.object_id = tr.parent_id
WHERE tr.name LIKE 'trg_%';


/* ************************************************************************************************************************************************************* */
-- C
/* ************************************************************************************************************************************************************* */


-- drop constraints if already exist
ALTER TABLE Participants DROP CONSTRAINT CHK_Participants_Age;
ALTER TABLE Trainers DROP CONSTRAINT CHK_Trainers_Age;
----------------------------------------------------------------------------------------------------------------------------------------------------------------

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
-- D
/* ************************************************************************************************************************************************************* */
GO
CREATE OR ALTER PROCEDURE sp_Hash_Password
	@password nvarchar(50),
    @hashed_password BINARY(64) OUTPUT,
    @salt BINARY(32) OUTPUT
--WITH ENCRYPTION
AS
BEGIN
    SET NOCOUNT ON;
    SET @salt = CRYPT_GEN_RANDOM(32);

    DECLARE @combined NVARCHAR(355); 
    SET @combined = @password + CONVERT(NVARCHAR(100), @salt, 1);

    SET @hashed_password = HASHBYTES('SHA2_512', @combined);
END;
GO
-- testint the hashing proc
--DECLARE @hp binary(64)
--DECLARE @salt binary(32)
--EXECUTE sp_Hash_Password @hp, @salt
GO


CREATE OR ALTER PROCEDURE sp_Check_User -- checks if user already exists
	@first_name nvarchar(50),
	@last_name nvarchar(50),
	@email nvarchar(50),
	@result int OUTPUT
	--WITH ENCRYPTION
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
		RETURN
	END

	SET @result = 0
END


GO
CREATE OR ALTER PROCEDURE sp_Register_Participants
	@first_name nvarchar(50),
	@last_name nvarchar(50),
	@email nvarchar(50),
	@phone_number nvarchar(15),
	@birth_date date,
	@password nvarchar(50),
	@result int OUTPUT
AS
BEGIN
	DECLARE @user_exists TINYINT
	EXEC sp_Check_User @first_name, @last_name, @email, @user_exists
	IF @user_exists = 1
	BEGIN
		SET @result = 1; -- user already exists
		RETURN
	END

	-- password hashing
	DECLARE @hashed_password binary(64)
	DECLARE @salt binary(32)

	EXEC sp_Hash_Password @password, @hashed_password OUTPUT, @salt OUTPUT
	INSERT INTO Participants(first_name, last_name, email, phone_number, birth_date) 
		VALUES (@first_name, @last_name, @email, @phone_number, @birth_date)

	DECLARE @userGUID UNIQUEIDENTIFIER
	SET @userGUID = (SELECT rowguid FROM Participants WHERE 
		first_name = @first_name AND
		last_name = @last_name AND 
		email = @email)

	INSERT INTO Logs(userGUID, password, salt) VALUES(@userGUID, @hashed_password, @salt)
	SET @result = 0
END
GO


