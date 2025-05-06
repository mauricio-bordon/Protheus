User Function MT410INC()
	if !EMPTY( SA1->A1_OBSERV )
		MSGALERT( SA1->A1_NOME + CHR(10) + CHR(10) + SA1->A1_OBSERV, "Atenção" )
	endif
return NIL
