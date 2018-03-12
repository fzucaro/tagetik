USE [PART0]
GO
/****** Object:  StoredProcedure [SK_F2_FLUSSI].[F2_EXP_TAGETIK_Anag]    Script Date: 06/02/2018 10:21:53 ******/
IF EXISTS (SELECT *
             FROM sys.objects
            WHERE OBJECT_ID = OBJECT_ID(N'[SK_F2_FLUSSI].[F2_EXP_TAGETIK_Anag]')
              AND TYPE IN (N'P', N'RF', N'PC'))
BEGIN
    DROP PROCEDURE SK_F2_FLUSSI.F2_EXP_TAGETIK_Anag;
END

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [SK_F2_FLUSSI].[F2_EXP_TAGETIK_Anag]
    @dataEstrazione date, @outputNum int OUTPUT, @outputMsg nvarchar(500) OUTPUT

WITH EXEC AS CALLER
AS
BEGIN
  declare @idOperazione         int
  declare @idPartecipata        int
  declare @tipoOperazione       nvarchar(5)
  declare @flagScarto           bit
  declare @motivoScarto         nvarchar(2000)
  declare @sndgPartecipata      nvarchar(16)
  declare @SAE                  nvarchar(6)
  declare @RAE                  nvarchar(3)
  declare @codFiscale           nvarchar(16)
  declare @partitaIVA           nvarchar(16)
  declare @ragioneSociale       nvarchar(2000) 
  declare @codiceABI            nvarchar(5)
  declare @ATECO                nvarchar(6)
  declare @codiceCR             nvarchar(16)
  declare @codiceUIC            nvarchar(16)
  declare @statoSedeLegale      nvarchar(200) 
  declare @cittaSedeLegale      nvarchar(200)
  declare @sede                 nvarchar(200)
  declare @residenza            nvarchar(8)
  declare @descrAttivita        nvarchar(200)
  declare @quotata              int
  declare @tipoQuotazione       nvarchar(8)
  declare @classBI              int
  declare @classIAS             nvarchar(3)
  declare @classPNF             int 
  declare @businessUnit         int
  declare @BUrif                nvarchar(3)
  declare @cmg                  nvarchar(20) 
  declare @metodo               nvarchar(3)
  declare @metodoConsBI         nvarchar(3)
  declare @metodoConsIAS        nvarchar(3)
  declare @metodoConsIASPrec    nvarchar(3)
  declare @metodoConsFinrep     nvarchar(3) 
  declare @gruppoBancario       bit 
  declare @dataInizioClCont     date
  declare @dataIngressoBI       char(8)
  declare @percPossessoGruppo   decimal (20,3)
  declare @percPossessoDVGruppo decimal (20,3)
  --declare @csSottoscrittoEuro   decimal (28,8)
  declare @superISIN            nvarchar(16)
  declare @tipoRaggruppamento   nvarchar(8)
  declare @settoreISVAP         nvarchar(8)
  declare @valuta               nvarchar(8)
  declare @tipoControparte      nvarchar(8) 
  declare @tipoControparteC     nvarchar(8)
  declare @tipoControparteR     nvarchar(8)
  declare @areaGeografica       nvarchar(8) 
  declare @areaGeograficaC      nvarchar(8) 
  declare @areaGeograficaR      nvarchar(8) 
  declare @affidatoGarante      nvarchar(8)
  declare @filialeAppart        int
  declare @categControparte     nvarchar(8)
  declare @carattPartecip       nvarchar(8)
  declare @subHolding           nvarchar(8)
  declare @variazioneMetodo     nvarchar(8)
  declare @gerarchiaFV          int
  declare @livelloFV            char(2)
  declare @gruppoAttEconomica   nvarchar(8)
  declare @tipoRapportoEff      nvarchar(8)
  declare @classBI_TipoQuot     nvarchar(8)
  declare @appGruppoBancario    nvarchar(8)
  declare @modPartecipazione    nvarchar(8)
  declare @gg                   int
  declare @ggprec               char(2)
  declare @mm                   int
  declare @mmprec               char(2)
  declare @yy                   int
  declare @yyprec               char(4)
  declare @dataPeriodoPrec      date
  declare @dataRif              date
  declare @statoOperazione      int
  declare @GUIDPersona          uniqueidentifier
  declare @dtFineOperazione     date
  -- dati flussobilancio consolidato
	declare @DTINICC							nvarchar(8)
	declare @DTFINECC							nvarchar(8)
	declare @DTCOST								nvarchar(8)
	declare @CODLEI								nvarchar(20)
	declare @SEDEAM								nvarchar(20)
	declare @CLIAS								nvarchar(8)
	declare @CODPR								nvarchar(8) -- Codice mappa gruppo da cc ???
	declare @TIPOP								nvarchar(5)
	declare @DESOP								nvarchar(50)
	declare @TIPDER								nvarchar(5)
	declare @DESDER								nvarchar(50)
	declare @GRPASS								nvarchar(1)

	declare @gruppo_assicurativo	bit
	declare @cmgMaxPerc           nvarchar(20)

    declare @dataIngressoBI_Date date
    -- campo id tipologia fondo
	declare @idTipologiaFondo int
	-- switch per generare file spaziatura fissa, in esercizio deve essere a false
	declare @spaziaturaFissa bit


  set @outputNum = 0
	set @outputMsg = 'OK'


	set @spaziaturaFissa = 0

	BEGIN TRANSACTION;
  
  BEGIN TRY
  
  -- Se esiste già un'estrazione per la stessa data cancello i dati precedenti
  DELETE FROM SK_F2_FLUSSI.F2_T_EXP_TAGETIK_Anag
   WHERE Data_estrazione = @dataEstrazione
     
  -- Ricavo data del periodo (trimestre) precedente l'attuale segnalazione
  set @gg = day(@dataEstrazione)
  set @mm = month(@dataEstrazione)
  set @yy = year(@dataEstrazione)
    
  IF @mm in (12, 11, 10)
  BEGIN
     set @ggPrec = '30'
     set @mmPrec = '09'
     set @yyPrec = convert(varchar,@yy)
  END
    
  IF @mm in (9, 8, 7)
  BEGIN
     set @ggPrec = '30'
     set @mmPrec = '06'
     set @yyPrec = convert(varchar,@yy)
  END
    
  IF @mm in (6, 5, 4)
  BEGIN
     set @ggPrec = '31'
     set @mmPrec = '03'
     set @yyPrec = convert(varchar,@yy)
  END
    
  IF @mm in (3, 2, 1)
  BEGIN
     set @ggPrec = '31'
     set @mmPrec = '12'
     set @yyPrec = convert(varchar,@yy-1)
  END
    
  set @dataPeriodoPrec = convert(date, @ggprec + '/' + @mmprec + '/' + @yyprec, 103)
  --print 'Data string [' + @ggprec + '/' + @mmprec + '/' + @yyprec + ']'
  --print 'Data date [' + convert(varchar,@dataPeriodoPrec) + ']'
  
  DECLARE Operazioni_CUR CURSOR FOR
  /* SELECT	op.ID, 
					op.ID_Tipo_Operazione, 
					tipop.Descrizione,
					op.ID_Persona, 
					p.SNDG, 
					p.ID_SAE, 
					p.ID_RAE, 
					p.Partita_IVA, 
					p.Codice_Fiscale, 
					op.ID_Stato_Operazione, 
					p.GUID_Persona, 
					ISNULL(op.Data_Fine, '31/12/9999')
    FROM SK_F2.F2_T_Operazioni op, SK_F2.F2_T_Persona p,SK_F2.F2_D_Tipi_Operazioni tipop
   WHERE op.ID_Tipo_Operazione in ('P', 'FE', 'SFP') -- Tutte le partecipazioni, filiali estere, Strumenti Finanziari Partecipativi
	   AND op.ID_Tipo_Operazione = tipop.ID
     AND p.ID = op.ID_Persona
     AND p.Data_Fine IS NULL 
     AND ((op.ID_Stato_Operazione = 1 AND op.Data_Inizio <= @dataEstrazione) OR (op.ID_Stato_Operazione = 2 and convert(date, op.data_fine) > @dataPeriodoPrec))
	   AND (op.Cancellata = 0 OR op.Cancellata IS NULL)
  UNION ALL*/
  SELECT		op.ID, 
						op.ID_Tipo_Operazione, 
						tipop.Descrizione,
						op.ID_Persona, 
						p.SNDG, 
						p.ID_SAE, 
						p.ID_RAE, 
						p.Partita_IVA, 
						p.Codice_Fiscale, 
						op.ID_Stato_Operazione, 
						p.GUID_Persona, 
						ISNULL(op.Data_Fine, '31/12/9999')
    FROM SK_F2.F2_T_Operazioni op, 
	SK_F2.F2_T_Persona p, sk_f2.f2_t_classificazioni_contabili cc,
	SK_F2.F2_D_Tipi_Operazioni tipop
   WHERE -- considero tutte le tipologie di operazioni
    op.ID_Tipo_Operazione = tipop.ID
     AND p.ID = op.ID_Persona
     AND p.Data_Fine IS NULL 
     AND cc.ID_Operazione = op.ID
     AND @dataEstrazione between convert(date, cc.data_inizio) and convert(date, isnull(cc.data_fine, '31/12/9999'))
	 AND cc.Codice_Mappa_Gruppo is not null
	 -- se tipooperazione è filiale estera non considero il filtro su metodo di consolidamento
	 -- AND (cc.ID_Metodo_Consolidamento_IAS is not null OR  op.ID_Tipo_Operazione in ('FE','IMP') )
	 -- eliminato filtro su tipo operazioni, prendo solo id_metodo consolidamento ias non nullo
	 AND cc.ID_Metodo_Consolidamento_IAS is not null 
     --AND cc.ID_Metodo_Consolidamento_IAS in ('CI', 'PN', 'PR')
     AND ( (op.ID_Stato_Operazione = 1 AND op.Data_Inizio <= @dataEstrazione)
	 OR (op.ID_Stato_Operazione = 2 and convert(date, op.data_fine) > @dataPeriodoPrec))
	 AND (op.Cancellata = 0 OR op.Cancellata IS NULL)
	 AND (cc.Cancellata = 0 OR cc.Cancellata IS NULL)


  --PRINT 'OPEN CURSOR' 
  OPEN Operazioni_CUR
  FETCH NEXT FROM Operazioni_CUR INTO @idOperazione, @tipoOperazione, @DESOP, @idPartecipata, @sndgPartecipata,
                                      @SAE, @RAE, @partitaIVA, @codFiscale, @statoOperazione, @GUIDPersona,
                                      @dtFineOperazione
	--PRINT 'DOPO FETCH' 
  WHILE (@@FETCH_STATUS = 0)
  BEGIN    
    set @flagScarto = 0
    set @motivoScarto = ''
    
    set @dataRif = @dataEstrazione
    IF @statoOperazione = 2 AND @dtFineOperazione < @dataEstrazione -- Cessata
    BEGIN
        set @dataRif = @dtFineOperazione --@dataPeriodoPrec -- se Op CESSATA la data di riferimento delle info di classificazion è il periodo precedente
    END
