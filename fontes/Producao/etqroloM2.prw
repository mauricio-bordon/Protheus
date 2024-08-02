user function etqrolom2()
	local cStrEtq

// SE O PRODUTO FOR PI IMPRIME E FABRICACAO IMPRIME
	//IF SH6->H6_PRODUTO$"PI_PA"

	CURDIR( 'etq' )
	cStrEtq := MemoRead( "etq_rolo_pi2.txt" )

	dbSelectArea("SB1")
	dbSeek(xFilial("SB1")+SH6->H6_PRODUTO)

<<<<<<< Updated upstream
		cStrEtq := STRTRAN(cStrEtq, "%B1_COD%", SB1->B1_COD)
		cStrEtq := STRTRAN(cStrEtq, "%B1_DESC%", SB1->B1_DESC)
		cStrEtq := STRTRAN(cStrEtq, "%D3_UM%", SB1->B1_UM)
		cStrEtq := STRTRAN(cStrEtq, "%D3_QUANT%", transform(SH6->H6_QTDPROD, "@E 999,999.999"))
		cStrEtq := STRTRAN(cStrEtq, "%D3_EMISSAO%", dtoc(SH6->H6_DTPROD))
		cStrEtq := STRTRAN(cStrEtq, "%D3_LOTECTL%", SH6->H6_LOTECTL)

		if left(SB1->B1_COD, 2) == "PA"
			//a observação é de uso interno da produção; não deve ser impressa no caso de PA
			cStrEtq := STRTRAN(cStrEtq, "%OBS%", " ")
		else
			cStrEtq := STRTRAN(cStrEtq, "%OBS%", SH6->H6_OBSERVA)
		endif

	    cStrEtq := STRTRAN(cStrEtq, "%BARRAS%", alltrim(SB1->B1_COD)+';'+alltrim(SH6->H6_LOTECTL)+';'+alltrim(transform(SH6->H6_QTDPROD, "@E 999,999.999")))
=======
	cStrEtq := STRTRAN(cStrEtq, "%B1_COD%", SB1->B1_COD)
	cStrEtq := STRTRAN(cStrEtq, "%B1_DESC%", SB1->B1_DESC)
	cStrEtq := STRTRAN(cStrEtq, "%D3_UM%", SB1->B1_UM)
	cStrEtq := STRTRAN(cStrEtq, "%D3_QUANT%", transform(SH6->H6_QTDPROD, "@E 999,999.999"))
	cStrEtq := STRTRAN(cStrEtq, "%D3_EMISSAO%", dtoc(SH6->H6_DTPROD))
	cStrEtq := STRTRAN(cStrEtq, "%D3_LOTECTL%", SH6->H6_LOTECTL)
	cStrEtq := STRTRAN(cStrEtq, "%OBS%", SH6->H6_OBSERVA)
	cStrEtq := STRTRAN(cStrEtq, "%BARRAS%", alltrim(SB1->B1_COD)+';'+alltrim(SH6->H6_LOTECTL)+';'+alltrim(transform(SH6->H6_QTDPROD, "@E 999,999.999")))
>>>>>>> Stashed changes

//imprime 2 etq
//cStrEtq += cStrEtq +chr(10)+chr(13)

	cPort := 'LPT1' // prnLPTPort()
	FERASE("c:\windows\temp\etq_rolo_pi.prn" )
	MemoWrite("c:\windows\temp\etq_rolo_pi.prn", cStrEtq)

	Copy File "c:\windows\temp\etq_rolo_pi.prn" To LPT1

//	ENDIF

return

