CREATE PROCEDURE FinalSynInsertFlight
@RUN INT 

AS

DECLARE
@AirlineNameSyn varchar(100),
@DepartAirportSyn varchar(250),
@DepartTerminalSyn varchar(100),
@DepartGateSyn varchar(250),
@ArriveAirportSyn varchar(250),
@ArriveTerminalSyn varchar(100),
@ArriveGateSyn varchar(250),
@FlightTimeSyn Time,
@FlightNameSyn varchar(100)

--randomize based on protocol; airport name, random gate and number

WHILE @RUN > 0
BEGIN
--random valid airport (only first 10 are populated)
DECLARE @DAP_ID INT = (SELECT RAND() * 10 + 1)
DECLARE @AAP_ID INT = (SELECT RAND() * 10 + 1)

SET @DepartAirportSyn = (SELECT AirportName FROM tblAIRPORT WHERE AirportID = @DAP_ID)
SET @ArriveAirportSyn = (SELECT AirportName FROM tblAIRPORT WHERE AirportID = @AAP_ID)

-- random valid terminal (A thru D)
DECLARE @DAT_ID INT = (SELECT RAND() * 4 + 1)
DECLARE @AAT_ID INT = (SELECT RAND() * 4 + 1)

SET @DepartTerminalSyn = (SELECT 
(CASE 
	WHEN @DAT_ID = 1
		THEN CONCAT(@DepartAirportSyn , ' A')
	WHEN @DAT_ID = 2
		THEN CONCAT(@DepartAirportSyn , ' B')
	WHEN @DAT_ID = 3
		THEN CONCAT(@DepartAirportSyn , ' C')
	WHEN @DAT_ID = 4
		THEN CONCAT(@DepartAirportSyn , ' D')
		END))

SET @ArriveTerminalSyn = (SELECT 
(CASE 
	WHEN @AAT_ID = 1
		THEN CONCAT(@ArriveAirportSyn , ' A')
	WHEN @AAT_ID = 2
		THEN CONCAT(@ArriveAirportSyn , ' B')
	WHEN @AAT_ID = 3
		THEN CONCAT(@ArriveAirportSyn , ' C')
	WHEN @AAT_ID = 4
		THEN CONCAT(@ArriveAirportSyn , ' D')
		END))

-- random gate number (1-8)
DECLARE @DAG_ID INT = (SELECT RAND() * 8 + 1)
DECLARE @AAG_ID INT = (SELECT RAND() * 8 + 1)

SET @DepartGateSyn = (SELECT CONCAT(@DepartTerminalSyn, @DAG_ID))
SET @ArriveGateSyn = (SELECT CONCAT(@ArriveTerminalSyn, @AAG_ID))

-- set airline
DECLARE @AirlineCount INT = (SELECT COUNT(*) FROM tblAIRLINE)

DECLARE @AL_ID INT

SET @AL_ID = (SELECT RAND() * @AirlineCount + 1)
SET @AirlineNameSyn = (SELECT AirlineName FROM tblAIRLINE WHERE AirlineID = @AL_ID)

--set time
SET @FlightTimeSyn = (SELECT DATEADD(s, RAND() * 40000, CAST('00:00:00' AS Time)))

--set a name (random letter + 3 numbers)
DECLARE @RandPrefixNo INT = (SELECT RAND() * 4 + 1)

DECLARE @RandPrefix varchar(5) = (SELECT
(CASE 
	WHEN @RandPrefixNo = 1
		THEN 'A'
	WHEN @RandPrefixNo = 2
		THEN 'B'
	WHEN @RandPrefixNo = 3
		THEN 'C'
	WHEN @RandPrefixNo = 4
		THEN 'D' END))

DECLARE @FltNum INT = (SELECT RAND() * 999 + 1)

SET @FlightNameSyn = (SELECT CONCAT(@RandPrefix, @FltNum))

--pack it all in. 


EXEC InsertFlight
@AirlineName = @AirlineNameSyn,
@DepartGate = @DepartGateSyn,
@ArriveGate = @ArriveGateSyn,
@FlightTimeStart = @FlightTimeSyn,
@FlightNameStart = @FlightNameSyn

SET @RUN = @RUN - 1
END

EXEC FinalSynInsertFlight 10000

GO