--print 'Datarif: ' + convert(nvarchar, @datarif)
--print 'ID_Pers: ' + convert(nvarchar, )
    IF @partitaIVA IS NULL or LTRIM(RTRIM(@partitaIVA)) = '' 
    BEGIN
        set @partitaIVA = @codFiscale
    END

		--PRINT '223' 
    set @ragioneSociale = '' 
    set @codiceABI = '' 
    set @ATECO = '' 
    set @codiceCR = '' 
    set @codiceUIC = '' 
    SELECT @ragioneSociale = pg.Ragione_Sociale,
           @codiceABI = CASE WHEN pg.Codice_ABI IS NULL OR pg.Codice_ABI = '00000' THEN '' ELSE pg.Codice_ABI END, 
           @ATECO = pg.ID_ATECO, 
           @codiceCR = pg.Codice_CR, 
           @codiceUIC = pg.Codice_UIC,
					 --FZ codice LEI
					 @CODLEI = pg.Codice_LEI,					 
					 @DTCOST = ISNULL(CONVERT(nvarchar,pg.Data_Costituzione,112),Space(8) ),
					 @idTipologiaFondo = ISNULL(CONVERT(nvarchar,pg.ID_Tipologia_Fondo),'')
      FROM SK_F2.F2_T_Persona_Giuridica pg
     WHERE pg.GUID_Persona = @GUIDPersona
       AND @dataRif between convert(date, pg.Data_Inizio) and convert(date,isnull(pg.Data_Fine, '31/12/9999'))

/*
Richiesta 5-01-18
Se la ragione sociale alla data è NULL prelevo la più recente
*/
 IF @ragioneSociale IS NULL OR LTRIM(RTRIM(@ragioneSociale)) = ''
  BEGIN
   SELECT TOP 1 @ragioneSociale = pg.Ragione_Sociale
	  FROM SK_F2.F2_T_Persona_Giuridica pg
     WHERE pg.GUID_Persona = @GUIDPersona
		 ORDER BY pg.Data_Inizio desc
   END


    --WHERE pg.ID_Persona = @idPartecipata
    --   AND pg.Data_Fine IS NULL   
   --PRINT '242'
    set @statoSedeLegale = '' 
    set @cittaSedeLegale = '' 
    SELECT @statoSedeLegale = Stato, 
           @cittaSedeLegale = Citta 
      FROM SK_F2.F2_T_Indirizzi_Persona ind
     WHERE --ind.ID_Persona = @idPartecipata
           ind.GUID_Persona = @GUIDPersona
       AND ind.ID_Tipo_Indirizzo = 4  -- Sede Legale
       AND @dataRif between convert(date, ind.Data_Inizio) and convert(date,isnull(ind.Data_Fine, '31/12/9999'))
       --AND Data_Fine IS NULL
    
    IF @statoSedeLegale = 'ITALIA' OR @statoSedeLegale IS NULL OR len(ltrim(rtrim(@statoSedeLegale))) = 0
    BEGIN
        set @sede = @cittaSedeLegale
        set @residenza = 'A00I'
    END
    ELSE
    BEGIN
        set @sede = @statoSedeLegale
        set @residenza = 'A00E'
    END
       
    --PRINT '265'
    -- Determinazione sede amministrativa
			Set @SEDEAM = ''
			SELECT @statoSedeLegale = Stato, 
           @cittaSedeLegale = Citta 
      FROM SK_F2.F2_T_Indirizzi_Persona ind
     WHERE --ind.ID_Persona = @idPartecipata
           ind.GUID_Persona = @GUIDPersona
       AND ind.ID_Tipo_Indirizzo = 3  -- Sede Amministrativa
       AND @dataRif between convert(date, ind.Data_Inizio) and convert(date,isnull(ind.Data_Fine, '31/12/9999'))
    IF @statoSedeLegale = 'ITALIA' OR @statoSedeLegale IS NULL OR len(ltrim(rtrim(@statoSedeLegale))) = 0
    BEGIN
        set @SEDEAM = @cittaSedeLegale        
    END
    ELSE
    BEGIN
        set @SEDEAM = @statoSedeLegale        
    END

		--PRINT '284'
    set @descrAttivita = ''
    set @quotata = NULL 
    set @classBI = NULL
    set @classIAS = '' 
    set @classPNF = NULL
    set @businessUnit = NULL
		set @CLIAS = NULL
    SELECT @descrAttivita = Descrizione_Attivita, 
           @quotata = ID_Quotata, 
           @classBI = ID_Classificazione_Banca_Italia,
           @classIAS = ID_Classificazione_IAS, 
           @classPNF = ID_Classificazione_PNF, 
           @businessUnit = ID_Cash_Generating_Unit,
					 @CLIAS = ID_Classificazione_IAS
      FROM SK_F2.F2_T_Classificazioni_Anagrafiche
     WHERE ID_Operazione = @idOperazione
       AND @dataRif between convert(date, Data_Inizio) and convert(date, isnull(Data_Fine, '31/12/9999'))
			 AND (Cancellata = 0 or Cancellata is null)
  
    -- Per le Filiali estere forziamo 5 in classificazione banca d'italia
    IF @tipoOperazione = 'FE'
    BEGIN
      set @classBI = 5
    END
    
    set @BUrif = ''
    IF @businessUnit IS NOT NULL
    BEGIN
        set @BUrif = RIGHT('000' + convert(varchar, @businessUnit), 3)
    END
