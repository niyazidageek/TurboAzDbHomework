CREATE DATABASE TurboAzDb
USE TurboAzDb

CREATE TABLE Models(
	Id int identity primary key,
	Name nvarchar(50),
	MakeId int references Makes(Id)
)

CREATE TABLE Makes(
	Id int identity primary key,
	Name nvarchar(50)
)

CREATE TABLE Colors(
	Id int identity primary key,
	Name nvarchar(50)
)

CREATE TABLE Currencies(
	Id int identity primary key,
	Name nvarchar(50)
)

CREATE TABLE AnnouncementStatuses(
	Id int identity primary key,
	Name nvarchar(50)
)

CREATE TABLE EngineVolumes(
	Id int identity primary key,
	Name nvarchar(50)
)

CREATE TABLE Cities(
	Id int identity primary key,
	Name nvarchar(50)
)

CREATE TABLE OilTypes(
	Id int identity primary key,
	Name nvarchar(50)
)

CREATE TABLE Transmissions(
	Id int identity primary key,
	Name nvarchar(50)
)

CREATE TABLE Drivetrains(
	Id int identity primary key,
	Name nvarchar(50)
)

CREATE TABLE MileageTypes(
	Id int identity primary key,
	Name nvarchar(50)
)

CREATE TABLE Segments(
	Id int identity primary key,
	Name nvarchar(50)
)

CREATE TABLE ProductionYears(
	Id int identity primary key,
	Year int
)

CREATE TABLE Equipments(
	Id int identity primary key,
	Name nvarchar(50)
)

CREATE TABLE EquipmentAnnouncement(
	Id int identity primary key,
	EquipmentId int references Equipments(Id),
	AnnouncementId int references Announcements(Id) on delete cascade
)

CREATE TABLE Photos(
	Id int identity primary key,
	Source nvarchar(255),
	AnnouncementId int references Announcements(Id) on delete cascade 
)

CREATE TABLE Autoshops(
	Id int identity primary key,
	Name nvarchar(50),
	CityId int references Cities(Id),
	PhoneNumber nvarchar(255),
	Address nvarchar(255)
)

CREATE TABLE DeletedAnnouncements(
	Id int,
	ColorId int,
	CurrencyId int,
	AnnouncementStatusId int,
	EngineVolumeId int,
	CityId int,
	OilTypeId int,
	TransmissionId int,
	DrivetrainId int,
	MileageTypeId int,
	SegmentId int,
	ProductionYearId int,
	AutoshopId int,
	Price decimal(10,2),
	CreationDate datetime,
	Email nvarchar(255),
	PublisherFullname nvarchar(255),
	PhoneNumber nvarchar(255),
	IsInCredit bit,
	BarterPossible bit,
	AdditionalInfo nvarchar(300),
	Mileage int,
	Horsepower int,
	ModelId int,
	Equipment nvarchar(300),
	Photos nvarchar(300)
)


CREATE TABLE Announcements(
	Id int identity primary key,
	ModelId int references Models(Id),
	ColorId int references Colors(Id),
	CurrencyId int references Currencies(Id),
	AnnouncementStatusId int references AnnouncementStatuses(Id),
	EngineVolumeId int references EngineVolumes(Id),
	CityId int references Cities(Id),
	OilTypeId int references OilTypes(Id),
	TransmissionId int references Transmissions(Id),
	DrivetrainId int references Drivetrains(Id),
	MileageTypeId int references MileageTypes(Id),
	SegmentId int references Segments(Id),
	ProductionYearId int references ProductionYears(Id),
	AutoshopId int references Autoshops(Id),
	Price decimal(10,2),
	CreationDate datetime,
	Email nvarchar(255),
	PublisherFullname nvarchar(255),
	PhoneNumber nvarchar(255),
	IsInCredit bit default(0),
	BarterPossible bit default(0),
	AdditionalInfo nvarchar(300),
	Mileage int,
	Horsepower int,
	Eqipment nvarchar(255)
)

CREATE VIEW GET_PHOTOS_AS_ID AS
SELECT ph.AnnouncementId, STRING_AGG(ph.Source, ' ,') AS 'Photos' FROM Photos ph
GROUP BY AnnouncementId

