/***
Valida TES x Localização do Produto (Controle de estoque)
***/
User Function zVlDProd(cCodPro, cTES, cItem)
	Local aArea := GetArea()
	Local cEstoque := ''
	Local cLocaliz := ''
	Local cMsg := 'OK'

	//conout("---------- PE ----------" + ProcName())
	//conout('Produto: ' + cCodPro)
	//if !empty(cTES)
		//conout('TES....: ' + cTES)
	//endif

	BEGIN SEQUENCE
		dbSelectArea('SB1')
		dbSetOrder(1)
		if !dbSeek(xFilial('SB1') + cCodPro)
			cMsg := "Produto '" + Alltrim(cCodPro) + "' não encontrado !"
			break
		else
			cCodPro := Alltrim(cCodPro)
            cLocaliz := upper(SB1->B1_LOCALIZ)
        endif

		if !empty(cTES)
			dbSelectArea('SF4')
			dbSetOrder(1)
			if !dbSeek(xFilial('SF4') + cTES)
				cMsg := "TES '" + cTES + "' não encontrado !"
				break
			endif
			cEstoque := upper(SF4->F4_ESTOQUE)
		endif

		//validar TES x Localização
		if !empty(cTES)
			if cEstoque == 'N' .and. cLocaliz == 'S'
				cMsg := u_sprintf("O produto '{}' controla estoque; TES '{}' incorreto !", {cCodPro, cTES})
            elseif cEstoque == 'S' .and. cLocaliz == 'N'
				cMsg := u_sprintf("O produto '{}' NÃO controla estoque; TES '{}' incorreto !", {cCodPro, cTES})
            endif

            if !empty(cItem)
                cMsg := cMsg + ' (linha ' + cItem + ')'
            endif

            cMsg := cMsg + ' !'
            break

		endif

END SEQUENCE

RestArea(aArea)

Return cMsg
