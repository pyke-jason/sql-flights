USE INFO430_Proj_06

CREATE TABLE tblCOUNTRY 
(CountryID INT IDENTITY(1,1) Primary Key,
CountryName varchar(100) not null)

CREATE TABLE tblSTATE 
(StateID INT IDENTITY(1,1) Primary Key,
CountryID INT FOREIGN KEY REFERENCES tblCOUNTRY (CountryID),
StateName varchar(100) not null)

CREATE TABLE tblCITY 
(CityID INT IDENTITY(1,1) Primary Key,
StateID INT FOREIGN KEY REFERENCES tblSTATE (StateID),
CityName varchar(100) not null)

CREATE TABLE tblAIRPORT 
(AirportID INT IDENTITY(1,1) Primary Key,
CityID INT FOREIGN KEY REFERENCES tblCITY (CityID),
AirportName varchar(250) not null,
AirportAddress varchar(500) null)

CREATE TABLE tblAIRPORT_TERMINAL 
(TerminalID INT IDENTITY(1,1) Primary Key,
AirportID INT FOREIGN KEY REFERENCES tblAIRPORT (AirportID),
TerminalName varchar(100) not null)

CREATE TABLE tblAIRPORT_GATE 
(GateID INT IDENTITY(1,1) Primary Key,
TerminalID INT FOREIGN KEY REFERENCES tblAIRPORT_TERMINAL (TerminalID),
GateNumber varchar(5) not null) --change up gateNo.

CREATE TABLE tblAIRLINE 
(AirlineID INT IDENTITY(1,1) Primary Key,
AirlineName varchar(100) not null,
AirlineDesc varchar(500) null)

CREATE TABLE tblSTATUS 
(StatusID INT IDENTITY(1,1) Primary Key,
StatusName varchar(100) not null)

CREATE TABLE tblFLIGHT 
(FlightID INT IDENTITY(1,1) Primary Key,
AirlineID INT FOREIGN KEY REFERENCES tblAIRLINE (AirlineID) not null,
DepartGateID INT FOREIGN KEY REFERENCES tblAIRPORT_GATE (GateID) not null,
ArrivalGateID INT FOREIGN KEY REFERENCES tblAIRPORT_GATE (GateID) not null,
FlightTime Time null)

CREATE TABLE tblFLIGHT_STATUS 
(FlightStatusID INT IDENTITY(1,1) Primary Key, 
FlightID INT FOREIGN KEY REFERENCES tblFLIGHT (FlightID) not null,
StatusID INT FOREIGN KEY REFERENCES tblSTATUS (StatusID) not null,
BeginTime Date not null,
EndTime Date not null)

CREATE TABLE tblCUSTOMER_TYPE 
(CustomerTypeID INT IDENTITY(1,1) Primary Key,
CustomerTypeName varchar(100) not null)

CREATE TABLE tblCUSTOMER 
(CustomerID INT IDENTITY(1,1) Primary Key,
CustomerTypeID INT FOREIGN KEY REFERENCES tblCUSTOMER_TYPE (CustomerTypeID) null,
CustFname varchar(100) not null,
CustLname varchar(100) not null,
CustomerDOB Date not null)

CREATE TABLE tblTICKET 
(TicketID INT IDENTITY(1,1) Primary Key,
FlightID INT FOREIGN KEY REFERENCES tblFLIGHT (FlightID) not null,
CustomerID INT FOREIGN KEY REFERENCES tblCUSTOMER (CustomerID) not null,
TicketPrice Numeric(10,2) not null)

CREATE TABLE tblPROGRESS 
(ProgressID INT IDENTITY(1,1) Primary Key,
ProgressName varchar(100) not null,
ProgressDesc varchar(500) null)

CREATE TABLE tblTICKET_PROGRESS 
(TicketProgressID INT IDENTITY(1,1) Primary Key,
TicketID INT FOREIGN KEY REFERENCES tblTICKET (TicketID) not null,
ProgressID INT FOREIGN KEY REFERENCES tblPROGRESS (ProgressID) not null,
DateLogged Date not null)
