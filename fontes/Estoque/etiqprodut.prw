#INCLUDE "RWMAKE.CH" 
#Include 'Protheus.ch'
#INCLUDE "TBICONN.CH" // BIBLIOTECA

User Function Etiqprodut()
    Local nTamlinha:=0, lok := .F.
	private nQuant := 1,nQuante := 1,cObs := space(50)
    
	loK := pergunta()

	if !lok
		return
	endif

    MSCBPRINTER("zebra2","LPT1",,,.f.,,,,) //IMPRESSORA ELTRON (TLP 2844) antes zebra2
    MSCBCHKSTATUS(.F.)                  
    MSCBBEGIN(nQuante,6)
			       nTamlinha:=50                    
                   if len(alltrim(SB1->B1_DESC))>50       
			    	nTamlinha:=tamlinha(substr(alltrim(SB1->B1_DESC),1,55))
    	    		endif
         
    
       MSCBLineH(05,23,150,4) //SEGUNDA LINHA HORIZONTAL
        MSCBSAYBAR(40,08,alltrim(SB1->B1_COD),"MB02","C",15,.F.,.F.,.F.,,2,1) 
								MSCBSAY(05,25,"Codigo: "+alltrim(SB1->B1_COD),"N","0","028,030")
				MSCBSAY(05,35,substr(alltrim(SB1->B1_DESC),1,nTamlinha),"N","0","028,030") 
				if len(alltrim(SB1->B1_DESC))>55   
				MSCBSAY(10,40,substr(alltrim(SB1->B1_DESC),(nTamlinha+1),50),"N","0","028,030") 
				MSCBSAY(05,50,"Qtde.: "+cValToChar(nQuant)+" "+alltrim(SB1->B1_UM),"N","0","028,030")	
				else
				MSCBSAY(05,45,"Qtde.: "+cValToChar(nQuant)+" "+alltrim(SB1->B1_UM),"N","0","028,030")
				endif 
			    MSCBSAY(05,55,alltrim(cObs),"N","0","028,030")     
	        
	            MSCBSAY(50,65,"Usuario: "+alltrim(cUserName),"N","0","015,018")    
    MSCBEND()
   
    MSCBCLOSEPRINTER()
    
return    


static function tamlinha(cText)
local nRet

nRet:=len(SUBSTR(cText, 1, RAT(" ", cText) - 1))   

return nRet

static function pergunta()
	Local lOk := .T.
	Local aButtons := {}

	Private lMsErroAuto :=.F.
	Private lMsHelpAuto :=.T.

	oDlg := MSDIALOG():New(000,000,200,400, 	" Informe os dados:" ,,,,,,,,,.T.)
	nLinha := 35
	nSpace := 15


	oSay1:= tSay():New(nLinha,10,{||"Quantidade produto"},oDlg,,,,,,.T.,,,)
	oGet1:= TGet():New(nLinha,60,, oDlg, 60,10,'@E 999',,,,,,,.T.,,.T.,,,,,.F.,,,'nQuant')
	oGet1:bSetGet := {|u| If(PCount()>0,nQuant:=u,nQuant) }
	nLinha += nSpace

	oSay2:= tSay():New(nLinha,10,{||"Quantidade Etiqueta"},oDlg,,,,,,.T.,,,)
	oGet2:= TGet():New(nLinha,60,, oDlg, 60,10,'@E 999',,,,,,,.T.,,.T.,,,,,.F.,,,'nQuante')
	oGet2:bSetGet := {|u| If(PCount()>0,nQuante:=u,nQuante) }
	nLinha += nSpace

	oSay8:= tSay():New(nLinha,10,{||"Observação:"},oDlg,,,,,,.T.,,,)
	oGet8:= TGet():New(nLinha,60,, oDlg, 120,10,'@!',,,,,,,.T.,,.T.,,,,,.F.,,,'cObs')
	oGet8:bSetGet := {|u| If(PCount()>0,cObs:=u,cObs) }
	nLinha += nSpace

	oDlg:lCentered := .T.

	ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg, {||lOk := valida(), iif(lOk,oDlg:End(), .F.)}, {|| lOk := .F., oDlg:End()},,aButtons))

	if !lOk
		alert('Usu?rio cancelou a rotina')
	endif

return lOk

static function valida()
	Local lret := .T.

    if nQuant == 0 .or. nQuante == 0
        msgstop('Informar valores maiores que 0')
        lret := .F.
    endif

return lRet