-- FZ modifica 9-01 : se l’operazione è di tipo Veicolo e la classificazione BANKIT non è valorizzata venga messo come default 1      
    if @tipoOperazione = 'V' and @classBI IS NULL 
		 BEGIN
		  set @classBI = 1
		 END




    set @cmg = ''
    set @metodoConsBI = ''
    set @metodoConsIAS = '' 
    set @metodoConsFinrep = '' 
    set @gruppoBancario = ''
    set @dataInizioClCont = ''
    --PRINT '322'
    SELECT @cmg = ISNULL(UPPER(Codice_Mappa_Gruppo),''), 
           @metodoConsBI = ISNULL(ID_Metodo_Consolidamento_Banca_Italia,''),
           @metodoConsIAS = ISNULL(ID_Metodo_Consolidamento_IAS,'XA'), 
           @metodoConsFinrep = ISNULL(ID_Metodo_Consolidamento_Finrep,''), 
           @gruppoBancario = Appartenente_Gruppo_Bancario,
					 --gruppo assicurativo
					 @gruppo_assicurativo = Appartentente_Gruppo_Assicurativo					
       
      FROM SK_F2.F2_T_Classificazioni_Contabili
     WHERE ID_Operazione = @idOperazione
       AND @dataRif between convert(date, Data_Inizio) and convert(date, isnull(Data_Fine, '31/12/9999'))
       AND (Cancellata = 0 or Cancellata is null)
    -- Metodo
    set @metodo = @metodoConsIAS

		-- Se stringa vuota imposto valore default
    IF RTRIM(LTRIM(@metodo)) = '' 
		 set @metodo = 'XA'
		


    IF @statoOperazione = 2 AND @dtFineOperazione <= @dataEstrazione -- Cessata alla data di estrazione
    BEGIN
      set @metodo = 'CS'
      set @metodoConsBI = 'CS'
      set @metodoConsIAS = 'CS' 
      set @metodoConsFinrep = 'CS'
    END
    
    -- Appartenente Gruppo Bancario
    set @appGruppoBancario = 'N'
    IF (@gruppoBancario = 1 and @tipoOperazione <> 'SFP') OR @tipoOperazione = 'FE'
    BEGIN
        set @appGruppoBancario = 'S'
    END
		--Appartenente Gruppo Assicurativo
		 set @GRPASS = 'N'
		  IF (@gruppo_assicurativo = 1 )
    BEGIN
        set @GRPASS = 'S'
    END

    -- Modalità partecipazione -- ??? TODO
    set @modPartecipazione = 'N'
    --IF @gruppoBancario = 1
    --BEGIN
    --    set @modPartecipazione = 'S'
    --END
    
    -- Gruppo Attività Economica -- ??? TODO
    set @gruppoAttEconomica = ''
    --IF @gruppoBancario = 1
    --BEGIN
    --    set @gruppoAttEconomica = 'S'
    --END
 
    -- Tipo Quotazione
    set @tipoQuotazione = 'N'
    IF @quotata = 1 or @quotata = 2 -- 1=Quotata azioni  2=Quotata altri titoli
    BEGIN
        set @tipoQuotazione = 'S'
    END
    
    -- Classificazione Banca Italia + Tipo Quotazione
    set @classBI_TipoQuot = ''
    set @classBI_TipoQuot = convert(varchar, ISNULL(@classBI, '')) + @tipoQuotazione
    --print '@classBI_TipoQuot [' + @classBI_TipoQuot + ']'
   
    -- Settore ISVAP
    set @settoreISVAP = 'N'
    IF @classPNF = 23 or @classPNF = 24 -- 23=SGR o 24=SIM
    BEGIN
        set @settoreISVAP = 'S'
    END

    -- Data Ingresso Bankit
	/*
	Algoritmo per calcolo data ingresso Bankit
	Considero tutte le cassificazioni contabili ordinate per data decrescente
	prendo la prima che ha codice PN
	*/


    set @dataIngressoBI_Date =  SK_F2_FLUSSI.getDataIngressoBI(@idOperazione);

	set @dataIngressoBI=''
    IF @dataIngressoBI_Date IS NOT NULL
    BEGIN
        set @dataIngressoBI = convert(char(8), @dataIngressoBI_Date, 112)
    END

    set @percPossessoGruppo = 0
    set @percPossessoDVGruppo = 0
    SELECT @percPossessoGruppo = convert(decimal(20,3), (SK_F2_REPORT.getQuotaGruppo(@idOperazione, @dataEstrazione)*100)),
           @percPossessoDVGruppo = convert(decimal(20,3), (SK_F2_REPORT.getQuotaDVGruppo(@idOperazione, @dataEstrazione)*100))
    --print '@percPossessoGruppo [' + convert(varchar,@percPossessoGruppo)  + ']'
    --print '@percPossessoDVGruppo [' + convert(varchar,@percPossessoDVGruppo)  + ']'

    -- Tipo raggruppamento
    set @tipoRaggruppamento = '00'
    IF @percPossessoGruppo >= 20 and @percPossessoGruppo <= 50
    BEGIN
        IF @classBI = 1 or @classBI = 5
        BEGIN
            set @tipoRaggruppamento = '01'
        END
        
        IF (@classBI = 2 or @classBI = 3 or @classBI = 4) AND @metodoConsBI = 'PN'
        BEGIN
            set @tipoRaggruppamento = '03'
        END
    END
    
    IF @percPossessoGruppo > 50
    BEGIN
        set @tipoRaggruppamento = '02'
    END 

    -- Caratteristica partecipazione
    set @carattPartecip = '00'
    IF @percPossessoGruppo >= 10 and @percPossessoGruppo < 20
    BEGIN
        set @carattPartecip = '01'
    END
    
    IF @percPossessoGruppo >= 20
    BEGIN
        set @carattPartecip = '02'
    END    
   
	 
	 --PRINT '439' 
    -- Tipo Rapporto Effettivo = tipoControlloIAS
    SELECT DISTINCT @idOperazione as id_operazione,
             rp.ID_Partecipante as Id_partecipante,
             SK_F2_REPORT.getCodiceMappaGruppo(pante.ID,'P',@dataEstrazione) as CMG_partecipante,
             SK_F2_REPORT.getQuotaPartecipante((select top 1 ID from sk_f2.f2_t_rapporti_partecipativi 
                                                  where ID_Operazione = rp.ID_Operazione
                                                    AND (Cancellata IS NULL or Cancellata = 0)
                                                    AND id_partecipante = rp.ID_Partecipante
                                                  order by Data_Inizio desc), @dataEstrazione)*100 as Perc_partecipante
        INTO #tempPartecipantiGruppo
        FROM SK_F2.F2_T_Rapporti_Partecipativi rp, SK_F2.F2_T_PERSONA pante
       WHERE rp.ID_Operazione = @idOperazione
         AND (rp.Cancellata IS NULL or rp.Cancellata = 0)
         AND convert(date, @dataEstrazione) between convert(date, rp.data_inizio) and convert(date, isnull(rp.data_fine, '31/12/9999'))  
         AND pante.ID = rp.ID_Partecipante
         AND exists (select top 1 id from sk_f2.f2_T_classificazioni_contabili cl
                      where cl.id_persona = rp.ID_Partecipante
                        and (cl.Appartentente_Gruppo_Civilistico = 1 or cl.Appartenente_Gruppo_Bancario = 1)
                        and @dataEstrazione between convert(date, cl.data_inizio) and convert(date, isnull(cl.data_fine, '31/12/9999'))
                        and (cl.Cancellata = 0 or cl.Cancellata is null))
	--PRINT '460'
    SELECT top 1 @cmgMaxPerc = CMG_partecipante
      FROM #tempPartecipantiGruppo
     WHERE Id_operazione = @idOperazione
     ORDER BY Perc_partecipante DESC
    set @cmgMaxPerc = isnull(@cmgMaxPerc, '')
    
    set @tipoRapportoEff = ''
    set @tipoRapportoEff = SK_F2.getCodiceTipoRapportoIAS(@classIAS, @percPossessoGruppo, @cmgMaxPerc)
    set @tipoRapportoEff = isnull(@tipoRapportoEff,'')    
    
    drop table #tempPartecipantiGruppo
    
    -- Super ISIN del capitale sociale 
    -- set @csSottoscrittoEuro = 0
    set @superISIN = ''
    
    -- IN DATA 01.2017 E' STATA RICHIESTA UNA CR PER LA NON VALORIZZAZIONE DEL CAMPO SUPER ISIN
    -- COMMENTATA PARTE SOTTO
        IF @tipoOperazione <> 'FE'
    BEGIN
        IF @tipoOperazione = 'P'
        BEGIN
            --SELECT @csSottoscrittoEuro = Capitale_Sociale_Sottoscritto_Euro
              --FROM SK_F2.F2_T_CapitaleSociale 
             --WHERE ID_Persona = @idPartecipata
             --  AND @dataEstrazione between data_inizio and isnull(data_fine, '31/12/9999')
               --PRINT '487'
            SELECT @superISIN = tit.Codice_ISIN
              FROM SK_F2.F2_T_CapitaleSociale cs, SK_F2.F2_T_Titoli tit
             WHERE cs.ID_Persona = @idPartecipata
               AND tit.ID_CapitaleSociale = cs.ID
               AND tit.superisin = 1
               AND @dataRif between convert(date, cs.data_inizio) and convert(date, isnull(cs.data_fine, '31/12/9999'))          
        END
       -- ELSE
        --BEGIN
        --    SELECT @csSottoscrittoEuro = Valore_complessivo__Euro
        --      FROM SK_F2.F2_T_Patrimonio
        --     WHERE ID_Persona = @idPartecipata
        --       AND @dataEstrazione between data_inizio and isnull(data_fine, '31/12/9999')
        --END
    END
    
    --PRINT '504'
    set @valuta = ''
    set @tipoControparteR = ''
    set @tipoControparte = ''
    set @tipoControparteC = ''
    set @areaGeograficaR = '' 
    set @areaGeografica = ''
    set @areaGeograficaC = ''
    set @affidatoGarante = ''
    set @filialeAppart = NULL
    SELECT @valuta = isnull((select SK_F2.F2_D_Valuta.Codice_SWIFT from sk_f2.f2_d_valuta where ID = ab.ID_Valuta),'EUR'), 
           @tipoControparteR = ID_Tipo_Controparte, 
           @areaGeograficaR = ID_Area_Geografica, 
           @affidatoGarante = ID_Affidato_Garante,
           @filialeAppart = ID_Appartenenza_Filiale
      FROM SK_F2.F2_T_Attributi_Bilancio ab
     WHERE ID_Persona = @idPartecipata
       AND @dataRif between convert(date, data_inizio) and convert(date, isnull(data_fine, '31/12/9999'))
    --PRINT '522'
    IF @@ROWCOUNT = 0
    BEGIN
		--PRINT '525'
      SELECT TOP 1 @valuta = isnull((select SK_F2.F2_D_Valuta.Codice_SWIFT from sk_f2.f2_d_valuta where ID = ab.ID_Valuta),'EUR'), 
             @tipoControparteR = ID_Tipo_Controparte, 
             @areaGeograficaR = ID_Area_Geografica, 
             @affidatoGarante = ID_Affidato_Garante,
             @filialeAppart = ID_Appartenenza_Filiale
        FROM SK_F2.F2_T_Attributi_Bilancio ab
       WHERE ID_Persona = @idPartecipata
       ORDER BY Data_Inizio DESC
    END
    

		IF RTRIM(LTRIM(@valuta)) = ''
		 set @valuta = 'EUR'

    -- Tipo Controparte
    IF @tipoControparteR IS NOT NULL AND len(ltrim(rtrim(@tipoControparteR))) > 0
    BEGIN
       set @tipoControparte = ''
       set @tipoControparteC = ''
			 --PRINT '541'
       SELECT @tipoControparte = ID_Tipo, @tipoControparteC = ID_TipoC
         FROM SK_F2_FLUSSI.F2_D_TipoControparteCR
        WHERE ID_TipoR = @tipoControparteR
    END
    
    -- Area Geografica
    IF @areaGeograficaR IS NOT NULL AND len(ltrim(rtrim(@areaGeograficaR))) > 0
    BEGIN
       set @areaGeografica = ''
       set @areaGeograficaC = ''
			 --PRINT '552'
       SELECT @areaGeografica = ID_Area, @areaGeograficaC = ID_AreaC
         FROM SK_F2_FLUSSI.F2_D_AreaGeograficaCR
        WHERE ID_AreaR = @areaGeograficaR
    END
    
    -- Categoria controparte
    set @categControparte = '7'
    IF @metodoConsBI <> 'CS'
    BEGIN
        IF @tipoOperazione = 'FE'
        BEGIN
            set @categControparte = '5'
        END
        ELSE
        BEGIN
            IF @metodoConsIAS = 'CI' AND @classIAS = 'CNT'
            BEGIN
                set @categControparte = '4'
            END
            
            IF @metodoConsIAS <> 'CI' AND @classIAS = 'CNT'
            BEGIN
                set @categControparte = '6'
            END
        END
    END
    
    -- Sub Holding
    set @subHolding = ''
    IF @tipoOperazione = 'FE'
    BEGIN
		--PRINT '584'
        SELECT TOP 1 @subHolding = Codice_Mappa_Gruppo 
          FROM SK_F2.F2_T_Classificazioni_Contabili
         WHERE ID_Persona = @filialeAppart
         ORDER BY Data_Inizio DESC  
    END
    
    -- Variazione Metodo: occorre verificare se il Metodo di consolidamento IAS è variato 
    -- rispetto al precedente periodo di segnalazione
    set @variazioneMetodo = 'N'

    set @metodoConsIASPrec = '' 
		--PRINT '596'
    SELECT @metodoConsIASPrec = ISNULL(ID_Metodo_Consolidamento_IAS, '')
      FROM SK_F2.F2_T_Classificazioni_Contabili
     WHERE ID_Operazione = @idOperazione
       AND @dataPeriodoPrec between convert(date, Data_Inizio) and convert(date, isnull(Data_Fine, '31/12/9999'))

    IF @metodoConsIAS <> @metodoConsIASPrec AND @dataIngressoBI <= @dataPeriodoPrec
    BEGIN
        set @variazioneMetodo = 'S'    
    END
    --print '@idOperazione  [' + convert(varchar, @idOperazione) + ']'
    --print '@metodoConsIAS [' + @metodoConsIAS + ']'
    --print '@metodoConsIASPrec [' + @metodoConsIASPrec + ']'
    --print '@variazioneMetodo [' + @variazioneMetodo + ']'
    
    -- Livello Fair Value
    set @gerarchiaFV = NULL
		--PRINT '613'
    SELECT @gerarchiaFV = ID_Gerarchia_Fair_Value
      FROM SK_F2.F2_T_Rapporti_Partecipativi
     WHERE ID_Operazione = @idOperazione
       AND ID_Partecipante = (select p.ID from SK_F2.F2_t_persona p, SK_F2.f2_d_banche b
                               where b.SNDG_BANCA = p.SNDG
                                 and b.flag_capogruppo = 'S'
                                 and p.data_fine is null)
    IF @gerarchiaFV IS NULL
    BEGIN
		--PRINT '623'
        SELECT TOP 1 @gerarchiaFV = ID_Gerarchia_Fair_Value
          FROM SK_F2.F2_T_Rapporti_Partecipativi
         WHERE ID_Operazione = @idOperazione
           AND SK_F2_REPORT.appartenenteGruppo(ID_Partecipante, @dataEstrazione) = 1
         ORDER BY Data_Inizio desc
    END
    
    set @livelloFV = ''
    IF @gerarchiaFV IS NOT NULL AND @gerarchiaFV <> 0
    BEGIN
        set @livelloFV = 'L' + convert(char, @gerarchiaFV)
    END
    

		set @DTINICC = ''
		
		-- Evolutiva 8-12-2017 - Estensione campi per Bilancio consolidato
		-- Data Inizio classificazione contabile prendere la più vecchia della classificazione
	DECLARE DATE_CLASSIFICAZIONI_CONTABILI_CUR CURSOR FOR
		SELECT TOP 1
            ISNULL(CONVERT(nvarchar,Data_Inizio,112),Space(8) ) dataInizio   
      FROM SK_F2.F2_T_Classificazioni_Contabili cc
			WHERE ID_Operazione = @idOperazione
			AND (cc.Cancellata = 0 OR cc.Cancellata IS NULL)
			ORDER BY Data_Inizio ASC
		OPEN DATE_CLASSIFICAZIONI_CONTABILI_CUR
		FETCH NEXT FROM DATE_CLASSIFICAZIONI_CONTABILI_CUR INTO @DTINICC
		CLOSE DATE_CLASSIFICAZIONI_CONTABILI_CUR
		DEALLOCATE DATE_CLASSIFICAZIONI_CONTABILI_CUR
						 
	-- Valorizzo @DTFINECC  come data fine operazione se presente
	
	IF  @dtFineOperazione <> '31/12/9999'
	 BEGIN
    set @DTFINECC =  ISNULL(CONVERT(nvarchar,@dtFineOperazione,112),SPACE(8) )
	 END
	 ELSE
	  	set @DTFINECC = SPACE(8)
