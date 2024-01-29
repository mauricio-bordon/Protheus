#include "protheus.ch"
#include "restful.ch"
#include 'rwmake.ch'
#Include "tbiconn.ch"
#include "topconn.ch"



wsrestful ws_vendas_intra description "WS para incluir pedido da intra"
	wsdata NUMERO as char OPTIONAL
	
	wsmethod post ws1;
		description "incluir pedido intra";
		wssyntax "/ws_vendas_intra/{NUMERO}";
		path "/ws_vendas_intra/{NUMERO}"

end wsrestful

wsmethod post ws1 wsservice ws_vendas_intra
	Local lPost := .T.
	Local lok := .T.
	Local oJson
    Local cNumero := ::NUMERO
	Local cBody := ::getContent()
    Local cAliasCabec, cAliasItens
	private cUserRest := cUsuario
	private cMsg := ''

	oJson := JsonObject():new()
	oJson:fromJSON(cBody)
	conout(cBody)

	
    lOk := incpedido()

	if !lOk
		::SetResponse('{ "message": "ValidaÃ§Ã£o de Empenho","detailedMessage": "'+cMsg+'"}')
		self:setStatus(400)
	else
		
			::SetResponse('{ "message": "ProduÃ§Ã£o realizada com sucesso","detailedMessage": "ProduÃ§Ã£o realizada com sucesso"}')
			self:setStatus(200)
		
	endif
	conout('-------------')
Return lPost


static function incpedido()

    cAliasCabec := getNextAlias()

    BeginSql alias cAliasCabec
        SELECT *
        FROM pedidos
        where numero = %exp:cNumero%
    ENdSql
    
    if (caliasCabec)->(eof())
        cmsgErro := "pedido não existe"
		Return .F.
    endif
    
