#INCLUDE 'totvs.ch'
#INCLUDE 'FWMVCDEF.CH'

User Function BRWPALLET()

	Private nPltAtual := SC2->C2_NPLTPRX
	Private oMark, cQueryBase, cLotectl
	//Private aRotina := {} //MenuDef()
	ZD3->( dbsetorder(2) )
	oMark := FWMarkBrowse():New()
	oMark:SetAlias('ZD3')
//oMark:SetSemaphore(.T.)
	oMark:SetDescription('Montagem de Pallet Selo de Indução')
	oMark:SetFieldMark( 'ZD3_OK' )
	oMark:SetAllMark( { || oMark:AllMark() } )

//oMark:SetMark( cMark, "ZD3", "ZD3_OK" )
//oMark:AddLegend( "ZA0_TIPO=='1'", "YELLOW", "Autor" )
//oMark:AddLegend( "ZA0_TIPO=='2'", "BLUE" , "Interprete" )
	oMark:SetOnlyFields( { 'ZD3_PALLET', 'ZD3_COD', 'ZD3_LOTE', 'ZD3_TIRADA', 'ZD3_ROLO','ZD3_LARG' , 'ZD3_MTROLO' , 'ZD3_UM', 'ZD3_OK', 'ZD3_NUMSEQ' } )
	oMark:SetIgnoreARotina(.T.)
	oMark:SetMenuDef('')
	cLotectl := PAD( SC2->C2_NUM + SC2->C2_ITEM, 20)
	cQuery := " ZD3_LOTE == '" + cLotectl+ "' "
	if msgyesno('Exibir Apenas Rolos sem Pallet?', 'Pergunta')
		cQuery +=  " .AND. alltrim(ZD3_PALLET) == '' "
	ENDIF

	oMark:SetFilterDefault( cQuery )

	oMark:AddButton( "Montar Pallet", {|| MNTPLTSI(), printetq(), Self:End()} )
	oMark:AddButton( "Imprimir Etiqueta", {|| printetq(ZD3->ZD3_PALLET)} )
	oMark:AddButton( "Selecionar Registros", {|| selrolos()} )
	oMark:AddButton( "Limpar Seleção", {|| limrolos()} )
	oMark:AddButton( "Desmontar Pallet", {|| DMNTPLTSI()} )
	oMark:AddButton( "Sair", {|| Self:End()} )

	oMark:Activate()

Return NIL

STATIC FUNCTION PRINTETQ(cPallet)
	Local cAlias := getNextalias()
	// Local cOpLike := SC2->C2_NUM+'%'
	Local cLotectl := '', aItens := {}, nTotalMT := 0, nRolos := 0, cstr

	if empty(cPallet)
		cPallet := strzero(nPltAtual,3)
	endif
	BeginSql alias CALIAS
		SELECT  ZD3_COD, ZD3_LOTE, ZD3_MTROLO AS METROS, SUM(ZD3_MTROLO) AS totalMT, COUNT(*) as rolos
				FROM  %TABLE:ZD3% D3 
				WHERE ZD3_FILIAL = %XFILIAL:ZD3% AND D3.%NOTDEL% 
				AND ZD3_OP = %EXP:SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN+SC2->C2_ITEMGRD%
                AND ZD3_PALLET =  %EXP:cPallet%
            GROUP BY ZD3_COD, ZD3_MTROLO, ZD3_LOTE
	ENDSQL
	cStr := ''
	aItens := {}
	nTotalMt := 0
	nRolos := 0
	while (calias)->(!eof())
		cLotectl := (calias)->ZD3_LOTE
		cStr += " Faixa: "+(CALIAS)->ZD3_COD + " MT Linear: "+TRANSFORM((CALIAS)->METROS,"@E 999,999.999") ;
			+ " Total MT "+TRANSFORM((CALIAS)->totalMt,"@E 999,999.999") ;
			+ " Rolos: "+TRANSFORM((CALIAS)->ROLOS,"@E 999,999.999") + CHR(13) + CHR(10)

		aAdd(aItens, TRANSFORM((CALIAS)->ROLOS,"@E 99") + ' Rolos de '+TRANSFORM((CALIAS)->METROS,"@E 9,999.999") + " metros. " )
		nTotalMT += (CALIAS)->totalmt
		nRolos   += (CALIAS)->ROLOS
		(calias)->(DBSKIP())
	enddo
	(calias)->(DBCLOSEAREA())

	if len(aItens) > 0
		ETQSIPLT(SC2->C2_NUM, SC2->C2_PRODUTO, cLotectl, '', aItens, ntotalMt, 0, nRolos)
		MsgInfo(cStr, 'info')
	else
		MsgAlert("Linha selecionada não está associada a Pallet", 'Aviso')
	endif

