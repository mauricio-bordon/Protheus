#include "ap5mail.ch"
#include "Protheus.Ch"
#include "TopConn.Ch"
#include "TBIConn.Ch"
#include "TbiCode.ch"


user function estoqmin()
	local cAlias,cAssunto,cHTML,lCor,c_color

	RpcSetType(3)
	RpcSetEnv("01","01") 
	prepare environment empresa '01' filial '01' tables "SB1,SB8"	

    cAssunto:="Produtos em estoque abaixo do minimo"


cHTML:=""
cHTML+='<html>'
cHTML+='<p align="CENTER"><b><u><font face="Times New Roman" size="4" color="0000FF">Alerta de Saldos de Produtos abaixo do minimo </font></u></b></p>'
cHTML+='<table width="100%" border="3" cellpadding="1">'
cHTML+='<tr>'
cHTML+='<td bgcolor="0000FF" width="15%"><b><i><font color="FFFFFF">Produto/Item</font></i></b></td>'
cHTML+='<td bgcolor="0000FF" width="40%"><b><i><font color="FFFFFF">Descri&ccedil;&atilde;o</font></i></b></td>'
cHTML+='<td bgcolor="0000FF" width="5%"><b><i><font color="FFFFFF">Um.</font></i></b></td>'
cHTML+='<td bgcolor="0000FF" width="15%"><b><i><font color="FFFFFF">Estoque Atual</font></i></b></td>'
cHTML+='<td bgcolor="0000FF" width="15%"><b><i><font color="FFFFFF">Estoque Mínimo</font></i></b></td>'
cHTML+='</tr>'

    cAlias := getNextAlias()

	BeginSql alias cAlias
	
    SELECT B1_COD,B1_DESC,B1_UM,B1_EMIN,SUM(B8_SALDO) AS SALDO
    FROM %TABLE:SB1% SB1
    INNER JOIN %TABLE:SB8% SB8
    ON B1_COD=B8_PRODUTO
    WHERE SB1.D_E_L_E_T_<>'*'
    AND SB8.D_E_L_E_T_<>'*'
    and B1_FILIAL=%xfilial:SB1%
    and B8_FILIAL=%xfilial:SB8%
    AND B1_EMIN>0
    GROUP BY B1_COD,B1_DESC,B1_UM,B1_EMIN
    HAVING SUM(B8_SALDO)-B1_EMIN<0 


	EndSQL

	WHILE (cAlias)->(!EOF())

	if lCor
				c_color := "#f5f5e9"
                lCor:=.F.
			else                   
				c_color := "#FFFFFF"
                lCor:=.T.
			endif 
		

 			cHTML+='<tr>'
			cHTML+='<td width="15%" bgcolor="'+c_color+'"><b><i><font color="000000">'+alltrim((cAlias)->B1_COD)+'</font></i></b></td>'
			cHTML+='<td width="40%" bgcolor="'+c_color+'"><b><i><font color="000000">'+alltrim((cAlias)->B1_DESC)+'</font></i></b></td>'
            cHTML+='<td width="5%" bgcolor="'+c_color+'"><b><i><font color="000000">'+alltrim((cAlias)->B1_UM)+'</font></i></b></td>'
			cHTML+='<td width="15%" bgcolor="'+c_color+'"><b><i><font color="000000">'+TRANSFORM((CALIAS)->SALDO,"@E 999,999.999")+'</font></i></b></td>'
			cHTML+='<td width="15%" bgcolor="'+c_color+'"><b><i><font color="000000">'+TRANSFORM((CALIAS)->B1_EMIN,"@E 999,999.999")+'</font></i></b></td>'
			cHTML+='</tr>'             


		(cAlias)->(DBSKIP())
	ENDDO
	(cAlias)->(DBCLOSEAREA())

cHTML+='</table>'
cHTML+='</html>'


c_ends:=getmv("EM_ESTOQMI")
//	subject:="Alerta de Saldo de Produtos"
	
//	if !empty(alltrim(getmv("MV_MODTST")))
//		arecebe:={alltrim(getmv("MV_MODTST"))}
//	endif		
//	U_SndEmail(amens,afiles,arecebe,.F.,subject)             
u_EnvMail( cAssunto, cHTML, c_ends, 'sistema@inducoat.com.br' )	


return
