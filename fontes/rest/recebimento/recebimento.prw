#include "protheus.ch"
#include "restful.ch"
#include 'rwmake.ch'
#Include "tbiconn.ch"
#include "topconn.ch"

wsrestful recebimento description "WS para listar recebiemnto "
	wsdata cID as char optional


	wsmethod get ws1;
		description "Consulta conferencia de recebimento" ;
		wssyntax "/recebimento/lista" ;
		path "/recebimento/lista"

	wsmethod get ws2;
		description "Perguntas recebimento" ;
		wssyntax "/recebimento/pergunta" ;
		path "/recebimento/pergunta"

	wsmethod post ws3;
		description "Inclui ZS1 ";
		wssyntax "/recebimento/add/zs1";
		path "/recebimento/add/zs1"

	wsmethod get ws4;
		description "Lista produto" ;
		wssyntax "/recebimento/listaprod/{cID}" ;
		path "/recebimento/listaprod/{cID}"

	wsmethod post ws5;
		description "Inclui ZS4 Respostas ";
		wssyntax "/recebimento/add/zs4/{cID}";
		path "/recebimento/add/zs4/{cID}"

	wsmethod post ws6;
		description "Inclui ZS2 Item ";
		wssyntax "/recebimento/add/zs2/{cID}";
		path "/recebimento/add/zs2/{cID}"


	wsmethod post ws7;
		description "Exclui ZS2 Item ";
		wssyntax "/recebimento/del/zs2/{cID}";
		path "/recebimento/del/zs2/{cID}"

	wsmethod post ws8;
		description "Update ZS2 Item ";
		wssyntax "/recebimento/update/zs2/{cID}";
		path "/recebimento/update/zs2/{cID}"


	wsmethod post ws9;
		description "Update ZS1 FIM ";
		wssyntax "/recebimento/update/zs1/{cID}";
		path "/recebimento/update/zs1/{cID}"

end wsrestful


wsmethod get ws1 wsservice recebimento
	local lRet as logical
	local aRecebe := {}
	local nL
	Local aJson := {}
	local wrk

	self:SetContentType("application/json")




	aRecebe:= retreceber()


	wrk := JsonObject():new()

	If Len(aRecebe) == 0
		Aadd(aJson,JsonObject():new())
		nPos := Len(aJson)

		aJson[nPos]['TIPO']:='R'
		aJson[nPos]['DOC']:=''
		aJson[nPos]['SERIE']:=''
		aJson[nPos]['EMISSAO']:=''
		aJson[nPos]['A2_COD']:=''
		aJson[nPos]['A2_NOME']:=''
		aJson[nPos]['ID']:=''

		self:setStatus(200)

	else

		CONOUT("ENTROU 200")
		self:setStatus(200)
		for nL := 1 to len(aRecebe)

			Aadd(aJson,JsonObject():new())
			nPos := Len(aJson)
			aJson[nPos]['TIPO']:=aRecebe[nL][1]
			aJson[nPos]['DOC']:=aRecebe[nL][2]
			aJson[nPos]['SERIE']:=aRecebe[nL][3]
			aJson[nPos]['EMISSAO']:=U_dtstoc(aRecebe[nL][4])
			aJson[nPos]['A2_COD']:=aRecebe[nL][5]
			aJson[nPos]['A2_NOME']:=aRecebe[nL][6]
			aJson[nPos]['ID']:=aRecebe[nL][7]
			aJson[nPos]['PLACA']:=aRecebe[nL][8]

			if !empty(alltrim(aRecebe[nL][7]))
				aJson[nPos]['LBAVALIA']:="TRUE"
				aJson[nPos]['LBCHECK']:="FALSE"

			else
				aJson[nPos]['LBAVALIA']:="FALSE"
				aJson[nPos]['LBCHECK']:="TRUE"

			endif
		next nL

	endif
	wrk:set(aJson)
	::SetResponse(wrk)


	FreeObj(aJson)
	FreeObj(wrk)
	lRet := .T.

return lRet



