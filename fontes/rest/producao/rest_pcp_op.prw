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
	WSDATA numero  AS CHARACTER OPTIONAL
	WSDATA item  AS CHARACTER OPTIONAL
	WSDATA sequencia  AS CHARACTER OPTIONAL
	WSDATA report AS CHARACTER OPTIONAL
	WSDATA aQueryString AS ARRAY OPTIONAL

	wsmethod get ws1;
		description "Lista Ordens" ;
		wssyntax "/ws_pcp_op/v1/op/" ;
		path "/ws_pcp_op/v1/op/"

	wsmethod get ws2;
		description "dados Ordem" ;
		wssyntax "/ws_pcp_op/v1/op/{numero}/{item}/{sequencia}" ;
		path "/ws_pcp_op/v1/op/{numero}/{item}/{sequencia}"	


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
	u_json_dbg(aItem)
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
		cWhere := "% AND RTRIM(C2_MAQUINA) <> '' %"
	endif
	cAlias := getNextAlias()


	BeginSQL alias cAlias
	SELECT C2_NUM, C2_ITEM, C2_SEQUEN, C2_PRODUTO, RTRIM(B1_DESC) AS DESCRICAO,   
	C2_MAQUINA, C2_PRIORID, C2_UM, C2_QUANT, C2_QUJE
	FROM %TABLE:SB1% B1  INNER JOIN  %TABLE:SC2% C2 ON B1.B1_COD=C2.C2_PRODUTO
		LEFT JOIN %TABLE:SH1% H1 ON H1.H1_CODIGO = C2_MAQUINA 
			AND H1.D_E_L_E_T_<>'*' AND H1_FILIAL = %XFILIAL:SH1%
	WHERE  C2.D_E_L_E_T_<>'*' AND C2_FILIAL = %XFILIAL:SC2%
		AND B1.D_E_L_E_T_<>'*' AND B1_FILIAL = %XFILIAL:SB1%
		AND C2_DATRF = '        '
		AND C2_ROTEIRO <> '  '
		AND C2_COLETOR='S'
		AND C2_PRIORID < 800
		%EXP:cWhere%
	ORDER BY C2_MAQUINA, C2_PRIORID,C2_NUM, C2_ITEM, C2_SEQUEN
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
		aItem[nPos]['prioridade']	:= (CALIAS)->C2_PRIORID
		(cAlias)->(dbSkip())
	enddo
	(cAlias)->(DbClosearea())


//	json_dbg(aItem)

return aItem

wsmethod get ws2 wsservice ws_pcp_op
	local lRet as logical
	local aItem := {}

	local wrk

	self:SetContentType("application/json")

	u_json_dbg(::aQueryString)
	u_json_dbg(::Fields)


	aItem:= getOp(::Numero, ::item, ::Sequencia)

	wrk := JsonObject():new()

	self:setStatus(200)
	wrk := aItem
	//wrk:set(aJson)
	::SetResponse(wrk)


	
	FreeObj(wrk)
	lRet := .T.

return lRet

static function getOp(cNumero, cItem, cSequencia)
	Local cAlias, cLotectl
	Local aItem := {}, aItem2 := {}, aLotes := {}

	
	cAlias := getNextAlias()


	BeginSQL alias cAlias
	SELECT C2_NUM, C2_ITEM, C2_SEQUEN, C2_PRODUTO, RTRIM(B1_DESC) AS DESCRICAO,   
	C2_MAQUINA, C2_PRIORID, C2_UM, C2_QUANT, C2_QUJE
	FROM %TABLE:SB1% B1  INNER JOIN  %TABLE:SC2% C2 ON B1.B1_COD=C2.C2_PRODUTO
		LEFT JOIN %TABLE:SH1% H1 ON H1.H1_CODIGO = C2_MAQUINA 
			AND H1.D_E_L_E_T_<>'*' AND H1_FILIAL = %XFILIAL:SH1%
	WHERE  C2.D_E_L_E_T_<>'*' AND C2_FILIAL = %XFILIAL:SC2%
		AND B1.D_E_L_E_T_<>'*' AND B1_FILIAL = %XFILIAL:SB1%
		AND C2_NUM = %EXP:cNumero% AND C2_ITEM = %EXP:cItem% AND C2_SEQUEN = %EXP:cSequencia%
	
	EndSQL
	u_dbg_qry()
	IF !(cAlias)->(Eof())
		aItem := JsonObject():new()
		aItem['numero']		:= alltrim((cAlias)->C2_NUM)
		aItem['item']			:= alltrim((cAlias)->C2_ITEM)
		aItem['sequencia']	:= alltrim((cAlias)->C2_SEQUEN)
		aItem['produto']		:= alltrim((cAlias)->C2_PRODUTO)
		aItem['descricao']	:= encodeUTF8(alltrim((cAlias)->DESCRICAO), "cp1252")
		aItem['um']			:= alltrim((cAlias)->C2_UM)
		aItem['quantidade']	:= (CALIAS)->C2_QUANT
		aItem['qtd_produzida']:= (CALIAS)->C2_QUJE
		aItem['maquina']		:= alltrim((cAlias)->C2_MAQUINA)
		aItem['prioridade']	:= (CALIAS)->C2_PRIORID
	ENDIF
	(cAlias)->(DbClosearea())

//Produções
	cAlias := getNextAlias()


	BeginSQL alias cAlias
	SELECT D3_LOTECTL, D3_QUANT 
	FROM %TABLE:SD3% D3 
	WHERE  D3.D_E_L_E_T_<>'*' AND D3_FILIAL = %XFILIAL:SD3%
		AND D3_OP = %EXP:cNumero+cItem+cSequencia% AND D3_CF = 'PR0'
		AND D3_ESTORNO <> 'S'
		order by 1 DESC
	EndSQL
	u_dbg_qry()
	WHILE !(cAlias)->(Eof())
		aItem2 := JsonObject():new()
		aItem2['LOTE']		:= alltrim((cAlias)->D3_LOTECTL)
		aItem2['QUANTIDADE']	:= (CALIAS)->D3_QUANT
		aAdd(aLotes, aItem2)
		conout('Lote: '+(cAlias)->D3_LOTECTL+'  = Quant: '+cvaltochar((CALIAS)->D3_QUANT))
		(cAlias)->(dbSkip())
	enddo
	(cAlias)->(DbClosearea())
	u_json_dbg(aLotes)
	aItem['producoes']	:= aLotes

	cAlias := getnextalias()

		BeginSql alias CALIAS
                SELECT MAX(D3_LOTECTL) AS LOTEMAX
                FROM %TABLE:SD3%
                WHERE D3_FILIAL = %XFILIAL:SD3% AND %NOTDEL%
                AND D3_OP = %EXP:cNumero+cItem+cSequencia%
                AND D3_CF = 'PR0'
                AND D3_ESTORNO <> 'S'
		EndSql
		if (CALIAS)->(EOF())
			nSeqOp := 0
		else
			nSeqOp := VAL( SUBSTR((CALIAS)->LOTEMAX,12,3) )
		endif
		(CALIAS)->(DBCLOSEAREA())
		nSeqOp++
		cLotectl := alltrim(cNumero+cItem+cSequencia) +  STRZERO(nSeqOp, 3)

	aItem['proximo_lote']	:= cLotectl
//	json_dbg(aItem)

return aItem

