#include "protheus.ch"
#include "restful.ch"
#include 'rwmake.ch'
#Include "tbiconn.ch"
#include "topconn.ch"


wsrestful ws_pcp_op_estrutura description "WS retorna a estrutura do produto"
	wsdata cOP as char optional

	wsmethod get ws1;
		description "Lista material necessario para ordem" ;
		wssyntax "/ws_pcp_op_estrutura/busca/{cOP}";
		path "/ws_pcp_op_estrutura/busca/{cOP}"


end wsrestful

wsmethod get ws1 wsservice ws_pcp_op_estrutura
	Local lRet := .F.
	Local lGet := .T.
	local aLote
	local nL
	local cLote, cProdEmp
	Local aJson := {}
	

	self:SetContentType("application/json")
	aDados := getEstrutura(::cOp)
	
    if aDados[1] == ''
	
    	::SetResponse('{"message": "Sem Estrutura","detailedMessage": "Sem estrutura"}')
		self:setStatus(400)
		Return lGet
	endif
	

		self:setStatus(200)
		for nL := 1 to len(aDados)
			aJson:=JsonObject():new()
			aJson['LOCALIZACAO']:=aLote[nL][1]
			aJson['EMPENHO']:=aLote[nL][2]
			aJson['LOTE']:=aLote[nL][3]
			aJson['LOCAL']:=aLote[nL][4]
			aJson['PRODUTO']:=aLote[nL][5]
			aJson['DESCRICAO']:=aLote[nL][6]
			aJson['QUANTIDADE']:=aDados[2]
			aJson['SALDO']:=aLote[nL][8]
		next nL
		::SetResponse(aJson)
	

	FreeObj(aJson)


Return lGet

static 
