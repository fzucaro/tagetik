-- gestita a saldi
SELECT count(*)
              FROM SK_F2.F2_T_Movimenti m
             WHERE m.ID_Rapporto_Partecipativo = 7321
                   -- VERIFICARE CON ENRICA
               AND m.data_fine IS NULL
               AND (m.Cancellata IS NULL OR
                    m.Cancellata = 0)
	
	
select *  FROM SK_F2.F2_T_Movimenti m	
	
				
-- Recupero onformazioni saldi
SELECT s.ID,
		0,
		s.Valore_Bilancio_Valuta,
		s.ID_Valuta,
		'SAL',
		s.Numero_Azioni,
		s.Numero_Azioni_SV,
	   	s.Data_Saldo
              FROM SK_F2.F2_T_Saldi s
             WHERE s.ID_Rapporto_Partecipativo > 7321
                   -- VERIFICARE CON ENRICA
               AND CONVERT(DATE, s.Data_Saldo) <= '31/12/2017'
               AND s.data_fine IS NULL
               AND (s.Cancellata IS NULL OR
                    s.Cancellata = 0)
				ORDER BY s.Data_Saldo
				 
