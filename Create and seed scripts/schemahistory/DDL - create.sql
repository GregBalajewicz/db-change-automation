CREATE SCHEMA schemahistory
GO

CREATE TABLE schemahistory.ChangeHistory
(
    RunID UNIQUEIDENTIFIER NOT NULL,
    [Version] DECIMAL(18,5) NOT NULL,
    [Filename] VARCHAR(MAX) NOT NULL,
    StartedOn DATETIME NOT NULL,
    SuccessfullyFinishedOn DATETIME NULL
)
GO

CREATE PROCEDURE [schemahistory].[ApplySchemaChangeFile_Start]
    @RunID UNIQUEIDENTIFIER,
    @Version DECIMAL(18,5),
    @Filename VARCHAR(MAX)
AS
IF EXISTS(SELECT * FROM ChangeHistory WHERE [Version] = @Version AND [filename] = @Filename AND SuccessfullyFinishedOn IS NOT NULL )
BEGIN
    SELECT 1 AS 'AlreadyApplied';
END ELSE BEGIN
    INSERT INTO schemahistory.ChangeHistory(RunID, [Version], [Filename], StartedOn, SuccessfullyFinishedOn)
    VALUES(@RunID, @Version, @Filename, GETDATE(), NULL);
    SELECT 0 AS 'AlreadyApplied';
END;
go

CREATE PROCEDURE schemahistory.ApplySchemaChangeFile_End_Success
    @RunID UNIQUEIDENTIFIER,
    @Version DECIMAL(18,5),
    @Filename VARCHAR(MAX)
AS
UPDATE schemahistory.ChangeHistory
    SET SuccessfullyFinishedOn = GETDATE()
    WHERE [Version] = @Version
    AND [Filename] = @Filename
    AND RunID = @RunID;
GO