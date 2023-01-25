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
USER FUNCTION laudo(cOrigem)
	Local  nLine, nIncline := 40, cFilename := '',aResult:={},i:=0
	Private lErro:=.F.,cMsg:=''
	//Declarando as fontes

	Private cNomeFont  	:= "Arial"
	Private nSize0		:= 10,nSize1:= 12, nSize2 := 12, nSize3 := 14, nSize4 := 15

	Private oFont0   	:= TFont():New(cNomeFont, 9, nSize0, .T., .F., 5, .T., 5, .T., .F., .F.)
	Private oFont0B   	:= TFont():New(cNomeFont, 9, nSize0, .T., .T., 5, .T., 5, .T., .F., .F.)
	Private oFont0U   	:= TFont():New(cNomeFont, 9, nSize0, .T., .F., 5, .T., 5, .T., .T., .F.)
	Private oFont0I   	:= TFont():New(cNomeFont, 9, nSize0, .T., .F., 5, .T., 5, .T., .F., .T.)


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
	Private nColIni	 	:=  20, nColFim := 2300
	PRIVATE oTpImpr := JsonObject():new()

	oTpImpr['SI'] := "Sem Impressão"
	oTpImpr['ID'] := "Impresso Dedicado"
	oTpImpr['IS'] := "Impresso Standard"


	lAdjustToLegacy := .t.
	lDisableSetup  := .T.

	if cOrigem=='NF'
		Alert('NF')
	endif
	//
	cFileName := 'laudo_'+DTOS(DDATABASE)+'_'+alltrim(SF2->F2_DOC)+'_'+SF2->F2_CLIENTE
	oPrinter := FWMSPrinter():New(cFileName+".rel", IMP_PDF, lAdjustToLegacy, , lDisableSetup, , , , , , .F., .T. )// Ordem obrigátoria de configuração do relatório
	oPrinter:SetResolution(72)
	//oPrinter:SetLandscape()
	oPrinter:SetPortrait()
	oPrinter:SetPaperSize(DMPAPER_A4)
	oPrinter:SetMargin(nColIni , nColIni, nColIni , nColIni) // nEsquerda, nSuperior, nDireita, nInferior
	oPrinter:SetParm( "-RFS")
	oPrinter:cPathPDF := "d:\tmp\" // Caso seja utilizada impressão em IMP_PDF


	dbSelectArea("SD2")
	SD2->(dbSetorder(3))
	SD2->(dbSeek(SF2->F2_FILIAL+SF2->F2_DOC+SF2->F2_SERIE))
	cNota := SF2->F2_DOC+SF2->F2_SERIE

	While SF2->F2_FILIAL=SD2->D2_FILIAL .And. !Eof() .And. SD2->D2_DOC+SD2->D2_SERIE == cNota

		oPrinter:StartPage()
		nColIni	 :=  20
		nLine 	:= 350
		oPrinter:SayBitmap( 80, 20,"/imagens/logoind3.bmp",437,212)



		//oPrinter:Line( n_line, 045, n_line,2275 )
		oPrinter:Say( nLine, nColIni+900, 'CERTIFICADO DE ANÁLISE' , oFont3B)
		nLine += nIncLine * 2
		oPrinter:Say( nLine, nColIni,'Cliente: ', oFont1B)
		oPrinter:Say( nLine, nColIni+160, ALLTRIM(POSICIONE('SA1', 1, XFILIAL('SA1')+SF2->F2_CLIENTE, 'A1_NOME')) , oFont1)
		nLine += nIncLine * 2
		oPrinter:Say( nLine, nColIni, 'Produto: '+ POSICIONE('SB1', 1, XFILIAL('SB1')+SD2->D2_COD, 'B1_DESC') + '.' , oFont1B)

		oPrinter:Say( nLine, nColIni+1700,'Data Fabricação: ', oFont1B)
		oPrinter:Say( nLine, nColIni+2000,DTOC(SD2->D2_DFABRIC)  , oFont1)

		nLine += nIncLine * 2
		oPrinter:Say( nLine, nColIni,'Nota Fiscal: ', oFont1B)
		oPrinter:Say( nLine, nColIni+250, alltrim(SF2->F2_DOC) , oFont1)
		oPrinter:Say( nLine, nColIni+1700,'Quantidade: ', oFont1B)
		oPrinter:Say( nLine, nColIni+1920,TRANSFORM(SD2->D2_QUANT,"@E 999,999.99")  , oFont1)
		oPrinter:Say( nLine, nColIni+2100,SD2->D2_UM  , oFont1)
		
		nLine += nIncLine * 2
		oPrinter:Say( nLine, nColIni,'Lote: ', oFont1B)
		oPrinter:Say( nLine, nColIni+210, alltrim(SD2->D2_LOTECTL) , oFont1)
		oPrinter:Say( nLine, nColIni+1700,'Data Emissão: ', oFont1B)
		oPrinter:Say( nLine, nColIni+2000,dtoc(ddatabase)  , oFont1)

		if empty(SD2->D2_LOTECTL)
			Alert('Este tipo de NF nao possue lote para emissao de laudo da Qualidade. Contacte a Qualidade')
			Return

		else
			aResult:=getensaios(SD2->D2_LOTECTL)
		ENDIF

		if Empty(aResult)
			Alert("Laudo do lote "+alltrim(SD2->D2_LOTECTL)+' sem medições. Contacte a Qualidade ')
			Return
		endif

		nLine += nIncLine * 2
		oPrinter:Say( nLine, nColIni+400,'Parâmetro', oFont1B)
		oPrinter:Say( nLine, nColIni+900,'Unidade', oFont1B)
		oPrinter:Say( nLine, nColIni+1100,'Especificado', oFont1B)
		oPrinter:Say( nLine, nColIni+1400,'Encontrado', oFont1B)

		for i:=1 to len(aResult)
			nLine += nIncLine

			oPrinter:Say( nLine, nColIni+400,aResult[i,1], oFont1)
			oPrinter:Say( nLine, nColIni+900,aResult[i,2], oFont1)
			oPrinter:Say( nLine, nColIni+1100,aResult[i,4], oFont1)
			oPrinter:Say( nLine, nColIni+1400,aResult[i,3], oFont1)




		next

		nLine += nIncLine * 3
 
