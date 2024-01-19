#include "topconn.ch"
#include "rwmake.ch"
#INCLUDE "Protheus.ch"

user function apontlaud()
	Local aButtons := {}
	Local lOK := .F.
	Local aAspec:= {}
	Local CALIAS
	Private nesp:=0.0,nlargmin:=0.0,nlargmax:=0.0,ndiamE:=0.0,ndiamI:=0.0,cAspec:=" ",nLargura
	Private cEspespc
	aAdd(aAspec, "Conforme   ")
	aAdd(aAspec, "Nao Conforme  ")

	cOP:=alltrim(SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN)

	CALIAS := getNextAlias()

	BEGINSQL ALIAS CALIAS
                SELECT *
                FROM %TABLE:ZQ0%
                WHERE ZQ0_FILIAL = %XFILIAL:ZQ0% 
				AND D_E_L_E_T_ <> '*'
                AND ZQ0_OP = %EXP:cOP%
	ENDSQL

	//Pega as informa??es da ?ltima query
	aDados := GetLastQuery()

	//Mostra mensagem com todas as informa??es capturadas
	cMensagem := "Query lista lanaçmentos qualidades existentes"
	cMensagem += "* cAlias - " + aDados[1] + Chr(13) + Chr(10)
	cMensagem += "* cQuery - " + aDados[2]
	//conout(cMensagem)




	IF(CALIAS)->(!EOF())
		dbselectarea("ZQ0")
		Alert("Existem lançamentos para esta ordem. Contacte a Qualidade.")
		Return
		// Verifica se ja existe valores se sim pergunra se deseja remover
		// IF !MsgYesNo('Existe valores lanÃ§ado para esta OP deseja excluir?', 'Pergunta')
/*
        Alert("ALERTA COINT")
    WHILE (CALIAS)->(!EOF())
		cR_E_C_N_O_:= (cAlias)->R_E_C_N_O_
			ZQ0->(dbGoto(cR_E_C_N_O_))
			ZQ0->(RecLock('ZQ0',.F.))
			    ZQ0->(dbdelete())
			ZQ0->(MsUnLock())
            (CALIAS)->(dbskip())
            
		ENDDO

   	ENDIF
*/
	ENDIF



	(calias)->(dbclosearea())

	oDlg:= MsDialog():New(0,0, 400,300, 'Apontamento Qualidade',,,,,CLR_BLACK,CLR_WHITE,,,.T.)
	//Ordem de Producao
	oSay1:= tSay():New(35,10,{||"Ordem: "+SC2->C2_NUM+" Item: "+SC2->C2_ITEM+" Sequencia:"+SC2->C2_SEQUEN},oDlg,,,,,,.T.,,,)

	oSay2:= tSay():New(50,10,{||"Espessura Total"},oDlg,,,,,,.T.,,,)
	oGet2:= TGet():New(50,80,, oDlg, 60,10,'@E 999.99',,,,,,,.T.,,.T.,,,,,.F.,,,'nesp')
	oGet2:bSetGet := {|u| If(PCount()>0,nesp:=u,nesp) }

	oSay3:= tSay():New(65,10,{||"Largura Min"},oDlg,,,,,,.T.,,,)
	oGet3:= TGet():New(65,80,, oDlg, 60,10,'@E 999.9',,,,,,,.T.,,.T.,,,,,.F.,,,'nlargmin')
	oGet3:bSetGet := {|u| If(PCount()>0,nlargmin:=u,nlargmin) }

	oSay31:= tSay():New(80,10,{||"Largura Max"},oDlg,,,,,,.T.,,,)
	oGet31:= TGet():New(80,80,, oDlg, 60,10,'@E 999.9',,,,,,,.T.,,.T.,,,,,.F.,,,'nlargmax')
	oGet31:bSetGet := {|u| If(PCount()>0,nlargmax:=u,nlargmax) }

	oSay4:= tSay():New(95,10,{||"Diametro Interno"},oDlg,,,,,,.T.,,,)
	oGet4:= TGet():New(95,80,, oDlg, 60,10,'@E 9.9',,,,,,,.T.,,.T.,,,,,.F.,,,'ndiamI')
	oGet4:bSetGet := {|u| If(PCount()>0,ndiamI:=u,ndiamI) }

	oSay5:= tSay():New(115,10,{||"Diametro Externo"},oDlg,,,,,,.T.,,,)
	oGet5:= TGet():New(115,80,, oDlg, 60,10,'@E 999.9',,,,,,,.T.,,.T.,,,,,.F.,,,'ndiamE')
	oGet5:bSetGet := {|u| If(PCount()>0,ndiamE:=u,ndiamE) }

	oSay6:= tSay():New(130,10,{||"Aspecto visual do rolo e do corte:"},oDlg,,,,,,.T.,,,)
	oGet6:= tComboBox():New(145,10,,,,80,oDlg,,,,,,.T.,,,,,,,,,)
	oGet6:cVariable := "cAspec"
	oGet6:bSetGet := {|u| If(PCount()>0,cAspec:=u,cAspec) }
	oGet6:aItems := aAspec
	oGet6:nAt := 0
	//oGet6:bChange := {|| u_updTCBRW()}


	ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg, {||lOk := valida(SC2->C2_PRODUTO), iif(lOk,oDlg:End(), .F.)}, {|| lOk := .F., oDlg:End()},,aButtons))


	if lOk
