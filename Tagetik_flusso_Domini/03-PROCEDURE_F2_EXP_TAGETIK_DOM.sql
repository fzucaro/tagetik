USE [PART0]
GO

IF EXISTS (SELECT *
             FROM sys.objects
            WHERE OBJECT_ID = OBJECT_ID(N'[SK_F2_FLUSSI].[F2_EXP_TAGETIK_DOMINI]')
              AND TYPE IN (N'P', N'RF', N'PC'))
BEGIN
    DROP PROCEDURE [sk_f2_flussi].[F2_EXP_TAGETIK_DOMINI];
END 
GO

SET ANSI_NULLS ON 
GO
SET QUOTED_IDENTIFIER ON 
GO

CREATE PROCEDURE [SK_F2_FLUSSI].[F2_EXP_TAGETIK_DOMINI]
@dataEstrazione date, @outputNum int OUTPUT, @outputMsg nvarchar(500) OUTPUT
WITH EXEC AS CALLER
AS
BEGIN

  declare @flagScarto     bit
  declare @motivoScarto   nvarchar(2000)
  declare @tabellaDom     nvarchar(50)
  declare @campoRif       nvarchar(50)
  declare @campoOut       nvarchar(50)
  
  set @outputNum = 0
	set @outputMsg = 'OK'

	BEGIN TRANSACTION;
  
  BEGIN TRY
  
  -- Se esiste già un'estrazione per la stessa data cancello i dati precedenti
  DELETE FROM SK_F2_FLUSSI.F2_T_EXP_TAGETIK_DOMINI
   WHERE Data_estrazione = @dataEstrazione
      
  DECLARE Domini_CUR CURSOR
      FOR SELECT Tabella, Campo_Rif, Campo_Output
      FROM SK_F2_FLUSSI.F2_D_TabelleDominio						

  OPEN Domini_CUR
  FETCH NEXT FROM Domini_CUR INTO @tabellaDom, @campoRif, @campoOut

  WHILE (@@FETCH_STATUS = 0)
  BEGIN    
    set @flagScarto = 0
    set @motivoScarto = ''
    
    -- Area Geografica -- RIP016
		IF @campoOut	= 'RIP016' And	@tabellaDom = 'SK_F2_FLUSSI.F2_D_AreaGeograficaCR'	
		BEGIN
				INSERT INTO SK_F2_FLUSSI.F2_T_EXP_TAGETIK_DOMINI (Data_estrazione, Nome_Dominio,
               Codice, Descrizione, Flag_Scarto, Motivo_Scarto)
        (SELECT DISTINCT @dataEstrazione, @campoOut, ID_Area, Descrizione_Area, @flagScarto, @motivoScarto 
           FROM SK_F2_FLUSSI.F2_D_AreaGeograficaCR
          WHERE ID_Area IS NOT NULL
         UNION ALL 
         SELECT @dataEstrazione, @campoOut, 'XA', 'NON DISPONIBILE', 0, '')
		END
      
    -- Area Geografica C -- RIP16C
    IF @campoOut	= 'RIP16C' And	@tabellaDom = 'SK_F2_FLUSSI.F2_D_AreaGeograficaCR'	
		BEGIN
				INSERT INTO SK_F2_FLUSSI.F2_T_EXP_TAGETIK_DOMINI (Data_estrazione, Nome_Dominio,
               Codice, Descrizione, Flag_Scarto, Motivo_Scarto)
        (SELECT DISTINCT @dataEstrazione, @campoOut, ID_AreaC, Descrizione_AreaC, @flagScarto, @motivoScarto 
           FROM SK_F2_FLUSSI.F2_D_AreaGeograficaCR
         WHERE ID_AreaC IS NOT NULL
         UNION ALL 
         SELECT @dataEstrazione, @campoOut, 'XA', 'NON DISPONIBILE', 0, '' )
	  END
    
    -- Area Geografica R -- RIP16R
    IF @campoOut	= 'RIP16R' And	@tabellaDom = 'SK_F2.F2_D_Aree_Geografiche'	
		BEGIN
				INSERT INTO SK_F2_FLUSSI.F2_T_EXP_TAGETIK_DOMINI (Data_estrazione, Nome_Dominio,
               Codice, Descrizione, Flag_Scarto, Motivo_Scarto)
        (SELECT DISTINCT @dataEstrazione, @campoOut, ID, Descrizione, @flagScarto, @motivoScarto 
           FROM SK_F2.F2_D_Aree_Geografiche
         WHERE ID IS NOT NULL
         UNION ALL 
         SELECT @dataEstrazione, @campoOut, 'XA', 'NON DISPONIBILE', 0, '')
	  END

    -- Tipologia Controparte -- RIP011
		IF 	@campoOut	= 'RIP011'	And	@tabellaDom = 'SK_F2_FLUSSI.F2_D_TipoControparteCR'	
		BEGIN
				INSERT INTO SK_F2_FLUSSI.F2_T_EXP_TAGETIK_DOMINI (Data_estrazione, Nome_Dominio,
               Codice, Descrizione, Flag_Scarto, Motivo_Scarto)
        (SELECT DISTINCT @dataEstrazione, @campoOut, ID_Tipo, Descrizione_Controparte, @flagScarto, @motivoScarto 
           FROM SK_F2_FLUSSI.F2_D_TipoControparteCR
          WHERE ID_Tipo IS NOT NULL
         UNION ALL 
         SELECT @dataEstrazione, @campoOut, 'XA', 'NON DISPONIBILE', 0, '' )
		END

	  -- T_CATTipoControparte -- RIP11C
		IF 	@campoOut	= 'RIP11C'	And	@tabellaDom = 'SK_F2_FLUSSI.F2_D_TipoControparteCR'	
		BEGIN
				INSERT INTO SK_F2_FLUSSI.F2_T_EXP_TAGETIK_DOMINI (Data_estrazione, Nome_Dominio,
               Codice, Descrizione, Flag_Scarto, Motivo_Scarto)
        (SELECT DISTINCT @dataEstrazione, @campoOut, ID_TipoC, Descrizione_ControparteC, @flagScarto, @motivoScarto 
           FROM SK_F2_FLUSSI.F2_D_TipoControparteCR
          WHERE ID_TipoC IS NOT NULL
         UNION ALL 
         SELECT @dataEstrazione, @campoOut, 'XA', 'NON DISPONIBILE', 0, '' )
		END
    
    -- Tipo Controparte R -- RIP11R
		IF 	@campoOut	= 'RIP11R'	And	@tabellaDom = 'SK_F2.F2_D_Tipi_Controparte'	
		BEGIN
				INSERT INTO SK_F2_FLUSSI.F2_T_EXP_TAGETIK_DOMINI (Data_estrazione, Nome_Dominio,
               Codice, Descrizione, Flag_Scarto, Motivo_Scarto)
        (SELECT DISTINCT @dataEstrazione, @campoOut, ID, Descrizione, @flagScarto, @motivoScarto 
           FROM SK_F2.F2_D_Tipi_Controparte
          WHERE ID IS NOT NULL
         UNION ALL 
         SELECT @dataEstrazione, @campoOut, 'XA', 'NON DISPONIBILE', 0, '' )
		END
    
    -- ATECO - SK_F2.F2_D_Ateco -- Eliminata il 23.09.2016 come da richiesta Vallino
    --IF 	@campoOut	= 'ATECO'	And	@tabellaDom = 'SK_F2.F2_D_Ateco'	
		--BEGIN
		--		INSERT INTO SK_F2_FLUSSI.F2_T_EXP_TAGETIK_DOMINI (Data_estrazione, Nome_Dominio,
    --           Codice, Descrizione, Flag_Scarto, Motivo_Scarto)
    --    (SELECT DISTINCT @dataEstrazione, @campoOut, ID, Descrizione, @flagScarto, @motivoScarto 
    --       FROM SK_F2.F2_D_Ateco
    --      WHERE ID IS NOT NULL
    --     UNION ALL 
    --     SELECT @dataEstrazione, @campoOut, 'XA', 'NON DISPONIBILE', 0, '' )
		--END
    
    -- Unità Business di riferimento (SK_F2.F2_D_Cash_Generating_Unit) - SUBSEG
    -- Eliminata il 23.09.2016 come da richiesta Vallino
    --IF 	@campoOut	= 'SUBSEG'	And	@tabellaDom = 'SK_F2.F2_D_Cash_Generating_Unit'	
		--BEGIN
		--		INSERT INTO SK_F2_FLUSSI.F2_T_EXP_TAGETIK_DOMINI (Data_estrazione, Nome_Dominio,
    --           Codice, Descrizione, Flag_Scarto, Motivo_Scarto)
    --    (SELECT DISTINCT @dataEstrazione, @campoOut, convert(varchar, ID), Descrizione, @flagScarto, @motivoScarto 
    --       FROM SK_F2.F2_D_Cash_Generating_Unit
    --      WHERE ID IS NOT NULL
    --     UNION ALL 
    --     SELECT @dataEstrazione, @campoOut, 'XA', 'NON DISPONIBILE', 0, '' )
		--END  
    
    -- SAE (SK_F2.F2_ANS_AFTATPR_SAE) - RIP911
    IF 	@campoOut	= 'RIP911'	And	@tabellaDom = 'SK_F2.F2_ANS_AFTATPR_SAE'	
		BEGIN
				INSERT INTO SK_F2_FLUSSI.F2_T_EXP_TAGETIK_DOMINI (Data_estrazione, Nome_Dominio,
               Codice, Descrizione, Flag_Scarto, Motivo_Scarto)
        (SELECT DISTINCT @dataEstrazione, @campoOut, PROF_ATTIVITA, DESCR_ATTIVITA, @flagScarto, @motivoScarto 
           FROM SK_F2.F2_ANS_AFTATPR_SAE
          WHERE PROF_ATTIVITA IS NOT NULL
         UNION ALL 
         SELECT @dataEstrazione, @campoOut, 'XA', 'NON DISPONIBILE', 0, '' )
		END
    
    -- Affidato Garante (SK_F2.F2_D_Affidati_Garante) - RIP200
    IF @campoOut = 'RIP200'	And	@tabellaDom = 'SK_F2.F2_D_Affidati_Garante'	
		BEGIN
				INSERT INTO SK_F2_FLUSSI.F2_T_EXP_TAGETIK_DOMINI (Data_estrazione, Nome_Dominio,
               Codice, Descrizione, Flag_Scarto, Motivo_Scarto)
        (SELECT DISTINCT @dataEstrazione, @campoOut, ID, Descrizione, @flagScarto, @motivoScarto 
           FROM SK_F2.F2_D_Affidati_Garante
          WHERE ID IS NOT NULL
         UNION ALL 
         SELECT @dataEstrazione, @campoOut, 'XA', 'NON DISPONIBILE', 0, '' )
		END
    
    -- Metodo consolidamento BI - METODO -- Eliminata il 23.09.2016 come da richiesta Vallino
    -- Metodo consolidamento IAS - AREAB
    -- Metodo consolidamento FINREP - AREAG -- Eliminata il 23.09.2016 come da richiesta Vallino
    --IF (@campoOut = 'METODO' OR @campoOut = 'AREAB' OR @campoOut = 'AREAG')	And	
    --    @tabellaDom = 'SK_F2.F2_D_Metodo_Consolidamento'
    IF @campoOut = 'AREAB' And	@tabellaDom = 'SK_F2.F2_D_Metodo_Consolidamento'
		BEGIN
				INSERT INTO SK_F2_FLUSSI.F2_T_EXP_TAGETIK_DOMINI (Data_estrazione, Nome_Dominio,
               Codice, Descrizione, Flag_Scarto, Motivo_Scarto)
        (SELECT DISTINCT @dataEstrazione, @campoOut, ID, Descrizione, @flagScarto, @motivoScarto 
           FROM SK_F2.F2_D_Metodo_Consolidamento
          WHERE ID IS NOT NULL
         UNION ALL 
         SELECT @dataEstrazione, @campoOut, 'XA', 'NON DISPONIBILE', 0, '' )
		END
    
    -- Classificazione BI - FLAGAT
    IF @campoOut = 'FLAGAT'	And	@tabellaDom = 'SK_F2.F2_D_Classificazione_Banca_Italia'	
		BEGIN
				INSERT INTO SK_F2_FLUSSI.F2_T_EXP_TAGETIK_DOMINI (Data_estrazione, Nome_Dominio,
               Codice, Descrizione, Flag_Scarto, Motivo_Scarto)
        (SELECT DISTINCT @dataEstrazione, @campoOut, convert(varchar, ID), Descrizione, @flagScarto, @motivoScarto 
           FROM SK_F2.F2_D_Classificazione_Banca_Italia
          WHERE ID IS NOT NULL
         UNION ALL 
         SELECT @dataEstrazione, @campoOut, 'XA', 'NON DISPONIBILE', 0, '' )
		END
    
    -- Classificazione IAS - CONTRO
