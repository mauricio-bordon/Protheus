User Function A250REQAUT

	Local cReqAut   := PARAMIXB[1]
	Local cProgMenu := FunName()
	Local cFunction := ProcName(3) + ' / ' + ProcName(4)
	Local cOP, cMaq, cProduto, cRoteiro,cColetor

	ConOut('-------------------------------------------')
	ConOut('---A250REQAUT---')

	ConOut('cReqAut  : ' + cReqAut)
	ConOut('cProgMenu: ' + cProgMenu)
	ConOut('cFunction: ' + cFunction)

	if l681
		conout("Origem: Prod Mod 2")
		//Produção Mod 2
		// Altera o tipo de requisição de Automatica para Digitada no caso de ordens na rotogravura.
		// Será estendido para demais maquinas
		//NO teste, pergunta ao administrador se quer desabilitar para facilitar testes
		cOp := If(empty(M->H6_OP), SH6->H6_OP, M->H6_OP)
		ConOut('cOp: ' + cOp)
		cMaq := POSICIONE('SC2', 1, XFILIAL('SC2') + cOp , 'C2_MAQUINA')
		cProduto := POSICIONE('SC2', 1, XFILIAL('SC2') + cOp , 'C2_PRODUTO')
		cRoteiro := POSICIONE('SC2', 1, XFILIAL('SC2') + cOp , 'C2_ROTEIRO')
		cColetor := POSICIONE('SC2', 1, XFILIAL('SC2') + cOp , 'C2_COLETOR')
		conout('Maquina '+ cMaq)
		conout('Produto '+ cProduto)
		conout('Roteiro '+ cRoteiro)
		if cReqAut == 'A' .AND. alltrim(cRoteiro) <> '' .and. left(cProduto,2) == 'PI' .and. cColetor == 'S'
			conout('Desabilita requisicao automatica para coletor')
			cReqAut := 'D'
		endif
	endif
	ConOut('---A250REQAUT END---')
	ConOut('-------------------------------------------')
Return(cReqAut)
