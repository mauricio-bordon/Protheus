#include "protheus.ch"
#include "restful.ch"
#include 'rwmake.ch'
#Include "tbiconn.ch"
#include "topconn.ch"



wsrestful ws_vendasintra description "WS para incluir pedido da intra"
	wsdata NUMERO as char OPTIONAL

	wsmethod post ws1;
		description "incluir pedido intra";
		wssyntax "/ws_vendasintra/{NUMERO}";
		path "/ws_vendasintra/{NUMERO}"

end wsrestful

wsmethod post ws1 wsservice ws_vendasintra
	Local lPost := .T.
	Local lok := .T.
	Local oJson
	Local cNumero := ::NUMERO
	Local cBody := ::getContent()

	private cUserRest := cUsuario
	private cMsg := ''

	oJson := JsonObject():new()
	oJson:fromJSON(cBody)
	conout(cBody)

	CONOUT(cNumero)
	lOk := incpedido(cNumero)

	if !lOk
		::SetResponse('{ "message": "Erro","detailedMessage": "'+cMsg+'"}')
		self:setStatus(400)
	else

		::SetResponse('{ "message": "Pedido incluido com sucesso","detailedMessage": "Pedido incluido com sucesso"}')
		self:setStatus(200)

	endif
	conout('-------------')
Return lPost


static function incpedido(cNumero)
	Local cAliasCabec, Calias2
	cAliasCabec := getNextAlias()

	BeginSql alias cAliasCabec
        SELECT *
        FROM PEDIDOS
        where CODIGO = %exp:cNumero%
	ENdSql

	if (caliasCabec)->(eof())
		cmsgErro := "pedido não existe"
		CONOUT(cMsgErro)
		Return .F.
	endif


	//Buscar próximo número de Pedido
	Q2:="SELECT COALESCE(MAX(C6.C6_NUM),'000000') AS MAXNUM FROM "+RETSQLNAME("SC6")+" C6 "
	Q2+="WHERE C6.D_E_L_E_T_ <> '*' AND C6_FILIAL='"+XFILIAL("SC6")+"'"
	Q2+="AND C6.C6_NUM LIKE '0%' "

	tcquery q2 alias "query2" new

	query2->(dbgotop())

	c_c6max:=query2->maxnum
	n_ped:=val(c_c6max) + 1

	query2->(dbclosearea())

	ccnum:=strzero(n_ped,6)

	ccliente := (caliasCabec)->cliente

	dbSelectArea("SA1")
	dbSetOrder(1)
	dbSeek(xFilial("SA1")+cCliente)

	aCabec:=    {{"C5_NUM",ccnum          				    ,Nil},; // Numero do pedido
	{"C5_TIPO"   ,"N" 	                        ,Nil},; // Tipo de pedido
	{"C5_CLIENTE", alltrim(cCliente)			            ,Nil},; // Codigo do cliente
	{"C5_LOJAENT","01"                 		    ,Nil},; // Loja para entrada
	{"C5_LOJACLI",'01'                          ,Nil},; // Loja do cliente
	{"C5_TIPOCLI","R"                           ,Nil},; // Tipo cliente
	{"C5_CONDPAG",(caliasCabec)->CONDPAG			            ,Nil},; // Codigo da condicao de pagamento
	{"C5_TPFRETE",alltrim((caliasCabec)->tipo_frete)               ,Nil},; // Tipo de frete -- Sem frete
	{"C5_TRANSP" ,alltrim((caliasCabec)->Transportadora)	                    ,Nil},; // Trasnportadora?
	{"C5_REDESP" ,alltrim((caliasCabec)->redespacho)                      ,Nil},; // Transportadora redespacho
	{"C5_CLIENT" ,ccliente                      ,Nil},; // Cliente de Entrega
	{"C5_TIPOPER",if((caliasCabec)->TIPO=='A', "A","N")    ,Nil},;  // Tipo de Liberacao
	{"C5_EMISSAO",dDatabase                     ,Nil},; // Data de emissao
	{"C5_LIBEROK","S"                           ,Nil},; // Liberacao Total
	{"C5_TIPLIB" ,"1"                           ,Nil}}//,; // Tipo de Liberacao
	//   {"C5_MSGNOTA",Alltrim(SA1->A1_OBSNOTA)+" "+Alltrim(SA1->A1_OBSNOT2)      ,Nil}} //mensagem para nota


	itemc6 := 1
	//Busca itens da nota
	//Obtém Nota fiscal do itxerp
	cAlias2 := getNextAlias()

	BeginSQL alias cAlias2
			SELECT *			
            FROM PEDIDO_ITENS 
			WHERE CODIGO = %EXP:cNumero% 
	ENdSql
	aItens:={}
	while (cAlias2)->(!eof())
		//gERAR PRODUTO  caso nao exista
