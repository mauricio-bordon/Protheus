//Bibliotecas
#Include "Protheus.ch"
 
User Function SD3250I()
    Local aArea        := GetArea()
    Local aAreaD3    := SD3->(GetArea())
    Local aAreaC2    := SC2->(GetArea())
    Local cOP, i, nTirada, nRoloAtual := SC2->C2_ROLOSTT
     
    //Pegando o número da op
    cOp := Alltrim(SD3->D3_OP)
     
  

    if SD3->D3_TIPO == 'PA' 
        //Se PA gera numero de tirada e rolos no registro ZD3

        cAlias := getNextAlias()
        BEGINSQL alias cAlias  
            select COALESCE(MAX(D3_TIRADA),0) AS MAX_TIRADA
            FROM %TABLE:SD3%
            WHERE D3_FILIAL = %XFILIAL:SD3% AND %NOTDEL%
            AND D3_OP = %EXP:SD3->D3_OP%
            AND D3_ESTORNO <> 'S'
            AND D3_CF = 'PR0'
        ENDSQL  

        nTirada := (CALIAS)->MAX_TIRADA

        nTirada++
        
        SD3->(RecLock('SD3', .F.) )
            SD3->D3_TIRADA  := nTirada
        SD3->(MsUnlock())

        DbSelectArea('ZD3')
        for i:= 1 to SD3->D3_NROLOS
            nRoloAtual++
            ZD3->(RECLOCK('ZD3',.T.))
                ZD3->ZD3_FILIAL := xFilial('ZD3')
                ZD3->ZD3_OP     := SD3->D3_OP
                ZD3->ZD3_PALLET := SPACE(10)
                ZD3->ZD3_COD    := SD3->D3_COD   
                ZD3->ZD3_LOTE := SD3->D3_LOTECTL
                ZD3->ZD3_TIRADA := nTirada
                ZD3->ZD3_LARG := POSICIONE("SB1",1, XFILIAL('SB1')+SD3->D3_COD,'B1_LARGURA')
                ZD3->ZD3_MTROLO := SD3->D3_MTROLO
                ZD3->ZD3_UM     := SD3->D3_UM
                ZD3->ZD3_NUMSEQ := SD3->D3_NUMSEQ
                ZD3->ZD3_ROLO   := nRoloAtual
            ZD3->(MSUNLOCK())
        next

        SC2->(RecLock('SD2', .F.))
            SC2->C2_ROLOSTT := nRoloAtual
        SC2->(MsUnlock())
        
    endif

    
    RestArea(aAreaC2)
    RestArea(aAreaD3)
    RestArea(aArea)
Return
