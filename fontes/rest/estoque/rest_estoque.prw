#include "protheus.ch"
#include "restful.ch"
#include 'rwmake.ch'
#Include "tbiconn.ch"


wsrestful ws_estoque description "WS ESTOQUE"
	wsdata cBarcode as char OPTIONAL
	wsdata cProduto as char OPTIONAL
	wsdata cLote as char OPTIONAL
	wsdata cLocal as char OPTIONAL
	wsdata cLoclz as char OPTIONAL
	wsdata cLocDest as char OPTIONAL
	wsdata cLoclzDest as char OPTIONAL
	wsdata nQuant as char optional

	wsmethod get ws1;
		description "Valida Localização" ;
		wssyntax "/ws_estoque/v1/valida_sbe/{cBarcode}" ;
		path "/ws_estoque/v1/valida_sbe/{cBarcode}"

	wsmethod get ws2;
		description "Busca Lote" ;
		wssyntax "/ws_estoque/v1/dados_lote/{cBarcode}" ;
		path "/ws_estoque/v1/dados_lote/{cBarcode}"

end wsrestful


wsmethod get ws1 wsservice ws_estoque
	local lRet as logical
	local lOk, cLocal, cLoclz
	Local oJson
	self:SetContentType("application/json")
	//::SetResponse('{"CODBAR":' + ::codBAR + ', "name":"sample"}')
// MP001009000011 ;20230329M027        ;2.750,000
	CONOUT(::cBarcode)
    cLocal := left(::cBarcode,2)
	cLoclz := SUBSTR(alltrim(::cBarcode),3,10)
	lOk:= valida_sbe(cLocal, cLoclz)
	oJson := JsonObject():new()
 	CONOUT(cLocal + " / " + cLoclz)

	If !lOk
		::SetResponse('{ "code": "400", "message": "Local informado não existe.","detailedMessage": "Não existe a localização informada"}')

		self:setStatus(400)

	else
			oJson['BE_LOCAL']:=cLocal
			oJson['BE_LOCALIZ']:=cLoclz
		self:setStatus(200)
		::SetResponse(oJson)

	endif

	FreeObj(oJson)

	lRet := .T.

return lRet


static function valida_sbe(cLocal, cLoclz)
	Local cAlias
	Local cWhere := ''
	Local lOk := .F.

	cWhere := " AND BE_LOCAL = '"+cLocal+"' AND BE_LOCALIZ = '"+cLoclz+"' "
	
	cWhere := '%'+cWhere+'%'
	cAlias := getNextAlias()


	BeginSQL alias cAlias
	SELECT *
	FROM %TABLE:SBE% BE	
	WHERE BE.%NOTDEL% AND BE_FILIAL = %XFILIAL:SBE%
        %EXP:cWhere%
	EndSQL
	    
	u_dbg_qry()

	if !(cAlias)->(Eof())
		lOk := .T.
	ENDIF
	(cAlias)->(DbClosearea())


//	json_dbg(aRmaterial)

return lOk

wsmethod get ws2 wsservice ws_estoque
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
		oJson2['message']:='Lote VÃ¡lido'
		//oJson2['detailedMessage']:='Lote VÃ¡lido'
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
