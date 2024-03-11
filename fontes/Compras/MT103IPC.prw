#INCLUDE "RWMAKE.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MT103IPC  ºAutor  ³Leonardo Azevedo    º Data ³  03/20/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Preenche o campo D1_DESCR do aCols com a descricao do       º±±
±±º          ³produto da SC7 ou se nao existir da SB1.                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function MT103IPC()

LOCAL _nPosDESCRI,_nPosCOD, _nPosPEDIDO, _nPosITEMPC:=0, _N

_aArea := GetArea()

_nPosDESCRI := ASCAN(aHeader,{|X|Trim(X[2])=="D1_DESCR"})
_nPosncm := ASCAN(aHeader,{|X|Trim(X[2])=="D1_POSIPI"})
_nPosCOD    := ASCAN(aHeader,{|X|Trim(X[2])=="D1_COD"})
_nPosPEDIDO := ASCAN(aHeader,{|X|Trim(X[2])=="D1_PEDIDO"})
_nPosITEMPC := ASCAN(aHeader,{|X|Trim(X[2])=="D1_ITEMPC"})

If _nPosCOD > 0
	dbSelectArea("SB1")
	_nOrdSB1 := IndexOrd()
	_nRecSB1 := Recno()

	For _n := 1 to Len(aCols)
		dbSelectArea("SB1")
		dbSetOrder(1)

		If dbSeek(xFilial("SB1") + aCols[_n,_nPosCOD])
		   	dbSelectArea("SC7")
			_nIndSC7 := IndexOrd()
			_nRecSC7 := Recno()
			dbSetOrder(1)
			
			If dbSeek(xFilial("SC7") + aCols[_n,_nPosPEDIDO] + aCols[_n,_nPosITEMPC])
				aCols[_n,_nPosDESCRI]  := Alltrim(SC7->C7_DESCRI)
			Else
				aCols[_n,_nPosDESCRI] := SB1->B1_DESC
			Endif
            aCols[_n,_nPosncm]:= SB1->B1_POSIPI
			dbSelectArea("SC7")
			dbSetOrder(_nIndSC7)
			dbGoTo(_nRecSC7)
	
		Endif
	Next

	dbSelectArea("SB1")
	dbSetOrder(_nOrdSB1)
	dbGoto(_nRecSB1)
	
Endif
			
RestArea(_aArea)

Return
