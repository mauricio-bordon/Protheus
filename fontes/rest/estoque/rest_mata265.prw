#include "protheus.ch"
#include "restful.ch"
#include 'rwmake.ch'
#Include "tbiconn.ch"


wsrestful Material_end description "WS MATA265 Endereca"
	wsdata cBarcode as char OPTIONAL
	wsdata cProduto as char OPTIONAL
	wsdata cLote as char OPTIONAL
	wsdata cLocal as char OPTIONAL
	wsdata cLoclz as char OPTIONAL
	wsdata cLocDest as char OPTIONAL
	wsdata cLoclzDest as char OPTIONAL
	wsdata nQuant as char optional

	WSMETHOD post ws1;
		DESCRIPTION "l para local designado" ;
		wssyntax "/Material_end/v1/endereca/{cLocDest}/{cLoclzDest}";
		PATH "/Material_end/v1/endereca/{cLocDest}/{cLoclzDest}"

	wsmethod get ws2;
		description "Consulta material para movimentacao" ;
		wssyntax "/Material_end/v1/consulta/{cBarcode}" ;
		path "/Material_end/v1/consulta/{cBarcode}"

end wsrestful

wsmethod post ws1 wsservice Material_end

	Local lret := .T.
	Local lok := .T.
	Local oJson
	Local cLote:=""

	Local cBody := ::getContent()

	Private cErrRest := ''

	oJson := JsonObject():new()
	oJson:fromJSON(cBody)


	cLocal_D 	:= 	::cLocDest
	cLoclz_D 	:= ::cLoclzDest
	cLote		:= oJson['LOTE']
	cproduto 	:= oJson['PRODUTO']
	nQuant		:= oJson['QUANTIDADE']

	lOk:= TMATA265(cLote,cLocal_D,cLoclz_D,nQuant)

		if !Lok

			oJson2 := JsonObject():new()
			oJson2['code']:='400'
			oJson2['message']:='Erro ao executar transferencia'
			oJson2['detailedMessage']:=cErrRest
			self:setStatus(400)
			::SetResponse(oJson2)
		else
			self:setStatus(200)
			oJson['LOTE']:=::cBarcode
			oJson['DESCRICAO']:=''
			oJson['QUANTIDADE']:=::nQuant
			oJson['EMPENHO']:=0
			oJson['LOCAL']:=''
			oJson['LOCALIZACAO']:=''
			self:setStatus(200)
			::SetResponse(oJson)
		endif


return lret

static function transfi(cCod, nQTD,cLocalOrig,cLoczOrigem, cLocalDest, cLoclzDest, cLote, cUserRest)

	Local aAuto := {}

	Local aLinha := {}
	Local lRet:=.T.

	//local dDtValid
	Private lMsErroAuto := .F.
	//cMaq := substr(cMaq,1,2)
	conout('Codigo '+cCod)
//conout('Qtd '+ alltrim(str(nqtd)))
	conout('Local Destino '+cLocalDest)
	conout('Loclz Destino '+cLoclzDest)
//	conout('Usuario '+cUserRest)
	conout('Lote '+cLote)
	//POSICIONA NA SB8
    SB8->(DBSETORDER(3))
    SB8->(DBSEEK(XFILIAL("SB8")+PadR(cCod, tamsx3('B8_PRODUTO') [1])+PadR(cLocalOrig, tamsx3('B8_LOCAL') [1])+PadR(cLote, tamsx3('B8_LOTECTL') [1])))
    conout("B8 "+SB8->B8_PRODUTO)
	conout("B8 Lote ->"+SB8->B8_LOTECTL)
	//dDtValid:=getvalidade(cCod,cLote);
	//lNovo := U_GERASB2(cCod, cLocalDest)

//u_zMta261(cCod, cLote, nQTD, cLocalOrig, cLoczOrigem, cLocalDest, cLoclzDest)
	Begin Transaction
		aadd(aAuto,{GetSxeNum("SD3","D3_DOC"),dDataBase}) //Cabecalho

		nx := 1
		aLinha := {}