RETURN

static FUNCTION selrolos()
	Local cInput, nRolos, i := 0
	Local cMarca := oMark:Mark()
	cInput := FWInputBox("Informe o quantidade de rolos do pallet."+chr(13)+chr(10)+"Os rolos já selecionados serão considerados", "")

	nRolos := val(cInput)

	ZD3->( dbGoTop() )

	While !ZD3->( EOF() )
		If !oMark:IsMark(cMarca) .and.  alltrim(ZD3->ZD3_PALLET) == ''
			oMark:MarkRec()
		EndIf
		If oMark:IsMark(cMarca)
			i++
		ENDIF
		if i == nRolos
			exit
		endif
		ZD3->( dbSkip() )
	Enddo
	if i< nRolos
		alert('Foram marcados apenas os '+transform(i, "@E 999")+" restantes.")
	endif
	ZD3->( dbGoTop() )
	oMark:refresh()
return

static FUNCTION limrolos()
	Local cMarca := oMark:Mark()
	ZD3->( dbGoTop() )

	While !ZD3->( EOF() )
		If oMark:IsMark(cMarca)
			oMark:MarkRec()
		EndIf
		ZD3->( dbSkip() )
	Enddo
	ZD3->( dbGoTop() )
	oMark:refresh()
return

STATIC Function MNTPLTSI()

	Local aArea := GetArea()
	Local cMarca := oMark:Mark()
//Local lInverte := oMark:IsInvert()
	Local nPltNext := nPltAtual + 1
	Local nCt := 0

	BEGIN TRANSACTION
		ZD3->( dbsetorder(2) )
		ZD3->( dbGoTop() )
		While !ZD3->( EOF() )
			If oMark:IsMark(cMarca)
				ZD3->(RECLOCK("ZD3", .F.))
				ZD3->ZD3_PALLET := strzero(nPltNext,3)
				ZD3->(MSUNLOCK())
				CONOUT(ZD3->ZD3_OP + ' - ' + strzero(ZD3->ZD3_TIRADA,3))
				nCt++
				oMark:MarkRec()
			EndIf
			ZD3->( dbSkip() )
		Enddo

		SC2->(RECLOCK('SC2',.F.))
		SC2->C2_NPLTPRX := NPLTNEXT
		SC2->(MsUnlock())
	END TRANSACTION
	nPltAtual := nPltNext
	ApMsgInfo( 'Foram associados ' + AllTrim( Str( nCt ) ) + ' rolos no pallet.' )
	RestArea( aArea )
	ZD3->( dbGoTop() )
	oMark:refresh()
Return NIL

STATIC Function DMNTPLTSI()

	Local aArea := GetArea()
	Local nCt := 0
	Local cPlt := ZD3->ZD3_PALLET

	if !MsgYesNo('Deseja desfazer a montagem do pallet '+cPlt+'?', 'Pergunta')
		RETURN
	endif

	BEGIN TRANSACTION
		ZD3->( dbGoTop() )
		While !ZD3->( EOF() )
			If cPlt == ZD3->ZD3_PALLET
				ZD3->(RECLOCK("ZD3", .F.))
				ZD3->ZD3_PALLET := SPACE(3)
				ZD3->(MSUNLOCK())
				CONOUT(ZD3->ZD3_OP + ' - ' + strzero(ZD3->ZD3_TIRADA,3))
				nCt++
			EndIf
			ZD3->( dbSkip() )
		Enddo

	END TRANSACTION
	ApMsgInfo( 'Pallet Removido' )
	RestArea( aArea )
	oMark:refresh()
Return NIL

