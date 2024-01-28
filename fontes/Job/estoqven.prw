#include "ap5mail.ch"
#include "Protheus.Ch"
#include "TopConn.Ch"
#include "TBIConn.Ch"
#include "TbiCode.ch"

//Alerta sobre estoque vencido
user function estoqven()
	local cAlias,cAssunto,cHTML,lCor,c_color,sDias

	RpcSetType(3)
	RpcSetEnv("01","01") 
	prepare environment empresa '01' filial '01' tables "SB1,SB8"	

    cAssunto:="Alerta vencimento em estoque"


cHTML:=""
cHTML+='<html>'
cHTML+='<p align="CENTER"><b><u><font face="Times New Roman" size="4" color="0000FF">Alerta de produtos vencidos ou proximo do vencimento. </font></u></b></p>'
cHTML+='<table width="100%" border="3" cellpadding="1">'
cHTML+='<tr>'
cHTML+='<td bgcolor="0000FF" width="15%"><b><i><font color="FFFFFF">Produto</font></i></b></td>'
cHTML+='<td bgcolor="0000FF" width="40%"><b><i><font color="FFFFFF">Descri&ccedil;&atilde;o</font></i></b></td>'
cHTML+='<td bgcolor="0000FF" width="40%"><b><i><font color="FFFFFF">Lote</font></i></b></td>'
cHTML+='<td bgcolor="0000FF" width="5%"><b><i><font color="FFFFFF">Quantidade</font></i></b></td>'
cHTML+='<td bgcolor="0000FF" width="15%"><b><i><font color="FFFFFF">Vencimento</font></i></b></td>'
cHTML+='<td bgcolor="0000FF" width="15%"><b><i><font color="FFFFFF">Dias</font></i></b></td>'
cHTML+='</tr>'

    cAlias := getNextAlias()

	BeginSql alias cAlias
	
	    SELECT B1_COD,B1_DESC,B1_UM,B8_LOTECTL,B8_SALDO,B8_DTVALID,DATEDIFF(DAY,GETDATE(),CONVERT(DATE, B8_DTVALID, 112)) AS DIAS
    FROM %TABLE:SB1% SB1
    INNER JOIN  %TABLE:SB8% SB8
    ON B1_COD=B8_PRODUTO
    WHERE SB1.D_E_L_E_T_<>'*'
    AND SB8.D_E_L_E_T_<>'*'
	and B1_FILIAL=%xfilial:SB1%
    and B8_FILIAL=%xfilial:SB8%
   	AND B8_SALDO>0
	AND DATEDIFF(DAY,GETDATE(),CONVERT(DATE, B8_DTVALID, 112)) <30
	ORDER BY 7 desc

   

	EndSQL

	WHILE (cAlias)->(!EOF())
	
	if (cAlias)->DIAS <0
		sDias:='Vencido'
	else
		sDias:=str((cAlias)->DIAS)
	endif



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
            cHTML+='<td width="5%" bgcolor="'+c_color+'"><b><i><font color="000000">'+alltrim((cAlias)->B8_LOTECTL)+'</font></i></b></td>'
			cHTML+='<td width="15%" bgcolor="'+c_color+'"><b><i><font color="000000">'+TRANSFORM((CALIAS)->B8_SALDO,"@E 999,999.999")+' '+(CALIAS)->B1_UM+'</font></i></b></td>'
			cHTML+='<td width="15%" bgcolor="'+c_color+'"><b><i><font color="000000">'+dtoc(stod((CALIAS)->B8_DTVALID))+'</font></i></b></td>'
			cHTML+='<td width="15%" bgcolor="'+c_color+'"><b><i><font color="000000">'+sDias+'</font></i></b></td>'
		
			cHTML+='</tr>'             


		(cAlias)->(DBSKIP())
	ENDDO
	(cAlias)->(DBCLOSEAREA())

cHTML+='</table>'
cHTML+='</html>'


c_ends:=getmv("EM_ESTOQVE")
//c_ends:='vandeir.aniceto@inducoat.com.br'

u_EnvMail( cAssunto, cHTML, c_ends, 'sistema@inducoat.com.br' )	


return
