#Include "Protheus.ch"
//Busca dados do pedido para paresentar na ordem.
user function getPedido(cCampo)
	local cDados:=" "

	if !Empty(SC2->C2_PEDIDO)
		dbSelectArea("SC6")
		dbSeek(xFilial("SC6")+SC2->C2_PEDIDO+SC2->C2_ITEMPV+SC2->C2_PRODUTO)

		dbSelectArea("SA1")
		dbSeek(xFilial("SA1")+SC6->C6_CLI)


		if cCampo=='TUBETE'
			cDados:=SC6->C6_TUBETE
		endif

		if cCampo=='EMBOBIN'
//1=Aluminio Externo;2=Aluminio Interno                                                                                           
			cDados:=SC6->C6_EMBOBIN

		ENDIF
		if cCampo=='CLIENTE'
			cDados:=SA1->A1_NOME


		endif




	endif



return cDados
