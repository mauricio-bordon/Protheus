#include "ap5mail.ch"
#include "Protheus.Ch"
#include "TopConn.Ch"
#include "TBIConn.Ch"
#include "TbiCode.ch"


user function inadimp()
	local cAlias,cAssunto,cHTML
	RpcSetType(3)
	RpcSetEnv("01","01")
	prepare environment empresa '01' filial '01' tables "SE1,SA1"


	cAssunto:="Aviso de Titulos Vencidos"

	cAlias := getNextAlias()

	BeginSql alias cAlias
	
	SELECT DATEDIFF(day,CONVERT(DATE,E1_VENCREA,103),GETDATE()) DIFERENCA
	,A1_NOME,A1_EMAIL,E1_SALDO,E1_NUM,E1_PARCELA,E1_VENCREA,A3_NOME,A3_EMAIL
	,E1_PREFIXO,E1_PARCELA
	FROM %TABLE:SE1% SE1
	INNER JOIN %TABLE:SA1% SA1
	ON A1_COD=E1_CLIENTE
	LEFT OUTER JOIN %TABLE:SA3% SA3
	ON A3_COD=A1_VEND
	WHERE SE1.D_E_L_E_T_<>'*' 
	AND SA1.D_E_L_E_T_<>'*'
	AND SA3.D_E_L_E_T_<>'*'
	and A1_FILIAL=%xfilial:SA1%
	and E1_FILIAL=%xfilial:SE1%
	and A3_FILIAL=%xfilial:SA3% 
	AND E1_SALDO>0
	AND DATEDIFF(day,CONVERT(DATE,E1_VENCREA,103),GETDATE())>1

	EndSQL

	WHILE (cAlias)->(!EOF())

		cHTML:=""
		cHTML+='<html>'
		cHTML+='<p align="CENTER"><b><u><font face="Times New Roman" size="4" color="0000FF">Aviso de T&iacute;tulos Vencidos</font></u></b></p>'
		cHTML+='<p align="left">Prezado cliente,<br><br>Os t&iacute;tulos abaixo constam em nosso sistema como vencidos. '
		cHTML+='Pedimos a gentileza de providenciar o pagamento dos mesmos o quanto antes. <br>'
		cHTML+='Caso os mesmos j&aacute; tenham sido pagos, por favor, desconsidere esta mensagem.</p>'
		cHTML+='<table width="100%" border="3" cellpadding="1">'
		cHTML+='<tr>'
		cHTML+='<td bgcolor="0000FF" width="30%" align="center"><b><i><font color="FFFFFF">T&iacute;tulo</font></i></b></td>'
		cHTML+='<td bgcolor="0000FF" width="30%" align="center"><b><i><font color="FFFFFF">Vencimento</font></i></b></td>'
		cHTML+='<td bgcolor="0000FF" width="40%" align="center"><b><i><font color="FFFFFF">Valor</font></i></b></td>'
		cHTML+='</tr>'

			cHTML+='<tr>'
			cHTML+='<td bgcolor="FFFFFF" width="30%" align="right"><b><font color="000000" size="2">'+alltrim(cAlias->E1_PREFIXO)+alltrim(cAlias->E1_NUM)+alltrim(cAlias->E1_PARCELA)+'</font></b></td>'
			cHTML+='<td bgcolor="FFFFFF" width="30%" align="right"><b><font color="000000" size="2">'+substr(cAlias->E1_VENCREA,7,2)+"/"+substr(cAlias->E1_VENCREA,5,2)+"/"+substr(cAlias->E1_VENCREA,1,4)+'</font></b></td>'
			cHTML+='<td bgcolor="FFFFFF" width="40%" align="right"><b><font color="000000" size="2">'+transform(cAlias->E1_SALDO,"@E 999,999,999.99")+'</font></i></b></td>'
			cHTML+='</tr>'
	
		
		cHTML+='</table>'
		cHTML+='<p align="left">Esta &eacute; uma mensagem autom&aacute;tica e n&atilde;o &eacute; necess&aacute;rio respond&ecirc;-la.'
		cHTML+='<br>Quaisquer d&uacute;vidas favor entrar em contato pelo email <a href="mailto:financeiro@inducoat.com.br">financeiro@inducoat.com.br</a> ou pelo telefone +55 (19) 3167-0700.</p>'
		cHTML+='</html>'

		//colocar em teste
		c_ends:="financeiro@inducoat.com.br; ti@inducoat.com.br"

		u_EnvMail( cAssunto, cHTML, c_ends, 'sistema@inducoat.com.br' )	

		(cAlias)->(DBSKIP())
	ENDDO
	(cAlias)->(DBCLOSEAREA())


RETURN
