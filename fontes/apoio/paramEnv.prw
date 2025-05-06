/*
parâmetros variáveis conforme o ambiente
*/

user Function ipPrimario
	return '187.49.39.130'

User Function portaPrn
	local cAmbiente := Upper(GetEnvServer())
	If 'DEV' $ cAmbiente
		return '3002'
	else
		return '3001'
	endif