/*
@CODPR  Codice Prevalente
Considerare ID Persona operazione corrente
consoiderare per le operazioni attive della persona il codice mappa gruppo 
secondo ordinamento seguente:
1. Filiale Estera
2. Partecipazione
3. Veicolo non partecipato
4. Strumento Finanziario Partecipativo
5. Obbligazione convertibile
6. Fondo
7. Derivato
8. Impegno, 
9. Indiretta
10. Patto Parasociale, 
11. Corporate Governance
per la prima che viene trovata recuperare le classificazioni contabili
e recuperare il codice mappa gruppo
*/
--PRINT '676'
select TOP 1 @CODPR = CC.Codice_Mappa_Gruppo
from
[SK_F2].[F2_T_Operazioni] op,
[SK_F2].[F2_T_Classificazioni_Contabili] CC
where op.GUID_Persona = @GUIDPersona
and op.Data_Fine IS NULL
AND (OP.Cancellata=0 OR OP.Cancellata IS NULL)
-- OPERAZIONI IN ESSERE
AND ID_Stato_Operazione = 1 -- VERIFICO
-- TOLGO I TIPI SU CUI NON ORDINO
and CC.ID_Operazione = op.ID
and
(CC.Cancellata = 0 or CC.Cancellata is null)
and CC.Data_Fine is null
ORDER BY 
	CASE op.ID_Tipo_Operazione
	 WHEN 'FE' THEN 'A'
	 WHEN 'P' THEN  'B'
	 WHEN 'V' THEN  'C'
	 WHEN 'SFP' THEN 'D'
	 WHEN 'OC' THEN 'E'
	 WHEN 'F' THEN 'F'
	 WHEN 'D' THEN  'G'
	 WHEN 'IMP' THEN 'H'
	 WHEN 'IND' THEN 'I'
	 WHEN 'PP' THEN 'L'
	 WHEN 'CG' THEN 'M'
	END




	 SET @TIPOP = @tipoOperazione
