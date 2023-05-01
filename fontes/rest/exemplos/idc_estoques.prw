#include "totvs.ch"
#include "restful.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} idc_estoques
Declaração do ws producs
@author Anderson Toledo
@since 25/04/2019
@version 1.0
/*/
//-------------------------------------------------------------------
WSRESTFUL idc_estoques DESCRIPTION 'endpoint idc_estoques API' FORMAT "application/json,text/html"
    WSDATA Page         AS INTEGER OPTIONAL
    WSDATA PageSize     AS INTEGER OPTIONAL
    WSDATA Order    AS CHARACTER OPTIONAL
    WSDATA Fields   AS CHARACTER OPTIONAL
    WSDATA aQueryString AS ARRAY OPTIONAL
    
    WSMETHOD GET EstList;
	    DESCRIPTION "Retorna uma lista de produtos e estoque";
	    WSSYNTAX "/api/v1/idc_estoques" ;
        PATH "/api/v1/idc_estoques" ;
	    PRODUCES APPLICATION_JSON
 	
END WSRESTFUL
WSMETHOD GET EstList QUERYPARAM Page WSREST idc_estoques
Return getEstList(self)

Static Function getEstList( oWS )
   Local lRet  as logical
   Local oProd as object
   DEFAULT oWS:Page      := 1  
   DEFAULT oWS:PageSize      := 10  
   DEFAULT oWS:Fields    := ""
   lRet        := .T.
   //PrdAdapter será nossa classe que implementa fornecer os dados para o WS
   // O primeiro parametro indica que iremos tratar o método GET
   oProd := EstAdapter():new( 'GET' )
  
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
   oProd:GetList()
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
