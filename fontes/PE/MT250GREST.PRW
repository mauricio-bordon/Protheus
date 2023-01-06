USER FUNCTION MT250GREST()
	Local cNumSeq := SD3->D3_NUMSEQ
	Local cAlias , cR_E_C_N_O_, nRolos := 0

	if SD3->D3_TIPO == 'PA'
		CALIAS := getNextAlias()

		BEGINSQL ALIAS CALIAS
            SELECT *
            FROM %TABLE:ZD3%
            WHERE ZD3_FILIAL = %XFILIAL:ZD3% AND D_E_L_E_T_ <> '*'
            AND ZD3_NUMSEQ = %EXP:cNumSeq%
		ENDSQL

		WHILE (CALIAS)->(!EOF())
			cR_E_C_N_O_:= (cAlias)->R_E_C_N_O_
			ZD3->(dbGoto(cR_E_C_N_O_))
			ZD3->(RecLock('ZD3',.F.))
			    ZD3->(dbdelete())
			ZD3->(MsUnLock())
            (calias)->(dbskip())
            nRolos++
		ENDDO
        (calias)->(dbclosearea())

        if nROlos > 0
            SC2->(DBSEEK(XFILIAL('SC2')+SD3->D3_OP))
            SC2->(RecLock('SC2', .F.))
                SC2->C2_ROLOSTT := SC2->C2_ROLOSTT - nRolos
            SC2->(MsUnlock())
        ENDIF
	ENDIF

RETURN