oPrinter:Say( nLine, nColIni,'Validade:', oFont1B)
oPrinter:Say( nLine, nColIni+150,' 12 meses a partir da data de fabricação.', oFont1)

nLine += nIncLine
oPrinter:Say( nLine, nColIni,'Tolerância de variação de metros por rolo:', oFont1B)
oPrinter:Say( nLine, nColIni+750,' ± 1%', oFont1)

nLine += nIncLine*2
oPrinter:Say( nLine, nColIni,'Condições de armazenamento:', oFont1B)
oPrinter:Say( nLine, nColIni+530,' Recomendável armazenar em local seco, protegido de raios solares e em temperatura máxima de 35°C e', oFont1)
nLine += nIncLine
oPrinter:Say( nLine, nColIni,'afastado de tetos e paredes.', oFont1)

nLine += nIncLine*2


oPrinter:Say( nLine, nColIni,'Este material foi inspecionado durante o processo produtivo e foi aprovado pela garantia da qualidade, segundo', oFont1)
nLine += nIncLine
oPrinter:Say( nLine, nColIni,'especificações internas Inducoat.', oFont1)

nLine += nIncLine*6

oPrinter:Say( nLine, nColIni,'Certificado emitido via sistema integrado com aprovação pela Garantia da Qualidade - Responsável : 00002', oFont1I)

		//Rodapé
		nLine := 2950
		oPrinter:Line( nLine, nColIni, nLine,nColFim )
		nLine += nIncLine
		oPrinter:Say( nLine, 900, 'http://www.inducoat.com.br (19) 3167-0700', oFont1b)

		oPrinter:EndPage()

		dbSkip()
	End



	FreeObj(oTpImpr)
	oPrinter:Preview()
RETURN



Static Function getensaios(cLote)
	Local cAlias
	Local aEnsaios:={}

	cAlias := getNextAlias()

	BEGINSQL ALIAS cAlias
                SELECT D3_OP
                FROM %TABLE:SD3%
                WHERE D3_FILIAL = %XFILIAL:SD3% 
				AND D_E_L_E_T_ <> '*'
				AND D3_CF='PR0'
                AND D3_LOTECTL = %EXP:cLote%
	ENDSQL

	WHILE (cAlias)->(!EOF())

		cOP:=(cAlias)->D3_OP

		(cAlias)->(dbskip())

	ENDDO


	(cAlias)->(dbclosearea())

	cAlias := getNextAlias()

	BEGINSQL ALIAS cAlias
                SELECT *
                FROM %TABLE:ZQ0%
                WHERE ZQ0_FILIAL = %XFILIAL:ZQ0% 
				AND D_E_L_E_T_ <> '*'
				AND ZQ0_OP=%EXP:cOP%
                
	ENDSQL


	WHILE (cAlias)->(!EOF())

		//cOP:=(cAlias)->D3_OP
		IF alltrim((CALIAS)->ZQ0_ENSAIO)=='Espessura'
			aAdd(aEnsaios,{'Espessura Total','µm',alltrim((CALIAS)->ZQ0_RESULT),(CALIAS)->ZQ0_ESPCIF})

		elseif alltrim((CALIAS)->ZQ0_ENSAIO)=='LarguraMin'
			cLargura:=alltrim((CALIAS)->ZQ0_RESULT)+' mín'

		elseif alltrim((CALIAS)->ZQ0_ENSAIO)=='LarguraMax'
			cLargura+=' - '+alltrim((CALIAS)->ZQ0_RESULT)+' máx'

			nLarg:=POSICIONE('SB1', 1, XFILIAL('SB1')+SD2->D2_COD, 'B1_LARGURA')
			cEpecif:=alltrim(transform(nLarg,"@E 999.9"))+' ± '+' 0,5'
			aAdd(aEnsaios,{'Largura Final','mm',cLargura,cEpecif})

		elseif alltrim((CALIAS)->ZQ0_ENSAIO)=='DiametroInt'
			aAdd(aEnsaios,{'Diâmetro Interno (informativo)','polegada',alltrim((CALIAS)->ZQ0_RESULT),alltrim((CALIAS)->ZQ0_RESULT)})

		elseif alltrim((CALIAS)->ZQ0_ENSAIO)=='DiametroExt'
			aAdd(aEnsaios,{'Diâmetro Externo','mm',alltrim((CALIAS)->ZQ0_RESULT),'N/A'})

		elseif alltrim((CALIAS)->ZQ0_ENSAIO)=='DiametroExt'
			aAdd(aEnsaios,{'Aspecto visual do rolo e do corte','n/a',alltrim((CALIAS)->ZQ0_RESULT),'alinhado e sem rebarbas'})

		ENDIF


		(cAlias)->(dbskip())

	ENDDO



Return aEnsaios
