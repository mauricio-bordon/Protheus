#include "protheus.ch"
#include "restful.ch"
#include 'rwmake.ch'
#Include "tbiconn.ch"
#include "topconn.ch"

wsrestful documentouser description "WS para manipular usuario intra"
	wsdata ctipo as char optional


	wsmethod get ws1;
		description "Consulta usuario" ;
		wssyntax "/documentouser/lista" ;
		path "/documentouser/lista"


end wsrestful


wsmethod get ws1 wsservice documentouser
	local lRet as logical
	local iTemtipo := {}
	local nL
	Local aJson := {}
	local wrk

	self:SetContentType("application/json")

	iTemtipo:= consultauser()

	wrk := JsonObject():new()

	CONOUT("ENTROU 200")
	self:setStatus(200)
	for nL := 1 to len(iTemtipo)

		Aadd(aJson,JsonObject():new())
		nPos := Len(aJson)
		aJson[nPos]['value']:=iTemtipo[nL][1]
		aJson[nPos]['label']:=iTemtipo[nL][2]
	next nL

	wrk:set(aJson)
	::SetResponse(wrk)


	FreeObj(aJson)
	FreeObj(wrk)
	lRet := .T.

return lRet

static function consultauser()
	Local cAlias
	Local aTipo := {}
	cAlias := getNextAlias()

	BeginSQL alias cAlias
	SELECT *
	FROM %TABLE:ZUS% ZUS 
	WHERE ZUS.D_E_L_E_T_<>'*' AND ZUS_FILIAL = %XFILIAL:ZUS%
	EndSQL
	//u_dbg_qry()

	While !(cAlias)->(Eof())
		aAdd(aTipo, {})
		aAdd(aTipo[len(aTipo)], alltrim((cAlias)->ZUS_ID) )
		aAdd(aTipo[len(aTipo)], alltrim((cAlias)->ZUS_NOME)+" ( "+alltrim((cAlias)->ZUS_LOGIN)+')' )

		(cAlias)->(dbSkip())
	enddo
	(cAlias)->(DbClosearea())


//	json_dbg(aRmaterial)

return aTipo