CREATE PROCEDURE SynTicket
@RUN INT 

AS

DECLARE
@FlightNameSyn varchar(100),
@FlightDGateSyn varchar(250),
@FlightAGateSyn varchar(250),
@FlightAirlineSyn varchar(100),
@CustFnameSyn varchar(100),
@CustLnameSyn varchar(100),
@CustDOBSyn Date,
@TixPriceSyn Numeric(10,2)

WHILE @RUN > 0
BEGIN

DECLARE @FlightRowCount INT = (SELECT COUNT(*) FROM tblFLIGHT)
DECLARE @CustRowCount INT = (SELECT COUNT(*) FROM tblCUSTOMER)

DECLARE @FL_PK INT, @CS_PK INT

SET @FL_PK = (SELECT RAND() * @FlightRowCount + 1)
SET @CS_PK = (SELECT RAND() * @CustRowCount + 1)

SET @FlightNameSyn = (SELECT FlightName FROM tblFLIGHT WHERE FlightID = @FL_PK)

DECLARE @DGATE_ID INT = (SELECT DepartGateID FROM tblFLIGHT WHERE FlightID = @FL_PK)
DECLARE @AGATE_ID INT = (SELECT ArrivalGateID FROM tblFLIGHT WHERE FlightID = @FL_PK)

SET @FlightDGateSyn = (SELECT GateNumber FROM tblAIRPORT_GATE WHERE GateID = @DGATE_ID)
SET @FlightAGateSyn = (SELECT GateNumber FROM tblAIRPORT_GATE WHERE GateID = @AGATE_ID)

DECLARE @AIR_ID INT = (SELECT AirlineID FROM tblFLIGHT WHERE FlightID = @FL_PK)

SET @FlightAirlineSyn = (SELECT AirlineName FROM tblAIRLINE WHERE AirlineID = @AIR_ID)

SET @CustFnameSyn = (SELECT CustFname FROM tblCUSTOMER WHERE CustomerID = @CS_PK)
SET @CustLnameSyn = (SELECT CustLname FROM tblCUSTOMER WHERE CustomerID = @CS_PK)
SET @CustDOBSyn = (SELECT CustomerDOB FROM tblCUSTOMER WHERE CustomerID = @CS_PK)

SET @TixPriceSyn = (SELECT RAND() * 2000)

---run it all.
EXEC InsertTicket
@FlightName = @FlightNameSyn,
@FlightDGate = @FlightDGateSyn,
@FlightAGate = @FlightAGateSyn,
@FlightAirline = @FlightAirlineSyn,
@CustFname = @CustFnameSyn,
@CustLname = @CustLnameSyn,
@CustDOB = @CustDOBSyn,
@TixPrice = @TixPriceSyn

SET @RUN = @RUN - 1
END

EXEC SynTicket 10000

GO

CREATE PROCEDURE SynTixProgress
@RUN INT

AS

DECLARE @FnameSyn varchar(100),
@LnameSyn varchar(100),
@CDOBSyn Date,
@FlightNameSyn varchar(100),
@FlightDGateSyn varchar(250),
@FlightAGateSyn varchar(250),
@FlightAirlineSyn varchar(100),
@ProgressNameSyn varchar(100),
@DateLogSyn Date

WHILE @RUN > 0
BEGIN


--get the flight and customer, associated to ticket. 
DECLARE @TicketRowCount INT = (SELECT COUNT(*) FROM tblTICKET)

DECLARE @C_PK INT, @F_PK INT, @T_PK INT, @P_PK INT

SET @T_PK = (SELECT RAND() * @TicketRowCount + 1)

SET @C_PK = (SELECT CustomerID FROM tblTICKET WHERE TicketID = @T_PK)
SET @F_PK = (SELECT FlightID FROM tblTICKET WHERE TicketID = @T_PK)

SET @FnameSyn = (SELECT CustFname FROM tblCUSTOMER WHERE CustomerID = @C_PK)
SET @LnameSyn = (SELECT CustLname FROM tblCUSTOMER WHERE CustomerID = @C_PK)
SET @CDOBSyn = (SELECT CustomerDOB FROM tblCUSTOMER WHERE CustomerID = @C_PK)

SET @FlightNameSyn = (SELECT FlightName FROM tblFLIGHT WHERE FlightID = @F_PK)

