GO
CREATE PROCEDURE GetCountryID
@CountryNameGet varchar(100),
@CountryIDGet INT OUTPUT

AS 
SET @CountryIDGet = (SELECT CountryID FROM tblCOUNTRY WHERE CountryName = @CountryNameGet)

GO
CREATE PROCEDURE GetStateID 
@StateNameGet varchar(100),
@StateIDGet INT OUTPUT

AS
SET @StateIDGet = (SELECT StateID FROM tblSTATE WHERE StateName = @StateNameGet)

GO
CREATE PROCEDURE GetCityID
@CityNameGet varchar(100),
@CityIDGet INT OUTPUT

AS
SET @CityIDGet = (SELECT CityID FROM tblCITY WHERE CityName = @CityNameGet)

GO
CREATE PROCEDURE GetAirportID
@AirportNameGet varchar(250),
@AirportIDGet INT OUTPUT

AS
SET @AirportIDGet = (SELECT AirportID 
FROM tblAIRPORT 
WHERE AirportName = @AirportNameGet)

GO
CREATE PROCEDURE GetTerminalID
@AirportTerminalGet varchar(100),
@TerminalIDGet INT OUTPUT

AS
DECLARE @AIR_ID INT

SET @TerminalIDGet = (SELECT TerminalID 
FROM tblTERMINAL 
WHERE TerminalName = @AirportTerminalGet)

GO
CREATE PROCEDURE GetGateID
@GateNameGet varchar(250),
@GateIDGet INT OUTPUT

AS
SET @GateIDGet = (SELECT GateID FROM tblAIRPORT_GATE
WHERE GateNumber = @GateNameGet)

GO
CREATE PROCEDURE GetAirlineID 
@AirlineNameGet varchar(100),
@AirlineIDGet INT OUTPUT

AS
SET @AirlineIDGet = (SELECT AirlineID FROM tblAIRLINE
WHERE AirlineName = @AirlineNameGet)
GO
CREATE PROCEDURE GetCustomerID 
@CustFnameGet varchar(100),
@CustLnameGet varchar(100),
@CustDOBGet Date,
@CustIDGet INT OUTPUT

AS
SET @CustIDGet = (SELECT CustomerID FROM tblCUSTOMER
WHERE CustFname = @CustFnameGet
AND CustLname = @CustLnameGet
AND CustomerDOB = @CustDOBGet)

GO
CREATE PROCEDURE GetCustomerTypeID
@CustTypeNameGet varchar(50),
@CustTypeIDGet INT OUTPUT
AS

SET @CustTypeIDGet = (SELECT CustomerTypeID FROM tblCUSTOMER_TYPE WHERE CustomerTypeName = @CustTypeNameGet)
GO
CREATE PROCEDURE GetFlightID
@FlightNameGet varchar(100),
@FlightDGateGet varchar(250),
@FlightAGateGet varchar(250),
@AirlineGet varchar(100),
@FlightIDGet INT OUTPUT

AS
DECLARE @DG_ID INT, @AG_ID INT, @AL_ID INT

EXEC GetGateID
@GateNameGet = @FlightDGateGet,
@GateIDGet = @DG_ID OUTPUT

EXEC GetGateID
@GateNameGet = @FlightAGateGet,
@GateIDGet = @AG_ID OUTPUT

EXEC GetAirlineID
@AirlineNameGet = @AirlineGet,
@AirlineIDGet = @AL_ID OUTPUT

SET @FlightIDGet = (SELECT FlightID FROM tblFLIGHT 
WHERE DepartGateID = @DG_ID
AND ArrivalGateID = @AG_ID
AND FlightName = @FlightNameGet
AND AirlineID = @AL_ID)

GO
CREATE PROCEDURE GetTicketID 
@FnameGet varchar(100),
@LnameGet varchar(100),
@CDOBGet Date,
@FlightNameGet varchar(100),
@FlightDGateGet varchar(250),
@FlightAGateGet varchar(250),
@FlightAirlineGet varchar(100),
@TicketIDGet INT OUTPUT

AS
DECLARE @C_ID INT, @F_ID INT

EXEC GetCustomerID
@CustFnameGet = @FnameGet,
@CustLnameGet = @LnameGet,
@CustDOBGet = @CDOBGet,
@CustIDGet = @C_ID OUTPUT

EXEC GetFlightID
@FlightNameGet = @FlightNameGet,
@FlightDGateGet = @FlightDGateGet,
@FlightAGateGet = @FlightAGateGet,
@AirlineGet = @FlightAirlineGet,
@FlightIDGet = @F_ID OUTPUT

SET @TicketIDGet = (SELECT TicketID FROM tblTICKET 
WHERE FlightID = @F_ID
AND CustomerID = @C_ID) 
GO
CREATE PROCEDURE GetProgressID 
@ProgressNameGet varchar(100),
@ProgressIDGet INT OUTPUT

AS
SET @ProgressIDGet = (SELECT ProgressID FROM tblPROGRESS WHERE ProgressName = @ProgressNameGet)

GO
CREATE PROCEDURE GetStatusID 
@StatusNameGet varchar(100),
@StatusIDGet INT OUTPUT

AS
SET @StatusIDGet = (SELECT StatusID FROM tblSTATUS WHERE StatusName = @StatusNameGet)
