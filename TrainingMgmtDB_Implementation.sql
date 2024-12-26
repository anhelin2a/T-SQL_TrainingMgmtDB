/* 

FILE STRUCTURE:
	A - Creating database and tables
	B - Triggers
	C - Constraints
	D - Types
	E - Functions
	F - Procedures
	G - Roles and access
	

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
-- testint the hashing proc
--DECLARE @hp binary(64)
--DECLARE @salt binary(32)
--EXECUTE sp_Hash_Password @hp, @salt
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
	SET @userGUID = (SELECT rowguid FROM Participants WHERE 
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

	DECLARE @userGUID UNIQUEIDENTIFIER
	SET @userGUID = (SELECT rowguid FROM Trainers WHERE 
		first_name = @first_name AND
		last_name = @last_name AND 
		email = @email)

	INSERT INTO Logs(userGUID, password, salt) VALUES(@userGUID, @hashed_password, @salt)
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
	