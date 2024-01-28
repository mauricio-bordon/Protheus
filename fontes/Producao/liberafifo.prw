#INCLUDE "TOPCONN.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "FONT.CH"
#include "protheus.ch"


user function liberafifo()
Local lRet := .F., cPwd, a_dadusr
Local aUsers:={}
Local oDlg
Local aArea := GetArea()

oFont := TFont():New('Arial',,20,.T.)

aUsers := {'admin', 'william.ferreira','alexandro.agostinho'}

aSort(aUsers,,,{|x,y| x <= y } )

oDlg:= MsDialog():New(115,085, 515,500, 'Liberação FIFO com Senha',,,,,CLR_BLACK,CLR_WHITE,,,.T.)

oSayUser	:= tSay():New(010,010,{||"Usuário:"},oDlg,,oFont,,,,.T.,,,)
oSayPwd		:= tSay():New(030,010,{||"Senha:"},oDlg,,oFont,,,,.T.,,,)
oSayPwd		:= tSay():New(050,010,{||"Obs:"},oDlg,,oFont,,,,.T.,,,)

cUsrlib := space(20)
cObs := space(255)
oCmbUser:= tComboBox():New(10,60,,,,300,oDlg,,,,,,.T.,,,,,,,,,)
oCmbUser:cVariable := "cUser"
oCmbUser:bSetGet := {|u| If(PCount()>0,cUser:=u,cUser) }
oCmbUser:aItems := aUsers
oCmbUser:nAt := 0

cPwd := space(12)
oGetPwd:= TGet():New( 030,060,, oDlg, 80,10,,,,,,,,.T.,,.T.,,,,,.F.,.T.,,'cPwd')
oGetPwd:bSetGet := {|u| If(PCount()>0,cPwd:=u,cPwd) }

//Observação
oMGet:= TMultiGet():New( 45,55,, oDlg, 100, 80,,,,,,.T.,,)
oMGet:bSetGet := {|u| If(PCount()>0,cObs:=u,cObs) }
oMGet:lWordWrap := .T.

oBtn1 := SButton():New(090,170 , 1,{|| lRet:=.T.,oDlg:End()},,)
oBtn2 := SButton():New(110,170 , 2,{|| lRet:=.F.,oDlg:End()},,)

oDlg:Activate(,,,.T.,,,,,)

if lRet
	lRet := .F.
	
	if alltrim(cObs) == ''
		lRet := .F.
		alert('Observação Obrigatória')
	else
		PswOrder(2)
		If pswSeek(cUser,.T.)
			a_dadusr:=PswRet(1)
			If pswname(cPwd)
				lRet := .T.

            //envia email fora do fifo
            cAssunto:="Autorizado consumo fora do FIFO Lote "+M->D4_LOTECTL
            c_ends:=getmv("EM_FIFOLIB")
           cHtml:= "Ordem Produção: "+SD4->D4_OP+"<br>Autorizado por: "+cUser+"<br>"+"Motivo: "+alltrim(cObs)+"<BR>"+"Lote: "+M->D4_LOTECTL+"<br>"
           MsAguarde({||MsgRun("Gerando E-mail... Aguarde","",{|| u_EnvMail( cAssunto, cHTML, c_ends, 'sistema@inducoat.com.br' )	 })})
	        



			else
				alert("Senha Inválida")
			endif
		endif
	endif
endif

Return lRet
