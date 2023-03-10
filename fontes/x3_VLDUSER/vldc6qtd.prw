#Include "TOTVS.ch"

/*
X3_VLDUSER --> C6_QTDVEN

sE PRODUTO PA (Selo de Indução), VALIDA SE QUANTIDADE DIGITADA É PROPPORCIONAL AO QUE SERÁ CORTADO
*/
user function vldc6qtd()

	local nPosMtRolo:= ascan(aHeader, {|aH| alltrim(aH[2]) == "C6_MTROLO"})
	local nMtRolo   := aCols[N, nPosMtRolo]

	local nC6_TES:= ascan(aHeader, {|aH| alltrim(aH[2]) == "C6_TES"})
	local cC6_TES:= aCols[N, nC6_TES]

	local nPosProd  := ascan(aHeader, {|aH| alltrim(aH[2]) == "C6_PRODUTO"})
	local cProduto  := aCols[N, nPosProd]
	local nLargProd := POSICIONE('SB1',1, xfilial("SB1")+cProduto,"B1_LARGURA") // Largura do Produto

	local nLargPI   := getmv('IC_PIFXCRT')                                      //Largura do PI para corte

	local nRolosCrt                                 // Numero de rolos para corte

	local nMtTirada

	local nPosQtdVen := ascan(aHeader, {|aH| alltrim(aH[2]) == "C6_QTDVEN"})
	local nQtdVen := aCols[N, nPosQtdVen]


	if left(cProduto,2) <> 'PA'
		return .T.
	endif

	if nMtRolo == 0
		MsgStop('Informe a metragem linear do rolo.', 'Aviso')
		return .F.
	endif

	nRolosCrt:= int(nLargPI / nLargProd)
	nMtTirada := nRolosCrt * nMtRolo
	if INCLUI .and. cC6_TES != '502'
		if mod(nQtdVen, nMtTirada) <> 0 //Se Rolos digitados não for multiplo avisa
			MsgStop('Quantidade em Metros Lineares digitada não é múltiplo dos metros lineares da tirada. ('+CValToChar(nMtTirada)+')', 'Aviso')
			return .F.
		endif
	ENDIF

return .T.
