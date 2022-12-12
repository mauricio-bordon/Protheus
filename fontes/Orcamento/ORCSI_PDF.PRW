//Bibliotecas
#Include "TOTVS.ch"
#Include "TopConn.ch"
#Include "RPTDef.ch"
#Include "FWPrintSetup.ch"

//Alinhamentos
#Define PAD_LEFT    0
#Define PAD_RIGHT   1
#Define PAD_CENTER  2

Static nCorCinza := RGB(204, 204, 204)
Static nCorAz1  := RGB(168, 189, 220)
Static nCorAz2  := RGB(90, 142, 220)
USER FUNCTION ORCSIPDF()
	Local  nLine, nIncline := 40, cFilename := ''
	//Declarando as fontes
	Private cNomeFont  	:= "Arial"
	Private nSize1		:= 12, nSize2 := 12, nSize3 := 10, nSize4 := 10
	Private oFont1   	:= TFont():New(cNomeFont, 9, nSize1, .T., .F., 5, .T., 5, .T., .F., .F.)
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

	cFileName := 'orc_'+DTOS(DDATABASE)+'_'+ZV0->ZV0_CODCLI+'_'+ZV0->ZV0_CODIGO+ZV0->ZV0_REVI
	oPrinter := FWMSPrinter():New(cFileName+".rel", IMP_PDF, lAdjustToLegacy, , lDisableSetup, , , , , , .F., .T. )// Ordem obrigátoria de configuração do relatório
	oPrinter:SetResolution(72)
	oPrinter:SetLandscape()
	oPrinter:SetPaperSize(DMPAPER_A4)
	oPrinter:SetMargin(nColIni , nColIni, nColIni , nColIni) // nEsquerda, nSuperior, nDireita, nInferior
	oPrinter:SetParm( "-RFS")
	oPrinter:cPathPDF := "d:\tmp\" // Caso seja utilizada impressão em IMP_PDF

	oPrinter:StartPage()
	nColIni	 :=  25
	nLine 	:= 200
	oPrinter:SayBitmap( nLine, nColFim - 450,"/imagens/logoind3.bmp",437,212)



	//oPrinter:Line( n_line, 045, n_line,2275 )

	oPrinter:Say( nLine, nColIni, ALLTRIM(diasemext(ZV0->ZV0_EMISS))+', '+ CValToChar(DAY(ZV0->ZV0_EMISS)) + ' de '+ MESEXTENSO(month(ZV0->ZV0_EMISS)) + ' de ' + cvaltochar(year(ZV0->ZV0_EMISS)) , oFont1)
	nLine += nIncLine * 2
	oPrinter:Say( nLine, nColIni, 'À' , oFont1)
	nLine += nIncLine
	oPrinter:Say( nLine, nColIni, ALLTRIM(POSICIONE('SA1', 1, XFILIAL('SA1')+ZV0->ZV0_CODCLI, 'A1_NOME')) , oFont1B)
	nLine += nIncLine * 2
	oPrinter:Say( nLine, nColIni, 'Att. Sr(a). '+ ZV0->ZV0_CONTAT + '.' , oFont1B)
	nLine += nIncLine
	oPrinter:Say( nLine, nColIni,  alltrim(ZV0->ZV0_EMAIL)  , oFont1U)
	nLine += nIncLine * 2
	oPrinter:Say( nLine, nColIni, 'Prezados, segue proposta.' , oFont1)
	nLine += nIncLine
	oPrinter:Say( nLine, nColIni, 'Desde já agradecemos a oportunidade à nós concedida, e nos colocamos a disposição para quaisquer esclarecimentos.' , oFont1)
	nLine += nIncLine

	oPrinter:Fillrect( {nLine, nColIni, nLine + nIncline, nColFim }, oBruAz1)
	nLine += nIncLine
	oPrinter:Say(nLine, nColIni,   "Carta Proposta "+ZV0->ZV0_CODIGO, oFont1B)
	oPrinter:Line( nLine, nColIni, nLine, nColFim )
	nLine += nIncLine

	oPrinter:Say( nLine, nColIni, 'Selo de Indução' , oFont1)
	nLine += nIncLine

	//tabela
	ZV0->(DbSetOrder(1))
	ZV0->(DBSEEK(XFILIAL('ZV0')+ZV1->ZV1_CODIGO+ZV1->ZV1_REVI))
	cAlias := getNextAlias()

	BEGINSQL alias CALIAS
		SELECT *
		FROM %TABLE:ZV1%
		WHERE ZV1_FILIAL = %XFILIAL:ZV1% AND %NOTDEL%
		AND ZV1_CODIGO = %EXP:ZV0->ZV0_CODIGO% AND ZV1_REVI = %EXP:ZV0->ZV0_REVI%
		AND ZV1_STATUS <> 'R'
		ORDER BY ZV1_ITEM
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
	nColPrcImp 	:= 270
	nColIPI		:= 140

	nColPos 	:=  nColIni
	oPrinter:Fillrect( {nLine, nColPOs, nLine + nIncLine * 2, nColFim }, oBruAz1)
	oPrinter:Line( nLine + nIncLine * 2, nColIni, nLine + nIncLine * 2, nColFim )

	oPrinter:SayAlign(nLine, nColPos, 'Item', oFont3b, nColItem, nIncLine * 2, , PAD_CENTER, 0)
	nColPos += nColItem

	oPrinter:SayAlign(nLine, nColPos, 'Quantidade', oFont3b, nColQtdVol, nIncLine, , PAD_CENTER, 0)
	oPrinter:SayAlign(nLine + nIncLine, nColPos, '(volume)', oFont3b, nColQtdVol, nIncLine, , PAD_CENTER, 0)
	nColPos += nColQtdVol

	oPrinter:SayAlign(nLine, nColPos, 'Unidade', oFont3b, nColUn, nIncLine * 2, , PAD_CENTER, 0)
	nColPos += nColUn

	oPrinter:SayAlign(nLine, nColPos, 'Material/Descrição', oFont3b, nColMatDesc, nIncLine * 2, , PAD_CENTER, 0)
	nColPos += nColMatDesc

	oPrinter:SayAlign(nLine, nColPos, 'Tipo de Selo', oFont3b, nColTpSelo, nIncLine * 2, , PAD_CENTER, 0)
	nColPos += nColTpSelo

	oPrinter:SayAlign(nLine, nColPos, 'Nº Cores', oFont3b, nColCores, nIncLine * 2, , PAD_CENTER, 0)
	nColPos += nColCores

	oPrinter:SayAlign(nLine, nColPos, 'Largura/Faixa (mm)', oFont3b, nColLargFx, nIncLine * 2, , PAD_CENTER, 0)
	nColPos += nColLargFx

	oPrinter:SayAlign(nLine, nColPos, 'Observação', oFont3b, nColObs, nIncLine * 2, , PAD_CENTER, 0)
	nColPos += nColObs

	oPrinter:SayAlign(nLine, nColPos, 'Preço Líquido', oFont3b, nColPrcLiq, nIncLine, , PAD_CENTER, 0)
	oPrinter:SayAlign(nLine + nIncLine, nColPos, '(MT)', oFont3b, nColPrcLiq, nIncLine, , PAD_CENTER, 0)
	nColPos += nColPrcLiq

	oPrinter:SayAlign(nLine, nColPos, 'Preço com impostos', oFont3b, nColPrcImp, nIncLine, , PAD_CENTER, 0)
	oPrinter:SayAlign(nLine + nIncLine, nColPos, '(MT)', oFont3b, nColPrcImp, nIncLine, , PAD_CENTER, 0)
	nColPos += nColPrcImp

	oPrinter:SayAlign(nLine, nColPos, 'IPI', oFont3b, nColIPI, nIncLine * 2, , PAD_CENTER, 0)
	nColPos += nColIPI

	/*

	oPrinter:SayAlign(nLine , 1800,   "Preço com Impostos", oFont1B, 500, 35, , PAD_CENTER, 0)
	oPrinter:SayAlign(nLine +  nIncline , 1800,   "(Metros Lineares)", oFont1B, 500, 35, , PAD_CENTER, 0)
	*/
	nLine += nIncLine  * 2

	WHILE (CALIAS)->(!EOF())
		nColPos 	:=  nColIni
		//nFxSobra := (calias)->ZV1_LARGPI - (calias)->ZV1_LARGCR * (CALIAS)->ZV1_NROLOS
		cObs2 := ''
		nMtTirada := (CALIAS)->ZV1_NROLOS * (CALIAS)->ZV1_MTLIN
		cObs2 := 'Pedido mínimo/múltiplo são: '+CValToChar((CALIAS)->ZV1_NROLOS)+ " faixas de "+CValToChar((calias)->ZV1_LARGCR)+ " mm com "+alltrim(transform((calias)->ZV1_MTLIN, "@E 99,999"))+" mt,"+Chr(13)+Chr(10)
		cObs2 += " totalizando: "+alltrim(transform(nMtTirada, "@E 999,999.999"))+" mt "+Chr(13)+Chr(10)
		nMultLine := 2
		cObsSobra := ''
		/*
		if nFxSobra > 0
			cObsSobra := CValToChar((CALIAS)->ZV1_NROLOS)+ " faixas de "+CValToChar((calias)->ZV1_LARGCR)+ " mm e 1 faixa de "+ CValToChar(nFxSobra) +"mm"
			cObs2 += cObsSobra+Chr(13)+Chr(10)
			nMultLine++
		endif
		*/
		cZV1Obs := alltrim(POSICIONE('ZV1',1,XFILIAL('ZV1')+ZV0->ZV0_CODIGO+ZV0->ZV0_REVI+(CALIAS)->ZV1_ITEM,"ZV1_OBS"))
		_nObsSize := oPrinter:GetTextWidth( cZV1Obs, oFont4,0)
		if !empty(cZV1Obs)
			cObs2 += cZV1Obs
			nMultLine++
		endif
		oPrinter:SayAlign(nLine, nColPos, (calias)->ZV1_ITEM, oFont1, nColItem, nIncLine * nMultLine, , PAD_CENTER, 0)
		nColPos += nColItem

		oPrinter:SayAlign(nLine, nColPos, transform((calias)->ZV1_MTTOT, "@E 9,999,999"), oFont1, nColQtdVol, nIncLine  * nMultLine, , PAD_CENTER, 0)
		nColPos += nColQtdVol

		oPrinter:SayAlign(nLine, nColPos, 'MT', oFont1, nColUn, nIncLine * nMultLine, , PAD_CENTER, 0)
		nColPos += nColUn

		oPrinter:SayAlign(nLine, nColPos, (calias)->ZV1_DESC, oFont1, nColMatDesc, nIncLine * nMultLine, , PAD_LEFT, 0)
		nColPos += nColMatDesc

		oPrinter:SayAlign(nLine, nColPos, oTpImpr[(calias)->ZV1_TPIMPR], oFont1, nColTpSelo, nIncLine * nMultLine, , PAD_CENTER, 0)
		nColPos += nColTpSelo

		oPrinter:SayAlign(nLine, nColPos,  cvaltochar((calias)->ZV1_CORES) , oFont1, nColCores, nIncLine * nMultLine, , PAD_CENTER, 0)
		nColPos += nColCores

		oPrinter:SayAlign(nLine, nColPos,  transform((calias)->ZV1_LARGCR, "@E 999.99"), oFont1, nColLargFx, nIncLine * nMultLine, , PAD_CENTER, 0)
		nColPos += nColLargFx
