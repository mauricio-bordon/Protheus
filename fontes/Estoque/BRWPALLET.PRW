#INCLUDE 'totvs.ch'
#INCLUDE 'FWMVCDEF.CH'
#include "RWMAKE.ch"

User Function BRWPALLET()

	Local cOP,lTodosRolos:=.T.
	Private  SC2->C2_NPLTPRX := SC2->C2_NPLTPRX
	Private oMark, cQueryBase, cLotectl

	//verifica se existe lancamento da qualidade
	cOP:=alltrim(SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN)
	dbselectarea('ZQ0')
	ZQ0->(dbsetorder(1))
	ZQ0->(dbseek(xfilial("ZQ0")+cOP))

	IF ZQ0->(!FOUND())
		MsgBox ("Apontamento da qualidade nao encontrado. Aponte em Mais acoes ->Qualidade apontamento","Erro!!!","STOP")
		Return
	endif

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
	oMark:SetOnlyFields( { 'ZD3_PALLET','ZD3_CAIXA', 'ZD3_COD', 'ZD3_LOTE', 'ZD3_TIRADA', 'ZD3_ROLO','ZD3_LARG' , 'ZD3_MTROLO' , 'ZD3_UM', 'ZD3_OK', 'ZD3_NUMSEQ' } )
	oMark:SetIgnoreARotina(.T.)
	oMark:SetMenuDef('')
	cLotectl := PAD( SC2->C2_NUM + SC2->C2_ITEM, 20)
	cQuery := " ZD3_LOTE == '" + cLotectl+ "' "
	if msgyesno('Exibir Apenas Rolos sem Pallet?', 'Pergunta')
		lTodosRolos:=.F.
		cQuery +=  " .AND. alltrim(ZD3_PALLET) == '' "
	ENDIF

	oMark:SetFilterDefault( cQuery )

	oMark:AddButton( "Montar Pallet", {|| MNTPLTSI()} ) //, Self:End()
	oMark:AddButton( "Imprime Etiq Pallet", {|| printetq(ZD3->ZD3_OP, ZD3->ZD3_PALLET)} )
	oMark:AddButton( "Imprime Etiq Caixa", {|| printcaix(ZD3->ZD3_OP)} )
	if lTodosRolos
		oMark:AddButton( "Monta Caixas", {|| MNTCAIXA()} )
	endif
	oMark:AddButton( "Selecionar Registros", {|| selrolos()} )
	oMark:AddButton( "Limpar Seleção", {|| limrolos()} )
	oMark:AddButton( "Desmontar Pallet", {|| DMNTPLTSI()} )
	oMark:AddButton( "Sair", {|| Self:End()} )

	oMark:Activate()

Return NIL

