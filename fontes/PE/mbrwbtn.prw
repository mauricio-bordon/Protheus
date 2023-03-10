#INCLUDE "TOPCONN.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "FONT.CH"
//#include "prot1.ch"
#include "protheus.ch"
#include "dbtree.ch"
#include "ptmenu.ch"

User Function Mbrwbtn()        // incluido pelo assistente de conversao do AP5 IDE em 13/03/01

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	LOCAL _LRET
	//LOCAL lreturn
	LOCAL a_xareasd4
	//local cLogin:=UsrRetName(RetCodUsr())

	Public l_tts := .F.
	a_xareasd4:=GetArea()



/*
Valores possiveis no PARAMIXB[3]
Visualizar - 2
Incluir    - 3
Alterar    - 4
Excluir    - 5
*/
	if FUNNAME() == "MATA650"

		if PARAMIXB[3] == 4 .or. PARAMIXB[3] == 2
			if !Empty(SC2->C2_PEDIDO)
				dbSelectArea("SC6")
				dbSeek(xFilial("SC6")+SC2->C2_PEDIDO+SC2->C2_ITEMPV+SC2->C2_PRODUTO)

				dbSelectArea("SA1")
				dbSeek(xFilial("SA1")+SC6->C6_CLI)
				if !Empty(SA1->A1_OBSPROD)
					MSGALERT( SA1->A1_OBSPROD, "Atenção" )

				endif
			endif

		endif
    endif


		return _LRET
