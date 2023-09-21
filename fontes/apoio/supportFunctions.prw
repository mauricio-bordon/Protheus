//MSSQL
#include "protheus.ch"

//FUnções de Suporte


User Function liberaPwd(cTitle, cSX5)
	Local lRet := .F., cUser, cPwd, a_dadusr
	Local aUsers:={} 
	Local oDlg

//Obtém Lista de Usuários a partir da tabela do SX5 informada	
	dbselectarea("SX5")
	SX5->(dbsetorder(1))
	If SX5->(dbseek(xfilial()+cSX5))
	    While SX5->x5_tabela == cSX5 .and. SX5->(!eof())
	        aadd(aUsers,padr(left(sx5->x5_descri,15),15))
	        SX5->(dbskip())
	    Enddo
	Endif

	aSort(aUsers,,,{|x,y| x <= y } )

	oDlg:= MsDialog():New(115,085, 315,500, cTitle,,,,,CLR_BLACK,CLR_WHITE,,,.T.) 

	oSayUser	:= tSay():New(010,030,{||"Usuário:"},oDlg,,,,,,.T.,,,) 
	oSayPwd		:= tSay():New(030,030,{||"Senha:"},oDlg,,,,,,.T.,,,)

    cUser := space(20)
	oCmbUser:= tComboBox():New(10,82,,,,300,oDlg,,,,,,.T.,,,,,,,,,)
	oCmbUser:cVariable := "cUser"
	oCmbUser:bSetGet := {|u| If(PCount()>0,cUser:=u,cUser) }
	oCmbUser:aItems := aUsers
	oCmbUser:nAt := 0
	  
   	cPwd := space(6)
	oGetPwd:= TGet():New( 030,082,, oDlg, 40,10,,,,,,,,.T.,,.T.,,,,,.F.,.T.,,'cPwd') 
 	oGetPwd:bSetGet := {|u| If(PCount()>0,cPwd:=u,cPwd) }
    
	oBtn1 := SButton():New(010,170 , 1,{|| lRet:=.T.,oDlg:End()},,)
	oBtn2 := SButton():New(030,170 , 2,{|| lRet:=.F.,oDlg:End()},,)

	oDlg:Activate(,,,.T.,,,,,)
	
	if lRet
		lRet := .F.
		PswOrder(2)
		If pswSeek(cUser,.T.)
		    a_dadusr:=PswRet(1)
		    If pswname(cPwd)
		        lRet := .T.
		    else
		    	alert("Senha Inválida")
		    endif
		endif
	endif
	
return lRet

USer Function debugMsg(cmsg, lOk )
      
	if lOk
	     Conout(cmsg)
	endif

return  

user function implode(cTok,aArr)
           
	Local cStr, nLen, i
	                
	nLen := len(aArr)
	    
	cStr := ''
	for i := 1 to nLen
		cStr += aArr[i]
		if i <> nLen
			cStr += cTok
		endif	
	next
	
return cStr  

user Function explode(cTok,cStr)
           
	Local aArr
	
	aArr := STRTOKARR(cStr, cTok)    
	
return aArr
