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

static function getEstrutura(cOP)
	local aDados := {}
	Local cAlias := getNextalias()
	Local cProduto := ''
	Local nQuant := 0
	Local cRevisao := ''

	cProduto:=alltrim(POSICIONE('SC2',1,xFilial('SC2')+cOP,"C2_PRODUTO"))
	nQuant:=POSICIONE('SC2',1,xFilial('SC2')+cOP,"C2_QUANT")
	cRevisao:=POSICIONE('SC2',1,xFilial('SC2')+cOP,"C2_REVISAO")

	conout("Quantidade da OP: "+str(nQuant));

	BeginSql alias CALIAS

SELECT G1_COMP,
    SB1_COMP.B1_DESC,
    SB1_COMP.B1_UM,
    SB1_PROD.B1_QB,
    G1_QUANT,
(%EXP:nQuant% / SB1_PROD.B1_QB) * G1_QUANT NECESSARIO
FROM SG1010 SG1
    INNER JOIN SB1010 SB1_COMP ON SB1_COMP.B1_FILIAL = %xFilial:SB1%
    AND SB1_COMP.B1_COD = G1_COMP
    AND SB1_COMP.D_E_L_E_T_ = ' '
    INNER JOIN SB1010 SB1_PROD ON SB1_PROD.B1_FILIAL = %xFilial:SB1%
    AND SB1_PROD.B1_COD = G1_COD
    AND SB1_PROD.D_E_L_E_T_ = ' '
    INNER JOIN
	(
		SELECT D4_COD
		FROM SD4010
		WHERE D4_FILIAL = %xFilial:SD4%
		    AND D4_OP = %EXP:cOP%
			AND D_E_L_E_T_ = ' '
		GROUP BY D4_COD
	) AS SD4_SUB ON SD4_SUB.D4_COD = G1_COMP
WHERE G1_COD = %EXP:cProduto%
    AND G1_REVINI <= %EXP:cRevisao%
    AND G1_REVFIM >= %EXP:cRevisao%
    AND SG1.D_E_L_E_T_ = ' '

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
