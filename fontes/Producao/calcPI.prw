#define NEWLINE chr(13)+chr(10)

/*
Calcular a quantidade necessária do PI a partir do PA correspondente, buscando:
- a quantidade nos pedidos de venda
- a quantidade das O.P.'s já abertas
- rotina acionada através de gatilho no campo C2_PRODUTO, ao incluir OP, ou no menu de contexto da MATA650
*/
user function calcPI(cPrefixo)
	local aArea := GetArea() //salva a área atual
	local cAlias := getNextalias()
	local nQtdPI := 0
	local nQtdProd := 0 //calcular cada largura de produto individualmente
	local nQtdPIAtual := 0 //quantidade já gerada para o PI
	Local cProduto := ''
	Local cCodPI := M->C2_PRODUTO
	Local nLargPI := 0
	Local nLargPA := 0
	Local nCarreiras := 0
	Local cMsg := ''
	Local cInfo := ''
	Local lError := .F.
	Local nLargCrt  := getmv('IC_PIFXCRT') // Largura padrão utilizada no corte - default 645
	Local cUM := 'm.' //unidade de medida - ATENÇÃO: esta rotina assume que todas as U.M. são iguais, em metros

	/*
	C5_LIBEROK	Liber. Total	Pedido Liberado Total	Utilizado pelo sistema.	C	1
	C6_QTDENT	Qtd.Entregue	Quantidade Entregue	Quantidade já entregue/faturada.
	C6_OP	OP Gerada	Flag de geracao de OP	Flag de geração da ordem de produção.
	C6_NUMOP	Numero OP	Num. da OP gerada por PV	Número da OP gerada autom
	C6_ITEMOP	Item da OP	Item da OP gerada por PV	Campo usado para amarrar o Pedido de Venda com a Ordem de Produção gerada para este.
	C2_STATUS	Situacao	Situacao da O.P.	Situação da Ordem de Produção, pode ser: U = Suspensa S = Sacramentada N = Normal
	*/

	cCodPI := 'PI' + substr(cPrefixo, 3, 4) + strzero(nLargCrt, 4)

	nLargPI := POSICIONE('SB1', 1, XFILIAL('SB1') + cCodPI, "B1_LARGURA") //Largura do PI

	if nLargPI == Nil
		FWAlertError("Largura do PI '" + cCodPI + "' não encontrada !", "Erro")
		return
	else
		if nLargPI <> nLargCrt
			cMsg:= "PI correspondente ao PA: " + cCodPI + " - Largura do PI: " + str(nLargPI) + NEWLINE
			cMsg += "Largura padrão utilizada no corte: " + str(nLargCrt) + NEWLINE
			cMsg += "Largura do PI diferente do padrão !"
			FWAlertError(cMsg, "Erro")
			return
		endif
	endif
	/*
	Procurar quantidade em PV ou OP para o PA correspondente ao PI
	TODO: flag pedido encerrado ?
	*/

	BeginSql alias cAlias

SELECT
	B1_LARGURA,
	B1_UM,
	C2_ITEM,
	C2_NUM,
	C2_QUANT,
	C2_SEQUEN,
	C6_ITEM,
	C6_NUM,
	C6_PRODUTO,
	C6_QTDVEN,
	E4_CTRADT,
	IIF(E4_CTRADT = '1', 3, 10) AS PERC_ACRES,
	IIF(
		C2_QUANT IS NULL,
		C6_QTDVEN * (1 + (IIF(E4_CTRADT = '1', 3, 10) / 100.0)),
		C2_QUANT * (1 + (IIF(E4_CTRADT = '1', 3, 10) / 100.0))
	) AS QUANT
	FROM %TABLE:SC6% SC6
    INNER JOIN %TABLE:SC5% SC5 ON C5_FILIAL = C6_FILIAL
    AND C5_NUM = C6_NUM
    AND C5_LIBEROK = ' '
	AND SC5.%NOTDEL%'

    INNER JOIN %TABLE:SB1% SB1 ON B1_FILIAL = %XFILIAL:SB1%
    AND B1_COD = C6_PRODUTO
    AND SB1.%NOTDEL%

    INNER JOIN %TABLE:SE4% SE4 ON E4_FILIAL = %XFILIAL:SE4%
    AND E4_CODIGO = C5_CONDPAG
    AND SE4.%NOTDEL%

    LEFT JOIN %TABLE:SC2% SC2 ON C2_FILIAL =  %XFILIAL:SC2%
    AND C2_NUM = C6_NUMOP
    AND C2_ITEM = C6_ITEMOP
    AND C2_PRODUTO = C6_PRODUTO
	AND SC2.%NOTDEL%
