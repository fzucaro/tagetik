USE [PART0]
GO

INSERT INTO [SK_F2].[F2_D_ExportFlussi]
           ([ID]
           ,[Descrizione]
           ,[DescrizioneEstesa]
           ,[SP_ExportDati]
           ,[FilenamePrefix]
           ,[FilenameSuffix]
           ,[Storicizza]
           ,[StoricoGiorni]
           ,[CmdSend]
           ,[Data_Inizio]
           ,[Data_Fine])
     VALUES
           (NULL
           ,'TagetikDom'
           ,'Export flusso Tagetik Domini'
           ,'SK_F2_FLUSSI.F2_EXP_TAGETIK_MOV'
           ,'TGTKFLU_{Data}'
           ,'txt'
           ,1
           ,10
           ,'snd_tgtk_flu.cmd'
           ,getdate()
           ,NULL)
GO


