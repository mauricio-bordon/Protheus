#include "protheus.ch"
#include "restful.ch"
#include 'rwmake.ch'
#Include "tbiconn.ch"
#include "topconn.ch"

wsrestful ws_pcp_op description "WS para Ordens de Producao "
	WSDATA Page         AS INTEGER OPTIONAL
	WSDATA PageSize     AS INTEGER OPTIONAL
	WSDATA Order    AS CHARACTER OPTIONAL
	WSDATA Fields   AS CHARACTER OPTIONAL
	WSDATA maquina AS CHARACTER OPTIONAL
	WSDATA report AS CHARACTER OPTIONAL
	WSDATA aQueryString AS ARRAY OPTIONAL

	wsmethod get ws1;
		description "Lista Ordens" ;
		wssyntax "/ws_pcp_op/v1/op/" ;
		path "/ws_pcp_op/v1/op/"


end wsrestful


wsmethod get ws1 wsservice ws_pcp_op
	local lRet as logical
	local aItem := {}
	Local aJson := {}
	local wrk

	self:SetContentType("application/json")

	u_json_dbg(::aQueryString)
	u_json_dbg(::Fields)


	aItem:= getOps(::maquina)

	wrk := JsonObject():new()

	self:setStatus(200)
	wrk['items'] := aItem
	//wrk:set(aJson)
	::SetResponse(wrk)


	FreeObj(aJson)
	FreeObj(wrk)
	lRet := .T.

return lRet

static function getOps(cMaquina)
	Local cAlias, nPos
	Local aItem := {}

	if alltrim(cMaquina) <> ''
		cWhere := "% AND C2_MAQUINA = '"+cMaquina+"' %"
	ELSE
		cWhere := '% %'
	endif
	cAlias := getNextAlias()


	BeginSQL alias cAlias
	SELECT C2_NUM, C2_ITEM, C2_SEQUEN, C2_PRODUTO, RTRIM(B1_DESC) AS DESCRICAO,   C2_MAQUINA,
	C2_UM, C2_QUANT, C2_QUJE
	FROM %TABLE:SB1% B1  INNER JOIN  %TABLE:SC2% C2 ON B1.B1_COD=C2.C2_PRODUTO
	WHERE  C2.D_E_L_E_T_<>'*' AND C2_FILIAL = %XFILIAL:SC2%
		AND B1.D_E_L_E_T_<>'*' AND B1_FILIAL = %XFILIAL:SB1%
		AND C2_DATRF = '        '
		%EXP:cWhere%
	ORDER BY C2_NUM, C2_ITEM, C2_SEQUEN
	EndSQL
	u_dbg_qry()
	While !(cAlias)->(Eof())
		Aadd(aItem,JsonObject():new())
		nPos := Len(aItem)
		aItem[nPos]['numero']		:= alltrim((cAlias)->C2_NUM)
		aItem[nPos]['item']			:= alltrim((cAlias)->C2_ITEM)
		aItem[nPos]['sequencia']	:= alltrim((cAlias)->C2_SEQUEN)
		aItem[nPos]['produto']		:= alltrim((cAlias)->C2_PRODUTO)
		aItem[nPos]['descricao']	:= encodeUTF8(alltrim((cAlias)->DESCRICAO), "cp1252")
		aItem[nPos]['um']			:= alltrim((cAlias)->C2_UM)
		aItem[nPos]['quantidade']	:= (CALIAS)->C2_QUANT
		aItem[nPos]['qtd_produzida']:= (CALIAS)->C2_QUJE
		aItem[nPos]['maquina']		:= alltrim((cAlias)->C2_MAQUINA)
		(cAlias)->(dbSkip())
	enddo
	(cAlias)->(DbClosearea())


//	json_dbg(aItem)

return aItem

