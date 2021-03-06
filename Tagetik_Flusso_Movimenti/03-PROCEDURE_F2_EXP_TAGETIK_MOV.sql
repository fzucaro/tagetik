USE [PART0]
GO

IF EXISTS (SELECT *
             FROM sys.objects
            WHERE OBJECT_ID = OBJECT_ID(N'[SK_F2_FLUSSI].[F2_EXP_TAGETIK_MOV]')
              AND TYPE IN (N'P', N'RF', N'PC'))
BEGIN
    DROP PROCEDURE [sk_f2_flussi].[F2_EXP_TAGETIK_MOV];
END 
GO

SET ANSI_NULLS ON 
GO
SET QUOTED_IDENTIFIER ON 
GO

CREATE PROCEDURE [sk_f2_flussi].[F2_EXP_TAGETIK_MOV]
@dataEstrazione DATE,
@outputNum INT OUTPUT,
@outputMsg NVARCHAR(500) OUTPUT WITH
EXEC AS CALLER AS
BEGIN
    DECLARE @idOperazione INT
    DECLARE @idPartecipata INT
    DECLARE @idMovimento INT
    DECLARE @tipoOperazione NVARCHAR(5)
    DECLARE @descTipoOperazione NVARCHAR(50)
    DECLARE @cmgPartecipata NVARCHAR(20)
    DECLARE @cmgPartecipante NVARCHAR(20)
    DECLARE @tipoDerivato INT
    DECLARE @descTipoDerivato NVARCHAR(200)
    DECLARE @denomPartecipante NVARCHAR(150)
    DECLARE @SNDGPArtecipante NVARCHAR(16)
    DECLARE @idPartecipante INT
    DECLARE @SNDGCapogruppo NVARCHAR(16)
    DECLARE @idRapportoPart INT
    DECLARE @azioni DECIMAL(28, 2)
    DECLARE @azioniDV DECIMAL(28, 2)
    DECLARE @importo DECIMAL(28, 2)
    DECLARE @numQuote DECIMAL(28, 2)
	DECLARE @numAzioniPartecipata DECIMAL(28,2)
	DECLARE @numAzioniPartecipataDV DECIMAL(28,2)
    DECLARE @valuta NVARCHAR(5)
    DECLARE @causale NVARCHAR(10)
    DECLARE @dataContabile DATETIME
    DECLARE @gg INT
    DECLARE @ggprec CHAR(2)
    DECLARE @mm INT
    DECLARE @mmprec CHAR(2)
    DECLARE @yy INT
    DECLARE @yyprec CHAR(4)
    DECLARE @dataPeriodoPrec DATE
    DECLARE @dataRif DATE
    DECLARE @statoOperazione INT
    DECLARE @GUIDPersona UNIQUEIDENTIFIER
    DECLARE @dtFineOperazione DATE
    DECLARE @cmgMaxPerc NVARCHAR(20)
    SET @outputNum = 0
    SET @outputMsg = 'OK'
	-- variabili per gestire azioni della partecipata - prima riga del flusso
	declare @nuovaOperazione      bit
	declare @azioniGruppo DECIMAL(28, 2)
    declare @azioniDVGruppo DECIMAL(28, 2)
	-- progressivo giornaliero del movimento
	declare @progrGiornMov int
	-- indica se ci sono movimenti validi
	declare @numMovimenti int
	-- indica se ci sono saldi validi
	declare @numSaldi int

	-- declare @operazioni


BEGIN TRANSACTION;
  
