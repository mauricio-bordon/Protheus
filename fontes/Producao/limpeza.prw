#include "protheus.ch"
#include "TOTVS.ch"
#define MB_YESNO                    4
#define MB_ICONASTERISK             64

//GRAVA C2_LIMPEZA 
user function limpeza()
	local slog:=dToS(Date()) + ";" +Time()+";"+cUserName
	local cmsg
	if empty(SC2->C2_LIMPEZA)
		cmsg:="Você "+cUserName+" realizou os procedimentos abaixo de limpeza de linha?"+chr(13)+chr(10)+chr(13)+chr(10)
		cmsg+="· Finalizado a ordem anterior, o apontamento e devolução"+chr(13)+chr(10)+chr(13)+chr(10)
		cmsg+="· Verificado se todo o material da ordem anterior está identificado"+chr(13)+chr(10)+chr(13)+chr(10)
		cmsg+="· Retirado as MPs e Embalagens da ordem anterior para retorno do Estoque"+chr(13)+chr(10)+chr(13)+chr(10)
		cmsg+="· Retirado os Produtos produzidos da ordem anterior para Rack e/ou Expedição"+chr(13)+chr(10)+chr(13)+chr(10)
		cmsg+="· Retirado toda a documentação referente a ordem anterior"+chr(13)+chr(10)+chr(13)+chr(10)
		cmsg+="· Retirado o lixo e os resíduos da ordem anterior, descartando-os em local adequado"+chr(13)+chr(10)+chr(13)+chr(10)
		cmsg+="· Realizado a higienização do equipamento, da bancada, dos utensílios e do chão com produto adequado."+chr(13)+chr(10)+chr(13)+chr(10)

		nRet := MessageBox(cmsg,"Limpeza de linha",MB_YESNO)

		if nRet == 6

			SC2->(RecLock("SC2", .F. ))
			SC2->C2_LIMPEZA := slog
			SC2->(MSUNLOCK())
			MSGINFO('Registro de limpeza de linha realizado com sucesso!', 'Aviso')
			MessageBox('Registro de limpeza de linha realizado com sucesso!', 'Aviso',MB_ICONASTERISK)

		endif
	endif

return
