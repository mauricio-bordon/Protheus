#include "protheus.ch"
#include "restful.ch"
#include 'rwmake.ch'
#Include "tbiconn.ch"


wsrestful ws_mata241 description "WS MAM Requisita material"
	wsdata codprod as char OPTIONAL
	wsdata locallocaliz as char OPTIONAL

	wsmethod get ws1;
		description "Lista e valida material para requisitar" ;
		wssyntax "/materialrequisita/{codprod}/{locallocaliz}";
		path "/materialrequisita/{codprod}/{locallocaliz}"


	WSMETHOD post ws2;
		DESCRIPTION "Requisita material " ;
		wssyntax "/ws_mata241/requisicao";
		PATH "/ws_mata241/requisicao"


end wsrestful


wsmethod get ws1 wsservice ws_mata241
	local lRet as logical
	local aRProduto := {}
	Local aJson := {}
	local wrk
	local sCodprod
	local sProduto:=''

	lRet := .T.
	self:SetContentType("application/json")

	sCodprod:=trim(::codprod)
	slocallocaliz:=trim(::locallocaliz)
	sLocaliz:=substr(trim(slocallocaliz),3,(len(slocallocaliz)-2))
	slocal=substr(slocallocaliz,1,2)
	//valida se nao ù MP PI PA PL BB SL
	if left(sCodprod,2)$'MP_PI_PA_BB_SL'

		::SetResponse('{ "message": "Nao permitido tipo","detailedMessage": "Os produtos MP_PI_PA_BB_SL n„o pode ser requsitado pelo APP"}')

		self:setStatus(400)


		return lRet
	endif

	//verifica se o produto faz parte de alguma estrutura
	sProduto:= consultEstru(sCodprod)
	If sProduto <> ''

		::SetResponse('{ "message": "Erro n„o permitido","detailedMessage": "Produto faz parte de uma estrutura"}')

		self:setStatus(400)

		return lRet
	endif
	//verifica se ù produto ou lote e se nao esta em uma estrutura


	aRProduto:= consultaValida(sCodprod,slocal,sLocaliz)

	wrk := JsonObject():new()

	If Len(aRProduto) == 0

		::SetResponse('{ "message": "Erro ao localizar produto","detailedMessage": "N„o encontramos produto ERRO"}')

		self:setStatus(400)

	else

		self:setStatus(200)



		wrk['PRODUTO']:=aRProduto[1,1]
		wrk['DESCRICAO']:=aRProduto[1,2]
		wrk['SALDO']:=aRProduto[1,3]
		wrk['UM']:=aRProduto[1,4]
		wrk['LOCAL']:=aRProduto[1,5]
		wrk['LOCALIZACAO']:=aRProduto[1,6]
		wrk['LOTE']:=aRProduto[1,7]

		::SetResponse(wrk)
	endif



	FreeObj(aJson)
	FreeObj(wrk)
	lRet := .T.

return lRet



wsmethod post ws2 wsservice ws_mata241

	Local lret := .T.
	Local oJson
	//Local cObs:=''
	Local cBody := ::getContent()
	Local cCod,cLOCAL,cLOCLZ,nQTD,cCC
	Private cErrRest := ''

	oJson := JsonObject():new()
	oJson:fromJSON(cBody)


	cCod:=oJson['PRODUTO']
	cLOCAL:=oJson['LOCAL']
	cLote:=oJson['LOTE']
	cLOCLZ:=oJson['LOCALIZACAO']
	nQTD:= oJson['QUANTIDADE']
	cCC:= '500' //oJson['CCUSTO']

	conout('Executando MSExecAuto MATA241.')
	lMsErroAuto := .F.
	_cDocSeq := GetSxeNum("SD3","D3_DOC")
        _aCab1 := {{"D3_DOC" ,_cDocSeq, NIL},;
			{"D3_TM" ,'505' , NIL},;
			{"D3_CC" ,cCC, NIL},;
			{"D3_EMISSAO" ,ddatabase, NIL}}

	aVetor:={    {"D3_COD",cCod,NIL},; //COD DO PRODUTO
	{"D3_QUANT",nQTD,NIL},;   //QUANTIDADE
	{"D3_LOCAL",cLOCAL,NIL},; //LOCAL
	{"D3_LOTECTL",cLote,NIL},; //LOTE
	{"D3_LOCALIZ",cLOCLZ,NIL}}//,; //LOCALIZACAO
	//{"D3_OBSROLO",cObs,NIL}}  //CENTRO DE CUSTO

	    _atotitem := {}
		aadd(_atotitem,aVetor)
		lMsErroAuto := .F.
		MSExecAuto({|x,y,z| MATA241(x,y,z)},_aCab1,_atotitem,3)

	conout(aVetor)
	If lMsErroAuto
		//PEGAR ERRO

		ctitulo:="Erro na execucao do MATA241. APP"
		cmsg:="Verificar no SIGAADV o log "+NomeAutoLog()
		conout(cMsg)

		::SetResponse('{ "message": "Erro ao requisitar produto","detailedMessage": "ERRO MATA241"}')

		self:setStatus(400)

		conout("OperaÁ„o N„o Realizada")
	Else

		::SetResponse('{ "message": "Opera? realizada com sucesso","detailedMessage": "OK"}')

		self:setStatus(200)
		conout("OperaÁ„o Realizada")

	Endif
	lRet := .T.

