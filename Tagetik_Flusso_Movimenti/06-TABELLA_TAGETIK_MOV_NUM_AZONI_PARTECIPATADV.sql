IF EXISTS(SELECT 1 FROM sys.columns 
          WHERE Name = N'num_azioni_partecipataDV'
          AND Object_ID = Object_ID(N'SK_F2_FLUSSI.F2_T_EXP_TAGETIK_MOV'))
BEGIN
    ALTER TABLE SK_F2_FLUSSI.F2_T_EXP_TAGETIK_MOV
    DROP COLUMN num_azioni_partecipataDV
END

ALTER TABLE SK_F2_FLUSSI.F2_T_EXP_TAGETIK_MOV
   ADD num_azioni_partecipataDV decimal(28,2)