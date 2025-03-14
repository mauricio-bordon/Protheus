/***
Usado para validar a inclusao da NF.
Esse Ponto de Entrada é chamado 2 vezes dentro da rotina A103Tudok().
Para o controle do número de vezes em que ele é chamado foi criada a variável lógica lMT100TOK, que quando for definida como (.F.) o ponto de entrada será chamado somente uma vez.
***/
User Function MT100TOK()
	Local lGrava := .T., nLinha, cMsg
	Local cD1_COD, cD1_ITEM, cD1_TES

	//conout("---------- PE MT100TOK ----------")

	Return lGrava //TODO: P.E. DESATIVADO

	for nLinha := 1 to len(aCols)
		If Acols[nLinha][len(aHeader)+1]  //linha deletada
			loop
		endif
		cD1_COD := U_zConHCol(aHeader, aCols, nLinha, "D1_COD")
		IF cD1_COD != NIL
			cD1_ITEM 	:= U_zConHCol(aHeader, aCols, nLinha, "D1_ITEM")
			cD1_TES 	:= U_zConHCol(aHeader, aCols, nLinha, "D1_TES")
		ELSE  //formulário próprio
			cD1_COD 	:= U_zConHCol(aHeader, aCols, nLinha, "D2_COD")
			cD1_ITEM 	:= U_zConHCol(aHeader, aCols, nLinha, "D2_ITEM")
			cD1_TES 	:= U_zConHCol(aHeader, aCols, nLinha, "D2_TES")
		endif
		cMsg := U_zVlDProd(cD1_COD, cD1_TES, cD1_ITEM)
		IF cMsg != 'OK'
			lGrava := .F.
			exit
		endif
	next

	if ! lGrava
		alert(cMsg)
	endif

	return lGrava