BEGIN TRY
    -- Se esiste già un'estrazione per la stessa data cancello i dati precedenti
    DELETE
      FROM [SK_F2_FLUSSI].[F2_T_EXP_TAGETIK_MOV]
     WHERE data_estrazione = @dataEstrazione
    -- Ricavo data del periodo (trimestre) precedente l'attuale segnalazione
    SET @gg = DAY(@dataEstrazione)
    SET @mm = MONTH(@dataEstrazione)
    SET @yy = YEAR(@dataEstrazione)
    IF @mm IN (12, 11, 10)
    BEGIN
        SET @ggPrec = '30'
        SET @mmPrec = '09'
        SET @yyPrec = CONVERT(VARCHAR, @yy)
    END
    IF @mm IN (9, 8, 7)
    BEGIN
        SET @ggPrec = '30'
        SET @mmPrec = '06'
        SET @yyPrec = CONVERT(VARCHAR, @yy)
    END
    IF @mm IN (6, 5, 4)
    BEGIN
        SET @ggPrec = '31'
        SET @mmPrec = '03'
        SET @yyPrec = CONVERT(VARCHAR, @yy)
    END
    IF @mm IN (3, 2, 1)
    BEGIN
        SET @ggPrec = '31'
        SET @mmPrec = '12'
        SET @yyPrec = CONVERT(VARCHAR, @yy - 1)
    END
    SET @dataPeriodoPrec = CONVERT(DATE, @ggprec + '/' + @mmprec + '/' + @yyprec, 103)
    -- Definisco cursore per operazioni
    DECLARE Operazioni_CUR CURSOR FOR
    /*SELECT op.ID
         , op.ID_Tipo_Operazione
         , tipop.Descrizione
         , op.ID_Persona
      FROM SK_F2.F2_T_Operazioni op
         , SK_F2.F2_T_Persona p
         , SK_F2.F2_D_Tipi_Operazioni tipop
     WHERE op.ID_Tipo_Operazione IN ('P', 'FE', 'SFP') -- Tutte le partecipazioni, filiali estere, Strumenti Finanziari Partecipativi
       AND op.ID_Tipo_Operazione = tipop.ID
       AND p.ID = op.ID_Persona
       AND p.Data_Fine IS NULL
       AND ((op.ID_Stato_Operazione = 1
         AND op.Data_Inizio <= @dataEstrazione) OR 
            (op.ID_Stato_Operazione = 2
         AND CONVERT(DATE, op.data_fine) > @dataPeriodoPrec))
       AND (op.Cancellata = 0 OR
            op.Cancellata IS NULL)
     UNION ALL
    SELECT op.ID
         , op.ID_Tipo_Operazione
         , tipop.Descrizione
         , op.ID_Persona
      FROM SK_F2.F2_T_Operazioni op
         , SK_F2.F2_T_Persona p
         , sk_f2.f2_t_classificazioni_contabili cc
         , SK_F2.F2_D_Tipi_Operazioni tipop
     WHERE op.ID_Tipo_Operazione NOT IN ('P', 'FE', 'CG', 'PP', 'SFP') -- le altre operazioni ma solo se com metodo consolidamento IAS CI PN PR
       AND op.ID_Tipo_Operazione = tipop.ID
       AND p.ID = op.ID_Persona
       AND p.Data_Fine IS NULL
       AND cc.ID_Operazione = op.ID
       AND @dataEstrazione BETWEEN CONVERT(DATE, cc.data_inizio) AND CONVERT(DATE, ISNULL(cc.data_fine, '31/12/9999'))
       AND cc.ID_Metodo_Consolidamento_IAS IN ('CI', 'PN', 'PR')
       AND ((op.ID_Stato_Operazione = 1
         AND op.Data_Inizio <= @dataEstrazione) OR 
            (op.ID_Stato_Operazione = 2
         AND CONVERT(DATE, op.data_fine) > @dataPeriodoPrec))
       AND (op.Cancellata = 0 OR
            op.Cancellata IS NULL)
       AND (cc.Cancellata = 0 OR
            cc.Cancellata IS NULL) */
