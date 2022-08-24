-- CC1: List the current number of customers for each airline, year to date
CREATE FUNCTION fn_NumCustomers(@PK INT)
RETURNS INT
AS
BEGIN
 
DECLARE @RET INT = 
    (SELECT COUNT (DISTINCT C.CustomerID)
    FROM tblFLIGHT F
        JOIN tblAIRLINE AL ON F.airlineID = AL.airlineID
        JOIN tblTICKET T ON F.flightID = T.flightID
        JOIN tblCUSTOMER C ON T.customerID = C.customerID
    WHERE AL.airlineID = @PK)
RETURN @RET
END
GO
 
ALTER TABLE tblAIRLINE
ADD CalcNumCust AS (dbo.fn_NumCustomers(AirlineID))

-- CC2: List the number of flights per customer.
CREATE FUNCTION fn_NumFlights(@PK INT)
RETURNS
INT
AS
BEGIN
 
DECLARE @RET INT=
    (SELECT COUNT (DISTINCT F.flightID)
    FROM tblFLIGHT F
        JOIN tblAIRLINE AL ON F.airlineID = AL.airlineID
        JOIN tblTICKET T ON F.flightID = T.flightID
        JOIN tblCUSTOMER C ON T.customerID = C.customerID
    WHERE C.customerID = @PK)
RETURN @RET
END
GO
 
ALTER TABLE tblCUSTOMER
ADD CalcNumFlights AS (dbo.fn_NumFligths(CustomerID))

-- CC3: Compute out  FLIGHT_STATUS begin and end times to find the No_Days_Affected.
CREATE FUNCTION fn_FlightDelayLength (@PK INT)
RETURNS INT
AS
BEGIN

DECLARE @RET INT = (SELECT DATEDIFF(Day, BeginTime, EndTime) 
FROM tblFLIGHT_STATUS
WHERE FlightStatusID = @PK)

RETURN @RET
END

ALTER TABLE tblFLIGHT_STATUS
ADD DaysDelay AS (dbo.fn_FlightDelayLength(FlightStatusID))

-- CC4: Calculate the total TicketPrice income for each airline.
CREATE FUNCTION fn_TicketPrice(@PK INT)
RETURNS NUMERIC(10,2)
AS
BEGIN
 
DECLARE @RET NUMERIC(10,2) = (SELECT SUM(T.TicketPrice) AS TotalIncome
                               FROM tblFLIGHT F
                                   JOIN tblAIRLINE AL ON F.airlineID = AL.airlineID
                                   JOIN tblTICKET T ON F.flightID = T.flightID
                                   JOIN tblCUSTOMER C ON T.customerID = C.customerID
                               WHERE AL.airlineID = @PK)
RETURN @RET
END
GO
 
ALTER TABLE tblAIRLINE
ADD CalcTotalIncome
AS (dbo.fn_TicketPrice(AirlineID))

-- CC5: Calculate the number of flights for each airline year to date.
CREATE FUNCTION fn_NumFlights(@PK INT)
RETURNS INT
AS
BEGIN
 
DECLARE @RET INT = (SELECT COUNT(F.FlightID) AS NumFlights
                   FROM tblFLIGHT F
                       JOIN tblAIRLINE AL ON F.airlineID = AL.airlineID
                       JOIN tblTICKET T ON F.flightID = T.flightID
                       JOIN tblCUSTOMER C ON T.customerID = C.customerID
                   WHERE YEAR(F.flightTime) = YEAR(GETDATE())
                   AND AL.AirlineID = @PK)
RETURN @RET
END
GO
 
ALTER TABLE tblAIRLINE
ADD CalcNumFlights
AS (dbo.fn_NumFlights(AL.AirlineID))

-- CC6: Calculate the number of passengers traveling through an airport in the last month
CREATE FUNCTION fn_CalcAirportPassengersLastMonth(@APK INT)
RETURNS INT
AS
BEGIN
	DECLARE @RET INT = (SELECT Sum(F.Passengers) 
		FROM tblAIRPORT A
		JOIN tblAIRPORT_TERMINAL ATM ON A.AirportID = ATM.AirportID
		JOIN tblAIRPORT_GATE AG ON ATM.TerminalID = AG.TerminalID
		JOIN tblFLIGHT F ON AG.GateID = F.DepartGateID
		JOIN tblFLIGHT F1 ON AG.GateID = F1.ArrivalGateID
		JOIN (SELECT F.FlightID as FID, MAX(FS.BeginTime) as FTime 
			FROM tblFLIGHT F
			JOIN tblFLIGHT_STATUS FS ON F.FlightID = FS.FlightID
			GROUP BY F.FlightID) 
		AS FT ON FT.FID = F.FlightID
		WHERE A.AirportID = @APK AND
			DATEADD(MONTH, -1, GETDATE()) > DAY(FT.FTime)
		)
	RETURN @RET
END
-- CC7: Calculate the average delay length for each airline, where the issue started in 2020.
CREATE FUNCTION fn_AirlineAvgDelay(@PK INT)
RETURNS INT
AS
BEGIN 

DECLARE @RET INT = (SELECT AVG(DATEDIFF(Day, FS.BeginTime, FS.EndTime))
	FROM tblAIRLINE A
	JOIN tblFLIGHT F on F.AirlineID = A.AirlineID
	JOIN tblFLIGHT_STATUS FS ON FS.FlightID = F.FlightID
	WHERE YEAR(FS.BeginTime) = '2020'
	AND A.AirlineID = @PK)
RETURN @RET
END


-- CC8: Calculate the income Alaska Air earned from flights departing each airport. 
CREATE FUNCTION fn_AlaskaProfit (@PK INT)
RETURNS NUMERIC(10,2)
AS
BEGIN

DECLARE @RET NUMERIC(10,2) = (SELECT SUM(T.TicketPrice)
	FROM tblFLIGHT F
	JOIN tblAIRLINE A ON F.AirlineID = A.AirlineID
    JOIN tblTICKET T ON F.FlightID = T.FlightID
    JOIN tblAIRPORT_GATE AG ON AG.GateID = F.DepartGateID
	JOIN tblAIRPORT_TERMINAL AIT ON AIT.TerminalID = AG.TerminalID
	JOIN tblAIRPORT AIR ON AIR.AirportID = AIT.AirportID
	WHERE AIR.AirportID = @PK)
RETURN @RET 
END


ALTER TABLE tblAIRPORT
ADD AlaskaAirProfit
AS (dbo.fn_AlaskaProfit(AirportID))