/*
		oPrinter:SayAlign(nLine, nColPos, cObsQtdMin, oFont4, nColObs, nIncLine, , PAD_LEFT, 0)

		if !empty(cObsSobra)
			oPrinter:SayAlign(nLine + nIncLine, nColPos, cObsSobra, oFont4, nColObs, nIncLine, , PAD_LEFT, 0)
		endif

		if !empty(cZV1Obs)			
			oPrinter:SayAlign(nLine + nIncLine*2, nColPos, cZV1Obs, oFont4, nColObs, nIncLine, , PAD_LEFT, 0)
		endif
*/
		nMultLine := fSayBox(oPrinter,oFont4,nLine,nColPos,nIncLine,nColObs,cObs2)

		nColPos += nColObs

		oPrinter:SayAlign(nLine, nColPos,  'R$ '+transform((calias)->ZV1_PRCLIQ, "@E 999.99999"), oFont1, nColPrcLiq, nIncLine * nMultLine, , PAD_CENTER, 0)
		nColPos += nColPrcLiq

		oPrinter:SayAlign(nLine, nColPos,  'R$ '+transform((calias)->ZV1_PRCIMP, "@E 999.99999"), oFont1, nColPrcImp, nIncLine * nMultLine, , PAD_CENTER, 0)
		nColPos += nColPrcImp

		oPrinter:SayAlign(nLine, nColPos, TRANSFORM((CALIAS)->ZV1_IPI, "@E 999.999")+' %', oFont1, nColIPI, nIncLine * nMultLine, , PAD_CENTER, 0)
		nColPos += nColIPI
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
	nLine := 2400
	oPrinter:Line( nLine, nColIni, nLine,nColFim )
	nLine += nIncLine
	oPrinter:Say( nLine, 1250, 'http://www.inducoat.com.br (19) 3167-0700', oFont1b)

	oPrinter:EndPage()
	FreeObj(oTpImpr)
	oPrinter:Preview()