-- DESOP FETCH da cursore
--PRINT '711'
   SELECT @TIPDER = d.ID_Tipo_Derivato,
					@DESDER = td.Descrizione
	 FROM [SK_F2].[F2_D_Tipi_Derivato] td,
	      SK_F2.F2_T_Dati_Derivato d
				where 
				d.ID_OPERAZIONE = @idOperazione
				and d.ID_TIPO_DERIVATO = td.ID


-- DEBUG

-- --PRINT SK_F2_REPORT.checkColumnSize_TEST('sssddddddddddddds', 'azienda')
-- PRINT SK_F2_REPORT.checkColumnSize_TEST('', '')

-- PRINT SK_F2_REPORT.checkColumnSize_TEST(, '')


/*
Data_estrazione
          ,Azienda
          ,ID_Operazione
          ,Tipo_Operazione
          ,Ragione_sociale
          ,Sede
          ,Metodo
          ,Metodo_consolidamento_BI
          ,Metodo_consolidamento_IAS
          ,Metodo_consolidamento_Finrep
          ,Classificazione_BI
          ,Descrizione_attivita
          ,Quotata
          ,Tipo_rapporto_effettivo
          ,Residenza
          ,Valuta
          ,Tipo_quotazione
          ,Gruppo_bancario
          ,Modalita_partecipazione
          ,ABI
          ,Partita_IVA
          ,Codice_fiscale
          ,Codice_UIC
          ,Codice_CR
          ,SNDG
          ,Settore_ISVAP
          ,Tipo_controparte
          ,Tipo_controparteC
          ,Tipo_controparteR
          ,Area_geografica
          ,Area_geograficaC
          ,Area_geograficaR
          ,Affidato_garante
          ,Attivita_economica
          ,SAE
          ,Tipo_raggruppamento
          ,Categoria_controparte
          ,Caratt_partecipazione
          ,Subholding
          ,Business_unit
          ,Variazione_metodo
          ,Livello_fair_value
          ,ISIN_prevalente
          ,ATECO
          ,Data_ingresso_BI
          ,Perc_possesso_gruppo
          ,Perc_possesso_DV_gruppo
          --,CS_sottoscritto_euro
          ,Flag_Scarto
          ,Motivo_Scarto
					,dt_inizio_class_contabile
					,dt_fine_class_contabile
					,dt_costituzione
					,cod_LEI
					,sede_amm
					,class_IAS
					,cod_prevalente
					,tipo_op
					,des_op
					,tipo_derivato
					,desc_derivato
					,grp_ass*/


--PRINT '794'
--PRINT SK_F2_REPORT.checkColumnSize_TEST(@dataEstrazione, 'Data_estrazione')
--PRINT SK_F2_REPORT.checkColumnSize_TEST(@cmg, 'Azienda')
--PRINT SK_F2_REPORT.checkColumnSize_TEST(@idOperazione, 'ID_Operazione')
--PRINT SK_F2_REPORT.checkColumnSize_TEST(@ragioneSociale ,'Ragione_sociale')  -- Ragione_sociale - char(2000)
--PRINT SK_F2_REPORT.checkColumnSize_TEST(@sede,'Sede')  -- Sede - char(200)
--PRINT SK_F2_REPORT.checkColumnSize_TEST(@metodo, 'Metodo')  -- Metodo - char(8)
--PRINT SK_F2_REPORT.checkColumnSize_TEST(@metodoConsBI, 'Metodo_consolidamento_BI')   -- Metodo_consolidamento_BI - char(8)
--PRINT SK_F2_REPORT.checkColumnSize_TEST(@metodoConsIAS, 'Metodo_consolidamento_IAS')  -- Metodo_consolidamento_IAS - char(8)
--PRINT SK_F2_REPORT.checkColumnSize_TEST(@metodoConsFinrep, 'Metodo_consolidamento_Finrep')   -- Metodo_consolidamento_Finrep - char(8)
--PRINT SK_F2_REPORT.checkColumnSize_TEST(@classBI, 'Classificazione_BI')
--PRINT SK_F2_REPORT.checkColumnSize_TEST(@descrAttivita, 'Descrizione_attivita')   -- Descrizione_attivita - char(40)
--PRINT SK_F2_REPORT.checkColumnSize_TEST(@classBI_TipoQuot, 'Quotata')   -- Quotata - classBI+TipoQuotazione - char(8)
--PRINT SK_F2_REPORT.checkColumnSize_TEST(@tipoRapportoEff, '')   -- Tipo_rapporto_effettivo - char(8)
--PRINT SK_F2_REPORT.checkColumnSize_TEST(@residenza, 'Tipo_rapporto_effettivo')   -- Residenza - char(8)
--PRINT SK_F2_REPORT.checkColumnSize_TEST(@valuta, 'Valuta')   -- Valuta - char(8)
--PRINT SK_F2_REPORT.checkColumnSize_TEST(@tipoQuotazione, 'Tipo_quotazione')  -- Tipo_quotazione - char(8)
--PRINT SK_F2_REPORT.checkColumnSize_TEST(@appGruppoBancario, 'Gruppo_bancario')   -- Gruppo_bancario - char(8)
--PRINT SK_F2_REPORT.checkColumnSize_TEST(@modPartecipazione,'Modalita_partecipazione')   -- Modalita_partecipazione - char(8)
--PRINT SK_F2_REPORT.checkColumnSize_TEST(@codiceABI, 'ABI')   -- ABI - char(6)
--PRINT SK_F2_REPORT.checkColumnSize_TEST(@partitaIVA, 'Partita_IVA')   -- Partita_IVA - char(11)
--PRINT SK_F2_REPORT.checkColumnSize_TEST(@codFiscale, 'Codice_fiscale')   -- Codice_fiscale - char(11)
--PRINT SK_F2_REPORT.checkColumnSize_TEST(@codiceUIC, 'Codice_UIC')   -- Codice_UIC - char(9)
--PRINT SK_F2_REPORT.checkColumnSize_TEST(@codiceCR, 'Codice_CR')   -- Codice_CR - char(13)
--PRINT SK_F2_REPORT.checkColumnSize_TEST(substring(@sndgPartecipata,2,15), 'SNDG')   -- SNDG - char(16)
--PRINT SK_F2_REPORT.checkColumnSize_TEST(@settoreISVAP, 'Settore_ISVAP')   -- Settore_ISVAP - char(8)
--PRINT SK_F2_REPORT.checkColumnSize_TEST(@tipoControparte, 'Tipo_controparte')   -- Tipo_controparte - char(8)
--PRINT SK_F2_REPORT.checkColumnSize_TEST(@tipoControparteC, 'Tipo_controparteC')   -- Tipo_controparteC - char(8)
--PRINT SK_F2_REPORT.checkColumnSize_TEST(@tipoControparteR, 'Tipo_controparteR')   -- Tipo_controparteR - char(8)
--PRINT SK_F2_REPORT.checkColumnSize_TEST(@areaGeografica, 'Area_geografica')   -- Area_geografica - char(8)
--PRINT SK_F2_REPORT.checkColumnSize_TEST(@areaGeograficaC, 'Area_geograficaC')   -- Area_geograficaC - char(8)
--PRINT SK_F2_REPORT.checkColumnSize_TEST(@areaGeograficaR, 'Area_geograficaR')   -- Area_geograficaR - char(8)
--PRINT SK_F2_REPORT.checkColumnSize_TEST(@affidatoGarante, 'Affidato_garante')  -- Affidato_garante - char(8)
--PRINT SK_F2_REPORT.checkColumnSize_TEST(@gruppoAttEconomica, 'Attivita_economica')   -- Attivita_economica - char(8)
--PRINT SK_F2_REPORT.checkColumnSize_TEST(@SAE, 'SAE')   -- SAE - char(8)
--PRINT SK_F2_REPORT.checkColumnSize_TEST(@tipoRaggruppamento, 'Tipo_raggruppamento')   -- Tipo_raggruppamento - char(8)
--PRINT SK_F2_REPORT.checkColumnSize_TEST(@categControparte, 'Categoria_controparte')   -- Categoria_controparte - char(8)
--PRINT SK_F2_REPORT.checkColumnSize_TEST(@carattPartecip, 'Caratt_partecipazione')  -- Caratt_partecipazione - char(8)
--PRINT SK_F2_REPORT.checkColumnSize_TEST(@subHolding, 'Subholding')   -- Subholding - char(8)
--PRINT SK_F2_REPORT.checkColumnSize_TEST(@BURif, 'Business_unit')   -- Business_unit - char(8)
--PRINT SK_F2_REPORT.checkColumnSize_TEST(@variazioneMetodo, 'N')   -- Variazione_metodo - char(8)
--PRINT SK_F2_REPORT.checkColumnSize_TEST(@livelloFV, 'Livello_fair_value')  -- Livello_fair_value - char(2)
--PRINT SK_F2_REPORT.checkColumnSize_TEST(@superISIN, 'ISIN_prevalente')   -- ISIN_prevalente - char(16)
--PRINT SK_F2_REPORT.checkColumnSize_TEST(@ATECO, 'ATECO')   -- ATECO - char(6)
--PRINT SK_F2_REPORT.checkColumnSize_TEST(@dataIngressoBI, '')  -- Data_ingresso_BI - char(8)
--PRINT SK_F2_REPORT.checkColumnSize_TEST(replace(convert(varchar, ISNULL(@percPossessoGruppo,0)), ',', ''),'Perc_possesso_gruppo')  -- Perc_possesso_gruppo - char(6)
--PRINT SK_F2_REPORT.checkColumnSize_TEST(replace(convert(varchar, ISNULL(@percPossessoDVGruppo,0)), ',', ''),'Perc_possesso_DV_gruppo')  -- Perc_possesso_DV_gruppo - char(6)          
--PRINT SK_F2_REPORT.checkColumnSize_TEST(convert(varchar,@DTINICC,112),'dt_inizio_class_contabile')  -- data inizio classificazione
--PRINT SK_F2_REPORT.checkColumnSize_TEST(convert(varchar,@DTFINECC,112),'dt_fine_class_contabile')  	-- data fine classificazione				
--PRINT SK_F2_REPORT.checkColumnSize_TEST(convert(varchar,@DTCOST,112),'')  	-- data costituzione da anagrafica
--PRINT SK_F2_REPORT.checkColumnSize_TEST(@CODLEI, 'cod_LEI')  -- Codice LEI														
--PRINT SK_F2_REPORT.checkColumnSize_TEST(@SEDEAM, 'sede_amm')  -- Sede amministrativa					
--PRINT SK_F2_REPORT.checkColumnSize_TEST(@CLIAS, 'class_IAS') 	-- Classificazione IAS					
--PRINT SK_F2_REPORT.checkColumnSize_TEST(@CODPR, 'cod_prevalente') 	-- Codice Prevalente					
--PRINT SK_F2_REPORT.checkColumnSize_TEST(@TIPOP, 'tipo_op') 	-- Tipo Operazione 							
--PRINT SK_F2_REPORT.checkColumnSize_TEST(@DESOP, 'des_op')  -- Descrizione Operazione							
--PRINT SK_F2_REPORT.checkColumnSize_TEST(@TIPDER, 'tipo_derivato') 	-- Tipo Derivato						
--PRINT SK_F2_REPORT.checkColumnSize_TEST(@DESDER, 'desc_derivato')  -- Descrizione Derivato							
--PRINT SK_F2_REPORT.checkColumnSize_TEST(@GRPASS, 'grp_ass') 	-- Gruppo assicurativo											
        
