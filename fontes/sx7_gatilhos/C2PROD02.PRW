#define NEWLINE chr(13)+chr(10)

//gatilho
user function C2PROD02()
	Local nQtdPI := 0
	Local nLargPI := 0
	Local nQtdPIAtual := 0
	Local cPrefixo := ''
	Local cInfo := ''
	Local aInfo := {}
	Local cCodPI := alltrim(M->C2_PRODUTO)
	Local nLargCrt  := getmv('IC_PIFXCRT') // Largura padrão utilizada no corte - default 645

	//se não for PI, ignorar (retornar a mesma quantidade que já está no campo C2_QUANT)
	if substr(cCodPI, 1, 2) != 'PI'
		return M->C2_QUANT
	endif

	//cálculo apenas para PI's com largura padrão
	if cCodPI != substr(cCodPI, 1, 6) + strzero(nLargCrt, 4)
		return M->C2_QUANT
	endif

	nLargPI := POSICIONE('SB1', 1, XFILIAL('SB1') + cCodPI, "B1_LARGURA") //Largura do PI

	if nLargPI == 0
		FWAlertError("Largura do PI não cadastrada !", "Erro")
		return
	endif

	cPrefixo := 'PA' + substr(cCodPI, 3, 4) + '%'

	aInfo := u_calcPI(cPrefixo)

	nQtdPI := aInfo[1]
	nQtdPIAtual := aInfo[2]
	cInfo := aInfo[3]

	if nQtdPI > 0
		If .not. MsgYesNo(cInfo, " Deseja utilizar a quantidade calculada ?")
			nQtdPI := M->C2_QUANT //retorna a quantidade original
		EndIf
	else
		nQtdPI := M->C2_QUANT //retorna a quantidade original
		if nQtdPIAtual > 0
			FWAlertWarning(cInfo, "ATENÇÃO !!")
		endif
	endif

return nQtdPI
