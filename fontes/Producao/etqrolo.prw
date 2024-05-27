user function etqrolo()
	local cStrEtq
	local cAlias
// SE O PRODUTO FOR PI IMPRIME E FABRICACAO IMPRIME
	IF SD3->D3_TIPO=="PI" .AND. D3_CF$"PR0_DE0_DE4_DE1"

		CURDIR( 'etq' )
		cStrEtq := MemoRead( "etq_rolo_pi.txt" )

		dbSelectArea("SB1")
		dbSeek(xFilial("SB1")+SD3->D3_COD)





		cStrEtq := STRTRAN(cStrEtq, "%B1_COD%", SB1->B1_COD)
		cStrEtq := STRTRAN(cStrEtq, "%B1_DESC%", SB1->B1_DESC)
		cStrEtq := STRTRAN(cStrEtq, "%D3_UM%", SD3->D3_UM)
		cStrEtq := STRTRAN(cStrEtq, "%D3_QUANT%", transform(SD3->D3_QUANT, "@E 999,999.999"))
		cStrEtq := STRTRAN(cStrEtq, "%D3_EMISSAO%", dtoc(SD3->D3_EMISSAO))
		cStrEtq := STRTRAN(cStrEtq, "%D3_LOTECTL%", SD3->D3_LOTECTL)
		cStrEtq := STRTRAN(cStrEtq, "%BARRAS%", alltrim(SB1->B1_COD)+';'+alltrim(SD3->D3_LOTECTL)+';'+alltrim(transform(SD3->D3_QUANT, "@E 999,999.999")))
		cStrEtq := STRTRAN(cStrEtq, "%OBS%", SH6->H6_OBSERVA)
//imprime 2 etq		
//cStrEtq += cStrEtq +chr(10)+chr(13)

		cPort := 'LPT1' // prnLPTPort()
		FERASE("c:\windows\temp\etq_rolo_pi.prn" )
		MemoWrite("c:\windows\temp\etq_rolo_pi.prn", cStrEtq)

		Copy File "c:\windows\temp\etq_rolo_pi.prn" To LPT1

	ENDIF

	IF SD3->D3_TIPO=="PA" .AND. SD3->D3_CF$"PR0"
		//etq rolo PA
		cAlias := getNextalias()
		cSaida := ''
		CURDIR( 'etq' )
		cStrEtq := MemoRead( "etq_rolo_pa.txt" )

		dbSelectArea("SB1")
		dbSeek(xFilial("SB1")+SD3->D3_COD)


		BeginSql alias cAlias
		SELECT D3_DTVALID,C6_PEDCLI,C6_DPD,D3_EMISSAO,B1_COD,B1_DESC,D3_UM,ZD3_MTROLO,D3_LOTECTL,ZD3_ROLO,C6_CLI,A1_NOME
		FROM %TABLE:SD3% SD3
		INNER JOIN %TABLE:ZD3% ZD3
		ON ZD3_NUMSEQ=D3_NUMSEQ
		INNER JOIN %TABLE:SB1% SB1
		ON B1_COD=D3_COD
		INNER JOIN %TABLE:SC6% SC6
		ON C6_PRODUTO=D3_COD
		AND C6_NUMOP=SUBSTRING(D3_OP,1,6)
		AND C6_ITEMOP=SUBSTRING(D3_OP,7,2)
		INNER JOIN %TABLE:SA1% SA1
		ON A1_COD=C6_CLI
		WHERE D3_FILIAL=%xfilial:SD3% AND SD3.D_E_L_E_T_<>'*' 
		AND ZD3_FILIAL=%xfilial:ZD3% AND ZD3.D_E_L_E_T_<>'*'
		AND B1_FILIAL=%xfilial:SB1% AND SB1.D_E_L_E_T_<>'*'
		AND C6_FILIAL=%xfilial:SC6% AND SC6.D_E_L_E_T_<>'*'
		AND A1_FILIAL=%xfilial:SA1% AND SA1.D_E_L_E_T_<>'*'
		AND D3_OP=%EXP:SD3->D3_OP%
		AND D3_NUMSEQ=%EXP:SD3->D3_NUMSEQ%
		ORDER BY ZD3_ROLO

		EndSQL

		WHILE (cAlias)->(!EOF())
			cStr:=cStrEtq
			cStr := STRTRAN(cStr, "%B1_COD%", alltrim(SB1->B1_COD))
			cStr := STRTRAN(cStr, "%B1_DESC%", alltrim(SB1->B1_DESC))
			cStr := STRTRAN(cStr, "%D3_UM%", alltrim(SD3->D3_UM))
			cStr := STRTRAN(cStr, "%D3_EMISSAO%", dtoc(SD3->D3_EMISSAO))
			cStr := STRTRAN(cStr, "%D3_DTVALID%", dtoc(SD3->D3_DTVALID))
			cStr := STRTRAN(cStr, "%D3_LOTECTL%", alltrim(SD3->D3_LOTECTL))
			cStr := STRTRAN(cStr, "%C6_PEDCLI%", alltrim((cAlias)->C6_PEDCLI))
			cStr := STRTRAN(cStr, "%C6_DPD%", alltrim((cAlias)->C6_DPD))
			cStr := STRTRAN(cStr, "%A1_NOME%", alltrim((cAlias)->A1_NOME))
			cStr := STRTRAN(cStr, "%ZD3_ROLO%", transform((cAlias)->ZD3_ROLO , "@E 999"))
			cStr := STRTRAN(cStr, "%ZD3_MTROLO%", transform((cAlias)->ZD3_MTROLO, "@E 999"))

			cSaida += cStr +chr(10)+chr(13)


			(cAlias)->(DBSKIP())
		ENDDO
		(cAlias)->(DBCLOSEAREA())


		cPort := 'LPT1' // prnLPTPort()
		FERASE("c:\windows\temp\etq_rolo_pa.prn" )
		MemoWrite("c:\windows\temp\etq_rolo_pa.prn", cSaida)

		Copy File "c:\windows\temp\etq_rolo_pa.prn" To LPT1



	END

