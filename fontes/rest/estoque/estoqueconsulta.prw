#include "protheus.ch"
#include "restful.ch"
#include 'rwmake.ch'
#Include "tbiconn.ch"
#include "topconn.ch"

wsrestful estoqueconsulta description "WS para listar materiais necessario Rack 02 para o LP "
	wsdata cLocaliz as char optional
	wsdata cLocal as char optional


	wsmethod get ws1;
		description "Consulta estoque pelo Rack" ;
		wssyntax "/estoqueconsulta/listrack/{cLocal}/{cLocaliz}" ;
		path "/estoqueconsulta/listrack/{cLocal}/{cLocaliz}"


end wsrestful


wsmethod get ws1 wsservice estoqueconsulta
	local lRet as logical
	local iTemprod := {}
	local nL
	Local aJson := {}
	local wrk
	
	self:SetContentType("application/json")

	cLocal := alltrim(::cLocal)
	cLocaliz := alltrim(::cLocaliz)
	
	


	iTemprod:= consultarack(cLocal,cLocaliz)


	wrk := JsonObject():new()

	If Len(iTemprod) == 0
	Aadd(aJson,JsonObject():new())
			nPos := Len(aJson)
		
			aJson[nPos]['PRODUTO']:=''
			aJson[nPos]['LOCALIZACAO']:=''
			aJson[nPos]['LOTE']:=''
			aJson[nPos]['QUANTIDADE']:=0
			aJson[nPos]['LOCAL']:=''
			aJson[nPos]['POSICAO']:=''
			aJson[nPos]['DESCRICAO']:=''
			aJson[nPos]['SALDO']:=0

		self:setStatus(200)

	else

		CONOUT("ENTROU 200")
		self:setStatus(200)
		for nL := 1 to len(iTemprod)

			Aadd(aJson,JsonObject():new())
			nPos := Len(aJson)
			aJson[nPos]['PRODUTO']:=iTemprod[nL][1]
			aJson[nPos]['LOTE']:=iTemprod[nL][2]
			aJson[nPos]['DESCRICAO']:=iTemprod[nL][3]
			aJson[nPos]['QUANTIDADE']:=iTemprod[nL][4]
			aJson[nPos]['EMPENHO']:=iTemprod[nL][5]
			aJson[nPos]['LOCAL']:=iTemprod[nL][6]
			aJson[nPos]['LOCALIZACAO']:=iTemprod[nL][7]
			aJson[nPos]['POSICAO']:=right(iTemprod[nL][7],1)
			aJson[nPos]['UM']:=iTemprod[nL][8]
			aJson[nPos]['SALDO']:=iTemprod[nL][9]			
		next nL
	
	endif
		wrk:set(aJson)
		::SetResponse(wrk)


	FreeObj(aJson)
	FreeObj(wrk)
	lRet := .T.

return lRet

static function consultarack(clocal,cLocaliz)
	Local cAlias
	Local aRmaterial := {}
	cAlias := getNextAlias()


	BeginSQL alias cAlias
	SELECT BF_PRODUTO, B1_UM, B1_TIPO, BF_QUANT,BF_LOCAL, BF_LOCALIZ,BF_LOTECTL, BF_EMPENHO, RTRIM(REPLACE(B1_DESC,'"','''')) as  B1_DESC
	FROM %TABLE:SBF% BF INNER JOIN %TABLE:SB1% B1 ON B1.B1_COD=BF.BF_PRODUTO
	WHERE BF_LOCAL=%Exp:cLocal% 
		AND BF_LOCALIZ=%Exp:cLocaliz% 
        AND BF.D_E_L_E_T_<>'*' AND BF_FILIAL = %XFILIAL:SBF%
        AND B1.D_E_L_E_T_<>'*' AND B1_FILIAL = %XFILIAL:SB1%
		AND BF_EMPENHO = 0
	ORDER BY 1, BF_LOCAL, BF_LOCALIZ
	EndSQL
	//u_dbg_qry()

	While !(cAlias)->(Eof())
		aAdd(aRmaterial, {})
		aAdd(aRmaterial[len(aRmaterial)], alltrim((cAlias)->BF_PRODUTO) )
		aAdd(aRmaterial[len(aRmaterial)], alltrim((cAlias)->BF_LOTECTL) )
		aAdd(aRmaterial[len(aRmaterial)], alltrim((cAlias)->B1_DESC) )
		aAdd(aRmaterial[len(aRmaterial)], (cAlias)->BF_QUANT )
		aAdd(aRmaterial[len(aRmaterial)], (cAlias)->BF_EMPENHO )
		aAdd(aRmaterial[len(aRmaterial)], (cAlias)->BF_LOCAL )
		aAdd(aRmaterial[len(aRmaterial)], (cAlias)->BF_LOCALIZ )
		aAdd(aRmaterial[len(aRmaterial)], alltrim((cAlias)->B1_UM) )
		aAdd(aRmaterial[len(aRmaterial)], (cAlias)->BF_QUANT )

		(cAlias)->(dbSkip())
	enddo
	(cAlias)->(DbClosearea())


//	json_dbg(aRmaterial)

return aRmaterial