static Function ETQSIPLT(CORDEM, CCOD, CLOTECTL, cCliente, aItens, ntotalMT, ntotalM2, nRolos)

	Local cStr := "", CALIAS, cLotesb8, i
	Local  cPedCli := '', cDtFabr, cDtValid, cDESC := ''
	Private aPort, cPort, nIni := 0, nFim := 0, NQtdRolo := 0

	cAlias := getNextalias()
	BeginSql alias CALIAS
        SELECT TOP 1 COALESCE(LTRIM(A1_NOME), ' ') AS A1_NOME, COALESCE(C6_PEDCLI, ' ') AS C6_PEDCLI, COALESCE(C6_ITEMPC, ' ') AS C6_ITEMPC, B1_DESC, A1_COD
        FROM %TABLE:SC2% C2 LEFT JOIN %TABLE:SC6% C6 ON (C6_NUM = C2_NUM AND C6_ITEM = C2_ITEM AND C2_SEQUEN = '001')
            INNER JOIN %TABLE:SA1% A1 ON (A1_COD = C6_CLI)
            INNER JOIN %TABLE:SB1% B1 ON (B1_COD = C2_PRODUTO)
        WHERE C2_FILIAL = %xfilial:SC2% AND C2.D_E_L_E_T_ <> '*'
        AND C6_FILIAL = %xfilial:SC6% AND C6.D_E_L_E_T_ <> '*'
        AND A1_FILIAL = %xfilial:SA1% AND A1.D_E_L_E_T_ <> '*'
        AND C2_NUM = %EXP:SC2->C2_NUM% AND C2_ITEM = %EXP:SC2->C2_ITEM% AND C2_SEQUEN = %EXP:SC2->C2_SEQUEN%
        AND C2_PRODUTO = %EXP:CCOD%
        order by C2.R_E_C_N_O_
	EndSQL

	IF (calias)->(!eof())
		cPedCli     := alltrim((CALIAS)->C6_PEDCLI)+"-"+alltrim((CALIAS)->C6_ITEMPC)
		cCliente    := alltrim((CALIAS)->A1_NOME)
		cDESC       := alltrim((CALIAS)->B1_DESC)
		cCodCli     := (CALIAS)->A1_COD
	endif

	(calias)->(dbclosearea())

/*
	cLotesb8 := 'OC'+cOrdem
	cAlias := getNextalias()
	BeginSql alias CALIAS
        SELECT TOP 1 B8_DFABRIC, B8_DTVALID
        FROM %TABLE:SB8% B8
        WHERE B8_FILIAL = '00' AND D_E_L_E_T_ <> '*'
        AND B8_LOTECTL = %EXP:cLotesb8% 
        order by R_E_C_N_O_
	EndSQL

	IF (calias)->(!eof())
		cDtFabr     := DTOC(StoD((CALIAS)->B8_DFABRIC))
		IF cCodCli == '003815'
			cDtValid    := DTOC(StoD((CALIAS)->B8_DFABRIC) + ( 365*2 ) )
		ELSE
			cDtValid    := DTOC(StoD((CALIAS)->B8_DFABRIC) + 365 )
		ENDIF
	endif
*/
	//carrega etiqueta
	CURDIR( 'etq' )
	cStrEtq := ''
	cStrEtq := MemoRead( "etq_pallet.txt" )

	cSaida := ''

	cStr := cStrEtq

	cStr := STRTRAN(cStr, "%DESC%", alltrim(cDESC) )
	cStr := STRTRAN(cStr, "%COD%", alltrim(cCOD) )
	cStr := STRTRAN(cStr, "%LOTE%", alltrim(cLOTECTL) )
	cStr := STRTRAN(cStr, "%CLIENTE%", cCliente)
	cStr := STRTRAN(cStr, "%TOTAL%", transform(ntotalMT, "@E 999,999.999"))
	cStr := STRTRAN(cStr, "%NROLOS%", transform(nRolos,"@E 999"))
	for i:=1 to len(aItens)
		cStr := STRTRAN(cStr, "%ITEM_"+(STRZERO(i,2))+"%", aItens[i])
	next
	for i:=len(aItens)+1 to 6
		cStr := STRTRAN(cStr, "%ITEM_"+(STRZERO(i,2))+"%", ' ')
	next
	cSaida += cStr +chr(10)+chr(13)


	MSGINFO( cSaida, 'ZPL' )

 /*
    cPort := 'LPT1' // prnLPTPort()
    FERASE("c:\windows\temp\zpl_etiqueta_pallet_si.prn" )
    MemoWrite("c:\windows\temp\zpl_etiqueta_pallet_si.prn", cSaida)
*/
cPort:='LPT2'
    if cPort == 'LPT1'
        Copy File "c:\windows\temp\zpl_etiqueta_pallet_si.prn" To LPT1
    elseif cPort == 'LPT2'
        Copy File "c:\windows\temp\zpl_etiqueta_pallet_si.prn" To LPT2
    endif


Return