// SE O PRODUTO FOR MP IMPRIME E FABRICACAO IMPRIME
	IF SD3->D3_TIPO$"MP P3 MC CO" .AND. SD3->D3_CF$"DE6 DE4"

		CURDIR( 'etq' )
		cStrEtq := MemoRead( "etq_rolo_mp.txt" )

		dbSelectArea("SB1")
		dbSeek(xFilial("SB1")+SD3->D3_COD)

		IF ALLTRIM(SD3->D3_CF)=="DE6"
		cD3_EMISSAO:=dtoc(SD3->D3_EMISSAO)
		ELSE
		cD3_EMISSAO:=ultimaemissao(SB1->B1_COD,SD3->D3_LOTECTL)
		ENDIF
	



		cStrEtq := STRTRAN(cStrEtq, "%B1_COD%", SB1->B1_COD)
		cStrEtq := STRTRAN(cStrEtq, "%B1_DESC%", SB1->B1_DESC)
		cStrEtq := STRTRAN(cStrEtq, "%D3_UM%", SD3->D3_UM)
		cStrEtq := STRTRAN(cStrEtq, "%D3_QUANT%", transform(SD3->D3_QUANT, "@E 999,999.999"))
		cStrEtq := STRTRAN(cStrEtq, "%D3_EMISSAO%", cD3_EMISSAO)
		cStrEtq := STRTRAN(cStrEtq, "%D3_LOTECTL%", SD3->D3_LOTECTL)
		cStrEtq := STRTRAN(cStrEtq, "%BARRA%",alltrim(SB1->B1_COD)+';'+alltrim(SD3->D3_LOTECTL)+';'+transform(SD3->D3_QUANT, "@E 999,999.999"))

//imprime 2 etq		
//cStrEtq += cStrEtq +chr(10)+chr(13)

		cPort := 'LPT1' // prnLPTPort()
		FERASE("c:\windows\temp\etq_rolo_mp.prn" )
		MemoWrite("c:\windows\temp\etq_rolo_mp.prn", cStrEtq)

		MemoWrite("c:\Relato\"+alltrim(SB1->B1_COD)+"_"+alltrim(SD3->D3_LOTECTL)+".prn", cStrEtq)

		Copy File "c:\windows\temp\etq_rolo_mp.prn" To LPT1

	ENDIF



return

static function ultimaemissao(cB1_COD,cD3_LOTECTL)
local cD3_EMISSAO:=''
local cAlias

	cAlias := getNexTAlias()
	BeginSQL alias cAlias
		SELECT TOP 1 *
		FROM %TABLE:SD3%
		WHERE D3_FILIAL = %XFILIAL:SD3% AND %NOTDEL%
		AND D3_COD = %exp:cB1_COD% 
		and D3_LOTECTL = %exp:cD3_LOTECTL%
		ORDER BY D3_EMISSAO ASC
	EndSQL

		while (cAlias)->(!eof())

		cD3_EMISSAO:=(cAlias)->D3_EMISSAO
		(cAlias)->(DBSKIP())
			enddo
		

	(cAlias)->(dbCloseArea())

cD3_EMISSAO:=DTOC(STOD(cD3_EMISSAO))


return cD3_EMISSAO
