#include "totvs.ch"
#include "restful.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} idc_userid
Declaração do ws producs
@author Anderson Toledo
@since 25/04/2019
@version 1.0
/*/
//-------------------------------------------------------------------
WSRESTFUL idc_userid DESCRIPTION 'endpoint idc_userid API' FORMAT "application/json,text/html"
    
 	WSMETHOD GET userid;
	    DESCRIPTION "Retorna uma lista de produtos";
	    WSSYNTAX "/api/v1/idc_userid" ;
        PATH "/api/v1/idc_userid" ;
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
WSMETHOD GET userid QUERYPARAM Page WSREST idc_userid
Return getUserId(self)
//-------------------------------------------------------------------
/*/{Protheus.doc} GET getPrdList
Função para tratamento da requisição GET
@author Anderson Toledo
@since 25/04/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function getUserId( oWS )
   Local lRet  as logical
   Local oJson := JsonObject():new()
   lRet        := .T.

    oJson['userid'] = __CUSERID 
    oWS:SetResponse(oJson:toJson())

Return lRet
