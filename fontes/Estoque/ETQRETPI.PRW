USER FUNCTION ETQRETPI()

	Local cOp := SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN+SC2->C2_ITEMGRD
	Local  cStrEtq := ''	, cStr := '', cSaida := '', cAlias, cAlias2
	//Verifica se ordem está encerrada
/*
	if EMPTY(SC2->C2_DATRF)
		MsgStop('Encerrar a ordem antes de gerar as etiquetas de retorno.', 'Aviso')
		RETURN
	ENDIF
*/
	//carrega etiqueta
	CURDIR( 'etq' )

	cStrEtq := MemoRead( "etq_rolo_pi.txt" )

	//obter lotes requisitados que ainda possuem saldo
	cAlias := getNextalias()

	BeginSql alias CALIAS
        SELECT B1_COD, B1_DESC, B1_UM, BF_QUANT, BF_LOTECTL
        FROM %TABLE:SBF% BF INNER JOIN %TABLE:SB1% B1 ON (B1_COD = BF_PRODUTO)
            INNER JOIN %TABLE:SD3% D3 ON ( D3_COD = BF_PRODUTO AND D3_LOTECTL = BF_LOTECTL AND D3_LOCAL = BF_LOCAL)
        WHERE BF_FILIAL = %XFILIAL:SBF% AND BF.%NOTDEL%
        AND  B1_FILIAL = %XFILIAL:SB1% AND B1.%NOTDEL%
         AND D3_FILIAL = %XFILIAL:SD3% AND D3.%NOTDEL%
		 AND D3_OP =  %EXP:cOp%
		 AND D3_ESTORNO <> 'S'
		 and D3_CF LIKE 'RE%'
		 AND D3_TIPO = 'PI'

	EndSql


	cSaida := ''
	WHILE (CALIAS)->(!EOF())
		//Obter dados da produção do lote em caso de PI

		cAlias2 := getNextalias()

		BeginSql alias CALIAS2
			SELECT MIN(B8_DFABRIC) AS B8_DFABRIC
			FROM  %TABLE:SB8% B8 
			WHERE  B8_FILIAL = %XFILIAL:SB8% AND B8.%NOTDEL% 
			AND B8_PRODUTO= %EXP:(CALIAS)->B1_COD%
			AND B8_LOTECTL = %EXP:(CALIAS)->BF_LOTECTL%
		EndSql

		if (calias2)->(!eof())
			dDtProducao := stod((calias2)->B8_DFABRIC)
		ELSE
			dDtProducao := ctod('  /  /  ')
		endif

		(CALIAS2)->(DBCLOSEAREA())

		cStr := cStrEtq
		cStr := STRTRAN(cStr, "%B1_COD%", alltrim((CALIAS)->B1_COD) )
		cStr := STRTRAN(cStr, "%B1_DESC%", alltrim((CALIAS)->B1_DESC) )
		cStr := STRTRAN(cStr, "%D3_UM%", alltrim((CALIAS)->B1_UM) )
		cStr := STRTRAN(cStr, "%D3_QUANT%", TRANSFORM((CALIAS)->BF_QUANT, "@E 999,999,999.999") )
		cStr := STRTRAN(cStr, "%D3_EMISSAO%", DTOC(dDtProducao) )
		cStr := STRTRAN(cStr, "%D3_LOTECTL%", alltrim((CALIAS)->BF_LOTECTL) )

		cSaida += cStr +chr(10)+chr(13)
		(CALIAS)->(DBSKIP())
	ENDDO
	(CALIAS)->(DBCLOSEAREA())

	MSGINFO( cSaida, 'ZPL' )

    /*
     cPort := 'LPT2' // prnLPTPort()
    FERASE("c:\windows\temp\etq_rolo_pi.prn" )
    MemoWrite("c:\windows\temp\etq_rolo_pi.prn", cSaida)

 
    if cPort == 'LPT1'
        Copy File "c:\windows\temp\etq_rolo_pi.prn" To LPT1
    elseif cPort == 'LPT2'
        Copy File "c:\windows\temp\etq_rolo_pi.prn" To LPT2
    endif
*/
RETURN