CREATE VIEW GET_ANNOUNCEMENTS_AS_ID AS
SELECT ea.AnnouncementId, ea.EquipmentId FROM EquipmentAnnouncement ea
LEFT JOIN Announcements a
ON ea.AnnouncementId = a.Id
LEFT JOIN Equipments e
ON ea.EquipmentId = e.Id


CREATE VIEW GET_ANNOUNCEMENTS_WITH_EQUIPMENT_AS_ID AS
SELECT g.AnnouncementId, STRING_AGG(e.Name, ' ,') AS 'Euqipment' FROM GET_ANNOUNCEMENTS_AS_ID g
LEFT JOIN Announcements a
ON g.AnnouncementId = a.Id
LEFT JOIN Equipments e
ON g.EquipmentId = e.Id
GROUP BY g.AnnouncementId

CREATE VIEW GET_ALL_ACTIVE_ANNOUNCEMENTS AS
SELECT a.Id AS 'Announcement Id',
	mk.Name AS 'Make', 
	md.Name AS 'Model',
	crs.Name AS 'Color', 
	crns.Name AS 'Currency',
	ans.Name AS 'Status',
	ev.Name AS 'Engine Volume',
	ct.Name AS 'City',
	ot.Name AS 'Oil type',
	tnm.Name AS 'Transmision type',
	dt.Name AS 'Drivetrain',
	mt.Name AS 'Mileage type',
	sg.Name AS 'Segment',
	py.Year AS 'Production year',
	ash.Name AS 'Autoshop name',
	a.Price,
	a.CreationDate,
	a.Email,
	a.PublisherFullname,
	a.PhoneNumber,
	a.IsInCredit,
	a.BarterPossible, 
	a.AdditionalInfo,
	a.Mileage,
	a.Horsepower,
	g.Euqipment,
	ph.Photos FROM GET_ANNOUNCEMENTS_WITH_EQUIPMENT_AS_ID g
		JOIN Announcements a
		ON g.AnnouncementId = a.Id
		JOIN Models md
		ON a.ModelId = md.Id
		JOIN Makes mk
		ON md.MakeId = mk.Id
		JOIN Colors crs
		ON a.ColorId = crs.Id
		JOIN Currencies crns
		ON a.CurrencyId = crns.Id
		JOIN AnnouncementStatuses ans
		ON a.AnnouncementStatusId = ans.Id
		JOIN EngineVolumes ev
		ON a.EngineVolumeId = ev.Id
		JOIN Cities ct
		ON a.CityId = ct.Id
		JOIN OilTypes ot
		ON a.OilTypeId = ot.Id
		JOIN Transmissions tnm
		ON a.TransmissionId = tnm.Id
		JOIN Drivetrains dt
		ON a.DrivetrainId = dt.Id
		JOIN MileageTypes mt
		ON a.MileageTypeId = mt.Id
		JOIN Segments sg
		ON a.SegmentId = sg.Id
		JOIN ProductionYears py
		ON a.ProductionYearId = py.Id
		LEFT JOIN Autoshops ash
		ON a.AutoshopId = ash.Id
		FULL JOIN GET_PHOTOS_AS_ID ph
		ON ph.AnnouncementId = a.Id



CREATE TRIGGER CorrelateAnnouncementAndEquipmentAnnouncementTableAndPhotosTable
ON Announcements
AFTER INSERT 
AS
BEGIN
	DECLARE @Id int
	SELECT @Id = AnnouncementsList.Id from inserted AnnouncementsList
	INSERT INTO EquipmentAnnouncement VALUES(NULL,@Id)
	INSERT INTO Photos VALUES(NULL,@Id)
END

CREATE TRIGGER AddToDeletedTable
ON Announcements
INSTEAD OF DELETE
AS
BEGIN
	INSERT INTO DeletedAnnouncements
	SELECT AnnouncementsList.*, g.Euqipment, gp.Photos FROM deleted AnnouncementsList, GET_ANNOUNCEMENTS_WITH_EQUIPMENT_AS_ID g, GET_PHOTOS_AS_ID gp
	WHERE g.AnnouncementId = AnnouncementsList.Id
	DELETE FROM Announcements WHERE (SELECT AnnouncementsList.Id FROM deleted AnnouncementsList) = Announcements.Id
END