--PRINT '854'

-- FINE DEBUG
    -- Insert in tabella F2_T_EXP_BOFINANCE_Anag
IF @spaziaturaFissa = 1
 BEGIN
    INSERT INTO [SK_F2_FLUSSI].[F2_T_EXP_TAGETIK_Anag]
          (Data_estrazione
          ,Azienda
          ,ID_Operazione
          ,Tipo_Operazione
          ,Ragione_sociale
          ,Sede
          ,Metodo
          ,Metodo_consolidamento_BI
          ,Metodo_consolidamento_IAS
          ,Metodo_consolidamento_Finrep
          ,Classificazione_BI
          ,Descrizione_attivita
          ,Quotata
          ,Tipo_rapporto_effettivo
          ,Residenza
          ,Valuta
          ,Tipo_quotazione
          ,Gruppo_bancario
          ,Modalita_partecipazione
          ,ABI
          ,Partita_IVA
          ,Codice_fiscale
          ,Codice_UIC
          ,Codice_CR
          ,SNDG
          ,Settore_ISVAP
          ,Tipo_controparte
          ,Tipo_controparteC
          ,Tipo_controparteR
          ,Area_geografica
          ,Area_geograficaC
          ,Area_geograficaR
          ,Affidato_garante
          ,Attivita_economica
          ,SAE
          ,Tipo_raggruppamento
          ,Categoria_controparte
          ,Caratt_partecipazione
          ,Subholding
          ,Business_unit
          ,Variazione_metodo
          ,Livello_fair_value
          ,ISIN_prevalente
          ,ATECO
          ,Data_ingresso_BI
          ,Perc_possesso_gruppo
          ,Perc_possesso_DV_gruppo
          --,CS_sottoscritto_euro
          ,Flag_Scarto
          ,Motivo_Scarto
					,dt_inizio_class_contabile
					,dt_fine_class_contabile
					,dt_costituzione
					,cod_LEI
					,sede_amm
					,class_IAS
					,cod_prevalente
					,tipo_op
					,des_op
					,tipo_derivato
					,desc_derivato
					,grp_ass
					,id_tipologia_fondo
					) 
    VALUES 
         (@dataEstrazione  -- Data_estrazione - date
          ,LEFT(ISNULL(@cmg, '') + space(8), 8)  -- Azienda - char(8)
          ,@idOperazione
          ,@tipoOperazione
          ,LEFT(ISNULL(@ragioneSociale, '') + space(2000), 2000)  -- Ragione_sociale - char(2000)
          ,LEFT(ISNULL(@sede,'') + space(20), 20)  -- Sede - char(20)
          ,LEFT(@metodo + space(8), 8)  -- Metodo - char(8)
          ,LEFT(ISNULL(@metodoConsBI, '') + space(8), 8)  -- Metodo_consolidamento_BI - char(8)
          ,LEFT(ISNULL(@metodoConsIAS, '') + space(8), 8)  -- Metodo_consolidamento_IAS - char(8)
          ,LEFT(ISNULL(@metodoConsFinrep, '') + space(8), 8)  -- Metodo_consolidamento_Finrep - char(8)
          ,CASE WHEN @classBI = 0 OR @classBI IS NULL THEN LEFT('' + space(8), 8)
                                                 ELSE LEFT((ISNULL(convert(nvarchar,@classBI), '')) + space(8), 8)
           END -- Classificazione_BI - char(8)
          ,LEFT(ISNULL(@descrAttivita, '') + space(40), 40)  -- Descrizione_attivita - char(40)
          ,LEFT(ISNULL(@classBI_TipoQuot, '') + space(8), 8)  -- Quotata - classBI+TipoQuotazione - char(8)
          ,LEFT(ISNULL(@tipoRapportoEff, '') + space(8), 8)  -- Tipo_rapporto_effettivo - char(8)
          ,LEFT(ISNULL(@residenza, '') + space(8), 8)  -- Residenza - char(8)
          ,LEFT(@valuta + space(8), 8)  -- Valuta - char(8)
          ,LEFT(ISNULL(@tipoQuotazione, '') + space(8), 8)  -- Tipo_quotazione - char(8)
          ,LEFT(@appGruppoBancario + space(8), 8)  -- Gruppo_bancario - char(8)
          ,LEFT(@modPartecipazione + space(8), 8)  -- Modalita_partecipazione - char(8)
          ,LEFT(ISNULL(@codiceABI, '') + space(6), 6)  -- ABI - char(6)
          ,LEFT(ISNULL(@partitaIVA, '') + space(11), 11)  -- Partita_IVA - char(11)
          ,LEFT(ISNULL(@codFiscale, '') + space(11), 11)  -- Codice_fiscale - char(11)
          ,LEFT(ISNULL(@codiceUIC, '') + space(9), 9)  -- Codice_UIC - char(9)
          ,LEFT(ISNULL(@codiceCR, '') + space(13), 13)  -- Codice_CR - char(13)
          ,LEFT(ISNULL(@sndgPartecipata, '') + space(16), 16)  -- SNDG - char(16)
          ,LEFT(ISNULL(@settoreISVAP, '') + space(8), 8)  -- Settore_ISVAP - char(8)
          ,LEFT(ISNULL(@tipoControparte, '') + space(8), 8)  -- Tipo_controparte - char(8)
          ,LEFT(ISNULL(@tipoControparteC, '') + space(8), 8)  -- Tipo_controparteC - char(8)
          ,LEFT(ISNULL(@tipoControparteR, '') + space(8), 8)  -- Tipo_controparteR - char(8)
          ,LEFT(ISNULL(@areaGeografica, '') + space(8), 8)  -- Area_geografica - char(8)
          ,LEFT(ISNULL(@areaGeograficaC, '') + space(8), 8)  -- Area_geograficaC - char(8)
          ,LEFT(ISNULL(@areaGeograficaR, '') + space(8), 8)  -- Area_geograficaR - char(8)
          ,LEFT(ISNULL(@affidatoGarante, '') + space(8), 8)  -- Affidato_garante - char(8)
          ,LEFT(ISNULL(@gruppoAttEconomica, '') + space(8), 8)  -- Attivita_economica - char(8)
          ,LEFT(ISNULL(@SAE, '') + space(8), 8)  -- SAE - char(8)
          ,LEFT(ISNULL(@tipoRaggruppamento, '') + space(8), 8)  -- Tipo_raggruppamento - char(8)
          ,LEFT(ISNULL(@categControparte, '') + space(8), 8)  -- Categoria_controparte - char(8)
          ,LEFT(ISNULL(@carattPartecip, '') + space(8), 8)  -- Caratt_partecipazione - char(8)
          ,LEFT(ISNULL(@subHolding, '') + space(8), 8)  -- Subholding - char(8)
          ,LEFT(ISNULL(@BURif, '') + space(8), 8)  -- Business_unit - char(8)
          ,LEFT(ISNULL(@variazioneMetodo, 'N') + space(8), 8)  -- Variazione_metodo - char(8)
          ,ISNULL(@livelloFV, '  ')  -- Livello_fair_value - char(2)
          ,LEFT(ISNULL(@superISIN, '') + space(16), 16)  -- ISIN_prevalente - char(16)
          ,LEFT(ISNULL(@ATECO, '') + space(6), 6)  -- ATECO - char(6)
          ,LEFT(ISNULL(@dataIngressoBI, '') + space(8), 8)  -- Data_ingresso_BI - char(8)
          ,RIGHT('000000' + replace(convert(varchar, ISNULL(@percPossessoGruppo,0)), '.', ''), 6)  -- Perc_possesso_gruppo - char(6)
          ,RIGHT('000000' + replace(convert(varchar, ISNULL(@percPossessoDVGruppo,0)), '.', ''), 6)  -- Perc_possesso_DV_gruppo - char(6)
          --,RIGHT('0000000000000000000000000000' + replace(convert(varchar, ISNULL(@csSottoscrittoEuro,0)), '.', ''), 28)  -- CS_sottoscritto_euro - char(28)
          ,'0'  -- Flag_Scarto - bit
          ,null -- Motivo_Scarto - nvarchar(2000)
					,LEFT(@DTINICC + space(8),8)		-- data inizio classificazione
					,LEFT(@DTFINECC + space(8),8)	-- data fine classificazione				
					,LEFT(@DTCOST	+ space(8),8)	-- data costituzione da anagrafica
					,LEFT(ISNULL(@CODLEI, '') + space(20), 20) -- Codice LEI														
					,LEFT(ISNULL(@SEDEAM, '') + space(20), 20) -- Sede amministrativa					
					,LEFT(ISNULL(@CLIAS, '') + space(8), 8)	-- Classificazione IAS					
					,LEFT(ISNULL(@CODPR, '') + space(8), 8)	-- Codice Prevalente					
					,LEFT(ISNULL(@TIPOP, '') + space(5), 5)	-- Tipo Operazione 							
					,LEFT(ISNULL(@DESOP, '') + space(50), 50) -- Descrizione Operazione							
					,LEFT(ISNULL(@TIPDER, '') + space(5), 5)	-- Tipo Derivato						
					,LEFT(ISNULL(@DESDER, '') + space(50), 50) -- Descrizione Derivato							
					,LEFT(ISNULL(@GRPASS, '') + space(1), 1)	-- Gruppo assicurativo
					,@idTipologiaFondo											
        )
    END
		ELSE BEGIN
		INSERT INTO [SK_F2_FLUSSI].[F2_T_EXP_TAGETIK_Anag]
          (Data_estrazione
          ,Azienda
          ,ID_Operazione
          ,Tipo_Operazione
          ,Ragione_sociale
          ,Sede
          ,Metodo
          ,Metodo_consolidamento_BI
          ,Metodo_consolidamento_IAS
          ,Metodo_consolidamento_Finrep
          ,Classificazione_BI
          ,Descrizione_attivita
          ,Quotata
          ,Tipo_rapporto_effettivo
          ,Residenza
          ,Valuta
          ,Tipo_quotazione
          ,Gruppo_bancario
          ,Modalita_partecipazione
          ,ABI
          ,Partita_IVA
          ,Codice_fiscale
          ,Codice_UIC
          ,Codice_CR
          ,SNDG
          ,Settore_ISVAP
          ,Tipo_controparte
          ,Tipo_controparteC
          ,Tipo_controparteR
          ,Area_geografica
          ,Area_geograficaC
          ,Area_geograficaR
          ,Affidato_garante
          ,Attivita_economica
          ,SAE
          ,Tipo_raggruppamento
          ,Categoria_controparte
          ,Caratt_partecipazione
          ,Subholding
          ,Business_unit
          ,Variazione_metodo
          ,Livello_fair_value
          ,ISIN_prevalente
          ,ATECO
          ,Data_ingresso_BI
          ,Perc_possesso_gruppo
          ,Perc_possesso_DV_gruppo
          --,CS_sottoscritto_euro
          ,Flag_Scarto
          ,Motivo_Scarto
					,dt_inizio_class_contabile
					,dt_fine_class_contabile
					,dt_costituzione
					,cod_LEI
					,sede_amm
					,class_IAS
					,cod_prevalente
					,tipo_op
					,des_op
					,tipo_derivato
					,desc_derivato
					,grp_ass
					,id_tipologia_fondo
					) 
    VALUES 
          (  @dataEstrazione  -- Data_estrazione - date
          ,  LEFT(ISNULL(@cmg, ''),8)   -- Azienda - char(8)
          ,  @idOperazione
          ,  @tipoOperazione
          , replace(ISNULL(@ragioneSociale, ''),';','')  -- Ragione_sociale - char(2000)
          , ISNULL(@sede,'')  -- Sede - char(200)
          , ISNULL(@metodo, '')  -- Metodo - char(8)
          , ISNULL(@metodoConsBI, '')   -- Metodo_consolidamento_BI - char(8)
          , ISNULL(@metodoConsIAS, '')  -- Metodo_consolidamento_IAS - char(8)
          , ISNULL(@metodoConsFinrep, '')   -- Metodo_consolidamento_Finrep - char(8)
          ,CASE WHEN @classBI = 0 OR @classBI IS NULL THEN  '' 
                                                 ELSE  ISNULL(@classBI, '')
           END -- Classificazione_BI - char(8)
          , ISNULL(@descrAttivita, '')   -- Descrizione_attivita - char(40)
          , ISNULL(@classBI_TipoQuot, '')   -- Quotata - classBI+TipoQuotazione - char(8)
          , ISNULL(@tipoRapportoEff, '')   -- Tipo_rapporto_effettivo - char(8)
          , ISNULL(@residenza, '')   -- Residenza - char(8)
          , ISNULL(@valuta, '')   -- Valuta - char(8)
          , ISNULL(@tipoQuotazione, '')  -- Tipo_quotazione - char(8)
          , @appGruppoBancario   -- Gruppo_bancario - char(8)
          , @modPartecipazione   -- Modalita_partecipazione - char(8)
          , ISNULL(@codiceABI, '')   -- ABI - char(6)
          , ISNULL(@partitaIVA, '')   -- Partita_IVA - char(11)
          , ISNULL(@codFiscale, '')   -- Codice_fiscale - char(11)
          , ISNULL(@codiceUIC, '')   -- Codice_UIC - char(9)
          , ISNULL(@codiceCR, '')   -- Codice_CR - char(13)		  
		  ,CASE WHEN (@sndgPartecipata IS NOT NULL AND LEN(@sndgPartecipata) > 0) THEN
		   replicate('0',16-len(@sndgPartecipata ) )  + @sndgPartecipata  
		    ELSE
			''
			END
          --, ISNULL(@sndgPartecipata, '')   -- SNDG - char(16)
          , ISNULL(@settoreISVAP, '')   -- Settore_ISVAP - char(8)
          , ISNULL(@tipoControparte, '')   -- Tipo_controparte - char(8)
					, ISNULL(@tipoControparteC, '')   -- Tipo_controparteC - char(8)
          , ISNULL(@tipoControparteR, '')   -- Tipo_controparteR - char(8)
          , ISNULL(@areaGeografica, '')   -- Area_geografica - char(8)
          , ISNULL(@areaGeograficaC, '')   -- Area_geograficaC - char(8)
          , ISNULL(@areaGeograficaR, '')   -- Area_geograficaR - char(8)
          , ISNULL(@affidatoGarante, '')  -- Affidato_garante - char(8)
          , ISNULL(@gruppoAttEconomica, '')   -- Attivita_economica - char(8)
          , ISNULL(@SAE, '')   -- SAE - char(8)
          , ISNULL(@tipoRaggruppamento, '')   -- Tipo_raggruppamento - char(8)
          , ISNULL(@categControparte, '')   -- Categoria_controparte - char(8)
          , ISNULL(@carattPartecip, '')  -- Caratt_partecipazione - char(8)
          , ISNULL(@subHolding, '')   -- Subholding - char(8)
          , ISNULL(@BURif, '')   -- Business_unit - char(8)
          , ISNULL(@variazioneMetodo, 'N')   -- Variazione_metodo - char(8)
          , ISNULL(@livelloFV, '  ')  -- Livello_fair_value - char(2)
          , ISNULL(@superISIN, '')   -- ISIN_prevalente - char(16)
          , ISNULL(@ATECO, '')   -- ATECO - char(6)
          , ISNULL(@dataIngressoBI, '')  -- Data_ingresso_BI - char(8)
          , left(replace(convert(varchar, ISNULL(@percPossessoGruppo,0)), ',', ''),6)  -- Perc_possesso_gruppo - char(6)
          , left(replace(convert(varchar, ISNULL(@percPossessoDVGruppo,0)), ',', ''),6)  -- Perc_possesso_DV_gruppo - char(6)          
          , '0'  -- Flag_Scarto - bit
          , null -- Motivo_Scarto - nvarchar(2000)
					, ISNULL(convert(varchar,@DTINICC,112),'')  -- data inizio classificazione
					, ISNULL(convert(varchar,@DTFINECC,112),'')  	-- data fine classificazione				
					, ISNULL(convert(varchar,@DTCOST,112),'')  	-- data costituzione da anagrafica
					, ISNULL(@CODLEI, '')  -- Codice LEI														
					, ISNULL(@SEDEAM, '')  -- Sede amministrativa					
					, ISNULL(@CLIAS, '') 	-- Classificazione IAS					
					, ISNULL(@CODPR, '') 	-- Codice Prevalente					
					, ISNULL(@TIPOP, '') 	-- Tipo Operazione 							
					, ISNULL(@DESOP, '')  -- Descrizione Operazione							
					, ISNULL(@TIPDER, '') 	-- Tipo Derivato						
					, ISNULL(@DESDER, '')  -- Descrizione Derivato							
					, ISNULL(@GRPASS, '') 	-- Gruppo assicurativo	
					, @idTipologiaFondo      -- tipologia fondo										
        )

		 END

    FETCH NEXT FROM Operazioni_CUR INTO @idOperazione, @tipoOperazione,@DESOP, @idPartecipata, @sndgPartecipata, 
                                        @SAE, @RAE, @partitaIVA, @codFiscale, @statoOperazione, @GUIDPersona,
                                        @dtFineOperazione
  END
    
  CLOSE Operazioni_CUR
  DEALLOCATE Operazioni_CUR

  -- Verifica Record da scartare --> Quali regole?
  -- AL momento scartati record per i quali non sono valorizzati COdice Mappa Gruppo
  -- e metodo consolidamento IAS
  -- TODO
  UPDATE SK_F2_FLUSSI.[F2_T_EXP_TAGETIK_Anag]
     SET Flag_Scarto = 1, Motivo_Scarto = ISNULL(Motivo_Scarto, '') + 'Codice Mappa Gruppo mancante '
   WHERE Data_estrazione = @dataEstrazione
     AND ltrim(rtrim(Azienda)) = ''
     
  UPDATE SK_F2_FLUSSI.[F2_T_EXP_TAGETIK_Anag]
     SET Flag_Scarto = 1, Motivo_Scarto = ISNULL(Motivo_Scarto,'') + 'Metodo Consolidamento IAS mancante '
   WHERE Data_estrazione = @dataEstrazione
     AND ID_Operazione not in (select id_operazione from sk_f2.f2_t_operazioni where SK_F2.F2_T_Operazioni.ID_Stato_Operazione = 2)
     AND ltrim(rtrim(Metodo_consolidamento_IAS)) = ''
  
  -- Select finale da tabella 
  -- Record di testata (010 fisso) + records dati presi da tabella che abbiano flagScarto = 0
