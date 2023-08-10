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
    WSDATA aQueryString AS ARRAY OPTIONAL

	wsmethod get ws1;
		description "Consulta faturamento" ;
		wssyntax "/faturamento/list" ;
		path "/faturamento/list"


end wsrestful


wsmethod get ws1 wsservice faturamento
	local lRet as logical
	local aItem := {}
	local nL
	Local aJson := {}
	local wrk
	
	self:SetContentType("application/json")

	u_json_dbg(::aQueryString)
	u_json_dbg(::Fields)



	aItem:= getFaturamento(::data_inicio,::data_fim)


	wrk := JsonObject():new()

	If Len(aItem) == 0
	Aadd(aJson,JsonObject():new())
			nPos := Len(aJson)
		
			aJson[nPos]['cliente']:=''
			aJson[nPos]['produto']:=''
			aJson[nPos]['um']:=''
			aJson[nPos]['quantidade']:=0
			aJson[nPos]['valor_total']:=0
			aJson[nPos]['valor_liquido']:=0

		self:setStatus(200)

	else

		CONOUT("ENTROU 200")
		self:setStatus(200)
		for nL := 1 to len(aItem)

			Aadd(aJson,JsonObject():new())
			nPos := Len(aJson)
			aJson[nPos]['cliente']:=aItem[nL][1]
			aJson[nPos]['produto']:=aItem[nL][2]
			aJson[nPos]['um']:=aItem[nL][3]
			aJson[nPos]['quantidade']:=aItem[nL][4]
			aJson[nPos]['valor_total']:=aItem[nL][5]
			aJson[nPos]['valor_liquido']:=aItem[nL][6]
		//	aJson[nPos]['LOCALIZACAO']:=aItem[nL][7]
		//	aJson[nPos]['POSICAO']:=right(aItem[nL][7],1)
		//	aJson[nPos]['UM']:=aItem[nL][8]
		//	aJson[nPos]['SALDO']:=aItem[nL][9]			
		next nL
	
	endif
		wrk['items'] = aJson
		//wrk:set(aJson)
		::SetResponse(wrk)


	FreeObj(aJson)
	FreeObj(wrk)
	lRet := .T.

return lRet

static function getFaturamento(sInicio,sFim)
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
	SELECT D2_CLIENTE, D2_COD, B1_UM, 
		SUM(D2_QUANT) AS D2_QUANT, SUM(D2_TOTAL) AS D2_TOTAL, 
		SUM(D2_TOTAL-D2_VALICM-D2_VALIMP5-D2_VALIMP6) AS FAT_LIQUIDO
	FROM %TABLE:SD2% D2 INNER JOIN %TABLE:SB1% B1 ON B1.B1_COD=D2.D2_COD
	WHERE D2_EMISSAO BETWEEN %EXP:sInicio% AND %EXP:sFim% 
        AND D2.D_E_L_E_T_<>'*' AND D2_FILIAL = %XFILIAL:SBF%
        AND B1.D_E_L_E_T_<>'*' AND B1_FILIAL = %XFILIAL:SB1%
		AND D2_TES IN (
			SELECT F4_CODIGO FROM %TABLE:SF4% 
			WHERE F4_DUPLIC = 'S' 
			AND D_E_L_E_T_<>'*' AND F4_FILIAL = %XFILIAL:SF4%
		)
	GROUP BY D2_CLIENTE, D2_COD, B1_UM
	ORDER BY 1, 2
	EndSQL
	//u_dbg_qry()

	While !(cAlias)->(Eof())
		aAdd(aItem, {})
		aAdd(aItem[len(aItem)], alltrim((cAlias)->D2_CLIENTE) )
		aAdd(aItem[len(aItem)], alltrim((cAlias)->D2_COD) )
		aAdd(aItem[len(aItem)], alltrim((cAlias)->B1_UM) )
		aAdd(aItem[len(aItem)], (cAlias)->D2_QUANT )
		aAdd(aItem[len(aItem)], (cAlias)->D2_TOTAL )
		aAdd(aItem[len(aItem)], (cAlias)->FAT_LIQUIDO )
		//aAdd(aItem[len(aItem)], (cAlias)->BF_LOCAL )
		//aAdd(aItem[len(aItem)], (cAlias)->BF_LOCALIZ )
	//	//aAdd(aItem[len(aItem)], alltrim((cAlias)->B1_UM) )
	//	aAdd(aItem[len(aItem)], (cAlias)->BF_QUANT )

		(cAlias)->(dbSkip())
	enddo
	(cAlias)->(DbClosearea())


//	json_dbg(aItem)

return aItem

