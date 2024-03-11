#Include "TOTVS.ch"

user function etqrecebe(cnota,cfornece,cproduto,citem,clotefor)
	local cAlias
	local lOk:=.T.
	 Local bObject := {|| JsonObject():New()}
    Local oJson   := Eval(bObject)
	local cJson
  Local cServer   := "187.49.39.130"                               // URL (IP) DO SERVIDOR
    Local cPort     := "3001"                                        // PORTA DO SERVIÇO REST
    Local cURI      := "http://" + cServer + ":" +cPort // URI DO SERVIÇO REST
    Local cResource := "/enviar"                  // RECURSO A SER CONSUMIDO
    Local oRest     := FwRest():New(cURI)                            // CLIENTE PARA CONSUMO REST
    Local aHeader   := {}                                            // CABEÇALHO DA REQUISIÇÃO

    // PREENCHE CABEÇALHO DA REQUISIÇÃO
    AAdd(aHeader, "Content-Type: application/json; charset=UTF-8")
    AAdd(aHeader, "Accept: application/json")
    AAdd(aHeader, "User-Agent: Chrome/65.0 (compatible; Protheus " + GetBuild() + ")")

	cSaida := ''
	cAlias := getNextalias()
	CURDIR( 'etq' )
	cStrEtq := MemoRead( "etq_rolo_mp.txt" )
	dbSelectArea("SB1")
	if dbSeek(xFilial("SB1")+cproduto)

	lok:=.T.
else
	lok:=.F.
	ENDIF

	BeginSql alias cAlias
		
        SELECT * 
FROM SD1010 SD1
INNER JOIN ZS1010 ZS1
ON D1_DOC=ZS1_DOC
AND D1_SERIE=ZS1_SERIE
AND D1_FORNECE=ZS1_FORNEC
INNER JOIN ZS2010 ZS2
ON ZS1_ID=ZS2_ID
AND D1_COD=ZS2_PRODUT
AND D1_LOTEFOR=ZS2_LOTEFO
WHERE ZS1.D_E_L_E_T_<>'*'
AND ZS2.D_E_L_E_T_<>'*'
AND SD1.D_E_L_E_T_<>'*'
AND ZS1_DOC=%EXP:cNota%
AND ZS1_FORNEC=%EXP:cfornece%
AND ZS2_PRODUT=%EXP:cproduto%
AND ZS2_ITEM=%EXP:citem%
AND ZS2_LOTEFO=%EXP:clotefor%
        
        
        
	EndSQL
		u_dbg_qry()

	WHILE (cAlias)->(!EOF())
		cStr:=cStrEtq

		cStr := STRTRAN(cStr, "%B1_COD%", SB1->B1_COD)
		cStr := STRTRAN(cStr, "%B1_DESC%", SB1->B1_DESC)
		cStr := STRTRAN(cStr, "%D3_UM%", SB1->B1_UM)
		cStr := STRTRAN(cStr, "%D3_QUANT%", transform((cAlias)->ZS2_QUANT, "@E 999,999.999"))
		cStr := STRTRAN(cStr, "%D3_EMISSAO%", dtoc(stod((cAlias)->D1_EMISSAO)))
		cStr := STRTRAN(cStr, "%D3_LOTECTL%", (cAlias)->D1_LOTECTL)
		cStr := STRTRAN(cStr, "%BARRA%",alltrim(SB1->B1_COD)+';'+alltrim((cAlias)->D1_LOTECTL)+';'+alltrim(transform((cAlias)->ZS2_QUANT, "@E 999,999.999")))

		cSaida += cStr+chr(10)+chr(13)


		(cAlias)->(DBSKIP())
	ENDDO
	(cAlias)->(DBCLOSEAREA())

/*
	cPort := 'LPT1' // prnLPTPort()
	FERASE("c:\windows\temp\etq_rolo_pa.prn" )
	MemoWrite("c:\windows\temp\etq_rolo_pa.prn", cSaida)

	Copy File "c:\windows\temp\etq_rolo_pa.prn" To LPT1

*/

conout("Print saida")
//CONOUT(cSaida)

oJson["chave"]:= "CoatIndu"
oJson["impressao"]:= cSaida
oJson["ip"]:= "192.168.2.229"

cJson:=oJson:ToJson()

    oRest:SetPath(cResource)

    oRest:SetPostParams(cJson)

    // REALIZA O MÉTODO POST E VALIDA O RETORNO
    If (oRest:Post(aHeader))
        ConOut("POST: " + oRest:GetResult())
    Else
        ConOut("POST: " + oRest:GetLastError())
		lOk:=.F.
    EndIf

return lOk