STATIC FUNCTION PRINTCAIX(cOP)
	Local cAlias := getNextalias()
	Local nCaixa:=0
	//carrega etiqueta
	CURDIR( 'etq' )
	cStrEtq := ''
	cStrEtq := MemoRead( "etq_caixa.txt" )

	cSaida := ''

	cStr := cStrEtq


	BeginSql alias CALIAS
		SELECT ZD3_OP,ZD3_COD,ZD3_LOTE,ZD3_CAIXA,COUNT(ZD3_MTROLO) AS QTDROLO,SUM(ZD3_MTROLO) AS TOTAL
		FROM %TABLE:ZD3% D3 
		WHERE ZD3_FILIAL = %XFILIAL:ZD3% 
		AND D3.%NOTDEL% 
		AND ZD3_OP=%EXP:cOP%
		AND D_E_L_E_T_<>'*'
		GROUP BY ZD3_OP,ZD3_COD,ZD3_LOTE,ZD3_CAIXA
	ENDSQL

	while (calias)->(!eof())
		nCaixa++
		(calias)->(DBSKIP())
	enddo

	(calias)->(DBgoTOP())

	while (calias)->(!eof())
		cStr := cStrEtq
		cStr := STRTRAN(cStr, "%B1_COD%", alltrim((CALIAS)->ZD3_COD) )
		cStr := STRTRAN(cStr, "%B1_DESC%", alltrim(POSICIONE('SB1',1,XFILIAL('SB1')+(CALIAS)->ZD3_COD,"B1_DESC")) )
		cStr := STRTRAN(cStr, "%ZD3_LOTE%", alltrim((CALIAS)->ZD3_LOTE) )

		cPrint1:=alltrim(transform((CALIAS)->QTDROLO,"@E 999"))+" Rolo(s) na caixa"
		cStr := STRTRAN(cStr, "%PRINT1%", cPrint1)

		cPrint2:="Quantidade "+alltrim(transform((CALIAS)->TOTAL,"@E 99999"))+" "+alltrim(POSICIONE('SB1',1,XFILIAL('SB1')+(CALIAS)->ZD3_COD,"B1_UM"))
		cStr := STRTRAN(cStr, "%PRINT2%", cPrint2)

		cStr :=STRTRAN(cStr, "%CAIXA%", alltrim(transform((CALIAS)->ZD3_CAIXA,"@E 999"))+' / '+alltrim(transform(nCaixa,"@E 999")) )
		sCodbar:=alltrim((CALIAS)->ZD3_LOTE)+";"+alltrim(transform((CALIAS)->ZD3_CAIXA,"@E 999"))+";"+alltrim(transform((CALIAS)->TOTAL,"@E 99999"))
		cStr :=STRTRAN(cStr, "%CODBAR%", sCodbar )

		cSaida += cStr +chr(10)+chr(13)

		(calias)->(DBSKIP())
	enddo
	(calias)->(DBCLOSEAREA())

	FERASE("c:\windows\temp\zpl_etq_caixa.prn" )
	MemoWrite("c:\windows\temp\zpl_etq_caixa.prn", cSaida)
	Copy File "c:\windows\temp\zpl_etq_caixa.prn" To LPT1


return

STATIC FUNCTION PRINTETQ(cOP, cPallet)
	Local cAlias := getNextalias()
	Local lPallet:=.T.
	// Local cOpLike := SC2->C2_NUM+'%'
	Local cLotectl := '', aItens := {}, nTotalMT := 0, nRolos := 0, cstr

	DbSelectArea('ZD2')
	ZD2->(DBSETORDER(1))
	ZD2->(DBSEEK(XFILIAL('ZD2')+cOp+cPallet))

	BeginSql alias CALIAS
		SELECT  ZD3_COD, ZD3_LOTE, ZD3_MTROLO AS METROS, SUM(ZD3_MTROLO) AS totalMT, COUNT(*) as rolos
				FROM  %TABLE:ZD3% D3 
				WHERE ZD3_FILIAL = %XFILIAL:ZD3% AND D3.%NOTDEL% 
				AND ZD3_OP = %EXP:cOp%
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
			+ " Rolos: "+((CALIAS)->ROLOS,"@E 999,999.999") + CHR(13) + CHR(10)

		aAdd(aItens, TRANSFORM((CALIAS)->ROLOS,"@E 99") + ' Rolos de '+TRANSFORM((CALIAS)->METROS,"@E 9,999.999") + " metros. " )
		nTotalMT += (CALIAS)->totalmt
		nRolos   += (CALIAS)->ROLOS
		(calias)->(DBSKIP())
	enddo
	(calias)->(DBCLOSEAREA())

	if len(aItens) > 0
		ETQSIPLT(SC2->C2_NUM,SC2->C2_ITEM, SC2->C2_PRODUTO,SC2->C2_LOCAL, cLotectl, ZD2->ZD2_CODCLI, aItens, ntotalMt, 0, nRolos, ZD2->ZD2_PESOLI, ZD2->ZD2_PESOBR)
		MsgInfo(cStr, 'Info')
	else
		MsgAlert("Linha selecionada não está associada a Pallet", 'Aviso')
	endif

	//verfifica se todos os itens foram palletizado
	/*
	dbSelectArea("ZD3")
	ZD3->(dbSetOrder(1)) //ZT0_FILIAL+ZT0_NUMOP+ZT0_ITEM
	ZD3->(dbSeek(xFilial("ZD3")+cOP))

*/	
		ZD3->( dbGoTop() )

	Do while ZD3->(!eof())  .And. ZD3->ZD3_OP = cOP
		//se existir rolo sem pallet aguarda.
		if EMPTY(alltrim(ZD3->ZD3_PALLET))
			lPallet:=.F.
			
			return
		endif
		ZD3->(dbSkip())
	Enddo

	//ZD3->(dbclosearea())

