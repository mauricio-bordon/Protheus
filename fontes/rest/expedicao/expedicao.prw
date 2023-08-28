#include "protheus.ch"
#include "restful.ch"
#include 'rwmake.ch'
#Include "tbiconn.ch"
#include "topconn.ch"

wsrestful expedicao description "WS para listar expedicao "
	wsdata cID as char optional
	wsdata cDOC as char optional
	wsdata cSerie as char optional


	wsmethod get ws1;
		description "Consulta conferencia de expedicao" ;
		wssyntax "/expedicao/lista" ;
		path "/expedicao/lista"

		
	wsmethod get ws2;
		description "Perguntas expedicao" ;
		wssyntax "/expedicao/pergunta" ;
		path "/expedicao/pergunta"

	wsmethod post ws3;
		description "Inclui ZS1 ";
		wssyntax "/expedicao/add/zs1";
		path "/expedicao/add/zs1"

	wsmethod get ws4;
		description "Lista produto" ;
		wssyntax "/expedicao/listaprod/{cDOC}/{cSerie}" ;
		path "/expedicao/listaprod/{cDOC}/{cSerie}"


end wsrestful


wsmethod get ws1 wsservice expedicao
	local lRet as logical
	local aExpedir := {}
	local nL
	Local aJson := {}
	local wrk

	self:SetContentType("application/json")




	aExpedir:= retexpedir()


	wrk := JsonObject():new()

	If Len(aExpedir) == 0
		Aadd(aJson,JsonObject():new())
		nPos := Len(aJson)

		aJson[nPos]['TIPO']:='E'
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
		for nL := 1 to len(aExpedir)

			Aadd(aJson,JsonObject():new())
			nPos := Len(aJson)
			aJson[nPos]['TIPO']:=aExpedir[nL][1]
			aJson[nPos]['DOC']:=aExpedir[nL][2]
			aJson[nPos]['SERIE']:=aExpedir[nL][3]
			aJson[nPos]['EMISSAO']:=U_dtstoc(aExpedir[nL][4])
			aJson[nPos]['A1_COD']:=aExpedir[nL][5]
			aJson[nPos]['A1_NOME']:=aExpedir[nL][6]
			aJson[nPos]['ID']:=aExpedir[nL][7]
			aJson[nPos]['PLACA']:=aExpedir[nL][8]

			if !empty(alltrim(aExpedir[nL][7]))
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




wsmethod get ws2 wsservice expedicao
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



wsmethod post ws3 wsservice expedicao
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

wsmethod get ws4 wsservice expedicao
	local lRet as logical
	local aProduto := {}
	local aProdItem := {}
	local nL,nl2
	Local aJson := {}
	Local aJson2 := {}
	local wrk
	Private cMsgErro := 'Ocorreu um erro não previsto'
	self:SetContentType("application/json")
	oJson := JsonObject():new()
	cDOC:=(::cDOC)
	cSerie:=PADR( (::cSerie), TAMSX3("ZS1_SERIE")[1] )
	


	aProduto:= retprod(cDOC,cSerie)


	wrk := JsonObject():new()

	If Len(aProduto) == 0
		Aadd(aJson,JsonObject():new())
		nPos := Len(aJson)

		aJson[nPos]['TIPO']:='E'
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

		
		


			Aadd(aJson,JsonObject():new())
			nPos := Len(aJson)
	
	
			aJson[nPos]['D2_COD']:=aProduto[nL][1]
			aJson[nPos]['D2_UM']:=aProduto[nL][2]
			aJson[nPos]['B1_DESC']:=aProduto[nL][3]
			aJson[nPos]['D2_LOTECTL']:=aProduto[nL][4]
			aJson[nPos]['QUANTIDADE']:=aProduto[nL][5]
			
			aJson[nPos]['lista']:=aJson2


		next nL

	endif
	wrk:set(aJson)
	::SetResponse(wrk)


	FreeObj(aJson)
	FreeObj(wrk)
	lRet := .T.

