#include "protheus.ch"
#include "restful.ch"
#include 'rwmake.ch'
#Include "tbiconn.ch"
#include "topconn.ch"

wsrestful faturamento description "WS para faturamento "
	WSDATA Page         AS INTEGER OPTIONAL
	WSDATA PageSize     AS INTEGER OPTIONAL
	WSDATA Order    AS CHARACTER OPTIONAL
	WSDATA Fields   AS CHARACTER OPTIONAL
	WSDATA data_inicio AS CHARACTER OPTIONAL
	WSDATA data_fim AS CHARACTER OPTIONAL
	WSDATA report AS CHARACTER OPTIONAL
	WSDATA aQueryString AS ARRAY OPTIONAL

	wsmethod get ws1;
		description "Consulta faturamento" ;
		wssyntax "/faturamento/list" ;
		path "/faturamento/list"


end wsrestful


wsmethod get ws1 wsservice faturamento
	local lRet as logical
	local aItem := {}
	Local aJson := {}
	local wrk

	self:SetContentType("application/json")

	u_json_dbg(::aQueryString)
	u_json_dbg(::Fields)


	if alltrim(::report) = 'cliente'
		aItem:= getFatCli(::data_inicio,::data_fim)
	elseif alltrim(::report) = 'produto'
		aItem:= getFatProd(::data_inicio,::data_fim)
	endif

	wrk := JsonObject():new()

	self:setStatus(200)
	wrk['items'] = aItem
	//wrk:set(aJson)
	::SetResponse(wrk)


	FreeObj(aJson)
	FreeObj(wrk)
	lRet := .T.

return lRet

static function getFatCli(sInicio,sFim)
	Local cAlias
	Local aItem := {}

	if alltrim(sInicio) == ''
		sInicio := dtos(dDatabase-30)
		sFim := dtos(dDatabase)
	elseif alltrim(sFim) == ''
		sFim := dtos(dDatabase)
	endif
	cAlias := getNextAlias()


	BeginSQL alias cAlias
	SELECT D2_CLIENTE, RTRIM(A1_NOME) AS A1_NOME,
		SUM(D2_QUANT) AS D2_QUANT, B1_UM, SUM(D2_QUANT * (B1_LARGURA/1000.0)) AS QUANT_M2, 
		SUM(D2_TOTAL) AS D2_TOTAL, 
		SUM(D2_TOTAL-D2_VALICM-D2_VALIMP5-D2_VALIMP6) AS FAT_LIQUIDO
	FROM %TABLE:SD2% D2 INNER JOIN %TABLE:SA1% A1 ON A1.A1_COD=D2.D2_CLIENTE
	INNER JOIN %TABLE:SB1% B1 ON B1.B1_COD=D2.D2_COD
	WHERE D2_EMISSAO BETWEEN %EXP:sInicio% AND %EXP:sFim% 
        AND D2.D_E_L_E_T_<>'*' AND D2_FILIAL = %XFILIAL:SBF%
        AND A1.D_E_L_E_T_<>'*' AND A1_FILIAL = %XFILIAL:SA1%
		AND B1.D_E_L_E_T_<>'*' AND B1_FILIAL = %XFILIAL:SB1%
		AND D2_TES IN (
			SELECT F4_CODIGO FROM %TABLE:SF4% 
			WHERE F4_DUPLIC = 'S' 
			AND D_E_L_E_T_<>'*' AND F4_FILIAL = %XFILIAL:SF4%
		)
	GROUP BY D2_CLIENTE, RTRIM(A1_NOME), B1_UM
	ORDER BY 1, 2
	EndSQL
	//u_dbg_qry()

	While !(cAlias)->(Eof())
		Aadd(aItem,JsonObject():new())
		nPos := Len(aItem)
		aItem[nPos]['codigo']		:= alltrim((cAlias)->D2_CLIENTE)
		aItem[nPos]['descricao']	:= alltrim((cAlias)->A1_NOME)
		aItem[nPos]['um']			:= alltrim((cAlias)->B1_UM)
		aItem[nPos]['quantidade']	:= (cAlias)->D2_QUANT
		aItem[nPos]['quantidade_M2']:= (cAlias)->QUANT_M2
		aItem[nPos]['valor_total']	:= (cAlias)->D2_TOTAL
		aItem[nPos]['valor_liquido']:= (cAlias)->FAT_LIQUIDO

		(cAlias)->(dbSkip())
	enddo
	(cAlias)->(DbClosearea())


//	json_dbg(aItem)

return aItem

static function getFatProd(sInicio,sFim)
	Local cAlias
	Local aItem := {}

	if alltrim(sInicio) == ''
		sInicio := dtos(dDatabase-30)
		sFim := dtos(dDatabase)
	elseif alltrim(sFim) == ''
		sFim := dtos(dDatabase)
	endif
	cAlias := getNextAlias()


	BeginSQL alias cAlias
	SELECT  LEFT(D2_COD,6) AS D2_COD , RTRIM(BM_DESC) AS BM_DESC, B1_UM, 
		SUM(D2_QUANT) AS D2_QUANT, SUM(D2_QUANT * (B1_LARGURA/1000.0)) AS QUANT_M2,  
		SUM(D2_TOTAL) AS D2_TOTAL, 
		SUM(D2_TOTAL-D2_VALICM-D2_VALIMP5-D2_VALIMP6) AS FAT_LIQUIDO
	FROM %TABLE:SD2% D2 INNER JOIN %TABLE:SB1% B1 ON B1.B1_COD=D2.D2_COD
		INNER JOIN %TABLE:SBM% BM ON B1.B1_GRUPO=BM.BM_GRUPO
	WHERE D2_EMISSAO BETWEEN %EXP:sInicio% AND %EXP:sFim% 
        AND D2.D_E_L_E_T_<>'*' AND D2_FILIAL = %XFILIAL:SBF%
        AND B1.D_E_L_E_T_<>'*' AND B1_FILIAL = %XFILIAL:SB1%
		AND D2_TES IN (
			SELECT F4_CODIGO FROM %TABLE:SF4% 
			WHERE F4_DUPLIC = 'S' 
			AND D_E_L_E_T_<>'*' AND F4_FILIAL = %XFILIAL:SF4%
		)
	GROUP BY D2_COD, B1_UM, RTRIM(B1_DESC)
	ORDER BY 1, 2
	EndSQL
	u_dbg_qry()

	While !(cAlias)->(Eof())
		Aadd(aItem,JsonObject():new())
		nPos := Len(aItem)
		aItem[nPos]['codigo']		:= alltrim((cAlias)->D2_COD)
		aItem[nPos]['descricao']	:= alltrim((cAlias)->BM_DESC)
		aItem[nPos]['um']			:= alltrim((cAlias)->B1_UM)
		aItem[nPos]['quantidade']	:= (cAlias)->D2_QUANT
		aItem[nPos]['quantidade_M2']:= (cAlias)->QUANT_M2
		aItem[nPos]['valor_total']	:= (cAlias)->D2_TOTAL
		aItem[nPos]['valor_liquido']:= (cAlias)->FAT_LIQUIDO

		(cAlias)->(dbSkip())
	enddo
	(cAlias)->(DbClosearea())


//	json_dbg(aItem)

return aItem