//se todos os rolos foram colocado em pallet envia email sobre o peso
	if lPallet
	//Alert()
	//cAssunto:="Finalizado op"
	//u_EnvMail( cAssunto, cHTML, c_ends, 'sistema@inducoat.com.br' )	

	ENDIF


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

STATIC Function MNTCAIXA()
//para montagem de caixas deve ser aviso para não filtrar apenas rolos no pallet.
	local nPorcaixa:=0,nQuant:=1,nCaixa:=1,lOk:=.F.
	Local aArea := GetArea()

	DEFINE MSDIALOG _oPT00005 FROM  50, 050 TO 250,250 TITLE OemToAnsi('Monta Caixa') PIXEL

	@ 010,005 Say OemToAnsi("Digite quantidade de rolos por caixa: ") Size 100,030

	@ 030,005 Get nPorcaixa PICT "@E 99"  Valid .t. Size 20,030

	@ 050,005 Button OemToAnsi("Montar Caixas") Size 036,016 Action (lOk := .T.,_oPT00005:End())
	@ 070,005 Button OemToAnsi("Cancelar")  Size 036,016 Action (_oPT00005:End())

	Activate Dialog _oPT00005 CENTERED

	if !lOK
		RETURN .F.
	endif

	if lOk

		BEGIN TRANSACTION
			ZD3->( dbGoTop() )
			While !ZD3->( EOF() )
				if nQuant<=nPorcaixa
					nQuant++

				else
					nCaixa++
					nQuant:=2
				endif

				ZD3->(RECLOCK("ZD3", .F.))
				ZD3->ZD3_CAIXA := nCaixa
				ZD3->(MSUNLOCK())

				ZD3->( dbSkip() )
			Enddo

		END TRANSACTION
		RestArea( aArea )
		oMark:refresh()

	endif
Return



STATIC Function MNTPLTSI()

	Local aArea := GetArea()
	Local cMarca := oMark:Mark()
//Local lInverte := oMark:IsInvert()
	Local nPltNext :=  SC2->C2_NPLTPRX + 1
	Local nCt := 0 , lOk := .F., cOP := SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN+SC2->C2_ITEMGRD
	Local cCliente := space(6), cLojacli:= space(2), nPesoLiq := 0, nPesoBruto := 0

	dbSelectArea("SC5")
	SC5->(dbSetorder(1))
	SC5->(DBSEEK(XFILIAL('SC5')+SC2->C2_PEDIDO))
	IF SC5->(FOUND())
		cCliente:= SC5->C5_CLIENTE
	ENDIF



	DEFINE MSDIALOG _oPT00005 FROM  50, 050 TO 250,500 TITLE OemToAnsi('Novo Pallet') PIXEL

	@ 010,005 Say OemToAnsi("Cliente: ") Size 040,030
	@ 020,005 Say OemToAnsi("Peso Liquido:") Size 070,030
	@ 030,005 Say OemToAnsi("Peso Bruto:") Size 070,030

	@ 010,060 Get cCliente F3 "SA1" Valid .t. Size 80,030
	@ 020,060 Get nPesoLiq PICT "@E 9,999.999"  Valid .t. Size 80,030
	@ 030,060 Get nPesoBruto PICT "@E 9,999.999"  Valid .t. Size 80,030

	@ 060,040 Button OemToAnsi("Montar Pallet") Size 036,016 Action (lOk := .T.,_oPT00005:End())
	@ 060,095 Button OemToAnsi("Cancelar")  Size 036,016 Action (_oPT00005:End())

	Activate Dialog _oPT00005 CENTERED

	if !lOK
		RETURN .F.
	endif

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

		DbSelectArea('ZD2')
		ZD2->(RECLOCK('ZD2',.T.))
		ZD2->ZD2_FILIAL := XFILIAL('ZD2')
		ZD2->ZD2_OP 	:= cOP
		ZD2->ZD2_PALLET := strzero(nPltNext,3)
		ZD2->ZD2_CODCLI := cCliente //TODO INFORMAR CLIENTE
		ZD2->ZD2_LOJCLI	:= cLojacli // TODO INFORMAR LOJA CLIENTE
		ZD2->ZD2_PESOLI := nPesoLiq	//todo informar peso liquido
		ZD2->ZD2_PESOBR := nPesoBruto	//todo informar peso bruto
		ZD2->(MsUnlock())

	END TRANSACTION

	ApMsgInfo( 'Foram associados ' + AllTrim( Str( nCt ) ) + ' rolos no pallet.' )
	RestArea( aArea )
	ZD3->( dbGoTop() )
	oMark:refresh()

	printetq(cOP, strzero( SC2->C2_NPLTPRX,3))
