IF EXISTS(SELECT 1 FROM sys.columns 
          WHERE Name = N'ID_Tipologia_Fondo'
          AND Object_ID = Object_ID(N'SK_F2_FLUSSI.F2_T_EXP_TAGETIK_Anag'))
BEGIN
    ALTER TABLE SK_F2_FLUSSI.F2_T_EXP_TAGETIK_Anag
    DROP COLUMN ID_Tipologia_Fondo
END

ALTER TABLE SK_F2_FLUSSI.F2_T_EXP_TAGETIK_Anag
   ADD ID_Tipologia_Fondo nvarchar(50)
	 