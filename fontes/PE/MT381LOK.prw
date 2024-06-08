//empenho multiplo valida linha
User Function MT381LOK()
Local ExpL1 := PARAMIXB[1]
Local ExpL2 := PARAMIXB[2]
Local ExpL3 := .T.//Validações do clienteReturn ExpL3 
 
 if !isblind() .and. ExpL1==.T.
	dbSelectArea('SC2')
	SC2->(DBSEEK(XFILIAL('SC2')+COP))

    if empty(SC2->C2_LIMPEZA)
   		MsgAlert("É obrigatório realizar limpeza de linha antes de iniciar produção.", 'Aviso')
        ExpL3 := .F.
    endif
 endif 


return ExpL3
