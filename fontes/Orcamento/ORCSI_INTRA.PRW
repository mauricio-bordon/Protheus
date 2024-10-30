//Bibliotecas
#Include "TOTVS.ch"
#Include "TopConn.ch"
#Include "RPTDef.ch"
#Include "FWPrintSetup.ch"

//Alinhamentos
#Define PAD_LEFT    0
#Define PAD_RIGHT   1
#Define PAD_CENTER  2


//Cores
#Define COR_RED   RGB(204, 10, 10)

Static nCorCinza := RGB(204, 204, 204)
Static nCorAz1  := RGB(168, 189, 220)
Static nCorAz2  := RGB(90, 142, 220)


USER FUNCTION ORCSIINTRA(sA1_COD)
	Local  nLine, nIncline := 40, cFilename := ''
	Local dHoje:=Date()
	Local aArquivos := {}
	Local lRet:=.T.
	Local nprecoBase25
	Private codcliente:=sA1_COD
	Private lOBSERVACAO:=.F.
	//Declarando as fontes
	Private cNomeFont  	:= "Arial"
	Private nSize1		:= 12, nSize2 := 12, nSize3 := 10, nSize4 := 10 , nSize0 := 10

	Private oFont0   	:= TFont():New(cNomeFont, 9, nSize0, .T., .F., 5, .T., 5, .T., .F., .F.)
	Private oFont0v   	:= TFont():New(cNomeFont, 9, nSize0, .T., .F., 5, .T., 5, .T., .F., .F.)
	Private oFont0B   	:= TFont():New(cNomeFont, 9, nSize0, .T., .T., 5, .T., 5, .T., .F., .F.)
	Private oFont0U   	:= TFont():New(cNomeFont, 9, nSize0, .T., .F., 5, .T., 5, .T., .T., .F.)
	Private oFont0I   	:= TFont():New(cNomeFont, 9, nSize0, .T., .F., 5, .T., 5, .T., .F., .T.)


	Private oFont1   	:= TFont():New(cNomeFont, 9, nSize1, .T., .F., 5, .T., 5, .T., .F., .F.)
	Private oFont1v   	:= TFont():New(cNomeFont, 9, nSize1, .T., .F., 5, .T., 5, .T., .F., .F.)
	Private oFont1B   	:= TFont():New(cNomeFont, 9, nSize1, .T., .T., 5, .T., 5, .T., .F., .F.)
	Private oFont1U   	:= TFont():New(cNomeFont, 9, nSize1, .T., .F., 5, .T., 5, .T., .T., .F.)
	Private oFont1I   	:= TFont():New(cNomeFont, 9, nSize1, .T., .F., 5, .T., 5, .T., .F., .T.)

	Private oFont2   	:= TFont():New(cNomeFont, 9, nSize2, .T., .F., 5, .T., 5, .T., .F., .F.)
	Private oFont2B   	:= TFont():New(cNomeFont, 9, nSize2, .T., .T., 5, .T., 5, .T., .F., .F.)
	Private oFont2U   	:= TFont():New(cNomeFont, 9, nSize2, .T., .F., 5, .T., 5, .T., .T., .F.)
	Private oFont2I   	:= TFont():New(cNomeFont, 9, nSize2, .T., .F., 5, .T., 5, .T., .F., .T.)

	Private oFont3   	:= TFont():New(cNomeFont, 9, nSize3, .T., .F., 5, .T., 5, .T., .F., .F.)
	Private oFont3B   	:= TFont():New(cNomeFont, 9, nSize3, .T., .T., 5, .T., 5, .T., .F., .F.)
	Private oFont3U   	:= TFont():New(cNomeFont, 9, nSize3, .T., .F., 5, .T., 5, .T., .T., .F.)
	Private oFont3I   	:= TFont():New(cNomeFont, 9, nSize3, .T., .F., 5, .T., 5, .T., .F., .T.)

	Private oFont4   	:= TFont():New(cNomeFont, 9, nSize4, .T., .F., 5, .T., 5, .T., .F., .F.)
	Private oFont4B   	:= TFont():New(cNomeFont, 9, nSize4, .T., .T., 5, .T., 5, .T., .F., .F.)
	Private oFont4U   	:= TFont():New(cNomeFont, 9, nSize4, .T., .F., 5, .T., 5, .T., .T., .F.)
	Private oFont4I   	:= TFont():New(cNomeFont, 9, nSize4, .T., .F., 5, .T., 5, .T., .F., .T.)

	Private oBruAz1 := TBrush():New( , nCorAz1)
	Private oBruAz2 := TBrush():New( , nCorAz2)
	Private nColIni	 	:=  20, nColFim := 2960
	PRIVATE oTpImpr := JsonObject():new()

	oTpImpr['SI'] := "Sem Impressão"
	oTpImpr['ID'] := "Impresso Dedicado"
	oTpImpr['IS'] := "Impresso Standard"


	lAdjustToLegacy := .t.
	lDisableSetup  := .T.
	cPathInServer:='/cartaproposta/'
	lViewPDF := .F.

	cFileName := 'orc_'+DTOS(DDATABASE)+'_'+sA1_COD

	// Verifica se o arquivo já existe
	If File(cPathInServer+cFileName+'.pdf')
		// Se existir, exclui o arquivo
		FErase(cPathInServer+cFileName+'.pdf')
	EndIf
	oPrinter := FWMSPrinter():New(cFileName+".rel", IMP_PDF, lAdjustToLegacy, cPathInServer, lDisableSetup, , , , , , .F.,lViewPDF)// Ordem obrigátoria de configuração do relatório
	oPrinter:SetResolution(72)
	oPrinter:SetLandscape()
	oPrinter:SetPaperSize(DMPAPER_A4)
	oPrinter:SetMargin(nColIni , nColIni, nColIni , nColIni) // nEsquerda, nSuperior, nDireita, nInferior
	oPrinter:SetParm( "-RFS")
	oPrinter:cPathPDF := "/cartaproposta/" // Caso seja utilizada impressão em IMP_PDF

	oPrinter:StartPage()
	nColIni	 :=  25
	nLine 	:= 200
	oPrinter:SayBitmap( nLine, nColFim - 450,"/imagens/logoind3.bmp",437,212)



	//oPrinter:Line( n_line, 045, n_line,2275 )

	oPrinter:Say( nLine, nColIni, ALLTRIM(diasemext(dHoje))+', '+ CValToChar(DAY(dHoje)) + ' de '+ MESEXTENSO(month(dHoje)) + ' de ' + cvaltochar(year(dHoje)) , oFont1)
	nLine += nIncLine * 2
	oPrinter:Say( nLine, nColIni, 'À' , oFont1)
	nLine += nIncLine
	oPrinter:Say( nLine, nColIni, ALLTRIM(POSICIONE('SA1', 1, XFILIAL('SA1')+sA1_COD, 'A1_NOME')) , oFont1B)
	nLine += nIncLine * 2
	oPrinter:Say( nLine, nColIni, 'Att. '+ ALLTRIM(POSICIONE('SA1', 1, XFILIAL('SA1')+sA1_COD, 'A1_CONTATO')) + '.' , oFont1B)
	nLine += nIncLine
	oPrinter:Say( nLine, nColIni,  ALLTRIM(POSICIONE('SA1', 1, XFILIAL('SA1')+sA1_COD, 'A1_MAILVEN'))  , oFont1U)
	//oPrinter:Fillrect( {nLine, nColIni, nLine + nIncline, nColFim }, oBruAz1)
	nLine += nIncLine