wsmethod get ws2 wsservice recebimento
	local lRet as logical
	local aPerg := {}
	local nL
	Local aJson := {}
	local wrk
	Local aopcoes1 := '{"label":"Sim", "value":"S"}'
	Local aopcoes2 := '{"label":"Não", "value":"N"}'
	Local aJson2 := {}

	self:SetContentType("application/json")


	oJson1:= JsonObject():new()
	oJson2:= JsonObject():new()
	oJson1:fromJSON(aopcoes1)
	oJson2:fromJSON(aopcoes2)
	Aadd(aJson2,oJson1)
	Aadd(aJson2,oJson2)


	aPerg:= retpergunta()


	wrk := JsonObject():new()

	If Len(aPerg) == 0
		Aadd(aJson,JsonObject():new())
		nPos := Len(aJson)


		::SetResponse('{ "message": "N�o foi locazidado perguntas","detailedMessage": "N�o foi locazidado perguntas"}')

		self:setStatus(400)

	else

		CONOUT("ENTROU 200")
		self:setStatus(200)
		for nL := 1 to len(aPerg)

			Aadd(aJson,JsonObject():new())
			nPos := Len(aJson)

			aJson[nPos]['property']:=aPerg[nL][1]
			aJson[nPos]['options']:=aJson2
			aJson[nPos]['label']:=aPerg[nL][2]

		next nL

	endif
	wrk:set(aJson)
	::SetResponse(wrk)


	FreeObj(aJson)
	FreeObj(wrk)
	lRet := .T.

return lRet




wsmethod post ws3 wsservice recebimento
	Local lPost := .T.
	Local oJson
	Local cBody := ::getContent()
	Private cMsgErro := 'Ocorreu um erro não previsto'
	oJson := JsonObject():new()
	oJson:fromJSON(cBody)
	cDOC:=oJson['DOC']
	cSerie:=PADR( oJson['SERIE'], TAMSX3("ZS1_SERIE")[1] )
	cA2_COD:=oJson['A2_COD']
	cID := GETSXENUM("ZS1","ZS1_ID")
	oJson['ID']:=cID

	dbselectarea("ZS1")
	ZS1->(dbsetorder(2))
	ZS1->(dbseek(xfilial("ZS1")+cDOC+cSerie+cA2_COD))

	IF ZS1->(!FOUND())

		ZS1->(RecLock('ZS1', .T.))
		ZS1->ZS1_FILIAL := xFilial("ZS4")
		ZS1->ZS1_TIPO := oJson['TIPO']
		ZS1->ZS1_ID := cID
		ZS1->ZS1_DOC := oJson['DOC']
		ZS1->ZS1_SERIE := oJson['SERIE']
		ZS1->ZS1_PLACA := oJson['PLACA']
		ZS1->ZS1_USERI := oJson['USUARIO']
		ZS1->ZS1_FORNEC := oJson['A2_COD']
		ZS1->ZS1_DTINIC:= dDataBase
		ZS1->ZS1_HRINIC :=substr(Time(),1,5)

		ZS1->(Msunlock())
		ConfirmSX8()

		ZS1->(dbCloseArea())
		::SetResponse(oJson)

		self:setStatus(200)

	ELSE


		::SetResponse('{ "message": "Ops...","detailedMessage": "'+cMsgErro+'"}')

		self:setStatus(400)
	ENDIF
Return lPost

