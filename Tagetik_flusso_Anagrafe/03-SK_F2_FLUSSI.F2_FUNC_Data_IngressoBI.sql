USE [PART0]
GO
/****** Object:  StoredProcedure [SK_F2_FLUSSI].[getDataIngressoBI]    Script Date: 06/02/2018 10:21:53 ******/
IF EXISTS (SELECT *
             FROM sys.objects
            WHERE OBJECT_ID = OBJECT_ID(N'[SK_F2_FLUSSI].[getDataIngressoBI]')
              AND TYPE IN (N'P', N'RF', N'PC',N'FN'))
BEGIN
-- eliminazione scalar function
    DROP FUNCTION SK_F2_FLUSSI.getDataIngressoBI;
END

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

USE [PART0]
GO

/****** Object:  UserDefinedFunction [SK_F2_FLUSSI].[getDataIngressoBI]    Script Date: 12/03/2018 18:16:34 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [SK_F2_FLUSSI].[getDataIngressoBI]
(@idOperazione as int)
RETURNS date
WITH EXEC AS CALLER
AS
BEGIN
declare @metodoConsBI nvarchar(3);
declare @dataInizio date;
declare @dataBI date;
declare @funcCursor as cursor;

SET @dataBI = NULL;

SET @funcCursor = CURSOR for
 SELECT  cla.ID_Metodo_Consolidamento_Banca_Italia,			
         Data_Inizio DataInizioClassCont
      FROM SK_F2.F2_T_Classificazioni_Contabili cla
     WHERE ID_Operazione = @idOperazione
           AND (Cancellata = 0 or Cancellata is null)
	   order by Data_Inizio desc;
OPEN @funcCursor;

FETCH NEXT FROM @funcCursor INTO @metodoConsBI,@dataInizio;
WHILE @@FETCH_STATUS = 0
BEGIN
 IF @metodoConsBI = 'PN'
  BEGIN 
   SET @dataBI = @dataInizio
   BREAK;
  END
  FETCH NEXT FROM @funcCursor INTO @metodoConsBI,@dataInizio;
END

CLOSE @funcCursor
DEALLOCATE @funcCursor 

RETURN @dataBI

END
GO