//Origem 
		SB1->(MsSeek(xFilial("SB1")+PadR(cCod, tamsx3('D3_COD') [1])))

		aadd(aLinha,{"ITEM", strzero(nX,3), Nil})
		aadd(aLinha,{"D3_COD", SB1->B1_COD, Nil}) //Cod Produto origem
		aadd(aLinha,{"D3_DESCRI", SB1->B1_DESC, Nil}) //descr produto origem
		aadd(aLinha,{"D3_UM", SB1->B1_UM, Nil}) //unidade medida origem
		aadd(aLinha,{"D3_LOCAL", PadR(cLocalOrig, tamsx3('D3_LOCAL') [1]), Nil}) //armazem origem
		aadd(aLinha,{"D3_LOCALIZ",  PadR(cLoczOrigem, tamsx3('D3_LOCALIZ') [1]), Nil}) //endereço origem

//Destino 
		aadd(aLinha,{"D3_COD", SB1->B1_COD, Nil}) //cod produto destino
		aadd(aLinha,{"D3_DESCRI", SB1->B1_DESC, Nil}) //descr produto destino
		aadd(aLinha,{"D3_UM", SB1->B1_UM, Nil}) //unidade medida destino
		aadd(aLinha,{"D3_LOCAL", PadR(cLocalDest, tamsx3('D3_LOCAL') [1]) , Nil}) //armazem destino
		aadd(aLinha,{"D3_LOCALIZ", PadR(cLoclzDest, tamsx3('D3_LOCALIZ') [1]), Nil}) //endereço destino

		aadd(aLinha,{"D3_NUMSERI", "", Nil}) //Numero serie
		aadd(aLinha,{"D3_LOTECTL", PadR(cLote, tamsx3('D3_LOTECTL') [1]), Nil}) //Lote Origem
		aadd(aLinha,{"D3_NUMLOTE", "", Nil}) //sublote origem
	//	aadd(aLinha,{"D3_DTVALID", '', Nil}) //data validade
		aadd(aLinha,{"D3_DTVALID", SB8->B8_DTVALID, Nil}) //data validade
    
		aadd(aLinha,{"D3_POTENCI", 0, Nil}) // Potencia
		aadd(aLinha,{"D3_QUANT", nQTD, Nil}) //Quantidade
		aadd(aLinha,{"D3_QTSEGUM", 0, Nil}) //Seg unidade medida
		aadd(aLinha,{"D3_ESTORNO", "", Nil}) //Estorno
		aadd(aLinha,{"D3_NUMSEQ", "", Nil}) // Numero sequencia D3_NUMSEQ

		aadd(aLinha,{"D3_LOTECTL",  PadR(cLote, tamsx3('D3_LOTECTL') [1]), Nil}) //Lote destino
		aadd(aLinha,{"D3_NUMLOTE", "", Nil}) //sublote destino
		//aadd(aLinha,{"D3_DTVALID", dDtValid, Nil}) //validade lote destino
		//aadd(aLinha,{"D3_DTVALID", '', Nil}) //data validade 
		aadd(aLinha,{"D3_DTVALID", SB8->B8_DTVALID, Nil}) //data validade
    
		aadd(aLinha,{"D3_ITEMGRD", "", Nil}) //Item Grade
		aadd(aLinha,{"D3_CODLAN", "", Nil}) //cat83 prod origem
		aadd(aLinha,{"D3_CODLAN", "", Nil}) //cat83 prod destino

		//	aadd(aLinha,{"D3_USUARIO", cUserRest, Nil}) //Item Grade
		//	aadd(aLinha,{"D3_DTSIST", DATE(), Nil}) //Item Grade
		//	aadd(aLinha,{"D3_HRSIST", TIME(), Nil}) //Item Grade

		aAdd(aAuto,aLinha)

		oJson := JsonObject():new()
		oJson:set(aAuto)
		conout(ctxt := oJson:toJson())
		MSExecAuto({|x,y| mata261(x,y)},aAuto,3)

		conout(' Valor do lMsErroAuto apos execu??o')
		conout(lMsErroAuto)
		if lMsErroAuto
			cmsg:="Verificar no SIGAADV o log "+ALLTRIM(NomeAutoLog()+CHR(13))
			conout(cMsg)
			cErrRest := cmsg
			lRet:=.F.
		endif

		if !lret
			conout('erro na execução')
			DisarmTransaction()
		endif
	End Transaction
return lRet