DECLARE @DGATE_ID INT = (SELECT DepartGateID FROM tblFLIGHT WHERE FlightID = @F_PK)
DECLARE @AGATE_ID INT = (SELECT ArrivalGateID FROM tblFLIGHT WHERE FlightID = @F_PK)

SET @FlightDGateSyn = (SELECT GateNumber FROM tblAIRPORT_GATE WHERE GateID = @DGATE_ID)
SET @FlightAGateSyn = (SELECT GateNumber FROM tblAIRPORT_GATE WHERE GateID = @AGATE_ID)

DECLARE @AIR_ID INT = (SELECT AirlineID FROM tblFLIGHT WHERE FlightID = @F_PK)

SET @FlightAirlineSyn = (SELECT AirlineName FROM tblAIRLINE WHERE AirlineID = @AIR_ID)

-- get the progress.
DECLARE @ProgressCount INT = (SELECT COUNT(*) FROM tblPROGRESS)

SET @P_PK = (SELECT RAND() * @ProgressCount + 1)

SET @ProgressNameSyn = (SELECT ProgressName FROM tblPROGRESS WHERE ProgressID = @P_PK)

-- Set the date.

SET @DateLogSyn = (SELECT GetDate() - (RAND() * 1000))

--put it all together. 

EXEC InsertTicketProgress
@Fname = @FnameSyn,
@Lname = @LnameSyn,
@CDOB = @CDOBSyn,
@FlightName = @FlightNameSyn,
@FlightDGate = @FlightDGateSyn,
@FlightAGate = @FlightAGateSyn,
@FlightAirline = @FlightAirlineSyn,
@ProgressName = @ProgressNameSyn,
@DateLog = @DateLogSyn

SET @RUN = @RUN - 1
END

EXEC SynTixProgress 10000

GO

CREATE PROCEDURE SynFlightStat
@RUN INT

AS

DECLARE @DGateSyn varchar(250),
@AGateSyn varchar(250),
@FltNameSyn varchar(100),
@AirlineSyn varchar(100),
@StatNameSyn varchar(100),
@BeginTimeSyn Date,
@EndTimeSyn Date

WHILE @RUN > 0
BEGIN

--get the flight details. 

DECLARE @FlightRowCount INT = (SELECT COUNT(*) FROM tblFLIGHT)

DECLARE @FL_PK INT, @S_PK INT

SET @FL_PK = (SELECT RAND() * @FlightRowCount + 1)

SET @FltNameSyn = (SELECT FlightName FROM tblFLIGHT WHERE FlightID = @FL_PK)

DECLARE @DGATE_ID INT = (SELECT DepartGateID FROM tblFLIGHT WHERE FlightID = @FL_PK)
DECLARE @AGATE_ID INT = (SELECT ArrivalGateID FROM tblFLIGHT WHERE FlightID = @FL_PK)

SET @DGateSyn = (SELECT GateNumber FROM tblAIRPORT_GATE WHERE GateID = @DGATE_ID)
SET @AGateSyn = (SELECT GateNumber FROM tblAIRPORT_GATE WHERE GateID = @AGATE_ID)

DECLARE @AIR_ID INT = (SELECT AirlineID FROM tblFLIGHT WHERE FlightID = @FL_PK)

SET @AirlineSyn = (SELECT AirlineName FROM tblAIRLINE WHERE AirlineID = @AIR_ID)


---get the status name.

DECLARE @StatusCount INT = (SELECT COUNT(*) FROM tblSTATUS)
SET @S_PK = (SELECT RAND() * @StatusCount + 1)

SET @StatNameSyn = (SELECT StatusName FROM tblSTATUS WHERE StatusID = @S_PK)

--dates.

SET @BeginTimeSyn = (SELECT GetDate() - (RAND() * 1000))
SET @EndTimeSyn = (SELECT GetDate() - (RAND() * 1000))

--put it all together.

EXEC InsertFlightStatus
@DGate = @DGateSyn,
@AGate = @AGateSyn,
@FltName = @FltNameSyn,
@Airline = @AirlineSyn,
@StatName = @StatNameSyn,
@BeginTime = @BeginTimeSyn,
@EndTime = @EndTimeSyn

SET @RUN = @RUN - 1
END

EXEC SynFlightStat 10000

