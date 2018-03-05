USE [PART0]
GO
/****** Object:  StoredProcedure [SK_F2_FLUSSI].[F2_EXP_ContrColl_Variazioni]    Script Date: 06/02/2018 10:21:53 ******/
IF EXISTS (SELECT *
             FROM sys.objects
            WHERE OBJECT_ID = OBJECT_ID(N'[SK_F2_FLUSSI].[F2_EXP_ContrColl_Variazioni]')
              AND TYPE IN (N'P', N'RF', N'PC'))
BEGIN
    DROP PROCEDURE SK_F2_FLUSSI.F2_EXP_ContrColl_Variazioni;
END

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [SK_F2_FLUSSI].[F2_EXP_ContrColl_Variazioni]
    @dataEstrazione DATE, @outputNum INT OUTPUT, @outputMsg NVARCHAR(500) OUTPUT
  WITH EXEC AS CALLER
AS
  BEGIN
    DECLARE @dataEstrazionePrec DATE
    DECLARE @delimitatore CHAR(1)

    SET @outputNum = 0
    SET @outputMsg = 'OK'

    SET @delimitatore = ';'
    --set @dataEstrazionePrec = dateadd(day, -1, @dataEstrazione)

    BEGIN TRANSACTION;

    BEGIN TRY

    DELETE FROM SK_F2_FLUSSI.F2_T_EXP_ContrColl
    WHERE DataRif = @dataEstrazione

    -- Ricavo data Ultima estrazione effettuata
    SET @dataEstrazionePrec = NULL
    SELECT @dataEstrazionePrec = MAX(DataRif)
    FROM SK_F2_FLUSSI.F2_T_EXP_ContrColl

    INSERT INTO SK_F2_FLUSSI.F2_T_EXP_ContrColl
      SELECT DISTINCT
        @dataEstrazione                                              AS DataRif,
        op.id                                                        AS IdOperazione,
        ISNULL(p.SNDG, '')                                           AS Sndg,
        ISNULL(p.Codice_Mappa_Gruppo, '')                            AS CodicePartecipata,
        ISNULL(pg.Ragione_Sociale, '')                               AS DenomPartecipata,
        ISNULL(cla.ID_Classificazione_IAS, '')                       AS CodClassIAS,
        ISNULL((SELECT Descrizione
                FROM SK_F2.F2_D_Classificazione_IAS
                WHERE ID = cla.ID_Classificazione_IAS), '')          AS DescClassIAS,
        ISNULL(p.ID_Tipo_NDG, '')                                    AS CodFormaGiuridica,
        ISNULL((SELECT Descrizione
                FROM SK_F2.F2_D_Tipo_NDG
                WHERE ID = p.ID_Tipo_NDG), '')                       AS DescFormaGiuridica,
        ISNULL(convert(NVARCHAR, pg.Data_Costituzione, 103), '')     AS DataCostituzione,
        ISNULL(p.Codice_Fiscale, '')                                 AS CodiceFiscale,
        ISNULL(p.ID_SAE, '')                                         AS SAE,
        ISNULL(p.ID_RAE, '')                                         AS RAE,
        ISNULL(ind.Citta, '')                                        AS Comune,
        ISNULL(ind.Indirizzo, '')                                    AS Indirizzo,
        ISNULL(ind.cap, '')                                          AS Cap,
        ISNULL(ind.Provincia, '')                                    AS Provincia,
        ISNULL(ind.Stato, '')                                        AS Stato,
        ISNULL(cla.ID_Classificazione_Banca_Italia, 0)               AS CodClassBankit,
        ISNULL((SELECT Descrizione
                FROM SK_F2.F2_D_Classificazione_Banca_Italia
                WHERE ID = cla.ID_Classificazione_Banca_Italia), '') AS DescClassBankit,
        ISNULL((SELECT Descrizione
                FROM SK_F2.F2_D_Centro_Reponsabilita
                WHERE ID = cla.ID_Centro_Responsabilita), '')        AS CentroResponsabilita,
        ISNULL((SELECT Descr_Daisy
                FROM SK_F2.F2_D_Gestori_Partecipazione
                WHERE ID = cla.Gestore_Partecipazione), '')          AS Gestore,
        op.Data_Inizio                                               AS OperDataInizio,
        op.Data_Fine                                                 AS OperDataFine,
        cla.Data_Inizio                                              AS ClassDataInizio,
        cla.Data_Fine                                                AS ClassDataFine
      FROM SK_F2.f2_t_operazioni op,
        SK_F2.f2_t_classificazioni_anagrafiche cla,
        SK_F2.f2_t_persona_giuridica pg,
        SK_F2.f2_t_persona p
        LEFT OUTER JOIN SK_F2.F2_T_Indirizzi_Persona ind
          ON ind.ID_Persona = p.id AND @dataEstrazione BETWEEN ind.Data_Inizio AND isnull(ind.Data_Fine, '31/12/9999')
             AND ind.ID_Tipo_Indirizzo = 4
      WHERE op.ID_Stato_Operazione <> 3
            AND (op.Cancellata IS NULL OR op.Cancellata = 0)
            AND isnull(op.Data_Fine, '31/12/9999') >= @dataEstrazione
            AND op.ID_Tipo_Operazione NOT IN ('CG', 'PP', 'FE', 'V')
            AND op.ID_Persona = p.id
            AND p.Data_Fine IS NULL
            AND pg.ID_Persona = p.ID
            --and @dataEstrazione between pg.Data_Inizio and isnull(pg.Data_Fine , '31/12/9999')
            AND pg.Data_Fine IS NULL
            AND cla.id_operazione = op.ID
            AND @dataEstrazione BETWEEN cla.Data_Inizio AND isnull(cla.Data_Fine, '31/12/9999')
            AND (cla.Cancellata IS NULL OR cla.Cancellata = 0)

    IF @dataEstrazionePrec IS NOT NULL
      BEGIN

        SELECT *
        INTO #ContrCollVariazioni
        FROM (
               -- Record di Testata
               SELECT
                   Ordine = 0,
                   'Indicatore' + @delimitatore
                   + 'Periodo' + @delimitatore
                   + 'Ndg di Gruppo' + @delimitatore
                   + 'Codice Partecipata' + @delimitatore
                   + 'Denominazione Partecipata' + @delimitatore
                   + 'Codice Classificazione IAS' + @delimitatore
                   + 'Descrizione Classificazione IAS' + @delimitatore
                   + 'Forma Giuridica' + @delimitatore
                   + 'Data Costituzione' + @delimitatore
                   + 'Codice Fiscale' + @delimitatore
                   + 'Settore Economico' + @delimitatore
                   + 'Ramo Economico' + @delimitatore
                   + 'Comune Sede Legale' + @delimitatore
                   + 'Indirizzo Sede Legale' + @delimitatore
                   + 'CAP Sede Legale' + @delimitatore
                   + 'Provincia Sede Legale' + @delimitatore
                   + 'Nazione Sede Legale' + @delimitatore
                   + 'Classificazione Bankit' + @delimitatore
                   + 'Centro di Responsabilita' + @delimitatore
                   + 'Gestore Partecipazione/Settorista' + @delimitatore
                   + 'Periodo Validita' + @delimitatore AS Record

               UNION

               ------------ VARIAZIONI
               SELECT
                   Ordine = 1,
                   'Variazioni' + @delimitatore
                   + convert(VARCHAR, x.DataRif, 103) + @delimitatore
                   + x.Sndg + @delimitatore
                   + ltrim(rtrim(isNull(x.CodicePartecipata,''))) + @delimitatore
                   + ltrim(rtrim(isNull(x.DenomPartecipata,''))) + @delimitatore
                   + ltrim(rtrim(isNull(x.CodClassIAS,''))) + @delimitatore
                   + ltrim(rtrim(isNull(x.DescClassIAS,''))) + @delimitatore
                   + ltrim(rtrim(isNull(x.DescFormaGiuridica,''))) + @delimitatore
                   + ltrim(rtrim(isNull(x.DataCostituzione,''))) + @delimitatore
                   + ltrim(rtrim(isNull(x.CodiceFiscale,''))) + @delimitatore
                   + ltrim(rtrim(isNull(x.SAE,''))) + @delimitatore
                   + ltrim(rtrim(isNull(x.RAE,''))) + @delimitatore
                   + ltrim(rtrim(isNull(x.Comune,''))) + @delimitatore
                   + ltrim(rtrim(isNull(x.Indirizzo,''))) + @delimitatore
                   + ltrim(rtrim(isNull(x.Cap,''))) + @delimitatore
                   + ltrim(rtrim(isNull(x.Provincia,''))) + @delimitatore
                   + ltrim(rtrim(isNull(x.Stato,''))) + @delimitatore
                   + ltrim(rtrim(isNull(x.DescClassBankit,''))) + @delimitatore
                   + ltrim(rtrim(isNull(x.CentroResponsabilita,''))) + @delimitatore
                   + ltrim(rtrim(isNull(x.Gestore,''))) + @delimitatore
                   + '' + @delimitatore AS Record
               FROM SK_F2_FLUSSI.F2_T_EXP_ContrColl x
                 INNER JOIN (
                              SELECT *
                              FROM SK_F2_FLUSSI.F2_T_EXP_ContrColl
                              WHERE DataRif = convert(DATE, @dataEstrazionePrec, 103)
                            ) AS Vista ON x.IdOperazione = Vista.IdOperazione
               WHERE x.DataRif = @dataEstrazione
                     AND (IsNull(x.DenomPartecipata, '') <> IsNull(Vista.DenomPartecipata, '')
                          OR (IsNull(x.CodClassIAS, '') <> IsNull(Vista.CodClassIAS, '') AND
                              x.CodClassIAS IN ('CLL', 'CJV')))

               UNION

               -------------- ENTRATE
               SELECT
                   Ordine = 2,
                   'Entrate' + @delimitatore
                   + convert(VARCHAR, x.DataRif, 103) + @delimitatore
                   + x.Sndg + @delimitatore
                   + ltrim(rtrim(isnull(x.CodicePartecipata,''))) + @delimitatore
                   + ltrim(rtrim(isnull(x.DenomPartecipata,''))) + @delimitatore
                   + ltrim(rtrim(isnull(x.CodClassIAS,''))) + @delimitatore
                   + ltrim(rtrim(isnull(x.DescClassIAS,''))) + @delimitatore
                   + ltrim(rtrim(isnull(x.DescFormaGiuridica,''))) + @delimitatore
                   + ltrim(rtrim(isnull(x.DataCostituzione,''))) + @delimitatore
                   + ltrim(rtrim(isnull(x.CodiceFiscale,''))) + @delimitatore
                   + ltrim(rtrim(isnull(x.SAE,''))) + @delimitatore
                   + ltrim(rtrim(isnull(x.RAE,''))) + @delimitatore
                   + ltrim(rtrim(isnull(x.Comune,''))) + @delimitatore
                   + ltrim(rtrim(isnull(x.Indirizzo,''))) + @delimitatore
                   + ltrim(rtrim(isnull(x.Cap,''))) + @delimitatore
                   + ltrim(rtrim(isnull(x.Provincia,''))) + @delimitatore
                   + ltrim(rtrim(isnull(x.Stato,''))) + @delimitatore
                   + ltrim(rtrim(isnull(x.DescClassBankit,''))) + @delimitatore
                   + ltrim(rtrim(isnull(x.CentroResponsabilita,''))) + @delimitatore
                   + ltrim(rtrim(isnull(x.Gestore,''))) + @delimitatore
				   -- classDataInizio sempre valorizzata.....
                   + 'Entrata nel Gruppo il: ' + convert(VARCHAR, x.ClassDataInizio, 103) + @delimitatore AS Record
               FROM SK_F2_FLUSSI.F2_T_EXP_ContrColl x
                 LEFT JOIN (
                             SELECT *
                             FROM SK_F2_FLUSSI.F2_T_EXP_ContrColl
                             WHERE DataRif = @dataEstrazionePrec
                           ) AS Vista ON x.IdOperazione = Vista.IdOperazione
               WHERE x.DataRif = @dataEstrazione
                     AND Vista.IdOperazione IS NULL
                     AND x.CodClassIAS IN ('CLL', 'CJV')

               UNION

               -------------- Usicte
               SELECT
                   Ordine = 3,
                   'Uscite' + @delimitatore
                   + convert(VARCHAR, Vista.DataRif, 103) + @delimitatore
                   + Vista.Sndg + @delimitatore
                   + ltrim(rtrim(isnull(Vista.CodicePartecipata,''))) + @delimitatore
                   + ltrim(rtrim(isnull(Vista.DenomPartecipata,''))) + @delimitatore
                   + ltrim(rtrim(isnull(Vista.CodClassIAS,''))) + @delimitatore
                   + ltrim(rtrim(isnull(Vista.DescClassIAS,''))) + @delimitatore
                   + ltrim(rtrim(isnull(Vista.DescFormaGiuridica,''))) + @delimitatore
                   + ltrim(rtrim(isnull(Vista.DataCostituzione,''))) + @delimitatore
                   + ltrim(rtrim(isnull(Vista.CodiceFiscale,''))) + @delimitatore
                   + ltrim(rtrim(isnull(Vista.SAE,''))) + @delimitatore
                   + ltrim(rtrim(isnull(Vista.RAE,''))) + @delimitatore
                   + ltrim(rtrim(isnull(Vista.Comune,''))) + @delimitatore
                   + ltrim(rtrim(isnull(Vista.Indirizzo,''))) + @delimitatore
                   + ltrim(rtrim(isnull(Vista.Cap,''))) + @delimitatore
                   + ltrim(rtrim(isnull(Vista.Provincia,''))) + @delimitatore
                   + ltrim(rtrim(isnull(Vista.Stato,''))) + @delimitatore
                   + ltrim(rtrim(isnull(Vista.DescClassBankit,''))) + @delimitatore
                   + ltrim(rtrim(isnull(Vista.CentroResponsabilita,''))) + @delimitatore
                   + ltrim(rtrim(isnull(Vista.Gestore,''))) + @delimitatore
                   + 'Uscita dal Gruppo il: ' + convert(VARCHAR, Vista.ClassDataFine, 103) + @delimitatore AS Record
               FROM (
                      SELECT *
                      FROM SK_F2_FLUSSI.F2_T_EXP_ContrColl
                      WHERE DataRif = @dataEstrazionePrec 
					  -- imposto filtro su valorizzazione data fine della classificazione
					  and ClassDataFine is not null
                    ) AS Vista
                 LEFT JOIN SK_F2_FLUSSI.F2_T_EXP_ContrColl x
                   ON x.IdOperazione = Vista.IdOperazione AND x.DataRif = @dataEstrazione
               WHERE x.IdOperazione IS NULL
                     AND Vista.CodClassIAS IN ('CLL', 'CJV')
             ) tab

        -- SELECT FINALE
        SELECT Record
        FROM #ContrCollVariazioni
        ORDER BY Ordine
      END
    ELSE
      BEGIN
        -- Non ho un periodo precedente di confronto, restituisco un valore vuoto
        SELECT '' AS Record
      END

    END TRY
    BEGIN CATCH
    SET @outputNum = -1
    SELECT @outputMsg = ERROR_MESSAGE()

    IF @@TRANCOUNT > 0
      ROLLBACK TRANSACTION;

    DECLARE @msg NVARCHAR(MAX);
    SET @msg = 'Il flusso F2_EXP_ContrColl_Variazioni è fallito; numero errore = ' +
               CONVERT(VARCHAR(MAX), ERROR_NUMBER());
    EXEC SK_F2.F2_ChiamaLogProcedura
        @ObjectID = @@PROCID,
    @InfoAggiuntive = @msg;

    END CATCH;

    IF @@TRANCOUNT > 0
      COMMIT TRANSACTION;

  END
