/*Valida inclus�o da SC*/
User Function MTA110OK()
	Local lRet := .T.
    Local cNumSol :=PARAMIXB[1]
    Local cSolicitante := PARAMIXB[2]
    

	cHTML:="Solicita��o de compra:<br>"
	cHTML+="<b>"+cNumSol+"</b><br>"
	cHTML+="Nova solicita��o de compra inclu�do pelo usu�rio "+cSolicitante+" .</b><br>"
	
	c_ends:=getmv("EM_APVSC")

      
	cAssunto:="Nova Solicita��o de compra para aprova��o "+cNumSol
	u_EnvMail( cAssunto, cHTML, c_ends, 'sistema@inducoat.com.br' )





Return ( lRet )

