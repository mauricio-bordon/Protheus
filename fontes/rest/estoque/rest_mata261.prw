#include "protheus.ch"
#include "restful.ch"
#include 'rwmake.ch'
#Include "tbiconn.ch"


wsrestful Material_mov description "WS MATA261"
	wsdata cBarcode as char OPTIONAL
	wsdata cProduto as char OPTIONAL
	wsdata cLote as char OPTIONAL
	wsdata cLocal as char OPTIONAL
	wsdata cLoclz as char OPTIONAL
	wsdata cLocDest as char OPTIONAL
	wsdata cLoclzDest as char OPTIONAL
	wsdata nQuant as char optional

	WSMETHOD post ws1;
		DESCRIPTION "Transfere material para local designado" ;
		wssyntax "/Material_mov/v1/transfere";
		PATH "/Material_mov/v1/transfere"

	wsmethod get ws2;
		description "Consulta material para movimentacao" ;
		wssyntax "/Material_mov/v1/consulta/{cBarcode}" ;
		path "/Material_mov/v1/consulta/{cBarcode}"

end wsrestful

wsmethod post ws1 wsservice Material_mov

	Local lret := .T.
	Local lok := .T.
	Local oJson, cAlias
	Local cLote:=""


	Local cBody := ::getContent()

	Private cErrRest := ''

	oJson := JsonObject():new()
	oJson:fromJSON(cBody)

	//u_json_dbg(cBody)

	//valida destino

	cLocal_O 	:= oJson['LOCAL_ORIGEM'] //2 primeiras posicoes para local
	cLoclz_O 	:= oJson['LOCALIZACAO_ORIGEM'] //restante para localização~
	cLocal_D 	:= oJson['LOCAL_DESTINO'] //2 primeiras posicoes para local
	cLoclz_D 	:= oJson['LOCALIZACAO_DESTINO'] //restante para localização~
	cLote		:= oJson['LOTE']
	cproduto 	:= oJson['PRODUTO']
	nQuant		:= oJson['QUANTIDADE']
	cAlias := getNexTAlias()
	BeginSQL alias cAlias
		SELECT *
		FROM %TABLE:SBE%
		WHERE BE_FILIAL = %XFILIAL:SBE% AND %NOTDEL%
		AND BE_LOCAL = %exp:cLocal_D% and BE_LOCALIZ = %exp:cLoclz_D%
	EndSQL

	IF 	(cAlias)->(EOF())
		cMsg := '{ '
		cMsg += '"message": "Localização não existe", '
		cMsg += '"detailedMessage": "Localização informada não existe." '
		cMsg += ' }'
		::SetResponse(cMsg)

		self:setStatus(400)
		lOk := .F.
	ENDIF

	(cAlias)->(dbCloseArea())


	//VERIFICA VALIDADE
	if lOk .and. .F.
		cAlias := getNextAlias()

		BeginSql Alias cAlias
			select top 1  B8_DTVALID from SB8070 (nolock)
			where B8_FILIAL = %XFILIAL:SB8% AND %NOTDEL% 
			AND B8_LOTECTL = %EXP:cLote% 
			AND B8_SALDO > 0
			AND B8_LOCAL = %EXP:oJson['LOCAL_ORIGEM']% 
			order by B8_NUMLOTE
		EndSql
		IF (CALIAS)->(!EOF())
			if stod((calias)->B8_DTVALID) < DDATABASE
				cMsg := '{ '
				cMsg += '"message": "Material Vencido", '
				cMsg += '"detailedMessage": "Material Vencido. Solicite revalidação pela qualidade." '
				cMsg += ' }'
				::SetResponse(cMsg)

				self:setStatus(400)
				lOk := .F.
			ENDIF
		ENDIF
		(cAlias)->(DBCLOSEAREA())
	endif

	if lOk
		CONOUT('INICIA TRANSFI')
		lOk := transfi(oJson['PRODUTO'], oJson['QUANTIDADE'],oJson['LOCAL_ORIGEM'],oJson['LOCALIZACAO_ORIGEM'],oJson['LOCAL_DESTINO'],oJson['LOCALIZACAO_DESTINO'], oJson['LOTE'], oJson['USUARIO'])

		CONOUT('FINALIZA TRANSFI')
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
	endif


return lret

static function transfi(cCod, nQTD,cLocalOrig,cLoczOrigem, cLocalDest, cLoclzDest, cLote, cUserRest)

	Local aAuto := {}

	Local aLinha := {}
	Local lRet:=.T.


	Private lMsErroAuto := .F.
	//cMaq := substr(cMaq,1,2)
	conout('Codigo '+cCod)
//conout('Qtd '+ alltrim(str(nqtd)))
	conout('Local Destino '+cLocalDest)
	conout('Loclz Destino '+cLoclzDest)