IF @spaziaturaFissa = 1
BEGIN
    SELECT * INTO #tempTAGETIKFAnagFISSA FROM (
			SELECT '00000' as Azienda, 0 as TipoRec, 
			'DET6NAME;LDESCI;ZDSEDE;METODO;AREAB;AREAG;AREAR;FLAGAT;ZATTIV;CONTRO;RESID;CURNCY' +
  		    ';QUOT;GRUPPO;ZABI;ZCODIVA;ZFISCOD;ZCCECOD;ZCODER;ZNSG;SIM;RIP011;RIP11C;RIP11R;RIP016' +
			';RIP016C;RIP016R;RIP200;RIP250;RIP911;RAGGR;CATEG;CARATT;SUBHO;METVAR;FVL' +
			';SISIN;ATECO;INBANKIT;PERC;PERCDV;DTINICC;DTFINECC;DTCOST;CODLEI;SEDEAM;CLIAS;CODPR;
			 TIPOP;DESOP;TIPDER;' as record
			UNION ALL
			SELECT Azienda, 1 as TipoRec, 
				Azienda + Ragione_sociale + Sede + Metodo + Metodo_consolidamento_BI + Metodo_consolidamento_IAS + 
						 Metodo_consolidamento_Finrep + Classificazione_BI + Descrizione_attivita 
						-- + Quotata +  Campo ATQUOT disabilitato
						 + Tipo_rapporto_effettivo + Residenza + Valuta + Tipo_quotazione + Gruppo_bancario 
						 -- Modalita_partecipazione campo MBANK disabilitato
						 + ABI + Partita_IVA + Codice_fiscale + Codice_UIC + Codice_CR + 
						 SNDG + Settore_ISVAP + Tipo_controparte + Tipo_controparteC + Tipo_controparteR + 
						 Area_geografica + Area_geograficaC + Area_geograficaR + Affidato_garante + 
						 Attivita_economica + SAE + Tipo_raggruppamento + Categoria_controparte + 
						 Caratt_partecipazione + Subholding + 
						 -- Business_unit campo SUBSEG disabilitato
						 + Variazione_metodo + 
						 Livello_fair_value + ISIN_prevalente + ATECO + Data_ingresso_BI + Perc_possesso_gruppo + 
						 Perc_possesso_DV_gruppo  + dt_inizio_class_contabile
						+ dt_fine_class_contabile
						+ dt_costituzione
						+ cod_LEI
						+ sede_amm
						+ class_IAS
						+ cod_prevalente
						+ tipo_op
						+ des_op
						+ tipo_derivato
					--	+ desc_derivato campo descrizione derivato disabilitato
					--	+ grp_ass flag gruppo assicurativo
						 as record
				FROM [SK_F2_FLUSSI].[F2_T_EXP_TAGETIK_Anag]
			 WHERE Data_estrazione = @dataEstrazione
				 AND Flag_Scarto = 0			
  ) tab
  SELECT record from #tempTAGETIKFAnagFISSA order by TipoRec, Azienda
