#include "ap5mail.ch"
#include "Protheus.Ch"
#include "TopConn.Ch"
#include "TBIConn.Ch"
#include "TbiCode.ch"

/*
Alerta de produtos monitorados, com saldo em estoque
Verifica campo B1_ESTAVIS = 'S'
*/

user function estqavis()
	local cAlias, cAssunto, cHTML, lCor, c_color

	RpcSetType(3)
	RpcSetEnv("01","01")
	prepare environment empresa '01' filial '01' tables "SB1,SB2,NNR"

	cAssunto:="Alerta de produtos com saldo em estoque. "
	cHTML:= ""
	cHTML+= '<html>'
	cHTML+= '<p align="CENTER"><b><u><font face="Times New Roman" size="4" color="0000FF">Alerta de produtos monitorados, com saldo em estoque.</font></u></b></p>'
	cHTML+= '<table width="100%" border="3" cellpadding="1">'
	cHTML+= '<tr>'
	cHTML+= '<td bgcolor="0000FF"><font color="FFFFFF">Produto</font></td>'
	cHTML+= '<td bgcolor="0000FF"><font color="FFFFFF">Descri&ccedil;&atilde;o</font></td>'
    cHTML+= '<td bgcolor="0000FF"><font color="FFFFFF">Local</font></td>'
    cHTML+= '<td align="right" bgcolor="0000FF"><font color="FFFFFF">Saldo</font></td>'
	cHTML+= '<td bgcolor="0000FF"><font color="FFFFFF">U.M.</font></td>'
	cHTML+= '</tr>'

	cAlias := getNextAlias()

	BeginSql alias cAlias

        SELECT B1_COD,
            B1_DESC,
            B1_UM,
            NNR_DESCRI,
            B2_QATU
        FROM %TABLE:SB1% SB1
            INNER JOIN %TABLE:SB2% SB2 ON B2_FILIAL = %xfilial:SB2%
            AND B2_COD = B1_COD
            AND B2_QATU > 0
            AND SB2.D_E_L_E_T_ = ' '
            INNER JOIN %TABLE:NNR% NNR ON NNR_FILIAL = %xfilial:NNR%
            AND NNR_CODIGO = B2_LOCAL
            AND NNR.D_E_L_E_T_ = ' '
        WHERE B1_FILIAL = %xfilial:SB1%
            AND B1_ESTAVIS = 'S'
            AND SB1.D_E_L_E_T_ = ' '
        ORDER BY B1_COD

	EndSQL

	c_color := "#FFFFFF"

	if (cAlias)->(EOF())
		cHTML+= '<tr>'
		cHTML+= '<td colspan="5" bgcolor="'+c_color+'"><font color="000000">'+'<br/>Nenhum produto foi encontrado.'+'</font></td>'
		cHTML+= '</tr>'
	endif

	WHILE (cAlias)->(!EOF())
		if lCor
			c_color := "#f5f5e9"
			lCor:=.F.
		else
			c_color := "#FFFFFF"
			lCor:=.T.
		endif

		cHTML+= '<tr>'
		cHTML+= '<td bgcolor="'+c_color+'"><font color="000000">'+alltrim((cAlias)->B1_COD)+'</font></td>'
		cHTML+= '<td bgcolor="'+c_color+'"><font color="000000">'+alltrim((cAlias)->B1_DESC)+'</font></td>'
        cHTML+= '<td bgcolor="'+c_color+'"><font color="000000">'+alltrim((cAlias)->NNR_DESCRI)+'</font></td>'
		cHTML+= '<td align="right" bgcolor="'+c_color+'"><font color="000000">'+transform((CALIAS)->B2_QATU,"@E 999,999.999")+'</font></td>'
        cHTML+= '<td bgcolor="'+c_color+'"><font color="000000">'+alltrim((cAlias)->B1_UM)+'</font></td>'
		cHTML+= '</tr>'

		(cAlias)->(DBSKIP())
	ENDDO
	(cAlias)->(DBCLOSEAREA())

	cHTML+= '</table>'
	cHTML+= '</html>'

	c_ends:=getmv("EM_ESTAVIS")

	u_EnvMail( cAssunto, cHTML, c_ends, 'sistema@inducoat.com.br' )
return
