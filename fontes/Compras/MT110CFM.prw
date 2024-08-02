/* Valida o usuário após Aprovação, Rejeição ou Bloqueio */
User Function MT110CFM()

Local cNumSol  := PARAMIXB[1]    
Local nopcao  := PARAMIXB[2]       //1 = Aprovar; 2 = Rejeitar; 3 = Bloquear
Local cOpcao

if nopcao==1
cOpcao:="Aprovado"
Endif

if nopcao==2
cOpcao:="Rejeitado"
Endif

if nopcao==3
cOpcao:="Bloqueado"
Endif


	cHTML:="Solicitação de compra:<br>"
	cHTML+="<b>"+cNumSol+"</b><br>"
	cHTML+="Foi "+cOpcao+" pelo usuário "+cUserName+" .</b><br>"
	
	c_ends:="compras@inducoat.com.br"
	cAssunto:="Solicitação de compra "+cNumSol+" - "+cOpcao
	u_EnvMail( cAssunto, cHTML, c_ends, 'sistema@inducoat.com.br' )



return
