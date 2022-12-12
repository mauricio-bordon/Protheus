#include "topconn.ch"
#include "rwmake.ch"

User Function MT241IMP()

	local cFile, nLines, i
	Local _aCab1 := {}
	Local _aItem := {}
	Local _atotitem:={}
	Local cCodigoTM:="001"
	Local cCodProd, cUnid
	Local cNotImp := '', cDoc

	Private lMsHelpAuto := .t. // se .t. direciona as mensagens de help
	Private lMsErroAuto := .f. //necessario a criacao

	Begin Transaction
		cFile	:= memoread('D:\INDUCOAT\txt\carga-estoque.txt')
		nLines	:= MLCOUNT(cFile)
		nSomaHr := 0
		for i:=1 to nLines
			cLine  := memoLine(cFile,,i)
			aDados := strtokarr(cLine,';')
			conout(cLine)
			cLotectl := aDados[5]
			if "_"+alltrim(cLotectl)+"_"$"_0063360113_0068810108_0066320101_0069880107_0069880108_0069880109_0069890102_0069890103_0069890104_0070920101_0070920102_0069870105_0069870106_0069870107_0071340101_0071340102_0071340103_0071340104_"
				conout("Pulando "+cLotectl)	
				loop
			endif
			cCodProd := aDados[4]

			cAlias := getNextAlias()
			BEGINSQL ALIAS CALIAS
					SELECT B1_COD, B1_UM 
					FROM %TABLE:SB1%
					WHERE B1_FILIAL = %XFILIAL:SB1% AND %NOTDEL%
					AND ( B1_COD = %EXP:cCodProd% OR B1_CODOLD= %EXP:cCodProd%)
			ENDSQL

			IF (CALIAS)->(!EOF())
				cCodProd := (calias)->B1_COD
			ENDIF
			(calias)->(dbclosearea())
			dbSelectArea("SB1")
			SB1->(dBSETORDER(1))
			if !SB1->(DBSEEK(XFILIAL('SB1')+cCodProd))
				cNotImp += cLine + Chr(10) + Chr (13)
				loop
			else

			endif

			nD3Quant:= val(aDados[7])
			nD3Custo1:= val(aDados[8])
			cUnid := SB1->B1_UM

			cDoc := NextNumero("SD3",2,"D3_DOC",.T.)

			_aCab1 := {{"D3_DOC" , cDoc , NIL},;
				{"D3_TM" ,cCodigoTM , NIL},;
				{"D3_CC" ,"        ", NIL},;
				{"D3_EMISSAO" ,ddatabase, NIL}}


			_aItem:={{"D3_COD" ,cCodProd ,NIL},;
				{"D3_UM" ,cUnid ,NIL},;
				{"D3_QUANT" ,nD3Quant ,NIL},;
				{"D3_CUSTO1" ,nD3Custo1 ,NIL},;
				{"D3_LOCAL" ,"01" ,NIL},;
				{"D3_LOTECTL" ,cLotectl,NIL},;
				{"D3_LOCALIZ" , "LP",NIL},;
				{"D3_OBSERVA" , aDados[2]+'-'+aDados[3]+' - Qtd Nota: ' +cValtochar(aDados[9]) ,NIL}}
			_atotitem:={}
			aadd(_atotitem,_aitem)

			lMsErroAuto := .f.
			MSExecAuto({|x,y,z| MATA241(x,y,z)},_aCab1,_atotitem,3)

			If lMsErroAuto
				Mostraerro()
				DisarmTransaction()
				cNotImp += cLine + Chr(10) + Chr (13)
				exit
			else
				ConOut(" Incluido doc: " + cDoc)
				ConOut(" Distribuindo NF: " + cDoc)
				lOk := TMATA265(cDoc, SD3->D3_NUMSEQ)

				if !Lok 
					DisarmTransaction()
					ConOut("Erro na inclusao!")
					cNotImp += cLine + Chr(10) + Chr (13)
					exit
				endif
			EndIf

		next
	End Transaction

	IF !lMsErroAuto
		MemoWrite( "D:\INDUCOAT\txt\carga-erro.txt", cNotImp )
	endif
return



sTATIC Function TMATA265(cDoc, cNumSeq)
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
		AND DA_DOC = %EXP:cDoc% AND DA_ORIGEM = 'SD3' AND DA_NUMSEQ = %EXP:cNumSeq%
	endsql

	WHILE (cALIAS)->(!EOF())
		lMsErroAuto := .F.
		conout("Dist: "+ (cALIAS)->DA_PRODUTO + ' - '+(cALIAS)->DA_LOTECTL)
		//Cabecalho com a informaçãoo do item e NumSeq que sera endereçado.
		aCabSDA := {{"DA_PRODUTO" ,(cALIAS)->DA_PRODUTO,Nil},;
			{"DA_NUMSEQ"  ,(cALIAS)->DA_NUMSEQ,Nil}}

		//Dados do item que será endereçado
		aItSDB := {{"DB_ITEM"     ,"0001"      ,Nil},;
			{"DB_ESTORNO"  ," "       ,Nil},;
			{"DB_LOCALIZ"  ,"LP"    ,Nil},;
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
