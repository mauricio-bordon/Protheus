#include "protheus.ch"
#include "restful.ch"
#include 'rwmake.ch'
#Include "tbiconn.ch"
#include "topconn.ch"

wsrestful ws_pcp_estrutura description "WS retorna a estrutura do produto"
	wsdata cOP as char optional

	wsmethod get ws1;
		description "Lista material necessario para ordem" ;
		wssyntax "/ws_pcp_estrutura/busca/{cOP}";
		path "/ws_pcp_estrutura/busca/{cOP}"

end wsrestful

wsmethod get ws1 wsservice ws_pcp_estrutura
	Local lGet := .T.
	Local aJson := {}


	self:SetContentType("application/json")
	aDados := getEstrutura(::cOp)

	self:setStatus(200)
	::SetResponse(aDados)


	FreeObj(aJson)


Return lGet

static function getEstrutura(COP)
	local aDados := {}
	Local cAlias := getNextalias()

	cProduto:=alltrim(POSICIONE('SC2',1,XFILIAL('SC2')+COP,"C2_PRODUTO"))
	nQuant:=POSICIONE('SC2',1,XFILIAL('SC2')+COP,"C2_QUANT")

	conout("Quantidade da OP: "+str(nQuant));
		BeginSql alias CALIAS

		SELECT G1_COMP,B1.B1_DESC,B1.B1_UM,B12.B1_QB,G1_QUANT,(%EXP:nQuant% / B12.B1_QB)*G1_QUANT NECESSARIO 
		FROM SG1010 G1
		INNER JOIN SB1010 B1
		ON B1.B1_COD=G1_COMP
		INNER JOIN SB1010 B12
		ON B12.B1_COD=G1_COD
		WHERE G1_COD=%EXP:cProduto%
		AND G1.D_E_L_E_T_<>'*'
		AND B1.D_E_L_E_T_<>'*'
		AND B12.D_E_L_E_T_<>'*'
	EndSQL
	u_dbg_qry()


	WHILE !(cAlias)->(Eof())

		Aadd(aDados,JsonObject():new())
		nPos := Len(aDados)

		aDados[nPos]['CODIGO']		:= alltrim((cAlias)->G1_COMP)
		aDados[nPos]['DESCRICAO']	:= alltrim((cAlias)->B1_DESC)
		aDados[nPos]['UM']			:= alltrim((cAlias)->B1_UM)
		aDados[nPos]['NECESSARIO']	:= (cAlias)->NECESSARIO

		(cAlias)->(dbSkip())
	enddo

	(cAlias)->(DbClosearea())




return aDados
