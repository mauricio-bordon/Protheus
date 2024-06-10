#define NEWLINE chr(13)+chr(10)

User Function MA650BUT()

//	AAdd( aRotina, { 'Altera Máquina ', 'u_M650ALTMAQ()', 0, 4 } )
//	AAdd( aRotina, { 'Altera Prioridade', 'u_M650ALTPRI()', 0, 4 } )
	AAdd( aRotina, { 'Limpeza Linha', 'u_limpeza', 0, 14 } )
	AAdd( aRotina, { 'Relatorio Pedido', 'u_relestoq()', 0, 14 } )
	AAdd( aRotina, { 'Etiqueta Retorno PI', 'u_ETQRETPI()', 0, 14 } )
	AAdd( aRotina, { 'Pallet SI', 'u_brwpallet()', 0, 14 } )
	AAdd( aRotina, { 'Qualidade apontamento', 'u_apontlaud()', 0, 14 } )
	aAdd( aRotina, { 'Cálculo PI conforme PA atual', 'u_ma650Cal()', 0, 14 })

Return (aRotina)

user function ma650Cal()
	Local cPrefixo := ''
	Local aInfo := {}

	if left(SC2->C2_PRODUTO, 2) != 'PA'
		FWAlertError("O produto da O.P selecionada não é PA	!", "Erro")
		return
	endif

	if empty(SC2->C2_PEDIDO) .or. empty(SC2->C2_ITEMPV)
		FWAlertError("O Pedido de Venda não está associado com O.P !", "Erro")
		return
	endif

	cPrefixo := substr(SC2->C2_PRODUTO, 1, 6) + '%'

	aInfo := u_calcPI(cPrefixo)

	cInfo := aInfo[3]

	FWAlertWarning(cInfo, "ATENÇÃO !!")
return