-- modifico filtro per operazioni in analogia al filtro del flusso di anagrafe
	SELECT	DISTINCT	op.ID, 
						op.ID_Tipo_Operazione, 
						tipop.Descrizione,
						op.ID_Persona									
    FROM SK_F2.F2_T_Operazioni op, 
	SK_F2.F2_T_Persona p, sk_f2.f2_t_classificazioni_contabili cc,
	SK_F2.F2_D_Tipi_Operazioni tipop
   WHERE -- considero tutte le tipologie di operazioni
    op.ID_Tipo_Operazione = tipop.ID
     AND p.ID = op.ID_Persona
     AND p.Data_Fine IS NULL 
     AND cc.ID_Operazione = op.ID
     --AND @dataEstrazione between convert(date, cc.data_inizio) and convert(date, isnull(cc.data_fine, '31/12/9999'))
	 AND cc.Codice_Mappa_Gruppo is not null	
     AND ( (op.ID_Stato_Operazione = 1 AND op.Data_Inizio <= @dataEstrazione)
	 OR (op.ID_Stato_Operazione = 2 and convert(date, op.data_fine) > @dataPeriodoPrec))
	 AND (op.Cancellata = 0 OR op.Cancellata IS NULL)
	 AND (cc.Cancellata = 0 OR cc.Cancellata IS NULL)	
	 				
    -- Prelevo operazioni
    OPEN Operazioni_CUR
    FETCH NEXT
     FROM Operazioni_CUR
     INTO @idOperazione, @tipoOperazione, @descTipoOperazione, @idPartecipata
    -- LOOP su Cursore Operazioni_CUR
    WHILE (@@FETCH_STATUS = 0)
    BEGIN
        -- Codice Mappa Gruppo Partecipata
		-- Calcolata dalle classificazioni contabili
		SET @cmgPartecipata = NULL
        SELECT @cmgPartecipata = Codice_Mappa_Gruppo
          FROM SK_F2.F2_T_Classificazioni_Contabili
         WHERE ID_Operazione = @idOperazione
           AND Data_Fine IS NULL
        IF @cmgPartecipata IS NULL
        BEGIN
            SET @cmgPartecipata = ''
        END

        -- Mappa gruppo della partecipante
        DECLARE Partecipanti_CUR CURSOR FOR
        SELECT rp.ID
             , rp.ID_Partecipante
          FROM SK_F2.F2_T_Rapporti_Partecipativi rp
         WHERE @dataEstrazione BETWEEN CONVERT(DATE, rp.Data_Inizio) AND CONVERT(DATE, ISNULL(rp.Data_Fine, '31/12/9999'))
           AND (rp.Cancellata = 0 OR
                rp.Cancellata IS NULL)
           AND rp.ID_Operazione = @idOperazione
		   -- considero tutti i partecipanti
           --AND (SK_F2.isSocietaGruppo(rp.ID_Partecipante, 'B', @dataEstrazione) = 1 OR
           --     SK_F2.isSocietaGruppo(rp.ID_Partecipante, 'C', @dataEstrazione) = 1)

        -- set flag nuova operazione per gestire prima riga con numero azioni della partecipata
		-- clear partecipante
        SET @denomPartecipante = ''
        SET @SNDGPartecipante = ''		
		SET @idRapportoPart = NULL
        OPEN Partecipanti_CUR
        FETCH NEXT
         FROM Partecipanti_CUR
         INTO @idRapportoPart, @idPartecipante
        WHILE (@@FETCH_STATUS = 0)
        BEGIN
            --print '@idOperazione [' + convert(varchar,@idOperazione) + ']'
            --print '@cmgPartecipata [' + @cmgPartecipata + ']'
            --print '@denomPartecipata[' + @denomPartecipata + ']'

            -- Ricavo i dati anagrafici del partecipante
            SELECT @SNDGPartecipante = p.SNDG
                 , @denomPartecipante = pg.Ragione_Sociale
              FROM sk_f2.f2_t_persona p
                 , sk_f2.f2_t_persona_giuridica pg
             WHERE p.id = @idPartecipante
               AND pg.id_persona = p.ID
               AND pg.data_fine IS NULL

            SET @SNDGCapogruppo = ''
            SELECT @SNDGCapogruppo = b.SNDG_BANCA
              FROM SK_F2.F2_D_Banche b
             WHERE b.FLAG_CAPOGRUPPO = 'S'
            -- Codice Mappa Gruppo Partecipante
            SET @cmgPartecipante = ''
            IF @SNDGPArtecipante = @SNDGCapogruppo
            BEGIN
                SET @cmgPartecipante = '06000'
            END
            ELSE
            BEGIN
			-- da verificare per i casi in cui non viene valorizzato cmg_partecipante
			-- eseguito se SNDGPartecipante <> SNDGCapogruppo
			-- Nota: presuppone ci sia un'operazione di partecipazione per cui prende 
			   -- in tal caso quel partecipante. Ci potrebbe essere il caso in cui le operazioni siano derivati...
			   -- in tal caso algoritmno ritorna null
			   SET @cmgPartecipante = NULL
                SELECT @cmgPartecipante = c.Codice_Mappa_Gruppo
                  FROM SK_F2.F2_T_Operazioni op
                     , SK_F2.F2_T_Classificazioni_Contabili c
                 WHERE op.Data_Fine IS NULL
                   AND op.ID_Tipo_Operazione = 'P'
                   AND c.ID_Operazione = op.ID
                   AND c.Data_Fine IS NULL
                   AND op.ID_Persona = @idPartecipante
            END
            IF @cmgPartecipante IS NULL
            BEGIN
                SET @cmgPartecipante = ''
            END

            -- Calcolo tipoderivato
            SET @tipoDerivato = NULL
            SET @descTipoDerivato = ''
            IF @tipoOperazione = 'D'
            BEGIN
                SELECT @tipoDerivato = d.id_tipo_derivato
                     , @descTipoDerivato = td.Descrizione
                  FROM SK_F2.F2_T_Dati_Derivato d
                     , SK_F2.F2_D_Tipi_Derivato td
                 WHERE d.ID_Operazione = @idOperazione
                   AND d.ID_Tipo_Derivato = td.ID
                -- Imposto Numero numquote = num azioni
                SET @numQuote = @azioni
            END
			ELSE
				BEGIN
					SET @numQuote = 0
				END
            -- CURSORE MOVIMENTI
            -- VERIFICARE CON ENRICA SE VOGLIONO IL SEGNO
            
			-- Interno al loop per ciascun partecipante
			-- se prima operazione inserisco il numero di azioni del Capitale Sociale
		
			-- Inserisco record relativo a sola partecipata con numero azioni del Capitale Sociale (prima era di gruppo)
			set @numAzioniPartecipata = 0
			set @numAzioniPartecipataDV = 0
			SELECT @numAzioniPartecipata = convert(bigint,SK_F2_REPORT.getTotaleAzioniCS(@idOperazione, @dataEstrazione))
			SELECT @numAzioniPartecipataDV = convert(bigint,SK_F2_REPORT.getTotaleAzioniDVCS(@idOperazione, @dataEstrazione))
         
		   -- TEST se gestita a saldi o movimenti
		   -- Controllo se ci sono movimenti validi, se non ci sono verifico che ci siano i saldi, in caso
		   -- contrario non inserisco nulla
		   set @numMovimenti = 0
		   SELECT @numMovimenti = count(*)
				FROM SK_F2.F2_T_Movimenti m
					WHERE m.ID_Rapporto_Partecipativo = @idRapportoPart
						AND m.data_fine IS NULL
						AND (m.Cancellata IS NULL OR
								m.Cancellata = 0)
            -- gestisco i movimenti
			IF @numMovimenti > 0	
				BEGIN
					DECLARE MOVIMENTI_CUR CURSOR FOR
					SELECT m.ID,
						   m.Progressivo_Giornaliero	
						 , m.Valore_Bilancio_Valuta
						 , m.ID_Valuta
						 , m.ID_Causale
						 , m.Data_Contabile
					  FROM SK_F2.F2_T_Movimenti m
					 WHERE m.ID_Rapporto_Partecipativo = @idRapportoPart
						   -- VERIFICARE CON ENRICA
					   AND CONVERT(DATE, m.data_contabile) <= @dataEstrazione
					   AND m.data_fine IS NULL
					   AND (m.Cancellata IS NULL OR
							m.Cancellata = 0)
						ORDER BY m.Data_Contabile

					OPEN MOVIMENTI_CUR
					FETCH NEXT
						FROM MOVIMENTI_CUR
						INTO @Idmovimento, @progrGiornMov, @Importo, @valuta, @causale, @dataContabile
					WHILE (@@FETCH_STATUS = 0)
					BEGIN
						
						SET @azioni = 0
						SET @azioniDV = 0
						SELECT @azioni = CONVERT(BIGINT, SK_F2_REPORT.getNumeroAzioniPartecipanteAlMovimento(@idRapportoPart, @dataContabile,@progrGiornMov) )
						SELECT @azioniDV = CONVERT(BIGINT, SK_F2_REPORT.getNumeroAzioniPartecipanteDVAlMovimento(@idRapportoPart, @dataContabile,@progrGiornMov))
			
						PRINT '*** Azioni Movimento ****'
						PRINT @azioni
						PRINT @azioniDV

					-- Inserisco nella tabella i dati calcolati
					INSERT
					  INTO [SK_F2_FLUSSI].[F2_T_EXP_TAGETIK_MOV]([data_estrazione]
															   , [id_Operazione]
															   , [id_movimento]
															   , [cmg_partecipata]
															   , [cmg_partecipante]
															   , [data_contabile]
															   , [numero_azioni]
															   , [numero_azioni_DV]
															   , [num_azioni_partecipata]
															   , [num_azioni_partecipataDV]
															   , [numero_quote]
															   , [tipo_derivato]
															   , [importo]
															   , [valuta]
															   , [id_causale])
					VALUES (@dataEstrazione
						  , @idOperazione
						  , @idMovimento
						  , @cmgPartecipata
						  , @cmgPartecipante
						  , @dataContabile
						  , @azioni
						  , @azioniDV
						  , @numAzioniPartecipata
						  , @numAzioniPartecipataDV
						  , @numQuote
						  , @tipoDerivato
						  , @Importo
						  , @valuta
						  , @causale)
					--   ,LEFT(ISNULL(@codiceCR, '') + space(13), 13)  -- Codice_CR - char(13)
					FETCH NEXT
					 FROM MOVIMENTI_CUR
					 INTO @Idmovimento, @progrGiornMov, @Importo, @valuta, @causale, @dataContabile
					END -- END CURSORE MOVIMENTI
				CLOSE MOVIMENTI_CUR
				DEALLOCATE MOVIMENTI_CUR
			   END -- Blocco codice se partecipazione gestita a movimenti

			   -- Gestione a saldi
			   SET @numSaldi = 0

			   SELECT @numSaldi = count(*)
				FROM SK_F2.F2_T_Saldi s
					WHERE s.ID_Rapporto_Partecipativo = @idRapportoPart
					AND s.data_fine IS NULL
					AND (s.Cancellata IS NULL OR
						s.Cancellata = 0)
               -- ci sono saldi
               IF @numSaldi > 0
				BEGIN
				PRINT 'MOV SALDO' 
				DECLARE SALDI_CUR CURSOR FOR
					SELECT TOP 1 s.ID,
						0,
					s.Valore_Bilancio_Valuta,
					s.ID_Valuta,
					'SAL',
					s.Numero_Azioni,
					s.Numero_Azioni_SV,
	   				s.Data_Saldo
					FROM SK_F2.F2_T_Saldi s
					WHERE s.ID_Rapporto_Partecipativo = @idRapportoPart
                   -- VERIFICARE CON ENRICA
					AND CONVERT(DATE, s.Data_Saldo) <= @dataEstrazione
					AND s.data_fine IS NULL
					AND (s.Cancellata IS NULL OR
                    s.Cancellata = 0)
					ORDER BY s.Data_Saldo desc

					OPEN SALDI_CUR
					FETCH NEXT FROM SALDI_CUR
						INTO @Idmovimento, @progrGiornMov, @Importo, @valuta, @causale, @azioni,@azioniDV,@dataContabile
					WHILE (@@FETCH_STATUS = 0)
						BEGIN
							INSERT
							INTO [SK_F2_FLUSSI].[F2_T_EXP_TAGETIK_MOV]([data_estrazione]
															   , [id_Operazione]
															   , [id_movimento]
															   , [cmg_partecipata]
															   , [cmg_partecipante]
															   , [data_contabile]
															   , [numero_azioni]
															   , [numero_azioni_DV]
															   , [num_azioni_partecipata]
															   , [num_azioni_partecipataDV]
															   , [numero_quote]
															   , [tipo_derivato]
															   , [importo]
															   , [valuta]
															   , [id_causale])
																VALUES (@dataEstrazione
																	  , @idOperazione
																	  , @idMovimento
																	  , @cmgPartecipata
																	  , @cmgPartecipante
																	  , @dataContabile
																	  , @azioni
																	  , @azioniDV
																	  , @numAzioniPartecipata
																	  , @numAzioniPartecipataDV
																	  , @numQuote
																	  , ''
																	  , @Importo
																	  , @valuta
																	  , @causale)
					
											FETCH NEXT
														FROM SALDI_CUR
															INTO @Idmovimento, @progrGiornMov, @Importo, @valuta, @causale,@azioni,@azioniDV, @dataContabile
						END -- END CURSORE SALDI
						CLOSE SALDI_CUR
						DEALLOCATE SALDI_CUR

				END

            FETCH NEXT
             FROM Partecipanti_CUR
             INTO @idRapportoPart, @idPartecipante
        END -- end partecipanti
        CLOSE Partecipanti_CUR
        DEALLOCATE Partecipanti_CUR
        -- rifare fetch per eventuale uscita da ciclo while 
        FETCH NEXT
         FROM Operazioni_CUR
         INTO @idOperazione, @tipoOperazione, @descTipoOperazione, @idPartecipata
    END -- END LOOP 
    CLOSE Operazioni_CUR
    DEALLOCATE Operazioni_CUR
    SELECT *
      INTO #tempTgtkMOV
      FROM (
            --SELECT  'D_PTFL_PAR;D_PTFL_SUB;MOV_DATA;P_MODFSHARE;P_INITSHARE;NUM_QUOTE;TIPDER;IMPORTO;CURRENCY;ID_CAUSALE_PARTY;DATARIF' as record
            --UNION ALL
			SELECT
			ID,
			 -- DPTFL_PAR : partecipante
			 -- DPTFL_SUB: partecipata
			 /* CASE
			   WHEN [cmg_partecipante] is NULL THEN ''
			   ELSE [cmg_partecipante] + ';'
			  END + */
			  isnull([cmg_partecipante],'') +';'+ 
			  isnull([cmg_partecipata],'') + ';'+ 
			  convert(nvarchar,[data_contabile],112) + ';'+ 
			  --P_INITSHARE: #azioni
			  --P_MODFSHARE: #azioniDV 
			  isnull(CAST([numero_azioni_DV] as nvarchar),'') +';'+ 
			  isnull(CAST([numero_azioni] as nvarchar),'') +';'+ 
			  isnull(CAST([num_azioni_partecipata] as nvarchar),'') +';'+ 
			  isnull(CAST([num_azioni_partecipataDV] as nvarchar),'') +';'+ 
			  isnull(convert(nvarchar,[numero_quote]),'') +';'+ 
			  isNULL([tipo_derivato],'') +';'+ 
			  isnull(cast([importo] as nvarchar),'') +';'+ 
			  isnull([valuta],'') +';'+ 
			  isnull([id_causale],'') +';'+ 
			  convert(nvarchar,[data_estrazione],112)  as record
              FROM [SK_F2_FLUSSI].[F2_T_EXP_TAGETIK_MOV] m
             WHERE Data_estrazione = @dataEstrazione) tab
			       
    SELECT record
      FROM #tempTgtkMOV order by ID end TRY
    BEGIN CATCH
        SET @outputNum = -1
        SELECT @outputMsg = ERROR_MESSAGE()
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
	
END CATCH;

	
IF @@TRANCOUNT > 0
    COMMIT TRANSACTION;
END