wsmethod get ws4 wsservice recebimento
	local lRet as logical
	local aProduto := {}
	local aProdItem := {}
	local nL,nl2
	Local aJson := {}
	Local aJson2 := {}
	local wrk
	local nTotal:=0
	local cID:=(::cID)
	self:SetContentType("application/json")




	aProduto:= retprod(cID)


	wrk := JsonObject():new()

	If Len(aProduto) == 0
		Aadd(aJson,JsonObject():new())
		nPos := Len(aJson)

		aJson[nPos]['TIPO']:='R'
		aJson[nPos]['DOC']:=''
		aJson[nPos]['SERIE']:=''
		aJson[nPos]['EMISSAO']:=''
		aJson[nPos]['A2_COD']:=''
		aJson[nPos]['A2_NOME']:=''
		aJson[nPos]['ID']:=''

		self:setStatus(200)

	else

		CONOUT("ENTROU 200")
		self:setStatus(200)
		for nL := 1 to len(aProduto)

			aProdItem:=retproditem(cID,aProduto[nL][2])

			aJson2 := {}

			If len(aProdItem)!=0

				nTotal:=0
				for nl2 := 1 to len(aProdItem)
					Aadd(aJson2,JsonObject():new())
					nPos2 := Len(aJson2)
					aJson2[nPos2]['ZS2_PRODUT']:=aProdItem[nL2][1]
					aJson2[nPos2]['ZS2_ITEM']:=aProdItem[nL2][2]
					aJson2[nPos2]['ZS2_LOTEFO']:=aProdItem[nL2][3]
					aJson2[nPos2]['ZS2_QUANT']:=aProdItem[nL2][4]
					aJson2[nPos2]['ZS2_SITUAC']:=aProdItem[nL2][5]
					aJson2[nPos2]['DELETE']:='Delete'
					aJson2[nPos2]['PRINT']:='Imprime'
					nTotal:=nTotal+aJson2[nPos2]['ZS2_QUANT']
				next nl2

			endif


			Aadd(aJson,JsonObject():new())
			nPos := Len(aJson)
			aJson[nPos]['ZS1_ID']:=aProduto[nL][1]
			aJson[nPos]['D1_COD']:=aProduto[nL][2]
			aJson[nPos]['B1_DESC']:=aProduto[nL][3]
			aJson[nPos]['D1_UM']:=aProduto[nL][4]
			aJson[nPos]['D1_LOTEFOR']:=aProduto[nL][5]
			aJson[nPos]['QUANTIDADE']:=aProduto[nL][6]
			aJson[nPos]['QTDTOTAL']:=nTotal
			aJson[nPos]['lista']:=aJson2


		next nL

	endif
	wrk:set(aJson)
	::SetResponse(wrk)


	FreeObj(aJson)
	FreeObj(wrk)
	lRet := .T.

return lRet




wsmethod post ws5 wsservice recebimento
	Local lPost := .T.
	Local lOk := .T.
	local i
	Local oJson,cID
	Local cBody := ::getContent()
	Private cMsgErro := 'Ocorreu um erro não previsto'
	oJson := JsonObject():new()
	oJson:fromJSON(cBody)
	cID:=::cID

	names := oJson:GetNames()

	for i := 1 to len(names)
		conout(names[i])


		dbselectarea("ZS4")
		ZS4->(RecLock('ZS4', .T.))
		ZS4->ZS4_FILIAL := xFilial("ZS4")
		ZS4->ZS4_ID := cID
		ZS4->ZS4_IDPERG := names[i]
		ZS4->ZS4_RESPOS := oJson[names[i]]

		ZS4->(Msunlock())

	next i




/*
	else
	
		lOk=.F.
		cMsgErro:="Post errado"
	ENDIF


*/

	if lOk

		::SetResponse(oJson)

		self:setStatus(200)

	else
		::SetResponse('{ "message": "Ops...","detailedMessage": "'+cMsgErro+'"}')

		self:setStatus(400)
	endif

Return lPost



wsmethod post ws6 wsservice recebimento
	Local lPost := .T.
	Local lOk := .T.
	local cAlias
	Local oJson,cID
	Local cBody := ::getContent()
	Private cMsgErro := 'Ocorreu um erro não previsto'
	oJson := JsonObject():new()
	oJson:fromJSON(cBody)
	cID:=::cID

	cD1_COD:=oJson['D1_COD']
	cAlias := getNextAlias()

	BeginSql alias cAlias

				SELECT ISNULL(MAX(ZS2_ITEM)+1,1) AS ITEM FROM %TABLE:ZS2%
				WHERE ZS2_ID=%EXP:cID%
				AND ZS2_PRODUT=%EXP:cD1_COD%
				AND %NOTDEL%
                
	EndSql

	nextItem := (cAlias)->ITEM
	conout("Item : "+strzero(nextItem,3))
	oJson['ITEM']:=strzero(nextItem,3)
	(cAlias)->(DbClosearea())

	dbselectarea("ZS2")
	ZS2->(RecLock('ZS2', .T.))
	ZS2->ZS2_FILIAL := xFilial("ZS2")
	ZS2->ZS2_ID := cID
	ZS2->ZS2_PRODUT:=cD1_COD
	ZS2->ZS2_ITEM:=oJson['ITEM']
	ZS2->ZS2_LOTEFO:=oJson['D1_LOTEFOR']
	ZS2->ZS2_QUANT:=oJson['QUANTIDADE']
	ZS2->ZS2_USER:=oJson['USUARIO']
	ZS2->(Msunlock())



	if lOk

		::SetResponse(oJson)

		self:setStatus(200)

	else
		::SetResponse('{ "message": "Ops...","detailedMessage": "'+cMsgErro+'"}')

		self:setStatus(400)
	endif