//se VALIDADO GRAVA DADOS

		dbselectarea("ZQ0")
		ZQ0->(RecLock('ZQ0', .T.))
		ZQ0_FILIAL := xFilial('ZQ0')
		ZQ0_OP:= cOP
		ZQ0_ENSAIO:= 'Espessura'
		ZQ0_RESULT:= transform(nesp,"@E 999.9")
		ZQ0_ESPCIF:= cEspespc
		ZQ0->(MSUNLOCK())


		ZQ0->(RecLock('ZQ0', .T.))
		ZQ0_FILIAL := xFilial('ZQ0')
		ZQ0_OP:= cOP
		ZQ0_ENSAIO:= 'LarguraMin'
		ZQ0_RESULT:= transform(nlargmin,"@E 999.99")
		ZQ0->(MSUNLOCK())

		ZQ0->(RecLock('ZQ0', .T.))
		ZQ0_FILIAL := xFilial('ZQ0')
		ZQ0_OP:= cOP
		ZQ0_ENSAIO:= 'LarguraMax'
		ZQ0_RESULT:= transform(nlargmax,"@E 999.99")
		ZQ0->(MSUNLOCK())


		ZQ0->(RecLock('ZQ0', .T.))
		ZQ0_FILIAL := xFilial('ZQ0')
		ZQ0_OP:= cOP
		ZQ0_ENSAIO:= 'DiametroInt'
		ZQ0_RESULT:= transform(ndiamI,"@E 999.9")
		ZQ0->(MSUNLOCK())


		ZQ0->(RecLock('ZQ0', .T.))
		ZQ0_FILIAL := xFilial('ZQ0')
		ZQ0_OP:= cOP
		ZQ0_ENSAIO:= 'DiametroExt'
		ZQ0_RESULT:= transform(ndiamE,"@E 999.9")
		ZQ0->(MSUNLOCK())

		ZQ0->(RecLock('ZQ0', .T.))
		ZQ0_FILIAL := xFilial('ZQ0')
		ZQ0_OP:= cOP
		ZQ0_ENSAIO:= 'Aspecto'
		ZQ0_RESULT:= cAspec
		ZQ0->(MSUNLOCK())


		Aviso('Atenção', 'Inclusão realizada!', {'OK'}, 03)



	EndIf

return


