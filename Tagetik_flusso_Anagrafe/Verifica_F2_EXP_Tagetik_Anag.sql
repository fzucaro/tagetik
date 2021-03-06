USE [PART0]
GO

DECLARE	@return_value int,
		@outputNum int,
		@outputMsg nvarchar(500)

EXEC	@return_value = [SK_F2_FLUSSI].[F2_EXP_TAGETIK_Anag]
		@dataEstrazione = '31/12/2017',
		@outputNum = @outputNum OUTPUT,
		@outputMsg = @outputMsg OUTPUT

SELECT	@outputNum as N'@outputNum',
		@outputMsg as N'@outputMsg'

SELECT	'Return Value' = @return_value

GO

--Verifica lunghezza SNDG
select 
len(t.SNDG),t.sndg
 from [SK_F2_FLUSSI].[F2_T_EXP_TAGETIK_Anag] t
 where len(t.sndg) = 16