Begin Transaction
	 	    
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
	    	        {"C5_CLIENTE", cCliente			            ,Nil},; // Codigo do cliente
	        	    {"C5_LOJAENT","01"                 		    ,Nil},; // Loja para entrada
	           	 	{"C5_LOJACLI",'01'                          ,Nil},; // Loja do cliente
		            {"C5_TIPOCLI","R"                           ,Nil},; // Tipo cliente        
		            {"C5_CLIFIN" ,cCliente        	      	    ,Nil},; // Codigo do cliente final	
		            {"C5_CONDPAG",(caliasCabec)->cond_pag			            ,Nil},; // Codigo da condicao de pagamento
		            {"C5_TPFRETE",(caliasCabec)->tipo_frete               ,Nil},; // Tipo de frete -- Sem frete
		            {"C5_TRANSP" ,(caliasCabec)->Transportadora	                    ,Nil},; // Trasnportadora?   
		            {"C5_REDESP" ,(caliasCabec)->redespacho                      ,Nil},; // Transportadora redespacho
	    	        {"C5_BLOQ"   ,'S'	                        ,Nil},; // Ped. Bloqueado ?
	        	    {"C5_CLIENT" ,ccliente                      ,Nil},; // Cliente de Entrega
		            {"C5_REMESSA","N"                           ,Nil},; // Simples remessa?
	    	        {"C5_TIPOPER",if(cTipoPed='AM', "A","N")    ,Nil},;  // Tipo de Liberacao
					{"C5_TABELA" ,"1"                           ,Nil},; // Codigo da Tabela de Preco
	 	            {"C5_EMISSAO",dDatabase                     ,Nil},; // Data de emissao
		            {"C5_PESOL"  ,0                         ,Nil},; // peso Liquido >> Obter na tela
		            {"C5_PBRUTO" ,0                         ,Nil},; // peso Bruto >> Obter na tela
		            {"C5_VOLUME1" ,0                       ,Nil},; // Volume >> Obter na tela
		            {"C5_ESPECI1" ,cEspecie+iif(nVolumes>1,'S', ''),Nil},; // Especie >> Obter na tela
		            {"C5_MOEDA"  ,1                             ,Nil},; // Moeda
	    	        {"C5_LIBEROK","S"                           ,Nil},; // Liberacao Total
	        	    {"C5_TIPLIB" ,"1"                           ,Nil}}//,; // Tipo de Liberacao
	        	 //   {"C5_MSGNOTA",Alltrim(SA1->A1_OBSNOTA)+" "+Alltrim(SA1->A1_OBSNOT2)      ,Nil}} //mensagem para nota  
	            	            
            (caliasCabec)->(dbclosearea())
	       	itemc6 := 1  
	 //Busca itens da nota   	         
		//Obtém Nota fiscal do itxerp
		cAlias2 := getNextAlias()
		
		BeginSQL alias cAliasItens
			SELECT *			
            FROM PEDIDO_ITENS 
			WHERE NUMERO = %EXP:cNumero% 
		ENdSql
		aItens:={}
	     while (cAlias2)->(!eof())   
	     		//gERAR PRODUTO  caso nao exista
             
			 
			    cProduto := 'PA' + (cAlias2)->produto+strzero( (cAlias2)->largura_corte, 4)

	           //Dados do produto   
		        QB1:="SELECT B1.B1_COD, B1.B1_DESC, B1.B1_UM, B1.B1_ORIGEM, B1.B1_TS FROM "+RETSQLNAME("SB1")+" B1 "
		        QB1+="WHERE B1.B1_FILIAL='"+XFILIAL("SB1")+"' AND B1.D_E_L_E_T_ <> '*' "
		        QB1+="AND B1.B1_COD='"+cproduto+"' "
		                    
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

				IF empty(CTES)
					alert('TES VAZIO. Verifique o pedido i4s')
					aItens := {}
					exit
				endif

		
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
		 	      dDtEntrega := stod(u_DIASUTEIS( DTOS(dDatabase),1))  
		          aadd(aItens, {{"C6_NUM"   ,ccnum          ,Nil},; // Numero do Pedido
								{"C6_ITEM"   ,strzero(itemc6,2)			           ,Nil},; // Numero do Item no Pedido
		            	        {"C6_PRODUTO",c_codb1                     ,Nil},; // Codigo do Produto
		                    	{"C6_DESCRI" ,c_descb1                    ,Nil},; // descrição
			                    {"C6_DPD"    ,c_dpd                   ,Nil},; // dpd
		    	                {"C6_UM"     ,c_umb1                      ,Nil},; // Unidade de Medida Primar.
		        	            {"C6_QTDVEN" ,(cAlias2)->total_metros_lineares                    ,Nil},; // Quantidade Vendida
		            	        {"C6_PRCVEN" ,(cAlias2)->preco_venda                    ,Nil},; // Preco Unitario Liquido   ?????????????
		                	    {"C6_PRUNIT" ,(cAlias2)->preco_venda                   ,Nil},; // Preco Unitario Liquido   ?????????????
		                	    {"C6_VALOR"  ,ROUND((cAlias2)->preco_venda * (cAlias2)->total_metros_lineares,2)					 ,Nil},; // Valor Total do Item  ??????????
		    	                {"C6_OPER"   ,cTpOper                                                                                                                                                                                     ,Nil},; // TP. OPERACAO
								{"C6_TES"    , cTes                    ,Nil},; // Tipo de Entrada/Saida do Item // {"C6_TES"    ,space(3) ,Nil},; // Tipo de Entrada/Saida do Item
								{"C6_CF"     , c_cfop                 ,Nil},; // CFOP
								{"C6_COMIS1" ,(cAlias2)->comissao          ,Nil},; // Comissao Vendedor
		        	            {"C6_ENTREG" ,stod((cAlias2)->data_entrega)   ,Nil},; // Data da Entrega
		            	             {"C6_CLI"    ,SA1->A1_COD        ,Nil},; // Cliente
		    	                {"C6_DESCONT",0                           ,Nil},; // Percentual de Desconto
		        	            {"C6_LOJA"   ,"01"                        ,Nil},; // Loja do Cliente
		            	        {"C6_NUMPCOM" ,cNUMPCOM	,Nil},; // pEDIDO CLIENTE
		  	                    {"C6_ITEMPC" ,cITEMPC	,Nil},; // item pEDIDO CLIENTE
		  	                    {"C6_CLASFIS",c_origb1                    ,Nil}}) // Classificação Fiscal            
		          		        
										   		                
		          				itemc6++    
		          				(cAlias2)->(dbSkip())
				enddo
				(cAlias2)->(dbCloseArea())	 
	 			if len(aItens) > 0	
	            	lMsErroAuto:=.F.
	           
	                MSExecAuto({|x,y,z|Mata410(x,y,z)},aCabec,aItens,3)   //Se houver mais de um item, passar no aItens entre virgulas; ex: {aItemPV,aItemPV1...}
		            conout("execauto")
		            ctitulo:="Erro na inclusao de pedido"
		            cmsg:="Houve erro na inclusao de pedido "
		            If lMsErroAuto  //Houve algum erro na execucao do SigaAuto
		                conout("erroauto")
		                //Mostraerro()
		                DisarmTransaction()
                        lok := .F. 
		            else
		            	//Avisos
		            	If nPesoB <= 0 .or. nPesoL <= 0 .or. nVolumes <= 0 
		            	  //   alert("Informações de Peso e/ou Volumes inconsistentes") 
		            	else
		            		msginfo("Pedido Incluido com Sucesso","Aviso")
							SC6->(DBSETORDER(1))
							SC6->(DBSEEK(XFILIAL('SC6')+ccnum))
                            lok := .T.
		            	endif
		            endif 
		            
		          
		        else
		             alert("Erro ao inserir pedido")   
		             DisarmTransaction() 
                     lok := .F.
		        endif            
	            End Transaction  

return lok
