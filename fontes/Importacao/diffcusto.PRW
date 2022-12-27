#include "topconn.ch"
#include "rwmake.ch"

User Function DIFFCUSTO()

	local cFile, nLines, i
	Local _aCab1 := {}
	Local _aItem := {}
	Local _atotitem:={}
	Local cCodigoTM, cTMReq := '503', cTMDev := '003'
	Local cCodProd, cUnid
	Local cNotImp := '', cDoc

	Private lMsHelpAuto := .t. // se .t. direciona as mensagens de help
	Private lMsErroAuto := .f. //necessario a criacao

	Begin Transaction
		cFile	:= memoread('D:\INDUCOAT-dev\txt\carga-diff-custo.txt')
		nLines	:= MLCOUNT(cFile)
		//nLines	:= 3
		nSomaHr := 0
		for i:=1 to nLines
			cLine  := memoLine(cFile,,i)
			aDados := strtokarr(cLine,';')
			conout(cLine)
			cLotectl := aDados[2]
			cCodProd := aDados[1]
			
			dbSelectArea("SB1")
			SB1->(dBSETORDER(1))
			SB1->(DBSEEK(XFILIAL('SB1')+cCodProd))
			
			nD3Quant:= 0
			nD3Custo1:= val(aDados[4])
			cUnid := SB1->B1_UM

			cDoc := GETSXENUM("SD3","D3_DOC")
			cCodigoTM := ''
			if nD3Custo1 >= 0 
				cCodigoTM := cTMReq
			else
				nD3Custo1 := nD3Custo1 * (-1.0)
				cCodigoTM := cTMDev
			endif
			_aCab1 := {{"D3_DOC" , cDoc , NIL},;
				{"D3_TM" ,cCodigoTM , NIL},;
				{"D3_CC" ,"        ", NIL},;
				{"D3_EMISSAO" ,STOD('20221202'), NIL}}


			_aItem:={{"D3_COD" ,cCodProd ,NIL},;
				{"D3_UM" ,cUnid ,NIL},;
				{"D3_QUANT" ,nD3Quant ,NIL},;
				{"D3_CUSTO1" ,nD3Custo1 ,NIL},;
				{"D3_LOCAL" ,"01" ,NIL},;
				{"D3_OBSERVA" , 'Ajuste Custo ' ,NIL}}
			_atotitem:={}
			aadd(_atotitem,_aitem)

			lMsErroAuto := .f.
			MSExecAuto({|x,y,z| MATA241(x,y,z)},_aCab1,_atotitem,3)

			If lMsErroAuto
				Mostraerro()
				DisarmTransaction()
				cNotImp += cLine + Chr(10) + Chr (13)
				exit
			else
				ConfirmSX8()
				ConOut(" Incluido doc: " + cDoc)
			EndIf

		next
	End Transaction

return