CREATE VIEW GET_ALL_DELETED_ANNOUNCEMENTS AS
SELECT	da.Id AS 'Announcement Id', 
	mk.Name AS 'Make',
	md.Name AS 'Model',
	crs.Name AS 'Color', 
	crns.Name AS 'Currency',
	ans.Name AS 'Status',
	ev.Name AS 'Engine Volume',
	ct.Name AS 'City',
	ot.Name AS 'Oil type',
	tnm.Name AS 'Transmision type',
	dt.Name AS 'Drivetrain',
	mt.Name AS 'Mileage type',
	sg.Name AS 'Segment',
	py.Year AS 'Production year',
	ash.Name as 'Autoshop name',
	da.Price,
	da.CreationDate,
	da.Email,
	da.PublisherFullname,
	da.PhoneNumber,
	da.IsInCredit,
	da.BarterPossible,
	da.AdditionalInfo,
	da.Mileage,
	da.Horsepower,
	da.Equipment,
	da.Photos
FROM DeletedAnnouncements da
JOIN Models md
ON da.ModelId = md.Id
JOIN Makes mk
ON md.MakeId = mk.Id
JOIN Colors crs
ON da.ColorId = crs.Id
JOIN Currencies crns
ON da.CurrencyId = crns.Id
JOIN AnnouncementStatuses ans
ON da.AnnouncementStatusId = ans.Id
JOIN EngineVolumes ev
ON da.EngineVolumeId = ev.Id
JOIN Cities ct
ON da.CityId = ct.Id
JOIN OilTypes ot
ON da.OilTypeId = ot.Id
JOIN Transmissions tnm
ON da.TransmissionId = tnm.Id
JOIN Drivetrains dt
ON da.DrivetrainId = dt.Id
JOIN MileageTypes mt
ON da.MileageTypeId = mt.Id
JOIN Segments sg
ON da.SegmentId = sg.Id
JOIN ProductionYears py
ON da.ProductionYearId = py.Id
LEFT JOIN Autoshops ash
ON da.AutoshopId = ash.Id


CREATE VIEW GET_ALL_ANNOUNCEMENTS AS
SELECT * FROM GET_ALL_DELETED_ANNOUNCEMENTS
UNION ALL
SELECT * FROM GET_ALL_ACTIVE_ANNOUNCEMENTS



CREATE PROCEDURE GetOverallIncomeFromAnnoucements
AS
SELECT SUM(COALESCE(st.Price+std.Price, st.Price, std.Price, 0)) AS 'Income since creation of the website' FROM GET_ALL_ANNOUNCEMENTS g
FULL JOIN Announcements a
ON g.[Announcement Id] = a.Id
FULL JOIN DeletedAnnouncements da
ON g.[Announcement Id] = da.Id
FULL JOIN AnnouncementStatuses st
ON a.AnnouncementStatusId = st.Id
FULL JOIN AnnouncementStatuses std
ON da.AnnouncementStatusId = std.Id

CREATE PROCEDURE GetIncomeByDateRange @StartDate nvarchar(30), @EndDate nvarchar(30)
AS
SELECT SUM(COALESCE(st.Price+std.Price, st.Price, std.Price, 0)) AS 'Income within given date range' FROM GET_ALL_ANNOUNCEMENTS g
FULL JOIN Announcements a
ON g.[Announcement Id] = a.Id
FULL JOIN DeletedAnnouncements da
ON g.[Announcement Id] = da.Id
FULL JOIN AnnouncementStatuses st
ON a.AnnouncementStatusId = st.Id
FULL JOIN AnnouncementStatuses std
ON da.AnnouncementStatusId = std.Id
WHERE g.CreationDate >= @StartDate AND g.CreationDate <= @EndDate

CREATE PROCEDURE GetAnnouncementsByDateRange @StartDate nvarchar(30), @EndDate nvarchar(30)
AS
SELECT * FROM GET_ALL_ACTIVE_ANNOUNCEMENTS g
WHERE g.CreationDate >= @StartDate AND g.CreationDate <= @EndDate 


CREATE PROCEDURE GetAnnouncementsByMake @Name nvarchar(50)
AS
SELECT * FROM GET_ALL_ACTIVE_ANNOUNCEMENTS g
WHERE g.Make = @Name


CREATE PROCEDURE GetAnnouncementsByModel @Name nvarchar(50)
AS
SELECT * FROM GET_ALL_ACTIVE_ANNOUNCEMENTS g
WHERE g.Model = @Name