//			cProduto := 'PA' + (cAlias2)->produto+strzero( (cAlias2)->largura_corte, 4)
		conout('Grupo: '+(cAlias2)->produto + ' Largura: '+str((cAlias2)->largura_corte))
		cProduto :=	criasb1((cAlias2)->produto, (cAlias2)->largura_corte)
		conout('Produto: '+cProduto)
		if alltrim(cProduto) == ''
			cmsgErro := 'Erro produto criar'
			CONOUT(cmsgErro)
			return .F.
		endif
		//Dados do produto
		QB1:="SELECT B1.B1_COD, B1.B1_DESC, B1.B1_UM, B1.B1_ORIGEM, B1.B1_TS FROM "+RETSQLNAME("SB1")+" B1 "
		QB1+="WHERE B1.B1_FILIAL='"+XFILIAL("SB1")+"' AND B1.D_E_L_E_T_ <> '*' "
		QB1+="AND B1.B1_COD='"+cproduto+"' "
		conout(qb1)
		tcquery qb1 alias "queryb1" new
		queryb1->(dbgotop())

		c_codb1:=queryb1->b1_cod
		c_descb1:=alltrim(queryb1->b1_desc)
		c_umb1:=queryb1->b1_um
		c_origem := queryb1->b1_origem
		queryb1->(dbclosearea())
		CTpOper := ''//(CALIAS2)->P19_TIPO_OPERACAO
		cTes := ''
		if !empty(cTpOper)
			cTes := MaTesInt(2,cTpOper,cCliente,'01',"C",c_codb1)
		endif

		//VERIFICA SE É AMOSTRA OU PEDIDO E DEFINE O tes ctpoper
		if (caliasCabec)->tipo=='A'
			CTpOper := '7'
			cTes := '502'

		else

			CTpOper := '01'
			cTes := '512'

		endIF

		//Dados de Situação tributária
		CQUERY := "SELECT F4_SITTRIB, F4_CF "
		CQUERY += "FROM "+RETSQLNAME("SF4")+" "
		CQUERY += "WHERE D_E_L_E_T_ <> '*' AND F4_FILIAL = '"+XFILIAL("SF4")+"' "
		CQUERY += "AND F4_CODIGO = '"+cTes+"'"

		tcquery cQuery alias "queryF4" new
		queryf4->(dbgotop())

		// c_origb1:=left(c_origem,1) + alltrim(queryF4->f4_sittrib)
		// if substr(queryF4->f4_cf,1,1)=='5' .and. SA1->A1_EST <> 'SP'
		// 	c_cfop:= '6' + substr(queryF4->f4_cf,2,3)
		// else
		c_cfop:=  queryF4->f4_cf
		// endif
		queryF4->(dbclosearea())


		cNUMPCOM := alltrim((cAlias2)->pedido_cliente)
		if alltrim((cAlias2)->item_pedido_cliente) <> ''
			cITEMPC :=alltrim((cAlias2)->item_pedido_cliente)
		endif
		//endif


		//ITEM DO PEDIDO
		//dDtEntrega := stod(u_DIASUTEIS( DTOS(dDatabase),1))
		aadd(aItens, {{"C6_NUM"   ,ccnum          ,Nil},; // Numero do Pedido
		{"C6_ITEM"   ,strzero(itemc6,2)			           ,Nil},; // Numero do Item no Pedido
		{"C6_PRODUTO",padr(c_codb1,15)                     ,Nil},; // Codigo do Produto
		{"C6_DESCRI" ,alltrim(c_descb1)																																																																																																			                    ,Nil},; // descrição
		{"C6_UM"     ,c_umb1                      ,Nil},; // Unidade de Medida Primar.
		{"C6_QTDVEN" ,(cAlias2)->quant_mt                    ,Nil},; // Quantidade Vendida
		{"C6_PRCVEN" ,(cAlias2)->PRECO_FINAL                    ,Nil},; // Preco Unitario Liquido   ?????????????
		{"C6_PRUNIT" ,(cAlias2)->PRECO_FINAL                   ,Nil},; // Preco Unitario Liquido   ?????????????
		{"C6_VALOR"  ,ROUND((cAlias2)->PRECO_FINAL * (cAlias2)->quant_mt,2)					 ,Nil},; // Valor Total do Item  ??????????
		{"C6_TES"    , cTes                    ,Nil},; // Tipo de Entrada/Saida do Item // {"C6_TES"    ,space(3) ,Nil},; // Tipo de Entrada/Saida do Item
		{"C6_CF"     , alltrim(c_cfop)                ,Nil},; // CFOP
		{"C6_COMIS1" ,(cAlias2)->comissao          ,Nil},; // Comissao Vendedor
		{"C6_ENTREG" ,(dDatabase+1)   ,Nil},; // Data da Entrega
		{"C6_TIRADAS"    ,(cAlias2)->tiradas         ,Nil},; // Cliente
		{"C6_MTROLO"    ,(cAlias2)->metragem_linear         ,Nil},; // Cliente
		{"C6_TUBETE"    ,(cAlias2)->DIAMETRO_INTERNO        ,Nil},; // Cliente
		{"C6_EMBOBIN"    ,(cAlias2)->sentido_rebob        ,Nil},; // Cliente
		{"C6_EMBALA"    ,(cAlias2)->embalagem        ,Nil},; // Cliente
		{"C6_NUMPCOM" ,cNUMPCOM	,Nil},; // pEDIDO CLIENTE
		{"C6_ITEMPC" ,cITEMPC	,Nil},;
		{"C6_LOJA"   ,"01"                        ,Nil}}) // Classificação Fiscal

