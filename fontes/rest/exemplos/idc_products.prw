#include "totvs.ch"
#include "restful.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} idc_products
Declaração do ws producs
@author Anderson Toledo
@since 25/04/2019
@version 1.0
/*/
//-------------------------------------------------------------------
WSRESTFUL idc_products DESCRIPTION 'endpoint idc_products API' FORMAT "application/json,text/html"
    WSDATA Page         AS INTEGER OPTIONAL
    WSDATA PageSize     AS INTEGER OPTIONAL
    WSDATA Order    AS CHARACTER OPTIONAL
    WSDATA Fields   AS CHARACTER OPTIONAL
    WSDATA aQueryString AS ARRAY OPTIONAL
    
 	WSMETHOD GET ProdList;
	    DESCRIPTION "Retorna uma lista de produtos";
	    WSSYNTAX "/api/v1/idc_products" ;
        PATH "/api/v1/idc_products" ;
	    PRODUCES APPLICATION_JSON
 	
END WSRESTFUL
//-------------------------------------------------------------------
/*/{Protheus.doc} GET ProdList
Método GET com id ProdList
@author Anderson Toledo
@since 25/04/2019
@version 1.0
/*/
//-------------------------------------------------------------------
WSMETHOD GET ProdList QUERYPARAM Page WSREST idc_products
Return getPrdList(self)
//-------------------------------------------------------------------
/*/{Protheus.doc} GET getPrdList
Função para tratamento da requisição GET
@author Anderson Toledo
@since 25/04/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function getPrdList( oWS )
   Local lRet  as logical
   Local oProd as object
   DEFAULT oWS:Page      := 1  
   DEFAULT oWS:PageSize      := 10  
   DEFAULT oWS:Fields    := ""
   lRet        := .T.
   //PrdAdapter será nossa classe que implementa fornecer os dados para o WS
   // O primeiro parametro indica que iremos tratar o método GET
   oProd := PrdAdapter():new( 'GET' )
  
   //o método setPage indica qual página deveremos retornar
   //ex.: nossa consulta tem como resultado 100 produtos, e retornamos sempre uma listagem de 10 itens por página.
   // a página 1 retorna os itens de 1 a 10
   // a página 2 retorna os itens de 11 a 20
   // e assim até chegar ao final de nossa listagem de 100 produtos 
   oProd:setPage(oWS:Page)
   // setPageSize indica que nossa página terá no máximo 10 itens
   oProd:setPageSize(oWS:PageSize)
    // SetOrderQuery indica a ordem definida por querystring
   oProd:SetOrderQuery(oWS:Order)
   // Esse método irá processar as informações
   //Irá transferir as informações de filtros da url para o objeto
   oProd:SetUrlFilter( oWS:aQueryString )
   // SetFields indica os campos que serão retornados via querystring
   oProd:SetFields( oWS:Fields )  
    // Esse método irá processar as informações
   oProd:GetListProd()
   //Se tudo ocorreu bem, retorna os dados via Json
   If oProd:lOk
       oWS:SetResponse(oProd:getJSONResponse())
   Else
   //Ou retorna o erro encontrado durante o processamento
       SetRestFault(oProd:GetCode(),oProd:GetMessage())
       lRet := .F.
   EndIf
   //faz a desalocação de objetos e arrays utilizados
   oProd:DeActivate()
   oProd := nil
   
Return lRet
