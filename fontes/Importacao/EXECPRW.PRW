USer Function execprw()
Local aParamBox := {}
Local aRet := {}
Local cBloco := "alert('Sem Rotina')"

aAdd(aParamBox,{1,"Rotina",Space(60),"","",,"",0,.F.}) // Tipo caractere

If ParamBox(aParamBox,"Teste...",@aRet)
   cBloco := aRet[1]
Endif 
	xRet := &(cBloco)
return xRet
