USER FUNCTION MT680VAL()
	LOCAL lOk := .T.
	Local cAlias , cOp := M->H6_OP

	cAlias := getNextAlias()

	BEGINSQL alias CALIAS
        SELECT *
        FROM %TABLE:SD4%
        WHERE D4_FILIAL = %XFILIAL:SD4% AND %NOTDEL%
        AND D4_OP = %EXP:COP% AND RTRIM(D4_LOTECTL) = ''
        AND D4_COD NOT LIKE 'PI8100%'
	ENDSQL

	if !isblind()

		if (calias)->(!eof())

			lOk := .F.
			conout('Não é possível produzir pois Existe empenho sem lote definido.')
		ENDIF
		(calias)->(DBCLOSEAREA())

		if !LOk .and. !isblind()
			msgstop('Existe empenho sem lote definido. Por favor, informe os lotes no ajuste de empenho.')
		endif
	endif
	// lOk:=.T.
return lOk
