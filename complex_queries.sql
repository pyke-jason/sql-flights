-- CQ1: What are the top 3 most profitable airlines departing from the US in 2021?
SELECT TOP 3 AL.AirlineName, SUM(T.TicketPrice) AS TotalIncome
FROM tblAIRLINE AL
JOIN tblFLIGHT F ON AL.AirlineID = F.AirlineID
JOIN tblTICKET T ON T.FlightID = F.FlightID
JOIN tblTICKET_PROGRESS TP ON TP.TicketID = T.TicketID
JOIN tblAIRPORT_GATE AG ON F.DepartGateID = AG.GateID
JOIN tblAIRPORT_TERMINAL AIT ON AIT.TerminalID = AG.TerminalID
JOIN tblAIRPORT AIR ON AIR.AirportID = AIT.AirportID
JOIN tblCITY C ON C.CityID = AIR.CityID
JOIN tblSTATE S ON S.StateID = C.StateID
JOIN tblCOUNTRY COU ON COU.CountryID = S.CountryID
WHERE COU.CountryName = 'United States'
AND YEAR(TP.DateLogged) = '2021'
GROUP BY AirlineName
ORDER BY TotalIncome DESC

-- CQ2: Which customers under the age of 18 years have had more than 3 flights in 2020?
SELECT C.CustFname, C.CustLname, COUNT(*) AS CustFlightCount
FROM tblCUSTOMER C
JOIN tblTICKET T ON T.CustomerID = C.CustomerID
JOIN tblFLIGHT F ON F.FlightID = T.FlightID
JOIN tblTICKET_PROGRESS TP ON TP.TicketID = T.TicketID
WHERE YEAR(TP.DateLogged) = '2020'
AND C.CustomerDOB < DATEADD(YEAR, -18, GETDATE())
GROUP BY C.CustFname, C.CustLname
HAVING COUNT(*) > 3

-- CQ3: Which airport has had the longest delays of type “Technical Fault” in Germany in 2020?
SELECT TOP 1 AIR.AirportName, DATEDIFF(Day, FS.BeginTime, FS.EndTime) AS DelayLength
FROM tblAIRPORT AIR
JOIN tblCITY C ON C.CityID = AIR.CityID
JOIN tblSTATE S ON S.StateID = C.StateID
JOIN tblCOUNTRY COU ON COU.CountryID = S.CountryID
JOIN tblAIRPORT_TERMINAL AIT ON AIT.AirportID = AIR.AirportID
JOIN tblAIRPORT_GATE AG ON AG.TerminalID = AIT.TerminalID
JOIN tblFLIGHT F ON F.ArrivalGateID = AG.GateID
JOIN tblFLIGHT_STATUS FS ON FS.FlightID = F.FlightID
JOIN tblSTATUS ST ON ST.StatusID = FS.StatusID
JOIN tblTICKET T ON T.FlightID = F.FlightID
JOIN tblTICKET_PROGRESS TP ON TP.TicketID = T.TicketID
WHERE ST.StatusName = 'Technical Fault'
AND YEAR(TP.DateLogged) = '2020'
AND COU.CountryName = 'Germany'
GROUP BY AIR.AirportName, DATEDIFF(Day, FS.BeginTime, FS.EndTime)
ORDER BY DelayLength

-- CQ4: What are the top 3 airlines that fly out of SeaTac airport that had the most flights with a status of ‘cancelled’ this month and also had at least 1,000 customers ages 18 and older this year?
WITH CTE_NumCancel (AirlineID, AirlineName, NumCancel)
AS
(SELECT TOP 3 AL.airlineID, AL.airlineName, COUNT(F.flightID) AS NumCancel
FROM tblFLIGHT F
    JOIN tblAIRLINE AL ON F.airlineID = AL.airlineID
    JOIN tblFLIGHT_STATUS FS ON F.flightID = FS.flightID
    JOIN tblSTATUS S ON FS.statusID = S.statusID
WHERE S.statusname = 'Canceled'
    AND MONTH(F.flightTime) = MONTH(GETDATE())
GROUP BY AL.airlineID, AL.airlineName),

