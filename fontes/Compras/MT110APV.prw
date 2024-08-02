User Function MT110APV 

Local lRet:=.F.// Validações 
Local nX
Local aGrupos  		:= UsrRetGrp(RetCodUsr())

For nX := 1 To Len(aGrupos)
	If aGrupos[nX] == "000001" //Grupo Aprovador SC
		lRet := .T.
	Endif
Next nX


if !lRet

MsgAlert("Seu usuário não tem permissão para aprovação de SC. Verifique o grupo de acesso.", 'Aviso')
	
Endif

Return lRet