/*
    IF @campoOut = 'CONTRO'	And	@tabellaDom = 'SK_F2.F2_D_Classificazione_IAS'	
		BEGIN
				INSERT INTO SK_F2_FLUSSI.F2_T_EXP_TAGETIK_DOMINI (Data_estrazione, Nome_Dominio,
               Codice, Descrizione, Flag_Scarto, Motivo_Scarto)
        (SELECT DISTINCT @dataEstrazione, @campoOut, convert(varchar, ID), Descrizione, @flagScarto, @motivoScarto 
           FROM SK_F2.F2_D_Classificazione_IAS
          WHERE ID IS NOT NULL
         UNION ALL 
         SELECT @dataEstrazione, @campoOut, 'XA', 'NON DISPONIBILE', 0, '' )
		END
*/
 /*            
    -- Altre codifiche presenti in tabella SK_F2_FLUSSI.F2_D_Codifiche_BOF (CARATT, CATEG, RAGGR, RESID)
    IF @tabellaDom = 'SK_F2_FLUSSI.F2_D_Codifiche_BOF'	
		BEGIN
				INSERT INTO SK_F2_FLUSSI.F2_T_EXP_TAGETIK_DOMINI (Data_estrazione, Nome_Dominio,
               Codice, Descrizione, Flag_Scarto, Motivo_Scarto)
        (SELECT DISTINCT @dataEstrazione, Tabella, Codice, Descrizione, @flagScarto, @motivoScarto 
           FROM SK_F2_FLUSSI.F2_D_Codifiche_BOF
          WHERE Tabella = @campoOut AND Codice IS NOT NULL
         UNION ALL 
         SELECT @dataEstrazione, @campoOut, 'XA', 'NON DISPONIBILE', 0, '' )
		END
*/
    -- Tabella SK_F2.F2_D_Tipi_Derivato
     IF @campoOut = 'TIPDER' and @tabellaDom = 'SK_F2.F2_D_Tipi_Derivato'	
	  BEGIN
				INSERT INTO SK_F2_FLUSSI.F2_T_EXP_TAGETIK_DOMINI (Data_estrazione, Nome_Dominio,
               Codice, Descrizione, Flag_Scarto, Motivo_Scarto)
        (SELECT DISTINCT @dataEstrazione, @campoOut, convert(varchar, ID), Descrizione, @flagScarto, @motivoScarto 
           FROM SK_F2.F2_D_Tipi_Derivato
          WHERE 
		  -- Verificare se scartare i record chiusi
            Data_Fine is null)
		END

    -- Tabella SK_F2.F2_D_Tipologie_Fondo
     IF @campoOut = 'TIPF' and  @tabellaDom = 'SK_F2.F2_D_Tipologie_Fondo'	
	  BEGIN
				INSERT INTO SK_F2_FLUSSI.F2_T_EXP_TAGETIK_DOMINI (Data_estrazione, Nome_Dominio,
               Codice, Descrizione, Flag_Scarto, Motivo_Scarto)
        (SELECT DISTINCT @dataEstrazione, @campoOut, convert(varchar, ID), Descrizione, @flagScarto, @motivoScarto 
           FROM SK_F2.F2_D_Tipi_Derivato
          WHERE 
		  -- Verificare se scartare i record chiusi
            Data_Fine is null)
		END

    -- Tabella Tipologia Operazione
	IF @tabellaDom = 'SK_F2.F2_D_Tipi_Operazioni'	
	  BEGIN
				INSERT INTO SK_F2_FLUSSI.F2_T_EXP_TAGETIK_DOMINI (Data_estrazione, Nome_Dominio,
               Codice, Descrizione, Flag_Scarto, Motivo_Scarto)
        (SELECT DISTINCT @dataEstrazione, @campoOut, convert(varchar, ID), Descrizione, @flagScarto, @motivoScarto 
           FROM SK_F2.F2_D_Tipi_Derivato
          WHERE 
		  -- Verificare se scartare i record chiusi
            Data_Fine is null)
		END


    -- Tabella Valuta
	IF @tabellaDom = 'SK_F2.F2_D_Valuta'	
	  BEGIN
				INSERT INTO SK_F2_FLUSSI.F2_T_EXP_TAGETIK_DOMINI (Data_estrazione, Nome_Dominio,
               Codice, Descrizione, Flag_Scarto, Motivo_Scarto)
        (SELECT DISTINCT @dataEstrazione, @campoOut, Codice_Swift, Descrizione, @flagScarto, @motivoScarto 
           FROM SK_F2.F2.F2_D_Valuta
          WHERE 
		  -- Verificare se scartare i record chiusi
            Data_Fine is null)
		END



    FETCH NEXT FROM Domini_CUR INTO @tabellaDom, @campoRif, @campoOut
    
  END
    
  CLOSE Domini_CUR
  DEALLOCATE Domini_CUR

  -- Verifica Record da scartare --> Quali regole?
  -- TODO
  
  -- Select finale da tabella 
  -- Record di testata (fisso) + records dati presi da tabella che abbiano flagScarto = 0
  SELECT * INTO #tempBOFDomini FROM (
    --SELECT 'A' as Nome_Dominio, 0 as TipoRec, 'WNOME;WCODICE;WDESC' as record
    --UNION ALL
    SELECT Nome_Dominio, 1 as TipoRec, Nome_Dominio + ';' + Codice + ';' + Descrizione as record
      FROM SK_F2_FLUSSI.F2_T_EXP_TAGETIK_DOMINI
     WHERE Data_estrazione = @dataEstrazione
       AND Flag_Scarto = 0
  ) tab
  
  SELECT record from #tempBOFDomini order by TipoRec, Nome_Dominio
  
 END TRY
	BEGIN CATCH
		set @outputNum = -1
		SELECT @outputMsg = ERROR_MESSAGE()

		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION;
	END CATCH;

	IF @@TRANCOUNT > 0
		COMMIT TRANSACTION;


END