CTE_NumCust (AirlineID, AirlineName, NumCustomers)
AS
(SELECT AL.airlineID, AL.airlineName, COUNT(*) AS NumCustomers
FROM tblFLIGHT F
    JOIN tblAIRLINE AL ON F.airlineID = AL.airlineID
    JOIN tblTICKET T ON F.flightID = T.flightID
    JOIN tblCUSTOMER C ON T.customerID = C.customerID
WHERE C.customerDOB < DateAdd(year,-18, GetDate())
    AND YEAR(F.flightTime) = YEAR(GETDATE())
GROUP BY AL.airlineID, AL.airlineName
HAVING COUNT(DISTINCT C.CustomerID) >= 1000)


SELECT A.airlineID, A.airlineName, A.NumCancel, B.NumCustomers
FROM CTE_NumCancel A
	JOIN CTE_NumCust B ON A.AirlineID = B.AirlineID

-- CQ5: What airport has the most incoming flights with Alaska Airlines that also had more than 1000 flights flying to Miami this year?
SELECT A.airportID, A.airportName, A.NumAlaskaFlights, B.NumMiamiFlights
   FROM
 
   (SELECT TOP 1 AP.airportID, AP.airportName, COUNT(F.flightID) NumAlaskaFlights
   FROM tblFLIGHT F
       JOIN tblAIRPORT_GATE AG ON F.arrivalGateID = AG.gateID
       JOIN tblAIRPORT_TERMINAL APT ON AG.terminalID = APT.terminalID
       JOIN tblAIRPORT AP ON APT.airportID = AP.airportID
   WHERE AP.airportName = 'Alaska Airlines'
   GROUP BY AP.airportID, AP.airportName) AS A,
 
   (SELECT AP.airportID, AP.airportName, COUNT(*) NumMiamiFlights
   FROM tblFLIGHT F
       JOIN tblAIRPORT_GATE AG ON F.arrivalGateID = AG.gateID
       JOIN tblAIRPORT_TERMINAL APT ON AG.terminalID = APT.terminalID
       JOIN tblAIRPORT AP ON APT.airportID = AP.airportID
       JOIN tblCITY C ON AP.cityID = C.cityID
       JOIN tblSTATE S ON C.stateID = S.stateID
   WHERE C.cityName = 'Miami'
       AND S.stateName = 'Florida'
       AND YEAR(F.flightTime) = YEAR(GETDATE())
   GROUP BY AP.airportID, AP.airportName
   HAVING COUNT(F.flightID) > 1000) AS B
 
   WHERE A.airportID = B.airportID

-- CQ6: What airline had the most customers departing from Seattle, Washington in 2010 born before 1999 that also had more than 6 customers with a last name starting with 'L' in 2009 born after 1999.
SELECT A.AirlineID, A.AirlineName, A.CustomerID, A.CustFname, A.CustLname, A.NumCustomersDepart, B.NumCustomerLname
FROM
(SELECT TOP 1 AL.AirlineID, AL.AirlineName, C.CustomerID, C.CustFname, C.CustLname, COUNT(C.CustomerID) AS NumCustomersDepart
FROM tblCustomer C
   JOIN tblTICKET T ON C.CustomerID = T.CustomerID
   JOIN tblFLIGHT F ON T.FlightID = F.FlightID
   JOIN tblAIRLINE AL ON F.AirlineID = AL.AirlineID
   JOIN tblAIRPORT_GATE AG ON F.DepartGateID = AG.GateID
   JOIN tblAIRPORT_TERMINAL APT ON AG.TerminalID = APT.TerminalID
   JOIN tblAIRPORT A ON APT.AirportID = A.AirportID
   JOIN tblCITY CT ON A.CityID = CT.CityID
   JOIN tblSTATE S ON CT.StateID = S.StateID
WHERE S.StateName = 'Washington'
AND CT.CityName = 'Seattle'
AND YEAR(C.CustomerDOB) < 1999
AND YEAR(F.FlightTime) = 2010
GROUP BY AL.AirlineID, AL.AirlineName, C.CustomerID, C.CustFname, C.CustLname) AS A,
 