RETURN

// imprime termos e codições  de venda
static function prnTCV(nLinAtu)
	Local nColTitulo := nColIni, nColInfo := 900
	local aInfo := {}, i

	aAdd(aInfo,{"Moeda da cotação:"				, "BRL R$" })

	cEstCli := POSICIONE('SA1', 1, XFILIAL('SA1')+ZV0->ZV0_CODCLI,"A1_EST")
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
	_cCondPag := POSICIONE('SE4', 1, XFILIAL('SE4')+ZV0->ZV0_CONDPG,"E4_DESCRI")
	aAdd(aInfo,{"Condição de pagamento:"		, _cCondPag})
	aAdd(aInfo,{"Frete:"						, "Posto São Paulo"})
	aAdd(aInfo,{"Observações:"					, "Para o cumprimento dos preços informados acima, precisamos que o pedido"})
	aAdd(aInfo,{""								, "seja emitido dentro das condições comercias descritas nesta carta proposta. "})
	aAdd(aInfo,{""								, ZV0->ZV0_OBS})
	aAdd(aInfo,{"Tolerância de Variação:"		,"Considerar variação de 10% para mais ou para menos entre a quantidade "})
	aAdd(aInfo,{""								, "solicitada e a quantidade produzida."})
	aAdd(aInfo,{"Entrega e Armazenagem:"		, "O despacho acontecera na data de entrega estipulada no pedido."})
	aAdd(aInfo,{""                                , "A quantidade produzida poderá ficar armazenada na Inducoat por até 180 dias."})
	aAdd(aInfo,{"Formato de Entrega:"			, "Bobina."})
	_cRepNome :=  ALLTRIM(POSICIONE('SA3', 1, XFILIAL('SA3')+ZV0->ZV0_REPRES,"A3_NOME"))
	_cRepmail :=  ALLTRIM(POSICIONE('SA3', 1, XFILIAL('SA3')+ZV0->ZV0_REPRES,"A3_EMAIL"))
	aAdd(aInfo,{"Contato Comercial:"			, _cRepNome + " ( " + _cRepmail + " ) "})
	_cUserName := alltrim(ZV0->ZV0_USER)
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



