CREATE PROCEDURE InsertFlight
@AirlineName varchar(100),
@DepartGate varchar(250),
@ArriveGate varchar(250),
@FlightTimeStart Time,
@FlightNameStart varchar(100)

AS
DECLARE @AG_ID INT, @DG_ID INT, @AL_ID INT

EXEC GetGateID
@GateNameGet = @DepartGate,
@GateIDGet = @DG_ID OUTPUT

EXEC GetGateID
@GateNameGet = @ArriveGate,
@GateIDGet = @AG_ID OUTPUT

EXEC GetAirlineID
@AirlineNameGet = @AirlineName,
@AirlineIDGet = @AL_ID OUTPUT


BEGIN TRANSACTION T1
INSERT INTO tblFLIGHT (AirlineID, DepartGateID, ArrivalGateID, FlightTime, FlightName)
VALUES (@AL_ID, @DG_ID, @AG_ID, @FlightTimeStart, @FlightNameStart)
IF @@ERROR <> 0 
	BEGIN
		PRINT 'Error found, rolling back'
		ROLLBACK TRANSACTION T1
	END
ELSE
	COMMIT TRANSACTION T1

GO

CREATE PROCEDURE InsertTicket
@FlightName varchar(100),
@FlightDGate varchar(250),
@FlightAGate varchar(250),
@FlightAirline varchar(100),
@CustFname varchar(100),
@CustLname varchar(100),
@CustDOB Date,
@TixPrice Numeric(10,2)

AS
DECLARE @F_ID INT, @C_ID INT

EXEC GetCustomerID
@CustFnameGet = @CustFname,
@CustLnameGet = @CustLname,
@CustDOBGet = @CustDOB,
@CustIDGet = @C_ID OUTPUT

EXEC GetFlightID
@FlightNameGet = @FlightName,
@FlightDGateGet = @FlightDGate,
@FlightAGateGet = @FlightAGate,
@AirlineGet = @FlightAirline,
@FlightIDGet = @F_ID OUTPUT


BEGIN TRANSACTION X1
INSERT INTO tblTICKET (FlightID, CustomerID, TicketPrice)
VALUES (@F_ID, @C_ID, @TixPrice)
IF @@ERROR <> 0 
	BEGIN
		PRINT 'Error found, rolling back'
		ROLLBACK TRANSACTION X1
	END
ELSE
	COMMIT TRANSACTION X1


GO 

CREATE PROCEDURE InsertTicketProgress
@Fname varchar(100),
@Lname varchar(100),
@CDOB Date,
@FlightName varchar(100),
@FlightDGate varchar(250),
@FlightAGate varchar(250),
@FlightAirline varchar(100),
@ProgressName varchar(100),
@DateLog Date

AS

DECLARE @T_ID INT , @P_ID INT

EXEC GetTicketID
@FnameGet = @Fname,
@LnameGet = @Lname,
@CDOBGet = @CDOB,
@FlightNameGet = @FlightName,
@FlightDGateGet = @FlightDGate,
@FlightAGateGet = @FlightAGate,
@FlightAirlineGet = @FlightAirline,
@TicketIDGet = @T_ID OUTPUT

EXEC GetProgressID
@ProgressNameGet = @ProgressName,
@ProgressIDGet = @P_ID OUTPUT

BEGIN TRANSACTION C1
INSERT INTO tblTICKET_PROGRESS (TicketID, ProgressID, DateLogged)
VALUES (@T_ID, @P_ID, @DateLog)
IF @@ERROR <> 0 
	BEGIN
		PRINT 'Error found, rolling back'
		ROLLBACK TRANSACTION C1
	END
ELSE
	COMMIT TRANSACTION C1

GO

CREATE PROCEDURE InsertFlightStatus
@DGate varchar(250),
@AGate varchar(250),
@FltName varchar(100),
@Airline varchar(100),
@StatName varchar(100),
@BeginTime Date,
@EndTime Date

AS
DECLARE @F_ID INT, @S_ID INT

EXEC GetFlightID
@FlightNameGet = @FltName,
@FlightDGateGet = @DGate,
@FlightAGateGet = @AGate,
@AirlineGet = @Airline,
@FlightIDGet = @F_ID OUTPUT

EXEC GetStatusID
@StatusNameGet = @StatName,
@StatusIDGet = @S_ID OUTPUT

BEGIN TRANSACTION D1
INSERT INTO tblFLIGHT_STATUS (FlightID, StatusID, BeginTime, EndTime)
VALUES (@F_ID, @S_ID, @BeginTime, @EndTime)
IF @@ERROR <> 0 
	BEGIN
		PRINT 'Error found, rolling back'
		ROLLBACK TRANSACTION D1
	END
ELSE
	COMMIT TRANSACTION D1
