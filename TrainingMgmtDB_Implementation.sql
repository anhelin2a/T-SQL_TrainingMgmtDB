

/* ************************************************************************************************************************************************************* */
-- A 
-- create database and its structure


-- create database
IF DB_ID('TrainingMgmtDB') IS NULL
BEGIN
	CREATE DATABASE TrainingMgmtDB
END


-- create tables
IF NOT EXISTS(SELECT * FROM dbo.sysobjects WHERE ID = OBJECT_ID(N'dbo. Participants') AND OBJECTPROPERTY(ID, N'IsTable') = 1)
BEGIN
	CREATE TABLE  Participants(
		 participantID INT PRIMARY KEY IDENTITY(1, 1),
		 first_name nvarchar(50) NOT NULL,
		 last_name nvarchar(50) NOT NULL,
		 email nvarchar(50) NOT NULL,
		 phone_number varchar(15) NOT NULL,
		 birth_date date NOT NULL,
		 modified_date date,
		 rowguid UNIQUEIDENTIFIER DEFAULT NEWID()
	)
END

-- add check id participant is >= 12 yo when adding new one
-- add trigger for modified date column
-- add mail confirmation of joining functionality


IF NOT EXISTS(SELECT * FROM dbo.sysobjects WHERE ID = OBJECT_ID(N'dbo.Plans') AND OBJECTPROPERTY(ID, N'IsTable') = 1)
BEGIN 
	CREATE TABLE Plans(
		planID INT PRIMARY KEY IDENTITY(1, 1),
		type nvarchar(50),
		difficulty_level int,
		description nvarchar(500),
		modified_date date,
		rowguid UNIQUEIDENTIFIER DEFAULT NEWID()
	)
END

-- add check if difficulty level is from 1 to 5
-- check constraint for type