CREATE PROCEDURE GetAnnouncementsByPriceRange @StartPrice decimal(10,2), @EndPrice decimal(10,2) = 99999999
AS
SELECT * FROM GET_ALL_ACTIVE_ANNOUNCEMENTS g
WHERE g.Price >= @StartPrice AND g.Price <= @EndPrice


CREATE PROCEDURE GetAnnouncementsByCity @Name nvarchar(50)
AS
SELECT * FROM GET_ALL_ACTIVE_ANNOUNCEMENTS g
WHERE g.City = @Name


CREATE PROCEDURE GetAnnouncementsByColor @Name nvarchar(50)
AS
SELECT * FROM GET_ALL_ACTIVE_ANNOUNCEMENTS g
WHERE g.Color = @Name


CREATE PROCEDURE GetAnnouncementsByOilType @Name nvarchar(50)
AS
SELECT * FROM GET_ALL_ACTIVE_ANNOUNCEMENTS g
WHERE g.[Oil type] = @Name


CREATE PROCEDURE GetAnnouncementsByTransmission @Name nvarchar(50)
AS
SELECT * FROM GET_ALL_ACTIVE_ANNOUNCEMENTS g
WHERE g.[Transmision type] = @Name


CREATE PROCEDURE GetAnnouncementsByCurrency @Name nvarchar(50)
AS
SELECT * FROM GET_ALL_ACTIVE_ANNOUNCEMENTS g
WHERE g.Currency = @Name


CREATE PROCEDURE GetAnnouncementsByDrivetrain @Name nvarchar(50)
AS
SELECT * FROM GET_ALL_ACTIVE_ANNOUNCEMENTS g
WHERE g.Drivetrain = @Name


CREATE PROCEDURE GetAnnouncementsBySegment @Name nvarchar(50)
AS
SELECT * FROM GET_ALL_ACTIVE_ANNOUNCEMENTS g
WHERE g.Segment = @Name


CREATE PROCEDURE GetAnnouncementsByEngineVolume @StartVolume int, @EndVolume int = 9999
AS
SELECT * FROM GET_ALL_ACTIVE_ANNOUNCEMENTS g
WHERE g.[Engine Volume] >= @StartVolume AND g.[Engine Volume] <= @EndVolume


CREATE PROCEDURE GetAnnouncementsByHorsepower @StartHp int, @EndHp int = 9999
AS
SELECT * FROM GET_ALL_ACTIVE_ANNOUNCEMENTS g
WHERE g.Horsepower >= @StartHp AND g.Horsepower <= @EndHp


CREATE PROCEDURE GetAnnouncementsByYearRange @StartYear int, @EndYear int = 9999
AS
SELECT * FROM GET_ALL_ACTIVE_ANNOUNCEMENTS g
WHERE g.[Production year] >= @StartYear AND g.[Production year] <= @EndYear


CREATE PROCEDURE GetAnnouncementsByMileage @StartMileage int, @EndMileage int = 999999999
AS
SELECT * FROM GET_ALL_ACTIVE_ANNOUNCEMENTS g
WHERE g.Mileage >= @StartMileage AND g.Mileage <= @EndMileage


CREATE PROCEDURE GetAnnouncementsBarterPossible
AS
SELECT * FROM GET_ALL_ACTIVE_ANNOUNCEMENTS g
WHERE g.BarterPossible = 1


CREATE PROCEDURE GetAnnouncementsIsInCredit
AS
SELECT * FROM GET_ALL_ACTIVE_ANNOUNCEMENTS g
WHERE g.IsInCredit = 1


CREATE PROCEDURE GetAnnouncementsByMileageType @Name nvarchar(50)
AS
SELECT * FROM GET_ALL_ACTIVE_ANNOUNCEMENTS g
WHERE g.[Mileage type] = @Name


CREATE FUNCTION GetOverallNumberOfAnnouncements()
RETURNS int 
AS
BEGIN
	DECLARE @Count int
	SELECT @Count = COUNT(g.[Announcement Id]) FROM GET_ALL_ANNOUNCEMENTS g
	RETURN @Count
END

CREATE FUNCTION GetNumberOfCarsInGivenMake(@Name nvarchar(50))
RETURNS int 
AS
BEGIN
	DECLARE @Count int
	SELECT @Count = COUNT(g.[Announcement Id]) FROM GET_ALL_ACTIVE_ANNOUNCEMENTS g
	WHERE g.Make = @Name
	RETURN @Count