END	
ELSE -- spaziatura NON fissa 
BEGIN
	SELECT * INTO #tempTAGETIKFAnag FROM (
    SELECT Azienda, 1 as TipoRec, Azienda + ';' +  Ragione_sociale + ';' + Sede + ';' + Metodo + ';' + Metodo_consolidamento_BI + ';' + Metodo_consolidamento_IAS + ';' + 
           Metodo_consolidamento_Finrep + ';' + Classificazione_BI + ';' + Descrizione_attivita + ';' 
		   -- + Quotata
            + ';' + Tipo_rapporto_effettivo + ';' + Residenza + ';' + Valuta + ';' + Tipo_quotazione + ';' + Gruppo_bancario
           -- Modalita_partecipazione 
		   + ';' + ABI + ';' + Partita_IVA + ';' + Codice_fiscale + ';' + Codice_UIC + ';' + Codice_CR + ';' + 
           SNDG + ';' + Settore_ISVAP + ';' + Tipo_controparte + ';' + Tipo_controparteC + ';' + Tipo_controparteR + ';' + 
           Area_geografica + ';' + Area_geograficaC + ';' + Area_geograficaR + ';' + Affidato_garante + ';' + 
           Attivita_economica + ';' + SAE + ';' + Tipo_raggruppamento + ';' + Categoria_controparte + ';' + 
           Caratt_partecipazione + ';' + Subholding + ';' +
		   Variazione_metodo + ';' + 
           Livello_fair_value + ';' + ISIN_prevalente + ';' + ATECO + ';' + Data_ingresso_BI + ';' + Perc_possesso_gruppo + ';' + 
           Perc_possesso_DV_gruppo  + ';' + dt_inizio_class_contabile
					+ ';' + dt_fine_class_contabile
					+ ';' + dt_costituzione
					+ ';' + cod_LEI
					+ ';' + sede_amm
					+ ';' + class_IAS
					+ ';' + cod_prevalente
					+ ';' + tipo_op
					+ ';' + des_op
					+ ';' + tipo_derivato
					+ ';' + id_tipologia_fondo
					+ ';' + convert(nvarchar,Data_estrazione,112)
					 as record
      FROM [SK_F2_FLUSSI].[F2_T_EXP_TAGETIK_Anag]
     WHERE Data_estrazione = @dataEstrazione
       AND Flag_Scarto = 0
  ) tab

  SELECT record from #tempTAGETIKFAnag order by TipoRec, Azienda
END

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