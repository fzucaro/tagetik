/*
Import Flussi per gestione dati BOFinance
Assegno ID 16 - Import Dati Bilancio INDIVIDUALE
Descrizione: INDBILTGTK
Tabella di bulk : SK_F2_BULK.F2_IMP_BIL_IND_TAGETIK
Format file: TGTKIND.fmt
Procedura elaborazione dati: SK_F2_FLUSSI.F2_IMP_INDBILTGTK
*/


USE [PART0]
GO

INSERT INTO [SK_F2].[F2_D_ImportFlussi]
           ([ID]
           ,[Descrizione]
           ,[DescrizioneEstesa]
           ,[TabellaBulk]
           ,[FormatFile]
           ,[SP_ImportDati]
           ,[NomeChiave]
           ,[Storicizza]
           ,[StoricoGiorni]
           ,[Data_Inizio]
           ,[Data_Fine]
           ,[FirstRow])
     VALUES
           (16
           ,'INDBILTGTK'
           ,'Import dati bilancio INDIVUDUALE TAGETIK'
           ,'SK_F2_BULK.F2_IMP_BIL_IND_TAGETIK'
           ,'TGTKIND.fmt'
           ,'SK_F2_FLUSSI.F2_IMP_INDBILTGTK'
           ,'BILINDTGTK_' -- da capire meglio cosa sia, forse nome file
           ,1
           ,10
           ,GETDATE()
           ,NULL
           ,1)
GO

