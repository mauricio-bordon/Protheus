user function etqident(cNumero, cItem, cSequencia, nVias, nRoloDe, nRoloAte)
	local cStrEtqNew := '', cStrEtq := '', cStrEtqTmp := ''
	local cBlockStart, cBlockEnd, nBlockStart, nBlockEnd
	local lNrolo, nRolo
	local lOk :=.T.
	Local bObject := {|| JsonObject():New()}
	Local oJson := Eval(bObject)
	local cJson
	Local cServer := u_ipPrimario()                               // IP FIXO INDUCOAT
	Local cServerBKP := "starlinkinducoat.myddns.me"              // URL DO SERVIDOR WAN2
    //Local dDtSrv := Date() 										  //data do servidor
	Local cPort := u_portaPrn()                                	  // PORTA DO SERVI�O REST - PORT FORWARD NO ROTEADOR PARA O IP DO RASPBERRY
	Local cURI := "http://" + cServer + ":" +cPort 			      // URI DO SERVI�O REST (NODE NO RASPBERRY)
	Local cURIBKP := "http://" + cServerBKP + ":" +cPort 		  // URI DO SERVI�O REST
	Local cResource := "/enviar"                  				  // RECURSO A SER CONSUMIDO
	Local oRest := FwRest():New(cURI)                        	  // CLIENTE PARA CONSUMO REST
	Local oRestBKP := FwRest():New(cURIBKP)                   	  // CLIENTE PARA CONSUMO REST BKP
	Local aHeader := {}                                           // CABE�ALHO DA REQUISI��O

	// PREENCHE CABE�ALHO DA REQUISI��O
	AAdd(aHeader, "Content-Type: application/json; charset=UTF-8")
	AAdd(aHeader, "Accept: application/json")
	AAdd(aHeader, "User-Agent: Chrome/65.0 (compatible; Protheus " + GetBuild() + ")")

	dbselectarea("SC2")
	SC2->(dbSetOrder(1))
	If dbseek(xfilial("SC2") + cNumero + cItem + cSequencia)
		conout('etqident - achou OP ' + cNumero + cItem + cSequencia)

		CURDIR( 'etq' )
		//cStrEtqNew := MemoRead( "C:\Dev\Protheus\etq\etq_rolo_ident.txt" )
		cStrEtqNew := MemoRead( "etq_rolo_ident.txt" )

		dbSelectArea("SB1")
        SB1->(dbSetOrder(1))
		dbSeek(xFilial("SB1") + SC2->C2_PRODUTO)

		//SH1 H1_IPPRINT
		//busca o ip da impressora no recurso.
		dbSelectArea("SH1")
		dbSeek(xFilial("SH1") + SC2->C2_MAQUINA)

		if nRoloDe == 0 .or. nRoloAte == 0
			lNrolo := .F.
			nRoloDe := 1 //para permitir o for / next
			nRoloAte := 1 //para permitir o for / next
		else
			lNrolo := .T.
			if nRoloDe > nRoloAte
				// swap
				nRolo := nRoloDe
				nRoloDe := nRoloAte
				nRoloAte := nRolo
			endif
		endif
		for nRolo := nRoloDe to nRoloAte
			cStrEtqTmp := cStrEtqNew
			cStrEtqTmp := STRTRAN(cStrEtqTmp, "%VIAS%", cvaltochar(nVias))
			cStrEtqTmp := STRTRAN(cStrEtqTmp, "%B1_COD%", rtrim(SB1->B1_COD))
			cStrEtqTmp := STRTRAN(cStrEtqTmp, "%B1_DESC%", rtrim(SB1->B1_DESC))
			//cStrEtqTmp := STRTRAN(cStrEtqTmp, "%DATA_PROD%", StrZero(Day(dDtSrv), 2) + "/" + StrZero(Month(dDtSrv), 2) + "/" + StrZero(Year(dDtSrv), 4))
			cStrEtqTmp := STRTRAN(cStrEtqTmp, "%OP%", cNumero + cItem + cSequencia)
			IF lNrolo
				cStrEtqTmp := STRTRAN(cStrEtqTmp, "%BARRAS%", cNumero + cItem + cSequencia + StrZero(nRolo, 3) + ';' + rtrim(SB1->B1_COD))
				cStrEtqTmp := STRTRAN(cStrEtqTmp, "%ROLO%", 'Rolo: ' + cvaltochar(nRolo))
			else
				//remover o bloco
				cBlockStart := '^FX{BEGIN_ROLO}^FS'
				cBlockEnd := '^FX{END_ROLO}^FS'
				nBlockStart := AT(cBlockStart, cStrEtqTmp, 1)
				nBlockEnd := AT(cBlockEnd, cStrEtqTmp,  1) + LEN(cBlockEnd)
				cStrEtqTmp := left(cStrEtqTmp, nBlockStart - 1) + substr(cStrEtqTmp, nBlockEnd + 1)
			endif
			cStrEtq+= cStrEtqTmp
		next nRolo

		oJson["chave"]:= "EtqIdent"
		oJson["impressao"]:= cStrEtq
		oJson["ip"]:= alltrim(SH1->H1_IPPRINT)

		cJson:=oJson:ToJson()

		oRest:SetPath(cResource)

		oRest:SetPostParams(cJson)

		// REALIZA O M�TODO POST E VALIDA O RETORNO
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

return lOk

// User Function CHKEXEC()
// 	u_etqident('001065', '01', '001', 1, 0, 0)

// 	return .T.