user function etqpim2(cLote)
	local cStrEtq
	local lOk:=.T.
	Local bObject := {|| JsonObject():New()}
	Local oJson   := Eval(bObject)
	local cJson
	Local cServer   := "187.49.39.130"                               // URL (IP) DO SERVIDOR
	Local cServerBKP   := "starlinkinducoat.myddns.me"                               // URL DO SERVIDOR WAN2

	Local cPort     := "3001"                                        // PORTA DO SERVIÇO REST
	Local cURI      := "http://" + cServer + ":" +cPort // URI DO SERVIÇO REST
	Local cURIBKP  := "http://" + cServerBKP + ":" +cPort // URI DO SERVIÇO REST
	Local cResource := "/enviar"                  // RECURSO A SER CONSUMIDO
	Local oRest     := FwRest():New(cURI)                            // CLIENTE PARA CONSUMO REST
	Local oRestBKP     := FwRest():New(cURIBKP)                            // CLIENTE PARA CONSUMO REST BKP

	Local aHeader   := {}                                            // CABEÇALHO DA REQUISIÇÃO

	// PREENCHE CABEÇALHO DA REQUISIÇÃO
	AAdd(aHeader, "Content-Type: application/json; charset=UTF-8")
	AAdd(aHeader, "Accept: application/json")
	AAdd(aHeader, "User-Agent: Chrome/65.0 (compatible; Protheus " + GetBuild() + ")")

// SE O PRODUTO FOR PI IMPRIME E FABRICACAO IMPRIME
	//IF SH6->H6_PRODUTO$"PI_PA"
	dbselectarea("SH6")
	SH6->(dbSetOrder(5))
	If dbseek(xfilial("SH6")+cLote)

		CURDIR( 'etq' )
		cStrEtq := MemoRead( "etq_rolo_pi2.txt" )

		dbSelectArea("SB1")
		dbSeek(xFilial("SB1")+SH6->H6_PRODUTO)
		//SC2 C2_MAQUINA
		dbSelectArea("SC2")
		dbSeek(xFilial("SC2")+alltrim(SH6->H6_OP))

		//SH1 H1_IPPRINT
		//busca o ip da impressora no recurso.
		dbSelectArea("SH1")
		dbSeek(xFilial("SH1")+SC2->C2_MAQUINA)

		cStrEtq := STRTRAN(cStrEtq, "%B1_COD%", SB1->B1_COD)
		cStrEtq := STRTRAN(cStrEtq, "%B1_DESC%", SB1->B1_DESC)
		cStrEtq := STRTRAN(cStrEtq, "%D3_UM%", SB1->B1_UM)
		cStrEtq := STRTRAN(cStrEtq, "%D3_QUANT%", transform(SH6->H6_QTDPROD, "@E 999,999.999"))
		cStrEtq := STRTRAN(cStrEtq, "%D3_EMISSAO%", dtoc(SH6->H6_DTPROD))
		cStrEtq := STRTRAN(cStrEtq, "%D3_LOTECTL%", SH6->H6_LOTECTL)
		cStrEtq := STRTRAN(cStrEtq, "%OBS%", SH6->H6_OBSERVA)
		cStrEtq := STRTRAN(cStrEtq, "%BARRAS%", alltrim(SB1->B1_COD)+';'+alltrim(SH6->H6_LOTECTL)+';'+alltrim(transform(SH6->H6_QTDPROD, "@E 999,999.999")))



		oJson["chave"]:= "CoatIndu"
		oJson["impressao"]:= cStrEtq
		oJson["ip"]:= alltrim(SH1->H1_IPPRINT)

		cJson:=oJson:ToJson()

		oRest:SetPath(cResource)

		oRest:SetPostParams(cJson)

		// REALIZA O MÉTODO POST E VALIDA O RETORNO
		If (oRest:Post(aHeader))
			ConOut("POST: " + oRest:GetResult())
		Else
			oRestBKP:SetPath(cResource)
			oRestBKP:SetPostParams(cJson)
			If (oRestBKP:Post(aHeader))
				ConOut("POST: " + oRestBKP:GetResult())
			Else

				ConOut("POST: " + oRestBKP:GetLastError())
				lOk:=.F.

			EndIf




		EndIf


	else
		lOk:=.F.

	ENDIF
//	ENDIF

return lOk