//	oPrinter:Say(nLine, nColFim - 450,   "Carta Proposta ", oFont1B)
	//oPrinter:Line( nLine, nColIni, nLine, nColFim )
//	nLine += nIncLine

//	oPrinter:Say( nLine, nColIni, 'Selo de Indução' , oFont1)
	nLine += nIncLine

	cAlias := getNextAlias()

	BEGINSQL alias CALIAS


		SELECT CLIENTE,LARGURA_CORTE,BM_DESC,PRECO_BASE,ICMS,BM_IPI,QUANTIDADE_COMPRA,METROS_LINEARES,NUM_ROLOS,OBSERVACAO
		FROM PRODUTOCLIENTE
		INNER JOIN SBM010 BM
		ON BM_GRUPO=PRODUTO
		WHERE BM.D_E_L_E_T_<>'*'
		AND DELETED_AT IS NULL
		AND CLIENTE=%EXP:sA1_COD%
		AND PROPOSTA='S'

	ENDSQL

	nColItem 	:=  80
	nColQtdVol	:= 180
	nColUn		:= 120
	nColMatDesc	:= 520
	nColTpSelo 	:= 300
	nColCores	:= 150
	nColLargFx	:= 180
	nColObs		:= 750
	nColPrcLiq	:= 270
	nColPrcImp 	:= 370
	nColIPI		:= 380
	nColValvolume:= 750

	nColPos 	:=  nColIni
	oPrinter:Fillrect( {nLine, nColPOs, nLine + nIncLine * 2, nColFim }, oBruAz1)
	oPrinter:Line( nLine + nIncLine * 2, nColIni, nLine + nIncLine * 2, nColFim )

	oPrinter:SayAlign(nLine, nColPos, 'Item', oFont3b, nColItem, nIncLine * 2, , PAD_CENTER, 0)
	nColPos += nColItem

	//oPrinter:SayAlign(nLine, nColPos, 'Quantidade', oFont3b, nColQtdVol, nIncLine, , PAD_CENTER, 0)
	//oPrinter:SayAlign(nLine + nIncLine, nColPos, '(volume)', oFont3b, nColQtdVol, nIncLine, , PAD_CENTER, 0)
	//nColPos += nColQtdVol

	oPrinter:SayAlign(nLine, nColPos, 'Unidade', oFont3b, nColUn, nIncLine * 2, , PAD_CENTER, 0)
	nColPos += nColUn

	oPrinter:SayAlign(nLine, nColPos, 'Material/Descrição', oFont3b, nColMatDesc, nIncLine * 2, , PAD_CENTER, 0)
	nColPos += nColMatDesc

	//oPrinter:SayAlign(nLine, nColPos, 'Tipo de Selo', oFont3b, nColTpSelo, nIncLine * 2, , PAD_CENTER, 0)
	//nColPos += nColTpSelo

	//oPrinter:SayAlign(nLine, nColPos, 'Nº Cores', oFont3b, nColCores, nIncLine * 2, , PAD_CENTER, 0)
	//nColPos += nColCores

	oPrinter:SayAlign(nLine, nColPos, 'Largura/Faixa (mm)', oFont3b, nColLargFx, nIncLine * 2, , PAD_CENTER, 0)
	nColPos += nColLargFx

	//oPrinter:SayAlign(nLine, nColPos, 'Observação', oFont3b, nColObs, nIncLine * 2, , PAD_CENTER, 0)
	//nColPos += nColObs

	oPrinter:SayAlign(nLine, nColPos, 'Preço Líquido', oFont3b, nColPrcLiq, nIncLine, , PAD_CENTER, 0)
	oPrinter:SayAlign(nLine + nIncLine, nColPos, '(MT)', oFont3b, nColPrcLiq, nIncLine, , PAD_CENTER, 0)
	nColPos += nColPrcLiq

	oPrinter:SayAlign(nLine, nColPos, 'Preço com ICMS\PIS\COFINS', oFont3b, nColPrcImp, nIncLine, , PAD_CENTER, 0)
	oPrinter:SayAlign(nLine + nIncLine, nColPos, '(MT)', oFont3b, nColPrcImp, nIncLine, , PAD_CENTER, 0)
	nColPos += nColPrcImp

	oPrinter:SayAlign(nLine, nColPos, 'IPI', oFont3b, nColIPI, nIncLine * 2, , PAD_CENTER, 0)
	nColPos += nColIPI

	oPrinter:SayAlign(nLine, nColPos, 'Valor por volume com ICMS\PIS\COFINS (MT)', oFont3b, nColObs, nIncLine * 2, , PAD_LEFT, 0)
	nColPos += nColObs

	/*

	oPrinter:SayAlign(nLine , 1800,   "Preço com Impostos", oFont1B, 500, 35, , PAD_CENTER, 0)
	oPrinter:SayAlign(nLine +  nIncline , 1800,   "(Metros Lineares)", oFont1B, 500, 35, , PAD_CENTER, 0)
	*/
	nLine += nIncLine  * 2

	WHILE (CALIAS)->(!EOF())
		nColPos 	:=  nColIni
		nMultLine := 2
		nColPos += nColItem

		nMtTirada := (CALIAS)->NUM_ROLOS * (CALIAS)->METROS_LINEARES

		if (calias)->QUANTIDADE_COMPRA>nMtTirada


			oPrinter:SayAlign(nLine, nColPos, 'MT', oFont1, nColUn, nIncLine * nMultLine, , PAD_CENTER, 0)
			nColPos += nColUn
			nColOBSProd:=nColPos
			oPrinter:SayAlign(nLine, nColPos, (calias)->BM_DESC, oFont3, nColMatDesc, nIncLine * nMultLine, , PAD_LEFT, 0)
			nColPos += nColMatDesc

			oPrinter:SayAlign(nLine, nColPos,  transform((calias)->LARGURA_CORTE, "@E 999.99"), oFont1, nColLargFx, nIncLine * nMultLine, , PAD_CENTER, 0)
			nColPos += nColLargFx

			oPrinter:SayAlign(nLine, nColPos,  'R$ '+transform((calias)->PRECO_BASE, "@E 999.9999"), oFont1, nColPrcLiq, nIncLine * nMultLine, , PAD_CENTER, 0)
			nColPos += nColPrcLiq

			// calcular impostos
			nFatIcms:=(100-(calias)->ICMS)/100
			nPrecoImpostos := ( (calias)->PRECO_BASE / nFatIcms ) /  0.9075
			nPrecoImpostos:= NoRound(nPrecoImpostos, 4)
			oPrinter:SayAlign(nLine, nColPos,  'R$ '+transform(nPrecoImpostos, "@E 999.9999"), oFont1, nColPrcImp, nIncLine * nMultLine, , PAD_CENTER, 0)
			nColPos += nColPrcImp

			oPrinter:SayAlign(nLine, nColPos, TRANSFORM((CALIAS)->BM_IPI, "@E 999.99")+' %', oFont1, nColIPI, nIncLine * nMultLine, , PAD_CENTER, 0)
			nColPos += nColIPI




			oPrinter:SayAlign(nLine, nColPos, " "+alltrim(transform((calias)->QUANTIDADE_COMPRA, "@E 9,999,999"))+" mt - "+' R$ '+transform(nPrecoImpostos, "@E 999.9999"), oFont1, nColObs, nIncLine * nMultLine, , PAD_LEFT, 0)

		else
			//caso seja 1 tirada

			// tirada com acrescimo de 25%
			oPrinter:SayAlign(nLine, nColPos, 'MT', oFont1, nColUn, nIncLine * nMultLine, , PAD_CENTER, 0)
			nColPos += nColUn
			nColOBSProd:=nColPos
			oPrinter:SayAlign(nLine, nColPos, (calias)->BM_DESC, oFont3, nColMatDesc, nIncLine * nMultLine, , PAD_LEFT, 0)
			nColPos += nColMatDesc

			oPrinter:SayAlign(nLine, nColPos,  transform((calias)->LARGURA_CORTE, "@E 999.99"), oFont1, nColLargFx, nIncLine * nMultLine, , PAD_CENTER, 0)
			nColPos += nColLargFx
			nprecoBase25:=(calias)->PRECO_BASE*1.25
			oPrinter:SayAlign(nLine, nColPos,  'R$ '+transform(nprecoBase25, "@E 999.9999"), oFont1, nColPrcLiq, nIncLine * nMultLine, , PAD_CENTER, 0)
			nColPos += nColPrcLiq

			// calcular impostos
			nFatIcms:=(100-(calias)->ICMS)/100
			nPrecoImpostos := ( nprecoBase25 / nFatIcms ) /  0.9075
			nPrecoImpostos:= NoRound(nPrecoImpostos, 4)
			oPrinter:SayAlign(nLine, nColPos,  'R$ '+transform(nPrecoImpostos, "@E 999.9999"), oFont1, nColPrcImp, nIncLine * nMultLine, , PAD_CENTER, 0)
			nColPos += nColPrcImp

			oPrinter:SayAlign(nLine, nColPos, TRANSFORM((CALIAS)->BM_IPI, "@E 999.99")+' %', oFont1, nColIPI, nIncLine * nMultLine, , PAD_CENTER, 0)
			nColPos += nColIPI




			oPrinter:SayAlign(nLine, nColPos, " "+alltrim(transform((calias)->QUANTIDADE_COMPRA, "@E 9,999,999"))+" mt - "+' R$ '+transform(((nPrecoImpostos)), "@E 999.9999"), oFont1, nColObs, nIncLine * nMultLine, , PAD_LEFT, 0)

			nLine += nIncLIne


			// tirada com valor normal
			nColPos 	:=  nColIni
			nColPos += nColItem

			oPrinter:SayAlign(nLine, nColPos, 'MT', oFont1, nColUn, nIncLine * nMultLine, , PAD_CENTER, 0)
			nColPos += nColUn
			nColOBSProd:=nColPos
			oPrinter:SayAlign(nLine, nColPos, (calias)->BM_DESC, oFont3, nColMatDesc, nIncLine * nMultLine, , PAD_LEFT, 0)
			nColPos += nColMatDesc

			oPrinter:SayAlign(nLine, nColPos,  transform((calias)->LARGURA_CORTE, "@E 999.99"), oFont1, nColLargFx, nIncLine * nMultLine, , PAD_CENTER, 0)
			nColPos += nColLargFx

			oPrinter:SayAlign(nLine, nColPos,  'R$ '+transform((calias)->PRECO_BASE, "@E 999.9999"), oFont1, nColPrcLiq, nIncLine * nMultLine, , PAD_CENTER, 0)
			nColPos += nColPrcLiq

			// calcular impostos
			nFatIcms:=(100-(calias)->ICMS)/100
			nPrecoImpostos := ( (calias)->PRECO_BASE / nFatIcms ) /  0.9075
			nPrecoImpostos:= NoRound(nPrecoImpostos, 4)
			oPrinter:SayAlign(nLine, nColPos,  'R$ '+transform(nPrecoImpostos, "@E 999.9999"), oFont1, nColPrcImp, nIncLine * nMultLine, , PAD_CENTER, 0)
			nColPos += nColPrcImp

			oPrinter:SayAlign(nLine, nColPos, TRANSFORM((CALIAS)->BM_IPI, "@E 999.99")+' %', oFont1, nColIPI, nIncLine * nMultLine, , PAD_CENTER, 0)
			nColPos += nColIPI





			//oPrinter:SayAlign(nLine, 1350, "Desconto de 25% para pedidos acima de ", oFont1, nColObs, nIncLine * nMultLine,COR_RED , PAD_LEFT, 0)
			oPrinter:SayAlign(nLine, nColPos, " "+alltrim(transform(nMtTirada*2, "@E 9,999,999"))+" mt - "+'R$ '+transform(nPrecoImpostos, "@E 999.9999")+'  25% Desconto', oFont1, nColObs, nIncLine * nMultLine,COR_RED , PAD_LEFT, 0)


		endif

		if !empty((calias)->OBSERVACAO)
			nLine += nIncLIne
			oPrinter:SayAlign(nLine, nColOBSProd, alltrim((calias)->OBSERVACAO), oFont0I, nColMatDesc, nIncLine * nMultLine, , PAD_LEFT, 0)
			lOBSERVACAO:=.T.

		endif
		nLine += nIncLIne
		//cObs2 += " "+alltrim(transform(nMtTirada, "@E 999,999.999"))+" mt - "+'R$ '+transform(((calias)->ZV1_PRCIMP*1.20), "@E 999.99999")+Chr(13)+Chr(10)
		nMultLine := 2



		nLine += nIncLIne * ( nMultLine - 1 )
		(CALIAS)->(DBSKIP())
	ENDDO
	(CALIAS)->(DBCLOSEAREA())

	nLine += nIncLine
	nLine := prnTCV(nLine)

