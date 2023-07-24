user function json_dbg(_var)
	Local cDebug := '', oJson
	//Debug do Vetor
	if ValType( _var ) == 'J'
		oJson := _var
		cDebug := oJson:toJson()
	elseif ValType( _var ) == 'A' .OR. ValType( _var ) == 'O'
		oJson := JsonObject():new()
		oJson:set(_var)
		cDebug := oJson:toJson()
	elseif(ValType( _var ) == 'C')
		cDebug := _var
	elseif(ValType( _var ) == 'D')
		cDebug := DTOS(_var)
	elseif(ValType( _var ) == 'L')
		IF _VAR
			cDebug := 'LÓGICO: .T.'
		else
			cDebug := 'LÓGICO: .F.'
		ENDIF
	elseif ValType( _var ) == 'N' .OR.  ValType( _var ) == 'F'
		cDebug := CVALTOCHAR(_var)
	elseif ValType( _var ) == 'U'
		cDebug := 'INDEFINIDO'
	else
        cDebug := 'TIPO DE VARIAVEL SEM TRATAMENTO: '+ValType( _var )
	endif
	CONOUT(' --- DEBUG JSON ---')
	conout(cDebug)
	CONOUT('---')

return cDebug