wsmethod get ws2 wsservice Material_end
	local lRet as logical
	local aRmaterial
	local cLote, cProduto, nQuant := 0
	Local oJson, oJson2, i
	self:SetContentType("application/json")
	conout('cBarcode '+ ::cBarcode)
	aDados := StrTokArr( ::cBarcode, '-' )
	u_json_dbg(aDados)
	if len(aDados) == 2
		cLote := aDados[1]
		nQuant := val(aDados[2])/1000.0
	else 
		aDados := StrTokArr( ::cBarcode, ';' )
		
		//u_json_dbg(aDados)
		if len(aDados) == 1
			cLote := aDados[1]
		elseif len(aDados) == 2
			cLote := aDados[1]
			nQuant := val(strtran(strtran(aDados[2],'.',''),',','.'))
		elseif len(aDados) == 3
			cProduto := aDados[1]
			cLote := aDados[2]
			nQuant := val(strtran(strtran(aDados[3],'.',''),',','.'))
		endif
	endif
	aRmaterial:= getLote(cLote, cProduto, nQuant)
	oJson := JsonObject():new()


	If Len(aRmaterial) == 0

		::SetResponse('{ "message": "Lote Informado nao possui saldo ou nao existe.","detailedMessage": "Nao existe lote em estoque disponivel"}')

		self:setStatus(400)

	else
		aLotes := {}

		for i:=1 to len(aRmaterial)
			//aadd(aLotes, {})
			oJson2 := JsonObject():new()
			oJson2['PRODUTO']:=aRmaterial[i,1]
			oJson2['LOTE']:=aRmaterial[i,2]
			oJson2['DESCRICAO']:=aRmaterial[i,3]
			oJson2['UM']:=aRmaterial[i,4]
			if nQuant>0
				oJson2['QUANTIDADE']:=nQuant
		
			endif

			aadd(aLotes, oJson2)
			FreeObj(oJson2)
		next

		CONOUT("ENTROU 200")

		oJson:set(aLotes[1])
		oJson2 := JsonObject():new()
		oJson2['type']:='success'
		oJson2['code']:='200'
		oJson2['message']:='Lote Válido'
		//oJson2['detailedMessage']:='Lote Válido'
		//oJson['_messages'] = oJson2
		self:setStatus(200)
		::SetResponse(oJson)
		FREEOBJ( oJson2 )
	endif

	FreeObj(oJson)

	lRet := .T.

return lRet


static function getLote(cLote, cProduto, nQuant)
	Local cAlias
	Local aRmaterial := {}
	cAlias := getNextAlias()


	BeginSQL alias cAlias
		SELECT DA_PRODUTO, B1_UM, B1_TIPO,DA_LOTECTL,RTRIM(REPLACE(B1_DESC,'"','''')) as  B1_DESC
		FROM %TABLE:SDA% SDA
		INNER JOIN %TABLE:SB1% SB1
		ON B1_COD=DA_PRODUTO
		WHERE DA_FILIAL = %XFILIAL:SDA% AND SDA.%NOTDEL%
		AND SB1.%NOTDEL%
		AND DA_LOTECTL = %EXP:cLote% AND DA_ORIGEM = 'SD3' AND DA_SALDO > 0
	
	EndSQL

	u_dbg_qry()

	While !(cAlias)->(Eof())
		aAdd(aRmaterial, {})
		aAdd(aRmaterial[len(aRmaterial)], alltrim((cAlias)->DA_PRODUTO) )
		aAdd(aRmaterial[len(aRmaterial)], alltrim((cAlias)->DA_LOTECTL) )
		aAdd(aRmaterial[len(aRmaterial)], alltrim((cAlias)->B1_DESC) )
		aAdd(aRmaterial[len(aRmaterial)], alltrim((cAlias)->B1_UM) )
		(cAlias)->(dbSkip())
	enddo
	(cAlias)->(DbClosearea())


//	json_dbg(aRmaterial)

return aRmaterial


sTATIC Function TMATA265(CLOTECTL,cLocal,cLocaliz,nQuant)
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
		//Cabecalho com a informaçãoo do item e NumSeq que sera endereçado.
		aCabSDA := {{"DA_PRODUTO" ,(cALIAS)->DA_PRODUTO,Nil},;
			{"DA_NUMSEQ"  ,(cALIAS)->DA_NUMSEQ,Nil}}


		//Dados do item que será endereçado
		aItSDB := {{"DB_ITEM"     ,"0001"      ,Nil},;
			{"DB_ESTORNO"  ," "       ,Nil},;
			{"DB_LOCALIZ"  ,cLocaliz    ,Nil},;
			{"DB_DATA"    ,dDataBase   ,Nil},;
			{"DB_QUANT"  ,nQuant          ,Nil}}
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