Static Function fSayBox(oPrn,oFnt,nY,nX,nH,nW,cTxt)

	Local aTexto
	Local aTexto2
	Local cTexto := lower(AllTrim(cTxt))
	Local nLin := nY, nA, nB
	Local nAltLin := 40 // oPrn:GetTextHeight("MMMM",oFnt)
	Local Nlinhas := 1
	nW := nW * 1.4
	aTexto := StrTokArr(cTexto,Chr(13)+Chr(10))

	For nA := 1 to Len(aTexto)

		aTexto2 := StrTokArr(aTexto[nA]," ")

		cLinha := ""

		For nB := 1 to Len(aTexto2)

			//If oPrn:GetTextWidth(cLinha+" "+aTexto2[nB],oFnt) > nW .And. !Empty(cLinha)
			if len(cLinha+" "+aTexto2[nB]) > 60 .And. !Empty(cLinha)
				oPrinter:SayAlign(nLin, nX, AllTrim(cLinha), oFnt, nW, nAltLin, , 3, 0)
				//oPrn:Say( nLin, nX ,AllTrim(cLinha),oFnt,,,,0)
				cLinha := ""
				nLin += nAltLin
				Nlinhas++

			Else

				cLinha += " "+aTexto2[nB]

			EndIf

		Next nB

		If !Empty(cLinha)
			oPrinter:SayAlign(nLin, nX, AllTrim(cLinha), oFnt, nW, nAltLin, , 3, 0)
			//oPrn:Say( nLin, nX ,AllTrim(cLinha),oFnt,,,,0)
			nLin += nAltLin
			Nlinhas++
		EndIf

	Next nA

Return Nlinhas