Return lPost


wsmethod post ws7 wsservice recebimento
	Local lPost := .T.
	Local lOk := .T.
	Local oJson,cID
	Local cBody := ::getContent()
	Private cMsgErro := 'Ocorreu um erro não previsto'
	oJson := JsonObject():new()
	oJson:fromJSON(cBody)
	cID:=::cID

	cZS2_PRODUT:=PADR( oJson['D1_COD'], TAMSX3("ZS2_PRODUT")[1] )
	cZS2_ITEM:=oJson['ZS2_ITEM']


	dbselectarea("ZS2")
	ZS2->(dbSetOrder(1))
	If dbseek(xfilial("ZS2")+cID+cZS2_PRODUT+cZS2_ITEM)
		ZS2->(RecLock('ZS2',.F.))
		
		ZS2->(dbdelete())
		ZS2->(MsUnLock())
	Endif

	ZS2->(dbCloseArea())


	if lOk

		::SetResponse(oJson)

		self:setStatus(200)

	else
		::SetResponse('{ "message": "Ops...","detailedMessage": "'+cMsgErro+'"}')

		self:setStatus(400)
	endif

Return lPost

wsmethod post ws8 wsservice recebimento
	Local lPost := .T.
	Local lOk := .T.
	Local oJson,cID
	Local cBody := ::getContent()
	Private cMsgErro := 'Ocorreu um erro não previsto'
	oJson := JsonObject():new()
	oJson:fromJSON(cBody)
	cID:=::cID

	cZS2_PRODUT:=cSerie:=PADR( oJson['D1_COD'], TAMSX3("ZS2_PRODUT")[1] )
	cZS2_LOTEFO:=PADR( oJson['D1_LOTEFOR'], TAMSX3("ZS2_LOTEFO")[1] )

	dbselectarea("ZS2")
	ZS2->(dbSetOrder(2))
	ZS2->(dbseek(xfilial("ZS2")+cID+cZS2_PRODUT+cZS2_LOTEFO))

	Do while ZS2->(!eof())  .And. ZS2->ZS2_ID+ZS2->ZS2_PRODUT+ZS2->ZS2_LOTEFO = cID+cZS2_PRODUT+cZS2_LOTEFO


		ZS2->(RecLock("ZS2", .F.))
		ZS2->ZS2_SITUAC:='S'
		ZS2->(MsUnLock())

		//Endif
		ZS2->(dbSkip())
	Enddo

	ZS2->(dbclosearea())



	if lOk

		::SetResponse(oJson)

		self:setStatus(200)

	else
		::SetResponse('{ "message": "Ops...","detailedMessage": "'+cMsgErro+'"}')

		self:setStatus(400)
	endif

Return lPost