/*
,; // Loja do Cliente

,; // item pEDIDO CLIENTE
		{"C6_CLASFIS",'500'                    ,Nil}
{"C6_OPER"   ,cTpOper                                                                                                                                                                                     ,Nil},; // TP. OPERACAO

		*/
		itemc6++
		(cAlias2)->(dbSkip())
	enddo
	(cAlias2)->(dbCloseArea())
	(caliasCabec)->(dbclosearea())
	u_json_dbg(aCabec)
	u_json_dbg(aItens)
	if len(aItens) > 0
		Begin Transaction

			lMsErroAuto:=.F.

			MSExecAuto({|x,y,z|Mata410(x,y,z)},aCabec,aItens,3)   //Se houver mais de um item, passar no aItens entre virgulas; ex: {aItemPV,aItemPV1...}
			conout("execauto")
			ctitulo:="Erro na inclusao de pedido"
			cmsg:="Houve erro na inclusao de pedido "
			If lMsErroAuto  //Houve algum erro na execucao do SigaAuto
				conout("erroauto")
				ctitulo:="Erro na execucao do AUTO010."
				cmsg:="Verificar no SIGAADV o log "+NomeAutoLog()+CHR(13)
				conout(cMsg)
				DisarmTransaction()
				lok := .F.
			else
				//Avisos
			
					//atualiza pedido intra
					cUpd := " UPDATE PEDIDOS set PEDIDO_PROTHEUS = '"+ccnum+"', STATUS = '2' WHERE CODIGO = '"+cNumero+"'"
					//Tenta executar o update
					nErro := TcSqlExec(cUpd)

					//Se houve erro, mostra a mensagem e cancela a transação
					If nErro != 0
						Help( ,, 'Help',, "Erro ao ATUALIZAR PEDIDO INTRA. "+TcSqlError() , 1, 0 )
						DisarmTransaction()
						cmsg := ' Erro ao atualizar pedido intra'
						lOk := .F.
					else
							lok := .T.
					EndIf
					
			endif

		End Transaction
	else
		cMsgErro := "Erro ao inserir pedido. N Itens"
		CONOUT("Erro ao inserir pedido. N Itens --------------------------------------------------")
		lok := .F.
	endif


return lok


static function CRIASB1(cGrupo, nLARGCR)
	Local lOK := .T., aVetor, cB1_DESC
	Local cB1_COD := ''


//verifica se tem decimal
	if MOD(nLARGCR,1)==0
		cB1_COD:='PA'+ALLTRIM(cGrupo)+cValToChar(PADL(int(nLargcr),4,"0"))
	else
		//se tiver decimal adiciona a letra D mais o decimal 2 digitos
		aString:= STRTOKARR(alltrim(str(nLargcr)),".")
		sDecimal:=aString[2]
		if len(sDecimal)==1
			sDecimal:=sDecimal+'0'
		endif
		cB1_COD:='PA'+ALLTRIM(cGrupo)+cValToChar(PADL(int(nLargcr),4,"0"))+"D"+sDecimal

	ENDIF

conout(cB1_COD)
	dbSelectArea('SB1')
	SB1->(DbSetOrder(1))
	SB1->(DBSEEK(XFILIAL('SB1')+cB1_COD  ), .t.)
	IF SB1->(FOUND())
		conout('Achou: '+SB1->B1_COD)
		return cB1_COD
	ENDIF

	// Produto não existe , criar novo
	//----------------------------------
	// Dados do Produto
	//----------------------------------

	//Obter descricao do produto
	dbSelectArea('SBM')
	SBM->(DbSetOrder(1))
	SBM->(DBSEEK(XFILIAL('SBM')+cGrupo))
	cB1_DESC := SBM->BM_DESC + CValToChar(cLargCr) + ' MM'
//	 {"B1_COD"     	,cB1_COD	    	,Nil},;

	aVetor:= {	{"B1_DESC"    	,cB1_DESC 			,Nil},;
		{"B1_TIPO"    	,'PA'   		,Nil},;
		{"B1_UM"      	,'MT'       		,Nil},;
		{"B1_LOCPAD"  	,'01'        	,Nil},;
		{"B1_LARGURA" 	,cLARGCR	   	,Nil},;
		{"B1_GRUPO"   	,ALLTRIM(cGrupo)       	,Nil},;
		{"B1_RASTRO"  	,'L'		   	,Nil},;
		{"B1_LOCALIZ"  	,'S'		   	,Nil},;
		{"B1_LARGURA" 	,cLARGCR	   	,Nil}}

	conout("Antes Execauto mata010")
	lMsErroAuto := .F.
	MSExecAuto({|x,y| Mata010(x,y)},aVetor,3) //Inclusao

	If lMsErroAuto
		conout("ERRO Cadastro produto "+cB1_COD)
		lOk := .F.
		ctitulo:="Erro na execucao do AUTO010."
		cmsg:="Verificar no SIGAADV o log "+NomeAutoLog()+CHR(13)
		conout(cMsg)
		return ''
	Endif

return cB1_COD
