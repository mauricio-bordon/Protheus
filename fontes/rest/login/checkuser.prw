#include "protheus.ch"
#include "restful.ch"
#include 'rwmake.ch'
#Include "tbiconn.ch"
#include "topconn.ch"

wsrestful checkuser description "WS para checar usuario"
	wsdata cID as char optional

	wsmethod post ws1;
		description "Checa usuario e senha";
		wssyntax "/checkuser/v1";
		path "/checkuser/v1"


	wsmethod get ws2;
		description "Checa usuario e senha";
		wssyntax "/checkuser/v1";
		path "/checkuser/v1"

end wsrestful

wsmethod post ws1 wsservice checkuser
	Local lPost := .T.
	Local oJson
	Local cBody := ::getContent()
	Private cMsgErro := 'Sem usuario'
	self:SetContentType("application/json")
	conout("POST Checkuser!")
	oJson := JsonObject():new()
	oJson:fromJSON(cBody)
	sLogin:=alltrim(oJson['login'])
	sSenha:=alltrim(oJson['senha'])

	dbselectarea("ZUS")
	ZUS->(dbsetorder(1))
	ZUS->(dbseek(xfilial("ZUS")+sLogin))

	IF ZUS->(!FOUND())



		::SetResponse('{ "message": "Ops...","detailedMessage": "'+cMsgErro+'"}')

		self:setStatus(400)

	ELSE
		sSenha:=md5(sSenha,2)
	//	conout("Senha -> ")
	//	conout(sSenha)
	//	conout("Banco -> ")
	//	conout(ZUS->ZUS_SENHA)

		if alltrim(ZUS->ZUS_SENHA)==sSenha
			::SetResponse('{ "message": "OK","detailedMessage": "OK","ZUS_LOGIN":"'+ZUS->ZUS_LOGIN+'","ZUS_VEND":"0000"}')

			self:setStatus(200)

		else
			cMsgErro:="Senha invalida"
			::SetResponse('{ "message": "Ops...","detailedMessage": "'+cMsgErro+'"}')

			self:setStatus(400)

		endif

	ENDIF

	ZUS->(dbCloseArea())

Return lPost


wsmethod get ws2 wsservice checkuser
	Local lGet := .T.
//metodo criado para o webservice nao cair
	conout("GET Checkuser!")

		::SetResponse('{"message": "Erro","detailedMessage": "Procure TI"}')
		self:setStatus(200)


Return lGet