wsmethod post ws9 wsservice recebimento
	Local lPost := .T.
	Local lOk := .T.
	Local oJson,cID
	Local cBody := ::getContent()
	Private cMsgErro := 'Ocorreu um erro não previsto'
	oJson := JsonObject():new()
	oJson:fromJSON(cBody)
	cID:=::cID

	dbselectarea("ZS1")
	ZS1->(dbSetOrder(1))
	

	If ZS1->(dbseek(xfilial("ZS1")+cID))
		RecLock("ZS1",.F.)
		ZS1->ZS1_STATUS:='F'
		ZS1->ZS1_USERF := oJson['USUARIO']
		ZS1->ZS1_DTFINA:= dDataBase
		
		MsUnLock()
	ZS1->(MsUnLock())

		Endif
		
	ZS1->(dbclosearea())



	if lOk

		::SetResponse(oJson)

		self:setStatus(200)

	else
		::SetResponse('{ "message": "Ops...","detailedMessage": "'+cMsgErro+'"}')

		self:setStatus(400)
	endif

Return lPost


static function retreceber()
	Local cAlias
	Local aRecebe := {}
	cAlias := getNextAlias()



	BeginSQL alias cAlias

	
	SELECT 'R' as 'TIPO',F1_DOC DOC, F1_SERIE SERIE,F1_EMISSAO EMISSAO,A2_NOME,A2_COD,ZS1_ID,ZS1_PLACA 
	FROM %TABLE:SF1% F1
	INNER JOIN %TABLE:SA2% A2
	ON F1_FORNECE=A2_COD
	LEFT OUTER JOIN %TABLE:ZS1% ZS1
	ON F1_DOC=ZS1_DOC
	AND F1_SERIE=ZS1_SERIE
	AND A2_COD=ZS1_FORNEC
	AND ZS1_STATUS<>'F'
	AND ZS1.D_E_L_E_T_<>'*' 
	AND ZS1_FILIAL = %XFILIAL:ZS1%
	WHERE F1.D_E_L_E_T_<>'*' AND F1_FILIAL = %XFILIAL:SF1%
    AND A2.D_E_L_E_T_<>'*' AND A2_FILIAL = %XFILIAL:SA2%
   	AND F1_EMISSAO>'20230801'
	AND F1_DOC NOT IN (SELECT ZS1_DOC FROM %TABLE:ZS1%  WHERE F1_DOC=ZS1_DOC	AND F1_SERIE=ZS1_SERIE
	AND A2_COD=ZS1_FORNEC AND ZS1_STATUS='F' AND D_E_L_E_T_<>'*' )
	

	EndSQL
	//u_dbg_qry()

	While !(cAlias)->(Eof())
		aAdd(aRecebe, {})
		aAdd(aRecebe[len(aRecebe)], alltrim((cAlias)->TIPO) )
		aAdd(aRecebe[len(aRecebe)], alltrim((cAlias)->DOC) )
		aAdd(aRecebe[len(aRecebe)], alltrim((cAlias)->SERIE) )
		aAdd(aRecebe[len(aRecebe)], alltrim((cAlias)->EMISSAO) )
		aAdd(aRecebe[len(aRecebe)], alltrim((cAlias)->A2_COD) )
		aAdd(aRecebe[len(aRecebe)], alltrim((cAlias)->A2_NOME) )
		aAdd(aRecebe[len(aRecebe)], alltrim((cAlias)->ZS1_ID) )
		aAdd(aRecebe[len(aRecebe)], alltrim((cAlias)->ZS1_PLACA) )



		(cAlias)->(dbSkip())
	enddo
	(cAlias)->(DbClosearea())


//	json_dbg(aRmaterial)

return aRecebe



static function retpergunta()
	Local cAlias
	Local aPergunta := {}
	cAlias := getNextAlias()



	BeginSQL alias cAlias

	
	SELECT * 
	FROM %TABLE:ZS3% ZS3
	WHERE ZS3.D_E_L_E_T_<>'*' AND ZS3_FILIAL = %XFILIAL:ZS3%
	AND ZS3_ATIVO='S'

	EndSQL
	//u_dbg_qry()
	//ZS3_FILIAL	ZS3_IDPERG	ZS3_PERG	ZS3_ATIVO	D_E_L_E_T_	R_E_C_N_O_	R_E_C_D_E_L_
	While !(cAlias)->(Eof())
		aAdd(aPergunta, {})
		aAdd(aPergunta[len(aPergunta)], alltrim((cAlias)->ZS3_IDPERG) )
		aAdd(aPergunta[len(aPergunta)], alltrim((cAlias)->ZS3_PERG) )

		(cAlias)->(dbSkip())
	enddo
	(cAlias)->(DbClosearea())


