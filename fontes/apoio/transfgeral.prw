#include "protheus.ch"
#include "restful.ch"
#include 'rwmake.ch'
#Include "tbiconn.ch"

/* sql RETORNA RESULTADO E TRANSFERE TUDO PARA 01/LP */
user function transfgeral()
LOCAL cAlias
local lLote
local cLocalDest, cLoclzDest

cLocalDest:='02'
cLoclzDest:='CH1'
// se for sem lote 
lLote:=.F.

	cAlias := getNextAlias()

		BeginSql Alias cAlias
			select * from SBF010 (nolock)
			where BF_FILIAL = %XFILIAL:SBF% AND %NOTDEL% 
			AND BF_QUANT > 0
			AND BF_LOCAL = '01' 
			AND (BF_PRODUTO LIKE 'PM%' or BF_PRODUTO LIKE 'EM%' )
            //AND BF_LOCALIZ<>'LP'

		EndSql
		While !(cAlias)->(Eof())
	
    // comentado quando usar descomentar
        transfi((cAlias)->BF_PRODUTO, (cAlias)->BF_QUANT,(cAlias)->BF_LOCAL,(cAlias)->BF_LOCALIZ, cLocalDest, cLoclzDest, (cAlias)->BF_LOTECTL, 'Admin',lLote)
    
        (cAlias)->(dbSkip())
	    enddo
	
    	(cAlias)->(DBCLOSEAREA())




RETURN

static function transfi(cCod, nQTD,cLocalOrig,cLoczOrigem, cLocalDest, cLoclzDest, cLote, cUserRest,lLote)

	Local aAuto := {}

	Local aLinha := {}
	Local lRet:=.T.

	//local dDtValid
	Private lMsErroAuto := .F.
	//cMaq := substr(cMaq,1,2)
	conout('Codigo '+cCod)
//conout('Qtd '+ alltrim(str(nqtd)))
	conout('Local Destino '+cLocalDest)
	conout('Loclz Destino '+cLoclzDest)
//	conout('Usuario '+cUserRest)
	conout('Lote '+cLote)
	//POSICIONA NA SB8
	if lLote
    SB8->(DBSETORDER(3))
    SB8->(DBSEEK(XFILIAL("SB8")+PadR(cCod, tamsx3('B8_PRODUTO') [1])+PadR(cLocalOrig, tamsx3('B8_LOCAL') [1])+PadR(cLote, tamsx3('B8_LOTECTL') [1])))
    conout("B8 "+SB8->B8_PRODUTO)
	conout("B8 Lote ->"+SB8->B8_LOTECTL)
	
	endif
	//dDtValid:=getvalidade(cCod,cLote);
	//lNovo := U_GERASB2(cCod, cLocalDest)

//u_zMta261(cCod, cLote, nQTD, cLocalOrig, cLoczOrigem, cLocalDest, cLoclzDest)
	Begin Transaction
		aadd(aAuto,{GetSxeNum("SD3","D3_DOC"),dDataBase}) //Cabecalho

		nx := 1
		aLinha := {}
//Origem 
		SB1->(MsSeek(xFilial("SB1")+PadR(cCod, tamsx3('D3_COD') [1])))

		aadd(aLinha,{"ITEM", strzero(nX,3), Nil})
		aadd(aLinha,{"D3_COD", SB1->B1_COD, Nil}) //Cod Produto origem
		aadd(aLinha,{"D3_DESCRI", SB1->B1_DESC, Nil}) //descr produto origem
		aadd(aLinha,{"D3_UM", SB1->B1_UM, Nil}) //unidade medida origem
		aadd(aLinha,{"D3_LOCAL", PadR(cLocalOrig, tamsx3('D3_LOCAL') [1]), Nil}) //armazem origem
		aadd(aLinha,{"D3_LOCALIZ",  PadR(cLoczOrigem, tamsx3('D3_LOCALIZ') [1]), Nil}) //endereço origem

//Destino 
		aadd(aLinha,{"D3_COD", SB1->B1_COD, Nil}) //cod produto destino
		aadd(aLinha,{"D3_DESCRI", SB1->B1_DESC, Nil}) //descr produto destino
		aadd(aLinha,{"D3_UM", SB1->B1_UM, Nil}) //unidade medida destino
		aadd(aLinha,{"D3_LOCAL", PadR(cLocalDest, tamsx3('D3_LOCAL') [1]) , Nil}) //armazem destino
		aadd(aLinha,{"D3_LOCALIZ", PadR(cLoclzDest, tamsx3('D3_LOCALIZ') [1]), Nil}) //endereço destino

		aadd(aLinha,{"D3_NUMSERI", "", Nil}) //Numero serie
		aadd(aLinha,{"D3_LOTECTL", PadR(cLote, tamsx3('D3_LOTECTL') [1]), Nil}) //Lote Origem
		aadd(aLinha,{"D3_NUMLOTE", "", Nil}) //sublote origem
	//	aadd(aLinha,{"D3_DTVALID", '', Nil}) //data validade
		
		if lLote
		aadd(aLinha,{"D3_DTVALID", SB8->B8_DTVALID, Nil}) //data validade
		endif 

		aadd(aLinha,{"D3_POTENCI", 0, Nil}) // Potencia
		aadd(aLinha,{"D3_QUANT", nQTD, Nil}) //Quantidade
		aadd(aLinha,{"D3_QTSEGUM", 0, Nil}) //Seg unidade medida
		aadd(aLinha,{"D3_ESTORNO", "", Nil}) //Estorno
		aadd(aLinha,{"D3_NUMSEQ", "", Nil}) // Numero sequencia D3_NUMSEQ

		aadd(aLinha,{"D3_LOTECTL",  PadR(cLote, tamsx3('D3_LOTECTL') [1]), Nil}) //Lote destino
		aadd(aLinha,{"D3_NUMLOTE", "", Nil}) //sublote destino
		//aadd(aLinha,{"D3_DTVALID", dDtValid, Nil}) //validade lote destino
		//aadd(aLinha,{"D3_DTVALID", '', Nil}) //data validade 
		// comentado no lLote
		//aadd(aLinha,{"D3_DTVALID", SB8->B8_DTVALID, Nil}) //data validade
    
		aadd(aLinha,{"D3_ITEMGRD", "", Nil}) //Item Grade
		aadd(aLinha,{"D3_CODLAN", "", Nil}) //cat83 prod origem
		aadd(aLinha,{"D3_CODLAN", "", Nil}) //cat83 prod destino

		//	aadd(aLinha,{"D3_USUARIO", cUserRest, Nil}) //Item Grade
		//	aadd(aLinha,{"D3_DTSIST", DATE(), Nil}) //Item Grade
		//	aadd(aLinha,{"D3_HRSIST", TIME(), Nil}) //Item Grade

		aAdd(aAuto,aLinha)

		oJson := JsonObject():new()
		oJson:set(aAuto)
		conout(ctxt := oJson:toJson())
		MSExecAuto({|x,y| mata261(x,y)},aAuto,3)

		conout(' Valor do lMsErroAuto apos execu??o')
		conout(lMsErroAuto)
		if lMsErroAuto
			cmsg:="Verificar no SIGAADV o log "+ALLTRIM(NomeAutoLog()+CHR(13))
			conout(cMsg)
			cErrRest := cmsg
			lRet:=.F.
		endif

		if !lret
			conout('erro na execução')
			DisarmTransaction()
		endif
	End Transaction
return lRet