static function valida(c2Produto)
	Local lRet := .F.
	Local lErro:=.F.
	Local cMsg:="",i,cEnsaioAtual
	Local cAlias,cGrupo,aEnsaios:={}
	Local cTipo:=""


	cGrupo:=substr(c2Produto,3,4)
	// grupo pex considera final 0810
	if substr(cGrupo,1,2)=='80'

		if cGrupo=="8015"
		cProdutpai:='PI80090810'
		cTipo:="PEX"
		
		else
		cProdutpai:='PI'+cGrupo+'0810'
		cTipo:="PEX"
		endif	
		//if ndiamE>=350 .and. ndiamE<=450
		ndiamEMin:=350
		ndiamEMax:=700
	else
		cProdutpai:='PI'+cGrupo+'0665'
		cTipo:="SELO"
		ndiamEMin:=350
		ndiamEMax:=450
	endif

	CALIAS := getNextAlias()

// Retorna as especificações
	BEGINSQL ALIAS CALIAS
		SELECT QP6_PRODUT,QP1_DESCPO,QP7_NOMINA,QP7_LIE,QP7_LSE 
		FROM %TABLE:QP6% QP6
		INNER JOIN %TABLE:QP7% QP7
		ON QP7_PRODUT=QP6_PRODUT
		AND QP7_REVI=QP6_REVI
		INNER JOIN %TABLE:QP1% QP1
		ON QP7_ENSAIO=QP1_ENSAIO
		where QP6.D_E_L_E_T_<>'*'
		AND QP7.D_E_L_E_T_<>'*'
		AND QP1.D_E_L_E_T_<>'*'
		AND QP6_PRODUT=%EXP:cProdutpai%  
		AND QP6_REVI= (SELECT MAX(QP6_REVI) FROM QP6010 WHERE D_E_L_E_T_<>'*' AND QP6_PRODUT=%EXP:cProdutpai% )
	ENDSQL

	IF(CALIAS)->(!EOF())

		WHILE (CALIAS)->(!EOF())


			aAdd(aEnsaios,{(CALIAS)->QP1_DESCPO,(CALIAS)->QP7_NOMINA,(CALIAS)->QP7_LIE,QP7_LSE})

			(CALIAS)->(dbskip())

		ENDDO

		(calias)->(dbclosearea())

		for i:=1 to len(aEnsaios)
			//verifica se estão dentro dos parametros de ensaio
			cEnsaioAtual:=alltrim(aEnsaios[i,1])
			if "ESPESSURA TOTAL"==cEnsaioAtual
				nmin:=Val(UPSTRTRAN(aEnsaios[i,3],",","."))
				nmax:=Val(UPSTRTRAN(aEnsaios[i,4],",","."))
				IF nesp>=nmin .and. nesp<=nmax
					lRet:=.T.
					cEspespc:=alltrim(aEnsaios[i,3])+' - '+alltrim(aEnsaios[i,4])
				ELSE
					lErro:=.T.
					cMsg:="Espessura total fora dos limites. Contacte a Qualidade "
				ENDIF

			endif
		next

		if !lErro
			dbSelectArea("SB1")
			SB1->(dBSETORDER(1))
			SB1->(DBSEEK(XFILIAL('SB1')+SC2->C2_PRODUTO))
			nLargura:=SB1->B1_LARGURA
			nLarglimite:=0.7 //limite 0,= %
			nlargMax2:=nLargura+nLarglimite
			nlargMin2:=nLargura-nLarglimite
			if  nlargmin>=nlargMin2 .and. nlargmax<=nlargMax2
				lRet:=.T.

			else
				lErro:=.T.
				cMsg:="Largura fora dos limites especificados. Contacte a Qualidade "

			endif
		endif

		if !lErro

			//if ndiamE>=350 .and. ndiamE<=450
			if ndiamE>=ndiamEMin .and. ndiamE<=ndiamEMax
				lRet:=.T.
			else
				lErro:=.T.
				cMsg:="Diametro externo fora dos limites especificados. Contacte a Qualidade "

			endif
		endif
	ELSE
		ALERT("Nao existe especificao para o produto "+cProdutpai+". Contacte a Qualidade ")
	ENDIF

	If lErro
		lRet:=.F.
		Alert(cMsg)
	EndIf

return lret
