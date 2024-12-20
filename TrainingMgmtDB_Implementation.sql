

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
		 participantID		INT PRIMARY KEY IDENTITY(1, 1),
		 first_name			nvarchar(50)	NOT NULL,
		 last_name			nvarchar(50)	NOT NULL,
		 email				nvarchar(50)	NOT NULL,
		 phone_number		nvarchar(15)	NOT NULL,
		 birth_date			date			NOT NULL,
		 modified_date		date,
		 rowguid			UNIQUEIDENTIFIER DEFAULT NEWID() UNIQUE
	)
END

-- add check id participant is >= 12 yo when adding new one
-- add trigger for modified date column
-- add mail confirmation of joining functionality


IF NOT EXISTS(SELECT * FROM dbo.sysobjects WHERE ID = OBJECT_ID(N'dbo.Plans') AND OBJECTPROPERTY(ID, N'IsTable') = 1)
BEGIN 
	CREATE TABLE Plans(
		planID				INT PRIMARY KEY IDENTITY(1, 1),
		type				nvarchar(50)	NOT NULL,
		difficulty_level	int				NOT NULL,
		description			nvarchar(500)	NOT NULL,
		modified_date		date,
		rowguid				UNIQUEIDENTIFIER DEFAULT NEWID() UNIQUE
	)
END

-- add check if difficulty level is from 1 to 5
-- check constraint for type
-- add trigger for modified date column


IF NOT EXISTS(SELECT * FROM dbo.sysobjects WHERE ID = OBJECT_ID(N'dbo.Trainers') AND OBJECTPROPERTY(ID, N'IsTable') = 1)
BEGIN
	CREATE TABLE Trainers(
		trainerID		INT PRIMARY KEY IDENTITY(1, 1),
		first_name		nvarchar(50)	NOT NULL,
		last_name		nvarchar(50)	NOT NULL,
		email			nvarchar(50)	NOT NULL,
		phone_number	nvarchar(15)	NOT NULL,
		specialization	nvarchar(100)	NOT NULL,
		birth_date		date			NOT NULL,
		modified_date	date,
		rowguid			UNIQUEIDENTIFIER DEFAULT NEWID() UNIQUE
	)
END

-- add check if trainer is >= 18 yo
-- add trigger for modified date column
-- add mail confirmation of joining functionality


IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE ID = OBJECT_ID(N'dbo.Places') AND OBJECTPROPERTY(ID, N'IsTable') =1)
BEGIN
	CREATE TABLE Places(
		placeID			INT PRIMARY KEY IDENTITY(1, 1),
		name			nvarchar(50)	NOT NULL,
		address			nvarchar(100)	NOT NULL,
		type			nvarchar(50)	NOT NULL,
		modified_date	date,
		rowguid			UNIQUEIDENTIFIER DEFAULT NEWID() UNIQUE
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
		date				datetime		NOT NULL,
		type				nvarchar(50)	NOT NULL,
		max_capacity		tinyint			NOT NULL,
		available_slots		tinyint			NOT NULL,
		modified_date		date,
		rowguid				UNIQUEIDENTIFIER DEFAULT NEWID() UNIQUE
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
		modified_date			date,
		rowguid					UNIQUEIDENTIFIER DEFAULT NEWID() UNIQUE
	)
END



IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE ID = OBJECT_ID(N'dbo.Reviews') AND OBJECTPROPERTY(ID, N'IsTable') = 1)
BEGIN 
	CREATE TABLE Reviews(
		reviewID			INT PRIMARY KEY IDENTITY(1, 1),
		trainingID			INT FOREIGN KEY REFERENCES Trainings(trainingID)		ON UPDATE CASCADE,
		participantID		INT FOREIGN KEY REFERENCES Participants(participantID)	ON UPDATE CASCADE,
		rating				tinyint			NOT NULL,
		comment				NVARCHAR(500),
		modified_date		date,
		rowguid				UNIQUEIDENTIFIER DEFAULT NEWID() UNIQUE
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
		modified_date		date,
		rowguid				UNIQUEIDENTIFIER DEFAULT NEWID() UNIQUE
	)
END

-- add trigger validity_date depending on type of membership


IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE ID = OBJECT_ID(N'Logs') AND OBJECTPROPERTY(ID, N'IsTable') = 1)
BEGIN
	CREATE TABLE Logs(
		logID				INT PRIMARY KEY IDENTITY(1, 1),
		userGUID			UNIQUEIDENTIFIER FOREIGN KEY REFERENCES Participants(rowguid) ON UPDATE CASCADE,
		password			nvarchar(128)	NOT NULL,
		salt				nvarchar(128)	NOT NULL,
		modified_date		date,
		rowguid				UNIQUEIDENTIFIER DEFAULT NEWID() UNIQUE
	)
END