//	json_dbg(aRmaterial)

return aPergunta

static function  retprod(cID)
	Local cAlias
	Local aProdutos := {}
	cAlias := getNextAlias()



	BeginSQL alias cAlias

	SELECT ZS1_ID,D1_COD,D1_UM,B1_DESC,D1_LOTEFOR,SUM(D1_QUANT) QUANTIDADE 
	FROM %TABLE:SD1% SD1
	INNER JOIN %TABLE:ZS1% ZS1
	ON D1_DOC=ZS1_DOC
	AND D1_SERIE=ZS1_SERIE
	AND D1_FORNECE=ZS1_FORNEC
	INNER JOIN %TABLE:SB1% SB1
	ON D1_COD=B1_COD
	WHERE SD1.D_E_L_E_T_<>'*' AND D1_FILIAL = %XFILIAL:SD1%
	AND ZS1.D_E_L_E_T_<>'*' AND ZS1_FILIAL = %XFILIAL:ZS1%
	AND SB1.D_E_L_E_T_<>'*' AND B1_FILIAL = %XFILIAL:SB1%
	AND ZS1_ID=%EXP:cID%
	GROUP BY ZS1_ID,D1_COD,D1_UM,B1_DESC,D1_LOTEFOR
	
	EndSQL
	//u_dbg_qry()
	//ZS3_FILIAL	ZS3_IDPERG	ZS3_PERG	ZS3_ATIVO	D_E_L_E_T_	R_E_C_N_O_	R_E_C_D_E_L_
	While !(cAlias)->(Eof())
		aAdd(aProdutos, {})
		aAdd(aProdutos[len(aProdutos)], alltrim((cAlias)->ZS1_ID) )
		aAdd(aProdutos[len(aProdutos)], alltrim((cAlias)->D1_COD) )
		aAdd(aProdutos[len(aProdutos)], alltrim((cAlias)->B1_DESC) )
		aAdd(aProdutos[len(aProdutos)], alltrim((cAlias)->D1_UM) )
		aAdd(aProdutos[len(aProdutos)], alltrim((cAlias)->D1_LOTEFOR) )
		aAdd(aProdutos[len(aProdutos)], (cAlias)->QUANTIDADE)

		(cAlias)->(dbSkip())
	enddo
	(cAlias)->(DbClosearea())


return aProdutos

static function  retproditem(cID,cProd)
	Local cAlias
	Local aProdItem := {}
	cAlias := getNextAlias()



	BeginSQL alias cAlias


	SELECT ZS2_PRODUT,ZS2_ITEM,ZS2_QUANT,ZS2_LOTEFO,ZS2_SITUAC 
	FROM %TABLE:ZS2% ZS2
	WHERE ZS2.D_E_L_E_T_<>'*' AND ZS2_FILIAL = %XFILIAL:ZS2%
	AND ZS2_ID=%EXP:cID%
	AND ZS2_PRODUT=%EXP:cProd%
	
	EndSQL
	//u_dbg_qry()
	//ZS3_FILIAL	ZS3_IDPERG	ZS3_PERG	ZS3_ATIVO	D_E_L_E_T_	R_E_C_N_O_	R_E_C_D_E_L_
	While !(cAlias)->(Eof())
		aAdd(aProdItem, {})
		aAdd(aProdItem[len(aProdItem)], alltrim((cAlias)->ZS2_PRODUT) )
		aAdd(aProdItem[len(aProdItem)], alltrim((cAlias)->ZS2_ITEM) )
		aAdd(aProdItem[len(aProdItem)], alltrim((cAlias)->ZS2_LOTEFO) )
		aAdd(aProdItem[len(aProdItem)], (cAlias)->ZS2_QUANT)
		aAdd(aProdItem[len(aProdItem)], (cAlias)->ZS2_SITUAC)
		(cAlias)->(dbSkip())
	enddo
	(cAlias)->(DbClosearea())


return aProdItem
