User function bcReader(cBarcode)
    Local aDados, cLote := '', nQuant := 0, cProduto := ''
    conout('cBarcode '+ cBarcode)
	aDados := StrTokArr( cBarcode, '-' )
	u_json_dbg(aDados)
	if len(aDados) == 2
		cLote := aDados[1]
		nQuant := val(aDados[2])/1000.0
	else 
		aDados := StrTokArr( cBarcode, ';' )
		
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
	aRet := {}
	aAdd(aret, cLote)
	aAdd(aret, nQuant)
	aAdd(aret, cProduto)

return aRet
