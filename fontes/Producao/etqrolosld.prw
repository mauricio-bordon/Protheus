// Etiqueta para PI da tela Saldo Estoque
user function etqrolosld()



		CURDIR( 'etq' )
		cStrEtq := MemoRead( "etq_rolo_pi.txt" )

		dbSelectArea("SB1")
		dbSeek(xFilial("SB1")+SBF->BF_PRODUTO)





		cStrEtq := STRTRAN(cStrEtq, "%B1_COD%", SB1->B1_COD)
		cStrEtq := STRTRAN(cStrEtq, "%B1_DESC%", SB1->B1_DESC)
		cStrEtq := STRTRAN(cStrEtq, "%D3_UM%", SB1->B1_UM)
		cStrEtq := STRTRAN(cStrEtq, "%D3_QUANT%", transform(SBF->BF_QUANT, "@E 999,999.999"))
		cStrEtq := STRTRAN(cStrEtq, "%D3_EMISSAO%", dtoc(ddatabase))
		cStrEtq := STRTRAN(cStrEtq, "%D3_LOTECTL%", SBF->BF_LOTECTL)
		cStrEtq := STRTRAN(cStrEtq, "%BARRA%", SB1->B1_COD+';'+SBF->BF_LOTECTL+';'+transform(SBF->BF_QUANT, "@E 999,999.999"))

//imprime 2 etq		
//cStrEtq += cStrEtq +chr(10)+chr(13)

		cPort := 'LPT1' // prnLPTPort()
		FERASE("c:\windows\temp\etq_rolo_pi.prn" )
		MemoWrite("c:\windows\temp\etq_rolo_pi.prn", cStrEtq)

		Copy File "c:\windows\temp\etq_rolo_pi.prn" To LPT1
return
