-- BR1: A flight status cannot be added if flight has a negative flight time and if status was ever logged as 'On Time'.
CREATE FUNCTION fn_FlightNeg()
RETURNS INTEGER
AS
BEGIN

DECLARE @RET INT = 0
IF EXISTS (SELECT *
FROM tblFLIGHT_STATUS FS
JOIN tblFLIGHT F ON F.FlightID = FS.FlightID 
JOIN tblSTATUS S ON S.StatusID = FS.StatusID
WHERE F.FlightTime < CAST('00:00:00' AS Time)
AND S.StatusName = 'On Time')

	SET @RET = 1
	RETURN @RET
	END

GO

ALTER TABLE tblFLIGHT_STATUS
ADD CONSTRAINT NoNegRule
CHECK (dbo.fn_FlightNeg() = 0)

GO

-- BR2:  Flight status end time cannot be more than 1 month after start time if the status is Staff Delays.
CREATE FUNCTION fn_StatusEnd()
RETURNS INTEGER
AS
BEGIN

DECLARE @RET INT = 0
IF EXISTS (SELECT *
FROM tblFLIGHT_STATUS FS
JOIN tblSTATUS S ON S.StatusID = FS.StatusID
WHERE S.StatusName = 'Staff Delays'
AND FS.EndTime < DATEADD(MONTH, 1, FS.BeginTime))

SET @RET = 1
RETURN @RET
END

GO

ALTER TABLE tblFLIGHT_STATUS
ADD CONSTRAINT StatusEndLength
CHECK (dbo.fn_StatusEnd() = 0)

GO

--BR3: Ticket price cannot be negative if the flight has status of 'On Time'. 
CREATE FUNCTION fn_NoNegTix() 
RETURNS INTEGER
AS
BEGIN

DECLARE @RET INT = 0
IF EXISTS (SELECT * 
FROM tblTICKET T
	JOIN tblFLIGHT F ON F.FlightID = T.FlightID
	JOIN tblFLIGHT_STATUS FS ON FS.FlightID = F.FlightID
	JOIN tblSTATUS S ON S.StatusID = FS.StatusID
WHERE S.StatusName = 'On Time'
AND T.TicketPrice < 0) 

SET @RET = 1
RETURN @RET
END

GO

ALTER TABLE tblTICKET
ADD CONSTRAINT NoNegTix
CHECK (dbo.fn_NoNegTix() = 0)

GO

--BR4: A flight's departure gate cannot be the same as it’s arrival gate.

CREATE FUNCTION fn_NoDepartfromArr()
RETURNS INT
AS
BEGIN
DECLARE @RET INT = 0
IF EXISTS (SELECT *
            FROM tblFLIGHT F
                JOIN tblAIRPORT_GATE AG ON F.departGateID = AG.gateID -- is this what I join on?
            WHERE F.departGateID = F.arrivalGateID)
SET @RET = 1
RETURN @RET
END
GO
ALTER TABLE tblFLIGHT
ADD CONSTRAINT CK_nosamegate
CHECK (dbo.fn_NoDepartfromArr() = 0)
GO

-- BR5: Customers may not have a birth year in the future.

CREATE FUNCTION fn_NoFutureBirth()
RETURNS INT
AS
BEGIN
DECLARE @RET INT = 0
IF EXISTS (SELECT *
            FROM tblCUSTOMER C
            WHERE C.customerDOB > GetDate())
SET @RET = 1
RETURN @RET
END
GO
ALTER TABLE tblCUSTOMER
ADD CONSTRAINT CK_notimetravel
CHECK (dbo.fn_NoFutureBirth() = 0)
GO

-- BR6: No Customer younger than 16 can buy their own ticket for a flight.
CREATE FUNCTION fn_Younger16()
RETURNS INT
AS
BEGIN
 
DECLARE @RET INT = 0
IF EXISTS (SELECT *
           FROM tblCustomer C
               JOIN tblTicket T ON C.CustomerID = T.CustomerID
           WHERE C.CustomerDOB < DATEADD(YEAR, -16, GETDATE()))
SET @RET = 1
RETURN @RET
END
GO
 
ALTER TABLE tblTicket
ADD CONSTRAINT ck_NoBuy
CHECK (dbo.fn_Younger16() = 0)
GO

-- BR7:  No flight can have a flight time of zero minutes if there is at least one customer.
CREATE FUNCTION fn_FlightTime()
RETURNS INT
AS
BEGIN
 
DECLARE @RET INT = 0
IF EXISTS (SELECT F.FlightName, COUNT(C.CustomerID) AS NumCustomers
           FROM tblFlight F
               JOIN tblTicket T ON F.FlightID = T.FlightID
               JOIN tblCustomer C ON T.CustomerID = C.CustomerID
           WHERE F.FlightTime < CAST('00:00:00' AS Time)
           GROUP BY F.FlightName
           HAVING  COUNT(C.CustomerID) >= 1)
SET @RET = 1
RETURN @RET
END
GO
 
ALTER TABLE tblFlight
ADD CONSTRAINT ck_FlightTimeNot0
CHECK (dbo.fn_FlightTime() = 0)

GO

-- BR8: No ticket may be issued for United Airlines flights which arrive in North Korea.
CREATE FUNCTION fn_IntlBlock()
RETURNS INTEGER
AS
BEGIN

DECLARE @RET INT = 0
IF EXISTS (SELECT *
FROM tblTICKET T
	JOIN tblFLIGHT F ON F.FlightID = T.FlightID
	JOIN tblAIRLINE AIR ON AIR.AirlineID = F.AirlineID
	JOIN tblAIRPORT_GATE AG ON AG.GateID = F.ArrivalGateID
	JOIN tblAIRPORT_TERMINAL ART ON ART.TerminalID = AG.TerminalID
	JOIN tblAIRPORT APT ON APT.AirportID = ART.AirportID
	JOIN tblCITY C ON C.CityID = APT.CityID
	JOIN tblSTATE S ON S.StateID = C.StateID
	JOIN tblCOUNTRY COU ON COU.CountryID = S.CountryID
WHERE AIR.AirlineName = 'United Airlines'
AND COU.CountryName = 'North Korea')

SET @RET = 1
RETURN @RET
END

GO

ALTER TABLE tblTICKET
ADD CONSTRAINT IntlBlocker
CHECK (dbo.fn_IntlBlock() = 0)
