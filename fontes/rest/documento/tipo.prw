#include "protheus.ch"
#include "restful.ch"
#include 'rwmake.ch'
#Include "tbiconn.ch"
#include "topconn.ch"

wsrestful documentotipo description "WS para manipular tipo doc"
	wsdata ctipo as char optional


	wsmethod get ws1;
		description "Consulta tipo" ;
		wssyntax "/documentotipo/lista" ;
		path "/documentotipo/lista"


end wsrestful


wsmethod get ws1 wsservice documentotipo
	local lRet as logical
	local iTemtipo := {}
	local nL
	Local aJson := {}
	local wrk

	self:SetContentType("application/json")

	iTemtipo:= consultatipo()

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

static function consultatipo()
	Local cAlias
	Local aTipo := {}
	cAlias := getNextAlias()

	BeginSQL alias cAlias
	SELECT *
	FROM %TABLE:ZDA% ZDA 
	WHERE ZDA.D_E_L_E_T_<>'*' AND ZDA_FILIAL = %XFILIAL:ZDA%
	EndSQL
	//u_dbg_qry()

	While !(cAlias)->(Eof())
		aAdd(aTipo, {})
		aAdd(aTipo[len(aTipo)], alltrim((cAlias)->ZDA_TIPO) )
		aAdd(aTipo[len(aTipo)], alltrim((cAlias)->ZDA_TIPO)+" - "+alltrim((cAlias)->ZDA_DESC) )

		(cAlias)->(dbSkip())
	enddo
	(cAlias)->(DbClosearea())


//	json_dbg(aRmaterial)

return aTipo