END


CREATE FUNCTION GetNumberOfCarsInGivenModel(@Name nvarchar(50))
RETURNS int 
AS
BEGIN
	DECLARE @Count int
	SELECT @Count = COUNT(g.[Announcement Id]) FROM GET_ALL_ACTIVE_ANNOUNCEMENTS g
	WHERE g.Model = @Name
	RETURN @Count
END



CREATE FUNCTION GetNumberOfCarsWithGivenStatus(@Name nvarchar(50))
RETURNS int 
AS
BEGIN
	DECLARE @Count int
	SELECT @Count = COUNT(g.[Announcement Id]) FROM GET_ALL_ACTIVE_ANNOUNCEMENTS g
	WHERE g.Status = @Name
	RETURN @Count
END



CREATE FUNCTION GetNumberOfCarsWithBarterPossible()
RETURNS int 
AS
BEGIN
	DECLARE @Count int
	SELECT @Count = COUNT(g.[Announcement Id]) FROM GET_ALL_ACTIVE_ANNOUNCEMENTS g
	WHERE g.BarterPossible = 1
	RETURN @Count
END


CREATE FUNCTION GetNumberOfCarsWithCredit()
RETURNS int 
AS
BEGIN
	DECLARE @Count int
	SELECT @Count = COUNT(g.[Announcement Id]) FROM GET_ALL_ACTIVE_ANNOUNCEMENTS g
	WHERE g.IsInCredit = 1
	RETURN @Count
END

CREATE PROCEDURE GetAnnouncementsByAutoshopName @Name nvarchar(50)
AS
SELECT * FROM GET_ALL_ACTIVE_ANNOUNCEMENTS g
WHERE g.[Autoshop name] = @Name


------------------------------------------------------------------



--main commands are declared below

SELECT * FROM GET_ALL_DELETED_ANNOUNCEMENTS
SELECT * FROM GET_ALL_ACTIVE_ANNOUNCEMENTS
SELECT * FROM GET_ALL_ANNOUNCEMENTS
EXEC GetOverallIncomeFromAnnoucements
EXEC GetIncomeByDateRange @StartDate = '2021/02/14', @EndDate = '2021/09/28'
EXEC GetAnnouncementsByMake @Name = 'Mercedes'
EXEC GetAnnouncementsByModel @Name = 'Prado'
EXEC GetAnnouncementsByPriceRange @StartPrice = 50000, @EndPrice = 100000
EXEC GetAnnouncementsByCity @Name = 'Ganja'
EXEC GetAnnouncementsByColor @Name = 'White'
EXEC GetAnnouncementsByOilType @Name = 'Petrol'
EXEC GetAnnouncementsByTransmission @Name = 'Automatic'
EXEC GetAnnouncementsByCurrency @Name = 'USD'
EXEC GetAnnouncementsByDrivetrain @Name = 'AWD'
EXEC GetAnnouncementsBySegment @Name = 'SUV'
EXEC GetAnnouncementsByEngineVolume @StartVolume = 2500
EXEC GetAnnouncementsByDateRange @StartDate = '2021/03/23', @EndDate = '2021/08/30'
EXEC GetAnnouncementsByHorsepower @StartHp = 3, @EndHp = 100
EXEC GetAnnouncementsByYearRange @StartYear = 2014, @EndYear = 2019
EXEC GetAnnouncementsByMileage @StartMileage = 799
EXEC GetAnnouncementsBarterPossible 
EXEC GetAnnouncementsIsInCredit
EXEC GetAnnouncementsByMileageType @Name = 'KM'
SELECT dbo.GetOverallNumberOfAnnouncements() AS 'Number of announcements till this day'
SELECT dbo.GetNumberOfCarsInGivenMake('Toyota') AS 'Number of announcements with the given make name'
SELECT dbo.GetNumberOfCarsInGivenModel('S-class') AS 'Number of announcements with the given model name'
SELECT dbo.GetNumberOfCarsWithGivenStatus('Vip') AS 'Number of announcements with the given status'
SELECT dbo.GetNumberOfCarsWithBarterPossible() AS 'Number of announcements with possible barter'
SELECT dbo.GetNumberOfCarsWithCredit() AS 'Number of announcements with credit'
EXEC GetAnnouncementsByAutoshopName @Name = 'Nurgun Motors'