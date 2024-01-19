#INCLUDE "TOPCONN.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "FONT.CH"

User Function GeraB1()
	Local cAlias := getNextalias()
	aArea:=GetArea()


	lRet:=.T.
	//Gera B1_COD
	if INCLUI
		//se nao for PI ou PA
		if ALLTRIM(M->B1_TIPO) != '' .AND. !M->B1_TIPO$"PI_PA" .AND. ALLTRIM(M->B1_GRUPO) != ''

			BeginSql alias CALIAS
		SELECT   ISNULL(MAx(SUBSTRING(B1_COD,7,6)),0)+1 NOVOCOD 
				FROM  SB1010 SB1 
				WHERE B1_FILIAL = %XFILIAL:SB1% AND SB1.%NOTDEL% 
				AND B1_TIPO = %EXP:M->B1_TIPO%
                AND B1_GRUPO =  %EXP:M->B1_GRUPO%
			ENDSQL

			while (calias)->(!eof())

				M->B1_COD:=M->B1_TIPO+M->B1_GRUPO+STRZERO((CALIAS)->NOVOCOD,6)
				(calias)->(DBSKIP())
			enddo
			(calias)->(DBCLOSEAREA())
		endif

		if M->B1_TIPO$"PI_PA" .AND. ALLTRIM(M->B1_GRUPO) != '' .AND. M->B1_UM<>'KG'

			IF M->B1_LARGURA==0
				Alert("Para PI e PA preecha a largura do produto antes do grupo!")
				lRet:=.F.

			ELSE
				//verifica se tem decimal
				if MOD(M->B1_LARGURA,1)==0

					//M->B1_COD:=M->B1_TIPO+M->B1_GRUPO+cValToChar(PADL(M->B1_LARGURA,4,"0"))
					M->B1_COD:=M->B1_TIPO+M->B1_GRUPO+cValToChar(PADL(int(M->B1_LARGURA),4,"0"))
				else
					//se tiver decimal adiciona a letra D mais o decimal 2 digitos
					aString:= STRTOKARR(alltrim(str(M->B1_LARGURA)),".")
					sDecimal:=aString[2]
					if len(sDecimal)==1
						sDecimal:=sDecimal+'0'
					endif
					M->B1_COD:=M->B1_TIPO+M->B1_GRUPO+cValToChar(PADL(int(M->B1_LARGURA),4,"0"))+"D"+sDecimal

				ENDIF

			ENDIF
			//se PI OU PA CONTROLA LOTE
			M->B1_RASTRO 	:= 'L'
			//M->B1_TIPOCQ	:= 'M'
			M->B1_PRVALID:=365
			M->B1_LOCPAD:='02'
		ELSE   //É PI  COM UNIDADE DE MEDIDA KILO
			BeginSql alias CALIAS
				SELECT   ISNULL(MAx(SUBSTRING(B1_COD,7,6)),0)+1 NOVOCOD 
				FROM  SB1010 SB1 
				WHERE B1_FILIAL = %XFILIAL:SB1% AND SB1.%NOTDEL% 
				AND B1_TIPO = %EXP:M->B1_TIPO%
                AND B1_GRUPO =  %EXP:M->B1_GRUPO%
			ENDSQL

			while (calias)->(!eof())

				M->B1_COD:=M->B1_TIPO+M->B1_GRUPO+STRZERO((CALIAS)->NOVOCOD,6)
				(calias)->(DBSKIP())
			enddo
			(calias)->(DBCLOSEAREA())

			//se PI KG CONTROLA LOTE
			M->B1_RASTRO 	:= 'L'
			M->B1_PRVALID:=365
			M->B1_LOCPAD:='02'
		endif


		if M->B1_TIPO$"EM_PM_MC"
			M->B1_LOCALIZ 	:= 'S'
		ENDIF

		if M->B1_TIPO$"P3"
			M->B1_LOCALIZ 	:= 'S'
			M->B1_RASTRO 	:= 'L'

		ENDIF


		if M->B1_TIPO$"MP"
			//se PI OU PA CONTROLA LOTE
			M->B1_RASTRO 	:= 'L'
			M->B1_TIPOCQ:='Q'
			M->B1_LOCPAD:='02'
		ENDIF

	endif


Return lRet
