USE [PART0]
GO

/****** Object:  Table [SK_F2_FLUSSI].[F2_T_EXP_TAGETIK_Anag]    Script Date: 08/02/2018 11:55:20 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [SK_F2_FLUSSI].[F2_T_EXP_TAGETIK_Anag](
	[Data_estrazione] [date] NOT NULL,
	[Azienda] [nvarchar](50) NOT NULL,
	[ID_Operazione] [int] NOT NULL,
	[Tipo_Operazione] [nvarchar](50) NOT NULL,
	[Ragione_sociale] [nvarchar](2000) NOT NULL,
	[Sede] [nvarchar](200) NULL,
	[Metodo] [nvarchar](50) NOT NULL,
	[Metodo_consolidamento_BI] [nvarchar](50) NOT NULL,
	[Metodo_consolidamento_IAS] [nvarchar](50) NOT NULL,
	[Metodo_consolidamento_Finrep] [nvarchar](50) NOT NULL,
	[Classificazione_BI] [nvarchar](50) NOT NULL,
	[Descrizione_attivita] [nvarchar](200) NULL,
	[Quotata] [nvarchar](50) NOT NULL,
	[Tipo_rapporto_effettivo] [nvarchar](50) NOT NULL,
	[Residenza] [nvarchar](50) NOT NULL,
	[Valuta] [nvarchar](50) NOT NULL,
	[Tipo_quotazione] [nvarchar](50) NOT NULL,
	[Gruppo_bancario] [nvarchar](50) NOT NULL,
	[Modalita_partecipazione] [nvarchar](50) NOT NULL,
	[ABI] [nvarchar](6) NOT NULL,
	[Partita_IVA] [nvarchar](50) NOT NULL,
	[Codice_fiscale] [nvarchar](50) NOT NULL,
	[Codice_UIC] [nvarchar](50) NULL,
	[Codice_CR] [nvarchar](50) NULL,
	[SNDG] [nvarchar](50) NOT NULL,
	[Settore_ISVAP] [nvarchar](50) NOT NULL,
	[Tipo_controparte] [nvarchar](50) NOT NULL,
	[Tipo_controparteC] [nvarchar](50) NOT NULL,
	[Tipo_controparteR] [nvarchar](50) NOT NULL,
	[Area_geografica] [nvarchar](50) NOT NULL,
	[Area_geograficaC] [nvarchar](50) NOT NULL,
	[Area_geograficaR] [nvarchar](50) NOT NULL,
	[Affidato_garante] [nvarchar](50) NOT NULL,
	[Attivita_economica] [nvarchar](50) NOT NULL,
	[SAE] [nvarchar](50) NOT NULL,
	[Tipo_raggruppamento] [nvarchar](50) NOT NULL,
	[Categoria_controparte] [nvarchar](50) NOT NULL,
	[Caratt_partecipazione] [nvarchar](50) NOT NULL,
	[Subholding] [nvarchar](50) NOT NULL,
	[Business_unit] [nvarchar](50) NOT NULL,
	[Variazione_metodo] [nvarchar](50) NOT NULL,
	[Livello_fair_value] [nvarchar](50) NOT NULL,
	[ISIN_prevalente] [nvarchar](50) NOT NULL,
	[ATECO] [nvarchar](6) NOT NULL,
	[Data_ingresso_BI] [nvarchar](50) NOT NULL,
	[Perc_possesso_gruppo] [nvarchar](100) NOT NULL,
	[Perc_possesso_DV_gruppo] [nvarchar](100) NOT NULL,
	[dt_inizio_class_contabile] [nvarchar](50) NOT NULL,
	[dt_fine_class_contabile] [nvarchar](50) NOT NULL,
	[dt_costituzione] [nvarchar](50) NOT NULL,
	[cod_LEI] [nvarchar](50) NOT NULL,
	[sede_amm] [nvarchar](50) NOT NULL,
	[class_IAS] [nvarchar](50) NOT NULL,
	[cod_prevalente] [nvarchar](50) NOT NULL,
	[tipo_op] [nvarchar](50) NOT NULL,
	[des_op] [nvarchar](50) NOT NULL,
	[tipo_derivato] [nvarchar](50) NOT NULL,
	[desc_derivato] [nvarchar](50) NOT NULL,
	[grp_ass] [nvarchar](1) NOT NULL,
	[Flag_Scarto] [bit] NOT NULL,
	[Motivo_Scarto] [nvarchar](2000) NULL,
 CONSTRAINT [PK_F2_T_EXP_TAGETIK_Anag] PRIMARY KEY CLUSTERED 
(
	[Data_estrazione] ASC,
	[Azienda] ASC,
	[SNDG] ASC,
	[ID_Operazione] ASC,
	[Tipo_Operazione] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO

