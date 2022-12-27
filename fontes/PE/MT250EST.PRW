USER FUNCTION MT250EST()
    Local lRet := .T., cMaxNumSeq, nRolosPlt

    if SD3->D3_TIPO = 'PA'
        cAlias := getNextAlias()
        BEGINSQL alias CALIAS   
            SELECT MAX(D3_NUMSEQ) AS MAX_NUMSEQ
            FROM %TABLE:SD3%
             WHERE D3_FILIAL = %XFILIAL:SD3% AND %NOTDEL%
            AND D3_OP = %EXP:SD3->D3_OP%
            AND D3_ESTORNO <> 'S'
            AND D3_CF = 'PR0'
        ENDSQL
        cMaxNumSeq := (CALIAS)->MAX_NUMSEQ
        (CALIAS)->(DBCLOSEAREA(  ))

        if SD3->D3_NUMSEQ  <> cMaxNumSeq
            MsgStop('Para ordens de PA, só é permitido estornar o último apontamento.', 'Aviso')
            lret := .F.
        endif

        //verifica se ja tem pallet montado
        cAlias := getNextAlias()
        BEGINSQL ALIAS CALIAS
            SELECT COUNT(*) AS ROLOS_PALLET
            FROM %TABLE:ZD3%
            WHERE ZD3_FILIAL = %XFILIAL:ZD3% AND D_E_L_E_T_ <> '*'
            AND ZD3_NUMSEQ = %EXP:SD3->D3_NUMSEQ%
            and RTRIM(ZD3_PALLET) <> ''
        ENDSQL
        nRolosPlt := (CALIAS)->ROLOS_PALLET
         (CALIAS)->(DBCLOSEAREA(  ))

         if nRolosPlt > 0
           MsgStop('Existe pallet montado com rolos desta produção. Primeiro desfaça a montagem do pallet', 'Aviso')
            lret := .F.
        endif
    ENDIF
return lRet
