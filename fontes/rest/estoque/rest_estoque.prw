#include "protheus.ch"
#include "restful.ch"
#include 'rwmake.ch'
#Include "tbiconn.ch"


wsrestful ws_estoque description "WS ESTOQUE"
	wsdata cBarcode as char OPTIONAL
	wsdata cProduto as char OPTIONAL
	wsdata cLote as char OPTIONAL
	wsdata cLocal as char OPTIONAL
	wsdata cLoclz as char OPTIONAL
	wsdata cLocDest as char OPTIONAL
	wsdata cLoclzDest as char OPTIONAL
	wsdata nQuant as char optional

	wsmethod get ws1;
		description "Valida Localização" ;
		wssyntax "/ws_estoque/v1/valida_sbe/{cBarcode}" ;
		path "/ws_estoque/v1/valida_sbe/{cBarcode}"

end wsrestful


wsmethod get ws1 wsservice ws_estoque
	local lRet as logical
	local lOk, cLocal, cLoclz
	Local oJson
	self:SetContentType("application/json")
	//::SetResponse('{"CODBAR":' + ::codBAR + ', "name":"sample"}')
// MP001009000011 ;20230329M027        ;2.750,000
    cLocal := left(::cBarcode,2)
	cLoclz := SUBSTR(alltrim(::cBarcode),3)
	lOk:= valida_sbe(cLocal, cLoclz)
	oJson := JsonObject():new()


	If !lOk
		::SetResponse('{ "code": "400", "message": "Local informado não existe.","detailedMessage": "Não existe a localização informada"}')

		self:setStatus(400)

	else
			oJson['BE_LOCAL']:=cLocal
			oJson['BE_LOCALIZ']:=cLoclz
		self:setStatus(200)
		::SetResponse(oJson)

	endif

	FreeObj(oJson)

	lRet := .T.

return lRet


static function valida_sbe(cLocal, cLoclz)
	Local cAlias
	Local cWhere := ''
	Local lOk := .F.

	cWhere := " AND BE_LOCAL = '"+cLocal+"' AND BE_LOCALIZ = '"+cLoclz+"' "
	
	cWhere := '%'+cWhere+'%'
	cAlias := getNextAlias()


	BeginSQL alias cAlias
	SELECT *
	FROM %TABLE:SBE% BE	
	WHERE BE.%NOTDEL% AND BE_FILIAL = %XFILIAL:SBE%
        %EXP:cWhere%
	EndSQL
	    
	u_dbg_qry()

	if !(cAlias)->(Eof())
		lOk := .T.
	ENDIF
	(cAlias)->(DbClosearea())


//	json_dbg(aRmaterial)

return lOk