/*
	if ZV0->ZV0_STATUS == '0'
		for i:= nLine + nIncLIne to 2400
			oPrinter:Say( i, 1250, 'ORÇAMENTO NÃO LIBERADO', oFont1b)
			I+=nIncLIne
		next
	ENDIF
*/
	//Rodapé
	nLine := 2350
	oPrinter:Line( nLine, nColIni, nLine,nColFim )
	nLine += nIncLine
	oPrinter:Say( nLine, 1250, 'http://www.inducoat.com.br (19) 3167-0700', oFont1b)

	oPrinter:EndPage()
	FreeObj(oTpImpr)
	oPrinter:Preview()
	SCODVEND:=POSICIONE('SA1', 1, XFILIAL('SA1')+codcliente,"A1_VEND")

	cAssunto:=" TESTE - Inducoat - Carta Proposta"
	cMensagem:="Olá "+ALLTRIM(POSICIONE('SA1', 1, XFILIAL('SA1')+sA1_COD, 'A1_CONTATO'))+",<br>"
	cMensagem+="<br><br>Em anexo a carta proposta."
	cMensagem+="<br>Em caso de dúvidas, pedimos a gentileza de entrar em contato com o representante comercial responsável: "+ALLTRIM(POSICIONE('SA3', 1, XFILIAL('SA3')+SCODVEND,"A3_NOME"))
	cMensagem+="<br><br>Atenciosamente,"
	cMensagem+="<br>Equipe Inducoat "
	cMensagem+="<br><br><br><i>E-mail enviado automaticamente via sistema, favor não responder. </i> "

	cPara:="ti@inducoat.com.br, gabriela.battistini@inducoat.com.br"
	aadd(aArquivos,cPathInServer+cFileName+'.pdf')
	GPEMail(cAssunto,cMensagem,cPara,aArquivos)

