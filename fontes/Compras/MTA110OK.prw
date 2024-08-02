/*Valida inclusão da SC*/
User Function MTA110OK()
	Local lRet := .T.
    Local cNumSol :=PARAMIXB[1]
    Local cSolicitante := PARAMIXB[2]
    

	cHTML:="Solicitação de compra:<br>"
	cHTML+="<b>"+cNumSol+"</b><br>"
	cHTML+="Nova solicitação de compra incluído pelo usuário "+cSolicitante+" .</b><br>"
	
	c_ends:=getmv("EM_APVSC")

      
	cAssunto:="Nova Solicitação de compra para aprovação "+cNumSol
	u_EnvMail( cAssunto, cHTML, c_ends, 'sistema@inducoat.com.br' )





Return ( lRet )

