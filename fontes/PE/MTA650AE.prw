/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma ³MTA650AE   ºAutor ³V
º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Executa apos excluir  op.							     -º±±
±±º          ³ Gera material necessario para separacao customizacao		  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP10.12                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function MTA650AE()
Local cNum  := SubStr(PARAMIXB[1],1,6)
Local cItem := PARAMIXB[2]
Local cSeq  := PARAMIXB[3]
Local cAssunto,cHTML,c_ends

dbSelectArea("ZQ0")
ZQ0->(dbSetOrder(1)) //ZT0_FILIAL+ZT0_NUMOP+ZT0_ITEM
ZQ0->(dbSeek(xFilial("ZQ0")+cNum+cItem+cSeq))

Do while ZQ0->(!eof())  .And. ZQ0->ZQ0_OP = cNum+cItem+cSeq
	//If Alltrim(ZQ0->ZQ0_OP) = Alltrim(cNum+cItem+cSeq)
		
		ZQ0->(RecLock("ZQ0", .F.))
		ZQ0->(DbDelete())
		ZQ0->(MsUnLock())
		
	//Endif
	ZQ0->(dbSkip())
Enddo

ZQ0->(dbclosearea())

cAssunto:="Ordem "+cNum+cItem+cSeq+" removida. "
cHTML:="Ordem "+cNum+cItem+cSeq+"<br>Produto "+SB1->B1_DESC+"<br>Removido por "+cusername
//Envia email para o pcp avisado que o email foi excluida
c_ends:="pcp@inducoat.com.br;ti@inducoat.com.br"
u_EnvMail( cAssunto, cHTML, c_ends, 'sistema@inducoat.com.br' )	



Return
