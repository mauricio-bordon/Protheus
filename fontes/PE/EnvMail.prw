#include "ap5mail.ch"
#include "Protheus.Ch"
#include "TopConn.Ch"
#include "TBIConn.Ch"
#include "TbiCode.ch"



User Function EnvMail( cAssunto, cMensagem, cDestino, cMailFrom )

Local cMailServer := GETMV("MV_RELSERV")
Local cMailContX  := GETMV("MV_RELACNT")
Local cMailSenha  := GETMV("MV_RELAPSW")
Local cMailDest   := Alltrim(cDestino)
Local lConnect    := .f.
Local lEnv        := .f.
Local lFim        := .f.
lOCAL cAmbiente:=Upper(GetEnvServer())
//Local cMailFrom   := cMailFrom 
//sempre o email de autenticaçao
conout("------------ Enviando email --------------")
If Empty(cMailFrom) 
	cMailFrom := cMailContX
Endif         
 cMailFrom   := cMailContX
 
If "DEV"$cAmbiente
	cMailDest:= "ti@inducoat.com.br"  
	cAssunto := "[ TESTE ] "+Alltrim(cAssunto)
Endif


CONNECT SMTP SERVER cMailServer ACCOUNT cMailContX PASSWORD cMailSenha RESULT lConnect

IF GetMv("MV_RELAUTH")
	MailAuth( cMailContX, cMailSenha )
EndIF

conout("Para"+cMailDest+"  --------------")
If (lConnect)  // testa se a conexão foi feita com sucesso
	SEND MAIL FROM cMailFrom TO cMailDest SUBJECT cAssunto BODY cMensagem RESULT lEnv
Endif

If ! lEnv
	GET MAIL ERROR cErro
	conout("Erro"+cErro+"  --------------")

EndIf

DISCONNECT SMTP SERVER RESULT lFim


Return(nil)