WHERE C6_FILIAL = %XFILIAL:SC6%
    AND C6_PRODUTO LIKE %EXP:cPrefixo%
    AND C6_QTDENT = 0
	AND SC6.%NOTDEL%
    AND (C2_DATRF IS NULL OR C2_DATRF = ' ')
    AND (C2_QUJE IS NULL OR C2_QUJE = 0)
    AND (C2_STATUS IS NULL OR C2_STATUS = 'N')
ORDER BY C6_PRODUTO, C6_NUM, C6_ITEM, C2_NUM, C2_ITEM, C2_SEQUEN

	EndSql

	aDados := GetLastQuery()
	u_dbg_qry("SomaQtd")

	nQtdPI := 0
	While !(cAlias)->(Eof())
		nQtdProd := 0
		nLargPA := (cAlias)->B1_LARGURA
		cProduto := (cAlias)->C6_PRODUTO
		if nLargPA == 0
			lError := .T.
			cMsg := "Largura do PA " + cProduto + " não cadastrada !"
			exit
		endif

		nCarreiras := Int(nLargPI / nLargPA)

		if cInfo <> ''
			cInfo += NEWLINE + NEWLINE
		endif
		cInfo += "Produto: " + cProduto + " - Carreiras: " + transform(nCarreiras, "@E 99") + NEWLINE + NEWLINE

		while cProduto == (cAlias)->C6_PRODUTO .and. !(cAlias)->(Eof())
			nQtdProd += (cAlias)->QUANT
			if empty((cAlias)->C2_NUM)
				cInfo += "PV: " + (cAlias)->C6_NUM + "/" + (cAlias)->C6_ITEM + " - Quantidade: " + transform((cAlias)->C6_QTDVEN, "@E 9,999,999") + " " + cUM + " - Acréscimo: " + transform((cAlias)->PERC_ACRES, "@E 99") + "%" + NEWLINE
			else
				cInfo += "OP: " + (cAlias)->C2_NUM + "/" + (cAlias)->C2_ITEM + "/" + (cAlias)->C2_SEQUEN  + " - Quantidade: " + transform((cAlias)->C2_QUANT, "@E 9,999,999") + " " + cUM + " - Acréscimo: " + transform((cAlias)->PERC_ACRES, "@E 99") + "%" + NEWLINE
			endif

			(cAlias)->(dbSkip())
		enddo

		nQtdPI += Ceiling(nQtdProd / nCarreiras)
	enddo

	(cAlias)->(DBCloseArea())

	RestArea(aArea)

	if lError
		FWAlertError(cMsg, "Erro")
		return M->C2_QUANT
	endif

	if cInfo <> ''
		cInfo += NEWLINE
	endif
	cInfo += "Qtd. total calculada: " + transform(nQtdPI, "@E 9,999,999") + " " + cUM


	nQtdPIAtual := qtdPI(cCodPI)

	if nQtdPI > 0
		if nQtdPIAtual > 0
			cInfo += NEWLINE + NEWLINE + "Quantidade do PI em O.P's já abertas: " +  transform(nQtdPIAtual, "@E 9,999,999") + " " + cUM + NEWLINE + NEWLINE
			cInfo += "A quantidade calculada não descontou a quantidade já gerada !!"
		endif
	else
		if nQtdPIAtual > 0
			cInfo := "Quantidade do PI em O.P's já abertas: " +  transform(nQtdPIAtual, "@E 9,999,999") + " " + cUM
		endif
	endif

	return {nQtdPI, nQtdPIAtual, cInfo}

/*
Calcular a quantidade de PI em O.P's já abertas
*/
static function qtdPI(cCodPI)
	local aArea := GetArea() //salva a área atual
	local cAlias := getNextalias()
	local nQtdPI := 0
	Local aDados := {}

	BeginSql alias cAlias
        SELECT SUM(C2_QUANT) C2_QUANT
        FROM %TABLE:SC2% SC2
        WHERE C2_FILIAL = %XFILIAL:SC2% AND SC2.%NOTDEL%
        AND C2_PRODUTO = %EXP:cCodPI%
        AND C2_DATRF = ' ' AND C2_QUJE = 0 AND C2_STATUS = 'N'
	EndSql

	aDados := GetLastQuery()
	u_dbg_qry("SomaQtd")

	if (cAlias)->(!EOF())
		nQtdPI := Iif((cAlias)->C2_QUANT == Nil, 0, (cAlias)->C2_QUANT)
	endif

	(cAlias)->(DBCloseArea())

	RestArea(aArea)

return nQtdPI