//	conout('Usuario '+cUserRest)
	conout('Lote '+cLote)

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
//	aadd(aLinha,{"D3_DTVALID", dDtValid, Nil}) //data validade
		aadd(aLinha,{"D3_POTENCI", 0, Nil}) // Potencia
		aadd(aLinha,{"D3_QUANT", nQTD, Nil}) //Quantidade
		aadd(aLinha,{"D3_QTSEGUM", 0, Nil}) //Seg unidade medida
		aadd(aLinha,{"D3_ESTORNO", "", Nil}) //Estorno
		aadd(aLinha,{"D3_NUMSEQ", "", Nil}) // Numero sequencia D3_NUMSEQ

		aadd(aLinha,{"D3_LOTECTL",  PadR(cLote, tamsx3('D3_LOTECTL') [1]), Nil}) //Lote destino
		aadd(aLinha,{"D3_NUMLOTE", "", Nil}) //sublote destino
//	aadd(aLinha,{"D3_DTVALID", dDtValid, Nil}) //validade lote destino
		aadd(aLinha,{"D3_ITEMGRD", "", Nil}) //Item Grade

		aadd(aLinha,{"D3_CODLAN", "", Nil}) //cat83 prod origem
		aadd(aLinha,{"D3_CODLAN", "", Nil}) //cat83 prod destino

		//	aadd(aLinha,{"D3_USUARIO", cUserRest, Nil}) //Item Grade
		//	aadd(aLinha,{"D3_DTSIST", DDATABASE, Nil}) //Item Grade
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

wsmethod get ws2 wsservice Material_mov
	local lRet as logical
	local aRmaterial
	local cLote, cProduto, nQuant := 0
	Local oJson, oJson2, i
	self:SetContentType("application/json")
	//::SetResponse('{"CODBAR":' + ::codBAR + ', "name":"sample"}')
// MP001009000011 ;20230329M027        ;2.750,000
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
			oJson2['QUANTIDADE']:=aRmaterial[i,4]
			oJson2['EMPENHO']:=aRmaterial[i,5]
			oJson2['LOCAL']:=aRmaterial[i,6]
			oJson2['LOCALIZACAO']:=aRmaterial[i,7]
			oJson2['UM']:=aRmaterial[i,8]
			oJson2['SALDO']:=aRmaterial[i,9]

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
	Local cWhere := ''

	cWhere := " BF_LOTECTL = '"+cLote+"' "
	if !empty(cProduto)
		cWhere += " AND BF_PRODUTO = '"+cProduto+"' "
	ENDIF
	cWhere := '%'+cWhere+'%'
	cAlias := getNextAlias()


	BeginSQL alias cAlias
	SELECT 
		BF_PRODUTO, B1_UM, B1_TIPO, BF_QUANT,BF_LOCAL, BF_LOCALIZ,BF_LOTECTL, BF_EMPENHO, RTRIM(REPLACE(B1_DESC,'"','''')) as  B1_DESC
	FROM %TABLE:SBF% BF INNER JOIN %TABLE:SB1%  B1 ON B1.B1_COD=BF.BF_PRODUTO
	WHERE BF.%NOTDEL% AND BF_FILIAL = %XFILIAL:SBF%
        AND B1.%NOTDEL% AND B1_FILIAL = %XFILIAL:SB1%
		AND %EXP:cWhere%
	ORDER BY 1, BF_LOCAL, BF_LOCALIZ
	EndSQL

	u_dbg_qry()

	While !(cAlias)->(Eof())
		aAdd(aRmaterial, {})
		aAdd(aRmaterial[len(aRmaterial)], alltrim((cAlias)->BF_PRODUTO) )
		aAdd(aRmaterial[len(aRmaterial)], alltrim((cAlias)->BF_LOTECTL) )
		aAdd(aRmaterial[len(aRmaterial)], alltrim((cAlias)->B1_DESC) )
		ConOut( (cAlias)->B1_TIPO )
		aAdd(aRmaterial[len(aRmaterial)],  nQuant)
		aAdd(aRmaterial[len(aRmaterial)], (cAlias)->BF_EMPENHO )
		aAdd(aRmaterial[len(aRmaterial)], (cAlias)->BF_LOCAL )
		aAdd(aRmaterial[len(aRmaterial)], (cAlias)->BF_LOCALIZ )
		aAdd(aRmaterial[len(aRmaterial)], alltrim((cAlias)->B1_UM) )
		aAdd(aRmaterial[len(aRmaterial)], (cAlias)->BF_QUANT )
		(cAlias)->(dbSkip())
	enddo
	(cAlias)->(DbClosearea())


//	json_dbg(aRmaterial)

return aRmaterial