Return .T.

STATIC Function DMNTPLTSI()

	Local aArea := GetArea()
	Local nCt := 0
	Local cPlt := ZD3->ZD3_PALLET

	if SC2->C2_NPLTPRX <> val(cPlt)
		MsgStop('Pallet devem ser desmontados na ordem contrária que foram criados. Último pallet: '+CValToChar(SC2->C2_NPLTPRX ), 'Erro')
		return
	endif

	if !MsgYesNo('Deseja desfazer a montagem do pallet '+cPlt+'?', 'Pergunta')
		RETURN
	endif

//POSICIONA NO CABEÇALHO
	DbSelectArea('ZD2')
	ZD2->(DBSETORDER(1))
	ZD2->(DBSEEK(XFILIAL('ZD2')+ZD3->ZD3_OP+ZD3->ZD3_PALLET))

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

		ZD2->(RECLOCK("ZD2", .F.))
		ZD2->(dbdelete())
		ZD2->(MsUnlock())

		SC2->(RECLOCK('SC2',.F.))
		SC2->C2_NPLTPRX := SC2->C2_NPLTPRX - 1
		SC2->(MsUnlock())
	END TRANSACTION
	ApMsgInfo( 'Pallet Removido' )
	RestArea( aArea )
	oMark:refresh()
Return NIL

static Function ETQSIPLT(CORDEM,cItemop, CCOD,cLocal, CLOTECTL, cCliente, aItens, ntotalMT, ntotalM2, nRolos, nPesoLiq, nPesoBruto)

	Local cStr := "", i//, CALIAS
	//Local  cDESC := ''
	Private aPort, cPort, nIni := 0, nFim := 0, NQtdRolo := 0

/*
	cAlias := getNextalias()
	BeginSql alias CALIAS
        SELECT TOP 1 COALESCE(LTRIM(A1_NOME), ' ') AS A1_NOME, COALESCE(C6_PEDCLI, ' ') AS C6_PEDCLI, COALESCE(C6_ITEMPC, ' ') AS C6_ITEMPC, B1_DESC, A1_COD
        FROM %TABLE:SC2% C2 LEFT JOIN %TABLE:SC6% C6 ON (C6_NUMOP = C2_NUM AND C6_ITEMOP = C2_ITEM AND C2_SEQUEN = '001')
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
		//cPedCli     := alltrim((CALIAS)->C6_PEDCLI)+"-"+alltrim((CALIAS)->C6_ITEMPC)
		cCliente    := alltrim((CALIAS)->A1_NOME)
		cDESC       := alltrim((CALIAS)->B1_DESC)
		//cCodCli     := (CALIAS)->A1_COD
	endif

	(calias)->(dbclosearea())
*/
	//carrega etiqueta
	CURDIR( 'etq' )
	cStrEtq := ''
	cStrEtq := MemoRead( "etq_pallet.txt" )

	cSaida := ''

	cStr := cStrEtq
	//verifica se existe DPD para o produto
	cDPD:=alltrim(POSICIONE('SC6',7,XFILIAL('SC6')+CORDEM+cItemop,"C6_DPD"))
	cPedCli:=alltrim(POSICIONE('SC6',7,XFILIAL('SC6')+CORDEM+cItemop,"C6_PEDCLI"))
	
	cStr := STRTRAN(cStr, "%DESC%", alltrim(POSICIONE('SB1',1,XFILIAL('SB1')+cCod,"B1_DESC")) )
	cStr := STRTRAN(cStr, "%DESC%", alltrim(POSICIONE('SB1',1,XFILIAL('SB1')+cCod,"B1_DESC")))
	cStr := STRTRAN(cStr, "%COD%", alltrim(cCOD) )
 	cStr := STRTRAN(cStr, "%DPD%", alltrim(cDPD) )
	cStr := STRTRAN(cStr, "%PEDCLI%", alltrim(cPedCli) )
	
	cStr := STRTRAN(cStr, "%LOTE%", alltrim(cLOTECTL) )
	cStr := STRTRAN(cStr, "%BARCODE%", alltrim(cLOTECTL) )
	cStr := STRTRAN(cStr, "%CLIENTE%", alltrim(POSICIONE('SA1',1,XFILIAL('SA1')+cCliente,"A1_NOME")) )
	cStr := STRTRAN(cStr, "%PESOLIQ%", transform(nPesoLiq, "@E 9,999.999")+' kg')
	cStr := STRTRAN(cStr, "%PESOBRUTO%", transform(nPesoBruto, "@E 9,999.999")+' kg')
	cStr := STRTRAN(cStr, "%TOTAL%", transform(ntotalMT, "@E 999,999.999"))
	cStr := STRTRAN(cStr, "%NROLOS%", transform(nRolos,"@E 999"))
	for i:=1 to len(aItens)
		cStr := STRTRAN(cStr, "%ITEM_"+(STRZERO(i,2))+"%", aItens[i])
	next
	for i:=len(aItens)+1 to 6
		cStr := STRTRAN(cStr, "%ITEM_"+(STRZERO(i,2))+"%", ' ')
	next
	cSaida += cStr +chr(10)+chr(13)

	//debug zpl
	//MSGINFO( cSaida, 'ZPL' )


	cPort := 'LPT2' // prnLPTPort()
	FERASE("c:\windows\temp\zpl_etiqueta_pallet_si.prn" )
	MemoWrite("c:\windows\temp\zpl_etiqueta_pallet_si.prn", cSaida)

	if cPort == 'LPT1'
		Copy File "c:\windows\temp\zpl_etiqueta_pallet_si.prn" To LPT1
	elseif cPort == 'LPT2'
		Copy File "c:\windows\temp\zpl_etiqueta_pallet_si.prn" To LPT2
	endif

	//ENDEREÇA PARA EXP
	lRet:=TMATA265(CLOTECTL,cLocal)

