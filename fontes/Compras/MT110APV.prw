User Function MT110APV 

Local lRet:=.F.// Valida��es 
Local nX
Local aGrupos  		:= UsrRetGrp(RetCodUsr())

For nX := 1 To Len(aGrupos)
	If aGrupos[nX] == "000001" //Grupo Aprovador SC
		lRet := .T.
	Endif
Next nX


if !lRet

MsgAlert("Seu usu�rio n�o tem permiss�o para aprova��o de SC. Verifique o grupo de acesso.", 'Aviso')
	
Endif

Return lRet
