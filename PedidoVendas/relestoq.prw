//Bibliotecas
#Include "Protheus.ch"
#Include "TopConn.ch"
#Include "RPTDef.ch"
#Include "FWPrintSetup.ch"

//Alinhamentos
#Define PAD_LEFT    0
#Define PAD_RIGHT   1
#Define PAD_CENTER  2

//Cores
#Define COR_CINZA   RGB(180, 180, 180)
#Define COR_PRETO   RGB(000, 000, 000)
#Define COR_FUNDO   RGB(180, 180, 180)

#Define COL_PEDIDO  0010
#Define COL_PRODUTO 0045
#Define COL_DPD 	0110
#Define COL_DESCRI 	0180
#Define COL_QTDVEN 	0380
#Define COL_PRCVEN 	0470
#Define COL_ENTREG 0506
#Define COL_PEDCLI 	0556

//#Define COL_VALOR_IPI 0700
#Define COL_LOTECTL 0045
#Define COL_DTVALID 0110
#Define COL_LOCAL 	0180
#Define COL_LOCALIZ 0220
#Define COL_QTDESTOQ 0310

#Define COL_QTDENT 0690
#Define COL_DISPONIVEL 0745

User Function relestoq()
	Local aArea  := GetArea()

	Private sCliente
	Private sProduto
	Private sClientenome
	Private dataInicio
	Private dataFim

	if dataInicio == nil
		if !pergunta()
			RETURN

		endif
	endif

	Processa({|| fMontaRel()}, "Buscando pedidos em aberto...")


	RestArea(aArea)


RETURN


Static Function fMontaRel()
	Local cCaminho    := ""
	Local cArquivo    := ""
	//Local nAtual      := 0
	local cAlias
	Local cWhere    := ""

	Local aSB8 := {}
	Local aSB8Total := {}
	Local i:=0
	
	//Linhas e colunas
	Private nLinAtu   := 000
	Private nTamLin   := 010
	Private nLinFin   := 590
	Private nColIni   := 010
	Private nColFin   := 800
	Private nColMeio  := (nColFin-nColIni)/2
	//Objeto de Impressão
	Private oPrintPvt
	Private oBrushCinza     := TBRUSH():New(,COR_CINZA)
	//Variáveis auxiliares
	Private dDataGer  := Date()
	Private cHoraGer  := Time()
	Private nPagAtu   := 1
	Private cNomeUsr  := UsrRetName(RetCodUsr())
	Private nTotal      := 0

	//Fontes
	Private cNomeFont := "Arial"
	Private oFontDet  := TFont():New(cNomeFont, 9, -10, .T., .F., 5, .T., 5, .T., .F.)
	Private oFontDetN := TFont():New(cNomeFont, 9, -10, .T., .T., 5, .T., 5, .T., .F.)
	Private oFontDetI  := TFont():New(cNomeFont, 9, -10, .T., .F., 5, .T., 5, .T., .T.)
	Private oFontRod  := TFont():New(cNomeFont, 9, -08, .T., .F., 5, .T., 5, .T., .F.)
	Private oFontTit  := TFont():New(cNomeFont, 9, -13, .T., .T., 5, .T., 5, .T., .F.)


	//Definindo o diretório como a temporária do S.O. e o nome do arquivo com a data e hora (sem dois pontos)
	cCaminho  := GetTempPath()
	cArquivo  := "pedido_" + dToS(dDataGer) + "_" + StrTran(cHoraGer, ':', '-')

	//Criando o objeto do FMSPrinter
	oPrintPvt := FWMSPrinter():New(cArquivo, IMP_PDF, .F., "", .T., , @oPrintPvt, "", , , , .T.)


	//Setando os atributos necessários do relatório
	oPrintPvt:SetResolution(72)
	//oPrintPvt:SetPortrait()
	oPrintPvt:SetLandScape()
	oPrintPvt:SetPaperSize(DMPAPER_A4)
	oPrintPvt:SetMargin(60, 60, 60, 60)

	sdataInicio:=DTOS(dataInicio)
	sdataFim:=DTOS(dataFim)

cWhere+="AND C6_ENTREG BETWEEN '"+sdataInicio+"' AND '"+sdataFim+"' "
if !Empty(sCliente)
	cWhere+=" AND C6_CLI='"+sCliente+"' "
endif

if !Empty(sProduto)
	cWhere+=" AND C6_PRODUTO='"+sProduto+"' "
endif

//Prepara a vari�vel para uso no BeginSql
cWhere := "%" + cWhere + "%"
	//Imprime o cabeçalho
	fImpCab()
	cAlias := getNextAlias()

	BeginSql Alias cAlias
			

