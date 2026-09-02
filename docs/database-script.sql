CREATE DATABASE RaceDayDB;
GO

USE RaceDayDB;
GO

CREATE TABLE [User] (
    UserId INT IDENTITY(1,1) PRIMARY KEY,
    Email VARCHAR(100) UNIQUE NOT NULL,
    PasswordHash VARCHAR(200) NOT NULL,
    FullName VARCHAR(100) NOT NULL,
    Role VARCHAR(20) NOT NULL CHECK (Role IN ('Participant', 'Organiser', 'Admin')),
    ProfilePictureUrl VARCHAR(500) NULL,
    IsActive BIT DEFAULT 1,
    CreatedDate DATETIME DEFAULT GETDATE()
);
GO

CREATE TABLE Organiser (
    OrganiserId INT IDENTITY(1,1) PRIMARY KEY,
    UserId INT UNIQUE NOT NULL,
    CompanyName VARCHAR(100) NOT NULL,
    PhoneNumber VARCHAR(20) NULL,
    IsVerified BIT DEFAULT 0,
    CONSTRAINT FK_Organiser_User FOREIGN KEY (UserId) REFERENCES [User](UserId) ON DELETE CASCADE
);
GO

CREATE TABLE Participant (
    ParticipantId INT IDENTITY(1,1) PRIMARY KEY,
    UserId INT UNIQUE NOT NULL,
    DateOfBirth DATE NULL,
    Gender VARCHAR(10) NULL,
    EmergencyContact VARCHAR(100) NULL,
    CONSTRAINT FK_Participant_User FOREIGN KEY (UserId) REFERENCES [User](UserId) ON DELETE CASCADE
);
GO

CREATE TABLE Event (
    EventId INT IDENTITY(1,1) PRIMARY KEY,
    OrganiserId INT NOT NULL,
    EventName VARCHAR(100) NOT NULL,
    Description TEXT NULL,
    EventDate DATE NOT NULL,
    Location VARCHAR(200) NOT NULL,
    Distance DECIMAL(5,2) NOT NULL,
    EventType VARCHAR(20) NOT NULL CHECK (EventType IN ('Run', 'Walk', 'Cycle')),
    MaxParticipants INT NOT NULL,
    CurrentEnrolments INT DEFAULT 0,
    Status VARCHAR(20) DEFAULT 'Open' CHECK (Status IN ('Open', 'Closed', 'Completed')),
    BannerImageUrl VARCHAR(500) NULL,
    CONSTRAINT FK_Event_Organiser FOREIGN KEY (OrganiserId) REFERENCES Organiser(OrganiserId) ON DELETE CASCADE
);
GO

CREATE TABLE Category (
    CategoryId INT IDENTITY(1,1) PRIMARY KEY,
    EventId INT NOT NULL,
    CategoryName VARCHAR(50) NOT NULL,
    Distance DECIMAL(5,2) NULL,
    EntryFee DECIMAL(10,2) NOT NULL,
    MaxParticipants INT NULL,
    CONSTRAINT FK_Category_Event FOREIGN KEY (EventId) REFERENCES Event(EventId) ON DELETE CASCADE
);
GO

CREATE TABLE Enrolment (
    EnrolmentId INT IDENTITY(1,1) PRIMARY KEY,
    ParticipantId INT NOT NULL,
    EventId INT NOT NULL,
    CategoryId INT NOT NULL,
    EnrolmentDate DATETIME DEFAULT GETDATE(),
    Status VARCHAR(20) DEFAULT 'Pending' CHECK (Status IN ('Pending', 'Approved', 'Rejected', 'Cancelled')),
    DocumentsUrl VARCHAR(500) NULL,
    Notes TEXT NULL,
    CONSTRAINT FK_Enrolment_Participant FOREIGN KEY (ParticipantId) REFERENCES Participant(ParticipantId),
    CONSTRAINT FK_Enrolment_Event FOREIGN KEY (EventId) REFERENCES Event(EventId),
    CONSTRAINT FK_Enrolment_Category FOREIGN KEY (CategoryId) REFERENCES Category(CategoryId),
    CONSTRAINT UQ_Enrolment_Unique UNIQUE (ParticipantId, EventId, CategoryId)
);
GO

INSERT INTO [User] (Email, PasswordHash, FullName, Role, IsActive) VALUES
('admin@raceday.co.za', 'hashed_admin_2026', 'Thabo Mbeki', 'Admin', 1),
('john.organiser@runsa.co.za', 'hashed_org_001', 'John Smith', 'Organiser', 1),
('sarah.organiser@capetrail.co.za', 'hashed_org_002', 'Sarah Johnson', 'Organiser', 1),
('sipho.runner@gmail.com', 'hashed_part_001', 'Sipho Dlamini', 'Participant', 1),
('lisa.walker@outlook.com', 'hashed_part_002', 'Lisa Walker', 'Participant', 1);
GO

INSERT INTO Organiser (UserId, CompanyName, PhoneNumber, IsVerified) VALUES
((SELECT UserId FROM [User] WHERE Email = 'john.organiser@runsa.co.za'), 'RunSA Events', '0821234567', 1),
((SELECT UserId FROM [User] WHERE Email = 'sarah.organiser@capetrail.co.za'), 'Cape Trail Series', '0837654321', 1);
GO

