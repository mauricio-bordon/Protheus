#include "protheus.ch"
#include "restful.ch"
#include 'rwmake.ch'
#Include "tbiconn.ch"
wsrestful doczdbcabec description "WS para manipular cabeçalho"
    wsdata tipo as char optional
	wsdata iddoc as char optional
    wsdata revisa as char optional


	wsmethod get ws1;
		description "Consulta cabeçalho do Doc" ;
		wssyntax "/doczdbcabec/gerencia" ;
		path "/doczdbcabec/gerencia"


	WSMETHOD post ws2;
		DESCRIPTION "Inclui ZDB cabeçalho" ;
		wssyntax "/doczdbcabec/novo";
		PATH "/doczdbcabec/novo"


end wsrestful


wsmethod get ws1 wsservice doczdbcabec
	local lRet as logical
	local doczdb := {}
	local nL
	Local aJson := {}
	local wrk
	//TODO : buscar usuario logado e listar apenas onde o usuario é elaborador ou revisor

	self:SetContentType("application/json")

	doczdb:= gerenciadoc()

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
		aJson[nPos]['ELABORADOR']:=doczdb[nL][5]
		aJson[nPos]['REVISOR']:=doczdb[nL][6]

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
    sRevisa:=oJson['ZDB_REVISA']
	sTitulo:=oJson['ZDB_TITULO']
	sElabor:=oJson['ZDB_ELABOR']
	sReviso:=oJson['ZDB_REVISO']

    //Busca o proximo iddoc do tipo
    siddoc:=getproxiddoc(sTipo)
    //busca a proxima 
    sRevisa:='0'


	conout('Adicionando linha.')
	lMsErroAuto := .F.
	 DBSELECTAREA( "ZDB" )
         ZDB->(RECLOCK('ZDB',.T.))
                ZDB->ZDB_FILIAL := xFilial('ZDB')
                ZDB->ZDB_TIPO  := sTipo
                ZDB->ZDB_IDDOC  := siddoc
                ZDB->ZDB_REVISA := sRevisa
                ZDB->ZDB_TITULO := sTitulo
                ZDB->ZDB_ELABOR := sElabor
                ZDB->ZDB_REVISO := sReviso
                ZDB->(MSUNLOCK())
       
    
    If lMsErroAuto
		//PEGAR ERRO

		ctitulo:="Erro na criação do documento. APP"
		cmsg:="Verificar no SIGAADV o log "+NomeAutoLog()
		conout(cMsg)

		::SetResponse('{ "message": "Erro ao requisitar produto","detailedMessage": "ERRO MATA241"}')

		self:setStatus(400)

		conout("Operação Não Realizada")
	Else

		::SetResponse('{ "message": "Realizada com sucesso","detailedMessage": "OK"}')

		self:setStatus(200)
		conout("Operação Realizada")

	Endif
	lRet := .T.

return lret

static function gerenciadoc()
	Local cAlias
	Local aDoc := {}
	cAlias := getNextAlias()

	BeginSQL alias cAlias
	
		SELECT ELAB.ZUS_NOME ELABORADOR,REVI.ZUS_NOME REVISOR
		,ZDB.*
		FROM %TABLE:ZDB% ZDB 
		LEFT JOIN %TABLE:ZUS% ELAB
		ON ELAB.ZUS_ID=ZDB_ELABOR
		LEFT JOIN %TABLE:ZUS% REVI
		ON REVI.ZUS_ID=ZDB_REVISO
		WHERE ZDB.D_E_L_E_T_<>'*' 
		AND ELAB.D_E_L_E_T_<>'*'
		AND REVI.D_E_L_E_T_<>'*'
		AND ZDB_FILIAL = %XFILIAL:ZDB%
    
	EndSQL
	u_dbg_qry()

	While !(cAlias)->(Eof())
		aAdd(aDoc, {})
		aAdd(aDoc[len(aDoc)], alltrim((cAlias)->ZDB_IDDOC) )
		aAdd(aDoc[len(aDoc)],  alltrim((cAlias)->ZDB_REVISA))
        aAdd(aDoc[len(aDoc)],  alltrim((cAlias)->ZDB_REVSUM))
		aAdd(aDoc[len(aDoc)],  alltrim((cAlias)->ZDB_TITULO))
		aAdd(aDoc[len(aDoc)],  alltrim((cAlias)->ELAB.ELABORADOR))
		aAdd(aDoc[len(aDoc)],  alltrim((cAlias)->REVI.REVISOR))

		(cAlias)->(dbSkip())
	enddo
	(cAlias)->(DbClosearea())


//	json_dbg(aRmaterial)

return aDoc


static function getproxiddoc(stipo)
Local cAlias
Local nTamanho := TamSX3('ZDB_IDDOC')[01]

cAlias := getNextAlias()
BeginSQL alias cAlias


	SELECT MAX(ZDB_IDDOC)+1 IDDOC
	FROM %TABLE:ZDB% ZDB 
	WHERE ZDB.D_E_L_E_T_<>'*' AND ZDB_FILIAL = %XFILIAL:ZDB%
    AND ZDB_TIPO=%Exp:stipo% 
	EndSQL
	
While !(cAlias)->(Eof())
    if (cAlias)->IDDOC==0
        siddoc  := PadL(1, nTamanho, '0')
    else
        siddoc  := PadL((cAlias)->IDDOC, nTamanho, '0')
    Endif
		(cAlias)->(dbSkip())
	enddo
	(cAlias)->(DbClosearea())




return siddoc