SELECT C5_NUM PEDIDO,C6_PRODUTO,C6_PEDCLI,C6_DESCRI,C6_QTDVEN,C6_PRCVEN,C6_ENTREG,C6_PEDCLI,C6_DTVALID,C6_QTDENT,C6_ITEMPC
FROM %TABLE:SC5% SC5
INNER JOIN %TABLE:SC6% SC6
ON C5_NUM=C6_NUM
INNER JOIN %TABLE:SB1% SB1
ON C6_PRODUTO=B1_COD
WHERE C5_FILIAL=%XFILIAL:SC5%
AND C6_FILIAL=%XFILIAL:SC6%
AND SC5.D_E_L_E_T_<>'*'
AND SC6.D_E_L_E_T_<>'*'
AND SB1.D_E_L_E_T_<>'*'
AND C5_NOTA='' 
AND (C6_PRODUTO LIKE 'PA%')
 %exp:cWhere% 	
ORDER BY C5_CLIENTE,C6_PRODUTO
	EndSql

	aDados := GetLastQuery()


	nAtual:=0
	While !(cAlias)->(Eof())
		nAtual++

		//Se a linha atual mais o espaço que será utilizado forem maior que a linha final, imprime rodapé e cabeçalho
		If nLinAtu + nTamLin > nLinFin
			fImpRod()
			fImpCab()
		EndIf

		//zebra
		If nAtual % 2 == 0
			oPrintPvt:FillRect({nLinAtu, nColIni, nLinAtu + 8  , nColFin}, oBrushCinza)
		EndIf
		//Imprimindo a linha atual

			aSB8Total:=getSB8Total((cAlias)->C6_PRODUTO)
	
		oPrintPvt:SayAlign(nLinAtu, COL_PEDIDO, (cAlias)->PEDIDO, oFontDet, 0080, nTamLin, COR_PRETO, PAD_LEFT, 0)
		oPrintPvt:SayAlign(nLinAtu, COL_PRODUTO, (cAlias)->C6_PRODUTO,  oFontDet, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
		oPrintPvt:SayAlign(nLinAtu, COL_DPD, (cAlias)->C6_PEDCLI,  oFontDet, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
		oPrintPvt:SayAlign(nLinAtu, COL_DESCRI, (cAlias)->C6_DESCRI,  oFontDet, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
		oPrintPvt:SayAlign(nLinAtu, COL_QTDVEN, alltrim(TRANSFORM((cAlias)->C6_QTDVEN,"@E 999,999.99")),  oFontDet, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
		oPrintPvt:SayAlign(nLinAtu, COL_PRCVEN, alltrim(TRANSFORM((cAlias)->C6_PRCVEN,"@E 999,999.9999")),  oFontDet, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
		oPrintPvt:SayAlign(nLinAtu, COL_ENTREG, dtoc(stod((cAlias)->C6_ENTREG)),  oFontDet, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
		oPrintPvt:SayAlign(nLinAtu, COL_PEDCLI, alltrim((cAlias)->C6_PEDCLI)+' '+alltrim((cAlias)->C6_ITEMPC),  oFontDet, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
		//oPrintPvt:SayAlign(nLinAtu, COL_DTVALID, dtoc(stod(aSB8[2])),  oFontDet, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
		//oPrintPvt:SayAlign(nLinAtu, COL_LOCAL, (cAlias)->C6_LOCAL,  oFontDet, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
		//oPrintPvt:SayAlign(nLinAtu, COL_LOCALIZ, (cAlias)->C6_LOCALIZ,  oFontDet, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
		//oPrintPvt:SayAlign(nLinAtu, COL_LOTECTL, (cAlias)->C6_LOTECTL,  oFontDet, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)

		oPrintPvt:SayAlign(nLinAtu, COL_QTDENT, alltrim(TRANSFORM((cAlias)->C6_QTDENT,"@E 999,999.99")),  oFontDet, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
		oPrintPvt:SayAlign(nLinAtu, COL_DISPONIVEL, alltrim(TRANSFORM(aSB8Total[1],"@E 999,999.99")),  oFontDet, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
		// cria sublinha
		if aSB8Total[1]>0
			aSB8:=getSB8((cAlias)->C6_PRODUTO)
			nLinAtu += nTamLin
			oPrintPvt:SayAlign(nLinAtu, COL_PEDIDO, "Detalhe:", oFontDetN, 0080, nTamLin, COR_PRETO, PAD_LEFT, 0)
			for i:=1 to len(aSB8)
			nLinAtu += nTamLin

			If nLinAtu + nTamLin > nLinFin
			fImpRod()
			fImpCab()
			EndIf

			oPrintPvt:SayAlign(nLinAtu, COL_LOTECTL,"Lote "+aSB8[i,1],  oFontDet, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
			oPrintPvt:SayAlign(nLinAtu, COL_DTVALID,"Val. "+ dtoc(stod(+aSB8[i,2])),  oFontDet, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
			oPrintPvt:SayAlign(nLinAtu, COL_LOCAL,"Local "+aSB8[i,3],  oFontDet, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
			//oPrintPvt:SayAlign(nLinAtu, COL_LOCALIZ,"Localz "+aSB8[i,4],  oFontDet, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
			oPrintPvt:SayAlign(nLinAtu, COL_QTDESTOQ, alltrim(TRANSFORM(aSB8[i,4],"@E 999,999.99")),  oFontDet, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
			
		next
			nLinAtu += nTamLin
		endif

		nLinAtu += nTamLin

		(cAlias)->(DBSKIP())

	EndDo


	(cAlias)->(DBCLOSEAREA())

	nLinAtu += nTamLin


	//Se ainda tiver linhas sobrando na página, imprime o rodapé final
	If nLinAtu <= nLinFin
		fImpRod()
	EndIf

	//Se for via job, imprime o arquivo para gerar corretamente o pdf
	oPrintPvt:Preview()

Return


Static Function getSB8Total(sProduto)

	local aLote := {}
	cAlias2 := getNextAlias()
	aAdd(aLote,0)
	aAdd(aLote,'')
	
	BeginSql Alias cAlias2
			

		SELECT sum(B8_SALDO) B8_SALDO 
		FROM %TABLE:SB8% SB8
		where D_E_L_E_T_<>'*'
		AND B8_PRODUTO=%EXP:sProduto%
		AND B8_SALDO>0
	EndSql


	While !(cAlias2)->(Eof())
		aLote[1]+=(cAlias2)->B8_SALDO
		(cAlias2)->(DBSKIP())

	EndDo


	(cAlias2)->(DBCLOSEAREA())

Return aLote




Static Function getSB8(sProduto)

	local aLotes := {}
	cAlias2 := getNextAlias()
	
	BeginSql Alias cAlias2
			
		SELECT B8_LOTECTL,B8_DTVALID,B8_LOCAL,sum(B8_SALDO) B8_SALDO
		FROM %TABLE:SB8%  B8
		where B8.D_E_L_E_T_<>'*'
		AND B8_FILIAL='00'
		AND B8_PRODUTO=%EXP:sProduto%
		AND B8_SALDO>0
		GROUP BY B8_LOTECTL,B8_DTVALID,B8_LOCAL

	EndSql


	While !(cAlias2)->(Eof())
		
		aadd(aLotes,{(cAlias2)->B8_LOTECTL,(cAlias2)->B8_DTVALID,(cAlias2)->B8_LOCAL,(cAlias2)->B8_SALDO})
		(cAlias2)->(DBSKIP())

	EndDo


	(cAlias2)->(DBCLOSEAREA())

Return aLotes


/*---------------------------------------------------------------------*
 | Func:  fImpCab                                                      |
 | Desc:  Função que imprime o cabeçalho                               |
 *---------------------------------------------------------------------*/
 
Static Function fImpCab()
    Local cTexto   := ""
    Local nLinCab  := 030
     
    //Iniciando Página
    oPrintPvt:StartPage()
     
    //Cabeçalho
    //cTexto := "Relat�rio pedido "+sClientenome
	cTexto := "Relat�rio de pedido em aberto"
    oPrintPvt:SayAlign(nLinCab, nColMeio - 120, cTexto, oFontTit, 240, 20, COR_CINZA, PAD_CENTER, 0)
     
    //Linha Separatória
    nLinCab += (nTamLin * 2)
    oPrintPvt:Line(nLinCab, nColIni, nLinCab, nColFin, COR_CINZA)
     
    //Cabeçalho das colunas
    nLinCab += nTamLin
    //oPrintPvt:SayAlign(nLinCab, 80, "Vendedor "+sCodVendedor,     oFontDetN, 0080, nTamLin, COR_PRETO, PAD_LEFT, 0)



		oPrintPvt:SayAlign(nLinCab, COL_PEDIDO, "Pedido", oFontDetN, 0080, nTamLin, COR_PRETO, PAD_LEFT, 0)
		oPrintPvt:SayAlign(nLinCab, COL_PRODUTO, "COD",  oFontDetN, 0080, nTamLin, COR_PRETO, PAD_LEFT, 0)
		oPrintPvt:SayAlign(nLinCab, COL_DPD, "DPD",  oFontDetN, 0080, nTamLin, COR_PRETO, PAD_LEFT, 0)
		oPrintPvt:SayAlign(nLinCab, COL_DESCRI,"Produto",  oFontDetN, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
		oPrintPvt:SayAlign(nLinCab, COL_QTDVEN, "Quant. Pedido",  oFontDetN, 0080, nTamLin, COR_PRETO, PAD_LEFT, 0)
		oPrintPvt:SayAlign(nLinCab, COL_PRCVEN, "Prc Vend",  oFontDetN, 0080, nTamLin, COR_PRETO, PAD_LEFT, 0)
		oPrintPvt:SayAlign(nLinCab, COL_ENTREG, "Dt. Entrega",  oFontDetN, 0080, nTamLin, COR_PRETO, PAD_LEFT, 0)
		oPrintPvt:SayAlign(nLinCab, COL_PEDCLI, "Ped. Cliente",  oFontDetN, 0080, nTamLin, COR_PRETO, PAD_LEFT, 0)
		//oPrintPvt:SayAlign(nLinCab, COL_DTVALID, "Dt. Validade",  oFontDetN, 0080, nTamLin, COR_PRETO, PAD_LEFT, 0)
		//oPrintPvt:SayAlign(nLinCab, COL_LOCAL, "Local",  oFontDetN, 0080, nTamLin, COR_PRETO, PAD_LEFT, 0)
		//oPrintPvt:SayAlign(nLinCab, COL_LOCALIZ, "Localizacao",  oFontDetN, 0080, nTamLin, COR_PRETO, PAD_LEFT, 0)
		//oPrintPvt:SayAlign(nLinCab, COL_LOTECTL, "Lote",  oFontDetN, 0080, nTamLin, COR_PRETO, PAD_LEFT, 0)
		oPrintPvt:SayAlign(nLinCab, COL_QTDENT, "Entregue",  oFontDetN, 0080, nTamLin, COR_PRETO, PAD_LEFT, 0)
		oPrintPvt:SayAlign(nLinCab, COL_DISPONIVEL, "Estoque",  oFontDetN, 0080, nTamLin, COR_PRETO, PAD_LEFT, 0)
	


    //oPrintPvt:SayAlign(nLinCab, 80, "Pedido",     oFontDetN, 0080, nTamLin, COR_PRETO, PAD_LEFT, 0)
    //oPrintPvt:SayAlign(nLinCab, 120, "Titulo",     oFontDetN, 0080, nTamLin, COR_PRETO, PAD_LEFT, 0)
    //oPrintPvt:SayAlign(nLinCab, 180, "Titulo",     oFontDetN, 0080, nTamLin, COR_PRETO, PAD_LEFT, 0) 
    //Atualizando a linha inicial do relatório
    nLinAtu := nLinCab + nTamLin+3
Return
 
/*---------------------------------------------------------------------*
 | Func:  fImpRod                                                      |
 | Desc:  Função que imprime o rodapé                                  |
 *---------------------------------------------------------------------*/
 
Static Function fImpRod()
    Local nLinRod   := nLinFin + nTamLin
    Local cTextoEsq := ''
    Local cTextoDir := ''
 
    //Linha Separatória
    oPrintPvt:Line(nLinRod, nColIni, nLinRod, nColFin, COR_CINZA)
    nLinRod += 3
     
    //Dados da Esquerda e Direita
    cTextoEsq := dToC(dDataGer) + "    " + cHoraGer + "    " +  "  Usuario  " + cNomeUsr
    cTextoDir := "P�gina " + cValToChar(nPagAtu)
     
    //Imprimindo os textos
    oPrintPvt:SayAlign(nLinRod, nColIni,    cTextoEsq, oFontRod, 500, 05, COR_CINZA, PAD_LEFT,  0)
    oPrintPvt:SayAlign(nLinRod, nColFin-40, cTextoDir, oFontRod, 040, 05, COR_CINZA, PAD_RIGHT, 0)
     
    //Finalizando a página e somando mais um
    oPrintPvt:EndPage()
    nPagAtu++
Return


static function pergunta()

	Local aParamBox := {}, aRet := {}
	Local lOk := .T.

	aAdd(aParamBox,{1,"Data Entrega Inicio"  ,Ctod(Space(8)),"","","","",50,.F.}) // Tipo data
	aAdd(aParamBox,{1,"Data Entrega Fim"  ,Ctod(Space(8)),"","","","",50,.F.}) // Tipo data
	aAdd(aParamBox,{1,"Cliente",Space(6),"","","SA1","",0,.F.})
	aAdd(aParamBox,{1,"Produto",Space(15),"","","SB1","",0,.F.})
	
	If ParamBox(aParamBox," Informe o cliente",@aRet)
		dataInicio:=aRet[1]
		dataFim:=aRet[2]
        sCliente:=	alltrim(aRet[3])
		sProduto:=	alltrim(aRet[4])
		
				if !Empty(sCliente)
			dbselectarea("SA1")
			SA1->(dbsetorder(1))
			If SA1->(dbseek(xfilial("SA1") + sCliente))
				sClientenome:=SA1->A1_NREDUZ
				
			ENDIF
			SA1->(DBCLOSEAREA())
	endif


	else
		lOk := .F.
	endif

return lOk

