
#INCLUDE "PROTHEUS.CH"
#include "RWMAKE.ch"
#include "Colors.ch"
#include "Font.ch"
#Include "HBUTTON.CH"
#include "Topconn.ch"
#include "TbiConn.ch"
#include "TbiCode.ch"
User Function lerbarnfe()
	Local cCodBar:=Space(44), x
	DEFINE MSDIALOG _oPTbar FROM  50, 050 TO 200,400 TITLE OemToAnsi('Ler Chave de acesso NFE') PIXEL
//@ 007,050 Say OemToAnsi("PRÉ NOTA INSERIDA COM SUCESSO") COLOR CLR_HBLUE Size 150,030

	@ 015,005 Say OemToAnsi("Leia a chave de acesso da Nota Fiscal")	  	Size 150,030
	@ 030,005 Get cCodBar  Picture "@!S80"  Size 150,060


//@ 135,060 Button OemToAnsi("Obter Peso") Size 036,016 Action (nPeso := U_PesoBalanca())
	@ 045,010 Button OemToAnsi("Ok")  Size 036,016 Action ( Close(_oPTbar) )
//	@ 135,160 Button OemToAnsi("Sair")   Size 036,016 Action (Fecha())


	Activate Dialog _oPTbar CENTERED


	//valida se foi digitado apenas numero
	for x:=1 to len (cCodBar)
		If substr(cCodBar,x,1) >=chr(48) .and. substr(cCodBar,x,1) <=chr(57)

		Else
			cCodBar:=""
		Endif
	Next




Return(cCodBar)
