/* 

FILE STRUCTURE:
	A - Creating database and tables
	B - Triggers

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

-- add check id participant is >= 12 yo when adding new one
-- add trigger for modified date column
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

-- add check if difficulty level is from 1 to 5
-- check constraint for type
-- add trigger for modified date column


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

-- add check if trainer is >= 18 yo
-- add trigger for modified date column
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

-- add type check constraint



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

-- add check constraint if available_slots <= capacity



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

-- add trigger validity_date depending on type of membership


IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE ID = OBJECT_ID(N'Logs') AND OBJECTPROPERTY(ID, N'IsTable') = 1)
BEGIN
	CREATE TABLE Logs(
		logID				INT PRIMARY KEY IDENTITY(1, 1),
		userGUID			UNIQUEIDENTIFIER FOREIGN KEY REFERENCES Participants(rowguid) ON UPDATE CASCADE,
		password			nvarchar(128)	 NOT NULL,
		salt				nvarchar(128)	 NOT NULL,
		modified_date		datetime		 DEFAULT (GETDATE()),
		rowguid				UNIQUEIDENTIFIER DEFAULT NEWID() UNIQUE NOT NULL
	)
END



/* ************************************************************************************************************************************************************* */
-- B
/* ************************************************************************************************************************************************************* */

-- automated trigger generation for every table in database to update 'modified_date' column
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

SELECT t.name AS Table_Name, tr.name AS Trigger_Name
FROM sys.tables t
INNER JOIN sys.triggers tr ON t.object_id = tr.parent_id
WHERE tr.name LIKE 'trg_UpdateModifiedDate_%';


insert into Participants(first_name, last_name, email, phone_number, birth_date) values ('Anhelina', 'Mendohralo', '248659@edu.p.lodz.pl', '579299793', '2004-06-04')
select * from Participants

update Participants
set last_name = 'Mend' where participantID = 1