#include "protheus.ch"
#include "restful.ch"
#include 'rwmake.ch'
#Include "tbiconn.ch"
#include "topconn.ch"

wsrestful doczdbcabec description "WS para manipular cabeçalho"
	wsdata iddoc as char optional
    wsdata revisa as char optional


	wsmethod get ws1;
		description "Consulta cabeçalho do Doc" ;
		wssyntax "/doczdbcabec/lista/{iddoc}/{revisa}" ;
		path "/doczdbcabec/lista/{iddoc}/{revisa}"


	WSMETHOD post ws2;
		DESCRIPTION "Inclui ZDB cabeçalho" ;
		wssyntax "/doczdbcabec/novo";
		PATH "/doczdbcabec/novo"


end wsrestful


wsmethod get ws1 wsservice doczdbcabec
	local lRet as logical
	local iTemtipo := {}
	local nL
	Local aJson := {}
	local wrk
    local iddoc:=::iddoc
    local revisa:=::revisa 

	self:SetContentType("application/json")

	doczdb:= consultadoc(iddoc,revisa)

	wrk := JsonObject():new()

	CONOUT("ENTROU 200")
	self:setStatus(200)
	for nL := 1 to len(doczdb)

		Aadd(aJson,JsonObject():new())
		nPos := Len(aJson)
		aJson[nPos]['ZDB_IDDOC']:=doczdb[nL][1]
		aJson[nPos]['ZDB_REVISA']:=doczdb[nL][2]
        aJson[nPos]['ZDB_REVSUM']:=doczdb[nL][3]
		aJson[nPos]['ZDB_TITULO']:=doczdb[nL][4]
	next nL

	wrk:set(aJson)
	::SetResponse(wrk)


	FreeObj(aJson)
	FreeObj(wrk)
	lRet := .T.

return lRet


wsmethod post ws2 wsservice doczdbcabec

	Local lret := .T.
	Local oJson
	//Local cObs:=''
	Local cBody := ::getContent()
	Private cErrRest := ''

	oJson := JsonObject():new()
	oJson:fromJSON(cBody)


	sTipo:=oJson['ZDB_TIPO']
	sTitulo:=oJson['ZDB_TITULO']
	sElabor:=oJson['ZDB_ELABOR']
	sReviso:=oJson['ZDB_REVISO']
    //Busca o proximo iddoc do tipo
    siddoc:=getproxiddoc(sTipo)
    //busca a proxima 
    sRevisa:='0'


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

		conout("Operação Não Realizada")
	Else

		::SetResponse('{ "message": "Opera? realizada com sucesso","detailedMessage": "OK"}')

		self:setStatus(200)
		conout("Operação Realizada")

	Endif
	lRet := .T.

return lret

static function consultadoc(iddoc,revisa)
	Local cAlias
	Local aDoc := {}
	cAlias := getNextAlias()

	BeginSQL alias cAlias
	SELECT *
	FROM %TABLE:ZDB% ZDB 
	WHERE ZDB.D_E_L_E_T_<>'*' AND ZDB_FILIAL = %XFILIAL:ZDB%
    AND ZDB_IDDOC=%Exp:iddoc% 
    AND ZDB_REVISA=%Exp:revisa% 
	EndSQL
	//u_dbg_qry()

	While !(cAlias)->(Eof())
		aAdd(aDoc, {})
		aAdd(aDoc[len(aDoc)], alltrim((cAlias)->ZDB_IDDOC) )
		aAdd(aDoc[len(aDoc)],  alltrim((cAlias)->ZDB_REVISA))
        aAdd(aDoc[len(aDoc)],  alltrim((cAlias)->ZDB_REVSUM))
		aAdd(aDoc[len(aDoc)],  alltrim((cAlias)->ZDB_TITULO))

		(cAlias)->(dbSkip())
	enddo
	(cAlias)->(DbClosearea())


//	json_dbg(aRmaterial)

return aDoc


static function getproxiddoc(stipo)
Local cAlias
cAlias := getNextAlias()



return siddoc

