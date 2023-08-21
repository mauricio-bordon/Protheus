#include "protheus.ch"
#include "restful.ch"
#include 'rwmake.ch'
#Include "tbiconn.ch"
#include "topconn.ch"

wsrestful ws_estoque_report description "WS para Relatorios de estoque "
	WSDATA Page         AS INTEGER OPTIONAL
	WSDATA PageSize     AS INTEGER OPTIONAL
	WSDATA Order    AS CHARACTER OPTIONAL
	WSDATA Fields   AS CHARACTER OPTIONAL
	WSDATA tipo AS CHARACTER OPTIONAL
	WSDATA report AS CHARACTER OPTIONAL
	WSDATA aQueryString AS ARRAY OPTIONAL

	wsmethod get ws1;
		description "Consulta Saldos" ;
		wssyntax "/ws_estoque_report/v1/estoque/saldo" ;
		path "/ws_estoque_report/v1/estoque/saldo"


end wsrestful


wsmethod get ws1 wsservice ws_estoque_report
	local lRet as logical
	local aItem := {}
	Local aJson := {}
	local wrk

	self:SetContentType("application/json")

	u_json_dbg(::aQueryString)
	u_json_dbg(::Fields)


	aItem:= getSaldos(::tipo)

	wrk := JsonObject():new()

	self:setStatus(200)
	wrk['items'] := aItem
	//wrk:set(aJson)
	::SetResponse(wrk)


	FreeObj(aJson)
	FreeObj(wrk)
	lRet := .T.

return lRet

static function getSaldos(cTipo)
	Local cAlias, nPos, nPosSbf
	Local aItem := {}

	if alltrim(cTipo) <> ''
	endif
	cAlias := getNextAlias()


	BeginSQL alias cAlias
	SELECT B1_COD, RTRIM(B1_DESC) AS DESCRICAO, B1_UM, B2_QATU,
	 BF_LOCAL, BF_LOCALIZ, BF_LOTECTL, coalesce(BF_QUANT,0) as BF_QUANT
	FROM %TABLE:SB1% B1  INNER JOIN  %TABLE:SB2% B2 ON B1.B1_COD=B2.B2_COD
	LEFT JOIN %TABLE:SBF% BF ON B2.B2_COD=BF.BF_PRODUTO AND B2_LOCAL = BF_LOCAL AND BF.D_E_L_E_T_<>'*' AND BF_FILIAL = %XFILIAL:SBF%
	WHERE  B2.D_E_L_E_T_<>'*' AND B2_FILIAL = %XFILIAL:SBF%
		AND B1.D_E_L_E_T_<>'*' AND B1_FILIAL = %XFILIAL:SB1%
	ORDER BY B1_COD, BF_LOCAL,BF_LOCALIZ, BF_LOTECTL
	EndSQL
	u_dbg_qry()
	cKey := ''
	While !(cAlias)->(Eof())
		if cKey <> (cAlias)->B1_COD
			cKey := (cAlias)->B1_COD
			Aadd(aItem,JsonObject():new())
			nPos := Len(aItem)
			aItem[nPos]['codigo']		:= alltrim((cAlias)->B1_COD)
			aItem[nPos]['descricao']	:= encodeUTF8(alltrim((cAlias)->DESCRICAO), "cp1252")
			aItem[nPos]['um']			:= alltrim((cAlias)->B1_UM)
			aItem[nPos]['quantidade']	:= 0
			aItem[nPos]['items']		:= {}
		ENDIF


		Aadd(aItem[nPos]['items'],JsonObject():new())
		nPosSbf := Len(aItem[nPos]['items'])
		aItem[nPos]['items'][nPosSbf]['local']		:= alltrim((cAlias)->BF_LOCAL)
		aItem[nPos]['items'][nPosSbf]['localizacao']		:= alltrim((cAlias)->BF_LOCALIZ)
		aItem[nPos]['items'][nPosSbf]['lote']	:= alltrim((cAlias)->BF_LOTECTL)
		aItem[nPos]['items'][nPosSbf]['quantidade']	:= (cAlias)->BF_QUANT
		aItem[nPos]['quantidade'] +=  (cAlias)->BF_QUANT
		(cAlias)->(dbSkip())
	enddo
	(cAlias)->(DbClosearea())


//	json_dbg(aItem)

return aItem

