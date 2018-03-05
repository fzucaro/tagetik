USE [PART0]
GO

/****** Object:  Table [SK_F2_FLUSSI].[[F2_T_EXP_TAGETIK_Anag]]    Script Date: 07/12/2017 15:48:06 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

/*
Se tabella esiste la droppo

*/
IF (EXISTS (SELECT * 
                 FROM INFORMATION_SCHEMA.TABLES 
                 WHERE TABLE_SCHEMA = 'SK_F2_FLUSSI' 
                 AND  TABLE_NAME = 'F2_T_EXP_TAGETIK_MOV'))
BEGIN
    DROP  TABLE SK_F2_FLUSSI.F2_T_EXP_TAGETIK_MOV
END

CREATE TABLE [SK_F2_FLUSSI].[F2_T_EXP_TAGETIK_MOV](
	[data_estrazione] [date] NOT NULL,
	[id_Operazione] [int] NOT NULL,
	[id_movimento] [int] NOT NULL,
	[cmg_partecipata] [nvarchar](5)   NULL,
	[cmg_partecipante] [nvarchar](5)   NULL,
	[data_contabile] [datetime] NULL,
	[numero_azioni] [decimal](28, 2) NULL,
	[numero_azioni_DV] [decimal](28, 2) NULL,
	[numero_quote] [decimal](28, 2) NULL,
	[tipo_derivato] [nvarchar](20)   NULL,
	importo [decimal](28, 2) NULL,
	[valuta] [nvarchar](20)   NULL,
	[id_causale] [nvarchar](20)   NULL,
	)