return lret









static function consultEstru(codprod)
	Local cAlias
	Local sProduto := ''

	cAlias := getNextAlias()
	BeginSQL alias cAlias
		SELECT TOP 1 G1_COD FROM SG1070 G1
		inner join SB1070 B1
		ON B1_COD=G1_COD
		WHERE B1.D_E_L_E_T_<>'*' 
		AND B1_FILIAL = %XFILIAL:SB1%
		AND G1.D_E_L_E_T_<>'*' 
		AND G1_FILIAL = %XFILIAL:SB1%
		AND ( B1_ATIVO<>'N' OR B1_MSBLQL<>'1')
		AND G1_COMP=%EXP:codprod%


	EndSQL

//Pega as informa??es da ?ltima query
	aDados := GetLastQuery()

	//Mostra mensagem com todas as informa??es capturadas
	cMensagem := ""
	cMensagem += "* cAlias - " + aDados[1] + Chr(13) + Chr(10)
	cMensagem += "* cQuery - " + aDados[2]
	conout(cMensagem)

	While !(cAlias)->(Eof())

		sProduto:=alltrim((cAlias)->G1_COD)


		(cAlias)->(dbSkip())
	enddo
	(cAlias)->(DbClosearea())

return sProduto

static function consultaValida(codprod,slocal,sLocaliz)
	Local cAlias
	Local aRProduto := {}

	cAlias := getNextAlias()
	BeginSQL alias cAlias

		SELECT TOP 1 BF_PRODUTO,B1_DESC,BF_QUANT,B1_UM,BF_LOCAL,BF_LOCALIZ,BF_LOTECTL
		FROM SBF070 BF
		INNER JOIN SB1070 B1
		ON B1_COD=BF_PRODUTO
		WHERE BF.D_E_L_E_T_<>'*' and BF_FILIAL = %XFILIAL:SBF%
		AND B1.D_E_L_E_T_<>'*' AND B1_FILIAL = %XFILIAL:SB1%
		AND (BF_PRODUTO = %EXP:codprod% or BF_LOTECTL = %EXP:codprod%)
		AND BF_LOCAL = %EXP:slocal%
		AND BF_LOCALIZ = %EXP:sLocaliz%
		ORDER BY BF_LOTECTL


	EndSQL

//Pega as informa??es da ?ltima query
	aDados := GetLastQuery()

	//Mostra mensagem com todas as informa??es capturadas
	cMensagem := ""
	cMensagem += "* cAlias - " + aDados[1] + Chr(13) + Chr(10)
	cMensagem += "* cQuery - " + aDados[2]
	conout(cMensagem)

	While !(cAlias)->(Eof())

		aAdd(aRProduto, {})
		aAdd(aRProduto[len(aRProduto)], alltrim((cAlias)->BF_PRODUTO) )
		aAdd(aRProduto[len(aRProduto)], alltrim((cAlias)->B1_DESC) )
		aAdd(aRProduto[len(aRProduto)], (cAlias)->BF_QUANT )
		aAdd(aRProduto[len(aRProduto)], alltrim((cAlias)->B1_UM) )
		aAdd(aRProduto[len(aRProduto)], alltrim((cAlias)->BF_LOCAL) )
		aAdd(aRProduto[len(aRProduto)], (cAlias)->BF_LOCALIZ )
		aAdd(aRProduto[len(aRProduto)], (cAlias)->BF_LOTECTL )


		(cAlias)->(dbSkip())
	enddo
	(cAlias)->(DbClosearea())
	u_json_dbg(aRProduto)
return aRProduto