RETURN lRet

// imprime termos e codições  de venda
static function prnTCV(nLinAtu)
	Local nColTitulo := nColIni,SCODVEND, nColInfo := 900
	local aInfo := {}, i
	SCODVEND:=POSICIONE('SA1', 1, XFILIAL('SA1')+codcliente,"A1_VEND")
	SCONDVEND:=POSICIONE('SA1', 1, XFILIAL('SA1')+codcliente,"A1_COND")

	aAdd(aInfo,{"Moeda da cotação:"				, "BRL R$" })

	cEstCli := POSICIONE('SA1', 1, XFILIAL('SA1')+codcliente,"A1_EST")
	cIcms := '7'
	if cEstCli$'RS,RJ,PR,MG,SC'
		cIcms := '12'
	elseif  cEstCli$'SP'
		cIcms := '18'
	endif
	aAdd(aInfo,{"Percentual de ICMS:"			, cIcms + "% (Não incluso no preço líquido)"})
	aAdd(aInfo,{"Percentual de PIS-COFINS:"		, "9,25% (Não incluso no preço líquido)"})
	aAdd(aInfo,{"Validade da proposta (dias):"	, "30"})
	aAdd(aInfo,{"Prazo de entrega (dias):"		, "À confirmar após a confirmação do pedido"})
	_cCondPag := POSICIONE('SE4', 1, XFILIAL('SE4')+SCONDVEND,"E4_DESCRI")
	aAdd(aInfo,{"Condição de pagamento:"		, _cCondPag})

	sA1_TPFRET := POSICIONE('SA1', 1, XFILIAL('SA1')+codcliente,"A1_TPFRET")

	if sA1_TPFRET=='C'
		aAdd(aInfo,{"Frete:"						, "CIF (Posto São Paulo)"})
	else
		aAdd(aInfo,{"Frete:"						, "FOB"})

	endif

	aAdd(aInfo,{"Observações:"					, "Para o cumprimento dos preços informados acima, precisamos que o pedido"})
	aAdd(aInfo,{""								, "seja emitido dentro das condições comercias descritas nesta carta proposta. "})
	if lOBSERVACAO
		aAdd(aInfo,{""								, "Para produto com impressão dedicada, o Material/Descrição pode sofrer alteração."})
	endif
	aAdd(aInfo,{""								, ""})
	aAdd(aInfo,{"Tolerância de Variação:"		,"Considerar variação de 10% para mais ou para menos entre a quantidade "})
	aAdd(aInfo,{""								, "solicitada e a quantidade produzida."})
	aAdd(aInfo,{"Entrega e Armazenagem:"		, "O despacho acontecera na data de entrega estipulada no pedido."})
	//aAdd(aInfo,{""                                , "A quantidade produzida poderá ficar armazenada na Inducoat por até 180 dias."})
	aAdd(aInfo,{"Formato de Entrega:"			, "Bobina."})
	_cRepNome :=  ALLTRIM(POSICIONE('SA3', 1, XFILIAL('SA3')+SCODVEND,"A3_NOME"))
	_cRepmail :=  ALLTRIM(POSICIONE('SA3', 1, XFILIAL('SA3')+SCODVEND,"A3_EMAIL"))
	aAdd(aInfo,{"Contato Comercial:"			, _cRepNome + " ( " + _cRepmail + " ) "})
	_cUserName := alltrim('admin')
	psworder(2)

	pswseek(_cUserName,.t.)
	_daduser:=pswret(1)
	_cNome :=alltrim(_daduser[1,4] )
	_cEmail := alltrim(_daduser[1,14] )
	//aAdd(aInfo,{"Orçamento elaborado por:"      , _cNome + " - "+_cEmail})
	aAdd(aInfo,{"Orçamento elaborado por:"        , _cNome})


	oPrinter:Fillrect( {nLinAtu, nColIni, nLinAtu + 40, nColFim }, oBruAz2)
	oPrinter:Line( nLinAtu + 40, nColIni, nLinAtu + 40, nColFim )
	oPrinter:Say(nLinAtu + 35, nColTitulo,   "Termos e Condições de Venda", oFont1B, 1000, CLR_WHITE)
	nLinAtu += 40
	nColTitulo := nColIni
	nColInfo := 1000
	for i:=1 to len(aInfo)
		nLinAtu +=  40
		oPrinter:Say(nLinAtu , nColTitulo,   aInfo[i,1], oFont1)
		oPrinter:Say(nLinAtu ,   nColInfo,   aInfo[i,2], oFont1)
	next
return nLinAtu

static function diasemext(dData)
	Local nDow:= dow(dData)
	lOcal aDias := {'Domingo', 'Segunda-Feira', 'Terça-Feira', 'Quarta-Feira', 'Quinta-Feira', 'Sexta-Feira', 'Sábado'}

return aDias[nDow]