(SELECT AL.AirlineID, AL.AirlineName, C.CustomerID, C.CustFname, C.CustLname, COUNT(*) AS NumCustomerLname
FROM tblCustomer C
   JOIN tblTICKET T ON C.CustomerID = T.CustomerID
   JOIN tblFLIGHT F ON T.FlightID = F.FlightID
   JOIN tblAIRLINE AL ON F.AirlineID = AL.AirlineID
WHERE C.CustLname LIKE 'L%'
AND YEAR(C.CustomerDOB) > 1999
AND YEAR(F.FlightTime) = 2009
GROUP BY AL.AirlineID, AL.AirlineName, C.CustomerID, C.CustFname, C.CustLname
HAVING COUNT(DISTINCT C.CustomerID) > 6) AS B
 
WHERE A.AirlineID = B.AirlineID

-- CQ7: How many tickets have a progress name ‘Purhcased’ that also have a flight status name of ‘on-time’
 SELECT P.ProgressName, S.StatusName, COUNT(*) AS NumTickets
FROM tblTicket T
   JOIN tblTicket_Progress TP ON T.TicketID = TP.TicketID
   JOIN tblProgress P ON TP.ProgressID = P.ProgressID
   JOIN tblFlight F ON T.FlightID = F.FlightID
   JOIN tblFlight_Status FS ON F.FlightID = FS.FlightID
   JOIN tblStatus S ON FS.StatusID = S.StatusID
WHERE P.ProgressName = 'Purchased'
AND S.StatusName = 'On-Time'
GROUP BY P.ProgressName, S.StatusName

-- CQ8: What are the top 10 airlines that had the most flights in the 2010s from Nevada that also had a flight status of ‘canceled’ more than 50 times.
SELECT A.AirlineID, A.AirlineName, A.StateName, B.StatusName, A.NumFlights, B.TotalCancelled
FROM
(SELECT TOP 10 AIR.AirlineID, AIR.AirlineName, S.StateName, COUNT(F.FlightID) AS NumFlights
FROM tblAirline AIR
   JOIN tblFlight F ON AIR.AirlineID = F.AirlineID
   JOIN tblAIRPORT_GATE AG ON F.ArrivalGateID = AG.GateID
   JOIN tblAIRPORT_TERMINAL APT ON AG.TerminalID = APT.TerminalID
   JOIN tblAirport A ON APT.AirportID = A.AirportID
   JOIN tblCity C ON A.CityID = C.CityID
   JOIN tblState S ON C.StateID = S.StateID
WHERE YEAR(F.FlightTime) LIKE '201%'
AND S.StateName = 'Nevada'
GROUP BY AIR.AirlineID, AIR.AirlineName, S.StateName) AS A,
 
(SELECT TOP 10 AIR.AirlineID, AIR.AirlineName, ST.StatusName, S.StateName, COUNT(ST.StatusID) AS TotalCancelled
FROM tblAirline AIR
   JOIN tblFlight F ON AIR.AirlineID = F.AirlineID
   JOIN tblFlight_Status FS ON F.FlightID = FS.FlightID
   JOIN tblStatus ST ON FS.StatusID = ST.StatusID
   JOIN tblAIRPORT_GATE AG ON F.ArrivalGateID = AG.GateID
   JOIN tblAIRPORT_TERMINAL APT ON AG.TerminalID = APT.TerminalID
   JOIN tblAirport A ON APT.AirportID = A.AirportID
   JOIN tblCity C ON A.CityID = C.CityID
   JOIN tblState S ON C.StateID = S.StateID
WHERE ST.StatusName = 'Canceled'
AND S.StateName = 'Nevada'
GROUP BY AIR.AirlineID, AIR.AirlineName, ST.StatusName, S.StateName
HAVING COUNT(ST.StatusID) > 50) AS B
WHERE A.AirlineName = B.AirlineName

