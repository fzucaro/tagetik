USE [PART0]
GO

/****** CREAZIONE TABELLA DATI IMPORT BILANCIO INDIVIDUALE TAGETIK ******/
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
                 WHERE TABLE_SCHEMA = 'SK_F2_BULK' 
                 AND  TABLE_NAME = 'F2_IMP_BIL_CONS_TAGETIK') )
BEGIN
    DROP  TABLE SK_F2_BULK.F2_IMP_BIL_CONS_TAGETIK
END

CREATE TABLE [SK_F2_BULK].[F2_IMP_BIL_CONS_TAGETIK](
	[ID] [int] IDENTITY(1,1) NOT NULL PRIMARY KEY,
	[periodo_contabile_D_DP] [nvarchar](20) NULL,
	[data_caricamento_DC] [nvarchar](8) NULL,
	[sndg_part] [nvarchar](20) NULL,
	[sndg_partn] [nvarchar](20) NULL,
	[P_PN]  [nvarchar](50),
	[P_AFS] [nvarchar](50),
	[CNS_PN_CI] [nvarchar](50),
	[CNS_AFS] [nvarchar](50),
	[AVV_PN] [nvarchar](50),
	[AVV_CI] [nvarchar](50),
	[RIS_AFS_LORDA] [nvarchar](50),
	[RIS_AFS_NETTA] [nvarchar](50),
	[IMPG][nvarchar](50),
	[GAR] [nvarchar](50),
	[IMPR] [nvarchar](50)
)
GO