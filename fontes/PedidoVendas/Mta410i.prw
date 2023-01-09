#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 14/11/00

User Function Mta410i()        // incluido pelo assistente de conversao do AP5 IDE em 14/11/00

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ


	if type("l410auto") == 'U' .or. !l410auto

		IF INCLUI
			if SC6->(recLock('SC6', .F.))
				SC6->C6_QTDORIG := C6_QTDVEN
				SC6->(msunlock())
			endif
		ENDIF
	endif

// Substituido pelo assistente de conversao do AP5 IDE em 14/11/00 ==> __Return(.t.)
Return(.t.)        // incluido pelo assistente de conversao do AP5 IDE em 14/11/00