Return



sTATIC Function TMATA265(CLOTECTL,cLocal)
	Local aCabSDA       := {}
	Local aItSDB        := {}
	Local _aItensSDB    := {}
	Local cAlias
	Private lMsErroAuto := .F.


	cAlias := Getnextalias()


	BeginSql alias calias
		SELECT *
		FROM %TABLE:SDA%
		WHERE DA_FILIAL = %XFILIAL:SDA% AND %NOTDEL%
		AND DA_LOTECTL = %EXP:CLOTECTL% AND DA_ORIGEM = 'SD3' AND DA_SALDO > 0
	endsql

	WHILE (cALIAS)->(!EOF())
		lMsErroAuto := .F.
		conout("Dist: "+ (cALIAS)->DA_PRODUTO + ' - '+(cALIAS)->DA_LOTECTL)
		//Cabecalho com a informaÃ§Ã£oo do item e NumSeq que sera endereÃ§ado.
		aCabSDA := {{"DA_PRODUTO" ,(cALIAS)->DA_PRODUTO,Nil},;
			{"DA_NUMSEQ"  ,(cALIAS)->DA_NUMSEQ,Nil}}


		if cLocal == '02'
			cLocaliz:='EXP'
		else
			cLocaliz:='LP'
		endif
		//Dados do item que serÃ¡ endereÃ§ado
		aItSDB := {{"DB_ITEM"     ,"0001"      ,Nil},;
			{"DB_ESTORNO"  ," "       ,Nil},;
			{"DB_LOCALIZ"  ,cLocaliz    ,Nil},;
			{"DB_DATA"    ,dDataBase   ,Nil},;
			{"DB_QUANT"  ,(cALIAS)->DA_SALDO           ,Nil}}
		_aItensSDB := {}
		aadd(_aItensSDB,aitSDB)

		//Executa o endere?amento do item
		MATA265( aCabSDA, _aItensSDB, 3)
		If lMsErroAuto
			MostraErro()
			EXIT
		Endif
		(CALIAS)->(DBSKIP())
	ENDDO
	(CALIAS)->(DBCLOSEAREA())

	IF lMsErroAuto
		RETURN .F.
	ENDIF
Return .T.