INSERT INTO Participant (UserId, DateOfBirth, Gender, EmergencyContact) VALUES
((SELECT UserId FROM [User] WHERE Email = 'sipho.runner@gmail.com'), '1990-05-15', 'Male', 'Jane 0823334444'),
((SELECT UserId FROM [User] WHERE Email = 'lisa.walker@outlook.com'), '1985-10-20', 'Female', 'John 0825556666');
GO

INSERT INTO Event (OrganiserId, EventName, Description, EventDate, Location, Distance, EventType, MaxParticipants, Status) VALUES
((SELECT OrganiserId FROM Organiser WHERE CompanyName = 'RunSA Events'), 
 'Comrades Marathon', 'The Ultimate Human Race', '2026-06-15', 'Pietermaritzburg to Durban', 89.00, 'Run', 20000, 'Open'),

((SELECT OrganiserId FROM Organiser WHERE CompanyName = 'Cape Trail Series'), 
 'Cape Town Cycle Tour', 'World''s largest timed cycle race', '2026-03-15', 'Cape Town', 109.00, 'Cycle', 35000, 'Open'),

((SELECT OrganiserId FROM Organiser WHERE CompanyName = 'RunSA Events'), 
 'Soweto Marathon', 'Run through the streets of Soweto', '2026-11-05', 'Soweto, Johannesburg', 42.20, 'Run', 15000, 'Open');
GO

INSERT INTO Category (EventId, CategoryName, Distance, EntryFee, MaxParticipants)
SELECT EventId, 'Ultra Marathon', 89.00, 800.00, 10000 FROM Event WHERE EventName = 'Comrades Marathon';

INSERT INTO Category (EventId, CategoryName, Distance, EntryFee, MaxParticipants)
SELECT EventId, 'Half Marathon', 42.00, 400.00, 8000 FROM Event WHERE EventName = 'Comrades Marathon';

INSERT INTO Category (EventId, CategoryName, Distance, EntryFee, MaxParticipants)
SELECT EventId, 'Elite', 109.00, 500.00, 1000 FROM Event WHERE EventName = 'Cape Town Cycle Tour';

INSERT INTO Category (EventId, CategoryName, Distance, EntryFee, MaxParticipants)
SELECT EventId, 'Open', 109.00, 350.00, 15000 FROM Event WHERE EventName = 'Cape Town Cycle Tour';

INSERT INTO Category (EventId, CategoryName, Distance, EntryFee, MaxParticipants)
SELECT EventId, 'Full Marathon', 42.20, 300.00, 10000 FROM Event WHERE EventName = 'Soweto Marathon';

INSERT INTO Category (EventId, CategoryName, Distance, EntryFee, MaxParticipants)
SELECT EventId, 'Half Marathon', 21.10, 200.00, 5000 FROM Event WHERE EventName = 'Soweto Marathon';
GO
  
INSERT INTO Enrolment (ParticipantId, EventId, CategoryId, Status, Notes)
SELECT p.ParticipantId, e.EventId, c.CategoryId, 'Approved', 'Travelling from Durban'
FROM Participant p
CROSS JOIN Event e
CROSS JOIN Category c
WHERE p.UserId = (SELECT UserId FROM [User] WHERE Email = 'sipho.runner@gmail.com')
AND e.EventName = 'Comrades Marathon'
AND c.CategoryName = 'Ultra Marathon';

INSERT INTO Enrolment (ParticipantId, EventId, CategoryId, Status, Notes)
SELECT p.ParticipantId, e.EventId, c.CategoryId, 'Pending', 'Waiting for medical clearance'
FROM Participant p
CROSS JOIN Event e
CROSS JOIN Category c
WHERE p.UserId = (SELECT UserId FROM [User] WHERE Email = 'lisa.walker@outlook.com')
AND e.EventName = 'Soweto Marathon'
AND c.CategoryName = 'Full Marathon';

INSERT INTO Enrolment (ParticipantId, EventId, CategoryId, Status, Notes)
SELECT p.ParticipantId, e.EventId, c.CategoryId, 'Approved', 'Experienced cyclist'
FROM Participant p
CROSS JOIN Event e
CROSS JOIN Category c
WHERE p.UserId = (SELECT UserId FROM [User] WHERE Email = 'sipho.runner@gmail.com')
AND e.EventName = 'Cape Town Cycle Tour'
AND c.CategoryName = 'Open';
GO
  
SELECT 
    e.EnrolmentId,
    u.FullName AS Participant,
    ev.EventName,
    c.CategoryName,
    e.Status,
    e.EnrolmentDate
FROM Enrolment e
JOIN Participant p ON e.ParticipantId = p.ParticipantId
JOIN [User] u ON p.UserId = u.UserId
JOIN Event ev ON e.EventId = ev.EventId
JOIN Category c ON e.CategoryId = c.CategoryId
ORDER BY e.EnrolmentDate DESC;
GO
