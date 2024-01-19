// CLASSIFICACAO FISCAL DO PRODUTO
User Function b1fiscal(cCod)
	Local lOk 		:= .T.
	
	//ncm e ipi para produtos SELO
	Local cNcm 		:= "76072000"
	Local nIpi 	 	:= 3.25
	
	Local nPcofins := 7.6
	Local nPis 	 := 1.65
	Local nPicm 	:= 18

	if cCod <> nil
		dbSelectArea("SB1")
		SB1->(dbSetOrder(1))
		SB1->(dbSeek(xfilial("SB1")+ccod))
		if SB1->(!found())
			return .F.
		endif
	endif

	if SB1->B1_TIPO == 'PA'

		conout('Classificando produto com b1fiscal COD '+SB1->B1_COD)
		//ncm pex 
		if substr(SB1->B1_GRUPO, 1, 2)=='80' 
		cNcm 		:= "39211900"
		nIpi 	 	:= 9.75

		endif
		
		SB1->(RecLock("SB1", .F. ))
		//SB1->B1_TE 		:= cTe
		//SB1->B1_TS		:= cTs
		//SB1->B1_CC 		:= cCc
		//SB1->B1_CONTA	:= cConta
       	SB1->B1_PICM  	:= nPicm
		SB1->B1_PPIS	:= nPis
		SB1->B1_PCOFINS := nPcofins
		SB1->B1_ORIGEM	:= IIF(Empty(SB1->B1_ORIGEM),"0",SB1->B1_ORIGEM)
		SB1->B1_IPI	    := nIpi
		SB1->B1_POSIPI  := cNcm

		SB1->(MSUNLOCK())

	ENDIF

return lOk