return lRet



static function retexpedir()
	Local cAlias
	Local aRecebe := {}
	cAlias := getNextAlias()



	BeginSQL alias cAlias

	
	SELECT 'E' as 'TIPO',F2_DOC DOC, F2_SERIE SERIE,F2_EMISSAO EMISSAO,A1_NOME,A1_COD,ZS1_ID,ZS1_PLACA 
	FROM %TABLE:SF2% F2
	INNER JOIN %TABLE:SA1% A1
	ON F2_CLIENTE=A1_COD
	LEFT OUTER JOIN %TABLE:ZS1% ZS1
	ON F2_DOC=ZS1_DOC
	AND F2_SERIE=ZS1_SERIE
	AND A1_COD=ZS1_CLIENT
	AND ZS1_STATUS<>'F'
	AND ZS1.D_E_L_E_T_<>'*' 
	AND ZS1_FILIAL = %XFILIAL:ZS1%
	WHERE F2.D_E_L_E_T_<>'*' AND F2_FILIAL = %XFILIAL:SF2%
    AND A1.D_E_L_E_T_<>'*' AND A1_FILIAL = %XFILIAL:SA1%
   	AND F2_EMISSAO>'20230801'
	AND F2_DOC NOT IN (SELECT ZS1_DOC FROM %TABLE:ZS1%  WHERE F2_DOC=ZS1_DOC	AND F2_SERIE=ZS1_SERIE
	AND A1_COD=ZS1_CLIENT AND ZS1_STATUS='F' AND D_E_L_E_T_<>'*' )
	

	EndSQL
	//u_dbg_qry()

	While !(cAlias)->(Eof())
		aAdd(aRecebe, {})
		aAdd(aRecebe[len(aRecebe)], alltrim((cAlias)->TIPO) )
		aAdd(aRecebe[len(aRecebe)], alltrim((cAlias)->DOC) )
		aAdd(aRecebe[len(aRecebe)], alltrim((cAlias)->SERIE) )
		aAdd(aRecebe[len(aRecebe)], alltrim((cAlias)->EMISSAO) )
		aAdd(aRecebe[len(aRecebe)], alltrim((cAlias)->A1_COD) )
		aAdd(aRecebe[len(aRecebe)], alltrim((cAlias)->A1_NOME) )
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

static function  retprod(cDoc,cSerie)
	Local cAlias
	Local aProdutos := {}
	cAlias := getNextAlias()



	BeginSQL alias cAlias

	SELECT D2_COD,D2_UM,B1_DESC,D2_LOTECTL,SUM(D2_QUANT) QUANTIDADE 
	FROM %TABLE:SD2% SD2
	INNER JOIN %TABLE:SB1% SB1
	ON D2_COD=B1_COD
	WHERE SD2.D_E_L_E_T_<>'*'
	AND SB1.D_E_L_E_T_<>'*'
	AND D2_DOC=%EXP:cDoc% AND D2_SERIE=%EXP:cSerie%
	GROUP BY D2_COD,D2_UM,B1_DESC,D2_LOTECTL
	
	EndSQL
	//u_dbg_qry()
	//ZS3_FILIAL	ZS3_IDPERG	ZS3_PERG	ZS3_ATIVO	D_E_L_E_T_	R_E_C_N_O_	R_E_C_D_E_L_
	While !(cAlias)->(Eof())
		aAdd(aProdutos, {})
		aAdd(aProdutos[len(aProdutos)], alltrim((cAlias)->D2_COD) )
		aAdd(aProdutos[len(aProdutos)], alltrim((cAlias)->D2_UM) )
		aAdd(aProdutos[len(aProdutos)], alltrim((cAlias)->B1_DESC) )
		aAdd(aProdutos[len(aProdutos)], alltrim((cAlias)->D2_LOTECTL) )
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



