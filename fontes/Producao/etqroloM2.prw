user function etqrolom2()
	local cStrEtq
// SE O PRODUTO FOR PI IMPRIME E FABRICACAO IMPRIME
	//IF SH6->H6_PRODUTO$"PI_PA" 

		CURDIR( 'etq' )
		cStrEtq := MemoRead( "etq_rolo_pi2.txt" )

		dbSelectArea("SB1")
		dbSeek(xFilial("SB1")+SH6->H6_PRODUTO)

		cStrEtq := STRTRAN(cStrEtq, "%B1_COD%", SB1->B1_COD)
		cStrEtq := STRTRAN(cStrEtq, "%B1_DESC%", SB1->B1_DESC)
		cStrEtq := STRTRAN(cStrEtq, "%D3_UM%", SB1->B1_UM)
		cStrEtq := STRTRAN(cStrEtq, "%D3_QUANT%", transform(SH6->H6_QTDPROD, "@E 999,999.999"))
		cStrEtq := STRTRAN(cStrEtq, "%D3_EMISSAO%", dtoc(SH6->H6_DTPROD))
		cStrEtq := STRTRAN(cStrEtq, "%D3_LOTECTL%", SH6->H6_LOTECTL)
		cStrEtq := STRTRAN(cStrEtq, "%OBS%", SH6->H6_OBSERVA)
	    cStrEtq := STRTRAN(cStrEtq, "%BARRAS%", alltrim(SB1->B1_COD)+';'+alltrim(SH6->H6_LOTECTL)+';'+alltrim(transform(SH6->H6_QTDPROD, "@E 999,999.999")))

//imprime 2 etq		
//cStrEtq += cStrEtq +chr(10)+chr(13)

		cPort := 'LPT1' // prnLPTPort()
		FERASE("c:\windows\temp\etq_rolo_pi.prn" )
		MemoWrite("c:\windows\temp\etq_rolo_pi.prn", cStrEtq)

		Copy File "c:\windows\temp\etq_rolo_pi.prn" To LPT1

//	ENDIF

return
