#include 'totvs.ch'
#include 'parmtype.ch'


//-------------------------------------------------------------------
/*/{Protheus.doc} EstAdapterb2
Classe Adapter para o serviço
@author  Anderson Toledo
@since   25/04/2019
@version 1.0
/*/
//-------------------------------------------------------------------
CLASS EstAdapterb2 FROM FWAdapterBaseV2
	METHOD New()
	METHOD GetList()
EndClass
//-------------------------------------------------------------------
/*/{Protheus.doc} New
Método construtor
@param cVerb, verbo HTTP utilizado
@author  Anderson Toledo
@since   25/04/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Method New( cVerb ) CLASS EstAdapterb2
	_Super:New( cVerb, .T. )
return
//-------------------------------------------------------------------
/*/{Protheus.doc} GetListProd
Método que retorna uma lista de produtos 
@author  Anderson Toledo
@since   25/04/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Method GetList( ) CLASS EstAdapterb2
	Local aArea 	AS ARRAY
	Local cWhere	AS CHAR
	aArea   := FwGetArea()
	//Adiciona o mapa de campos Json/ResultSet
	AddMapFields( self )
	//Informa a Query a ser utilizada pela API
	::SetQuery( GetQuery() )
	//Informa a clausula Where da Query
	cWhere := " B1_FILIAL = '"+ FWxFilial('SB1') +"' AND SB1.D_E_L_E_T_ = ' ' and B2_FILIAL = '"+ FWxFilial('SB2') +"' AND SB2.D_E_L_E_T_ = ' ' "
	cWhere += " AND B2_LOCAL BETWEEN '01' AND '98' AND B1_TIPO NOT IN ('AT') "
	::SetWhere( cWhere )
	//Informa a ordenação a ser Utilizada pela Query
	::SetOrder( "B1_COD" )
	//Executa a consulta, se retornar .T. tudo ocorreu conforme esperado
	If ::Execute()
		conout(getLastQuery()[2]) 
		// Gera o arquivo Json com o retorno da Query
		// Pode ser reescrita, iremos ver em outro artigo de como fazer
		::FillGetResponse()
	else
		conout(getLastQuery()[2])
	EndIf
	
	FwrestArea(aArea)
RETURN
//-------------------------------------------------------------------
/*/{Protheus.doc} AddMapFields
Função para geração do mapa de campos
@param oSelf, object, Objeto da própria classe
@author  Anderson Toledo
@since   25/04/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function AddMapFields( oSelf )
	
	oSelf:AddMapFields( 'ID'             	, 'ID'  	, .T., .T., { 'ID'		, 'C', 60	, 0 },'B1_COD+B2_LOCAL' )
	oSelf:AddMapFields( 'CODIGO'            , 'B1_COD'  	, .T., .T., { 'B1_COD'		, 'C', TamSX3( 'B1_COD' )[1]	, 0 } )
	oSelf:AddMapFields( 'TIPO'	    		, 'B1_TIPO' 	, .T., .F., { 'B1_TIPO'		, 'C', TamSX3( 'B1_TIPO' )[1]	, 0 } )	
	oSelf:AddMapFields( 'DESCRIPTION'	    , 'B1_DESC' 	, .T., .F., { 'B1_DESC'		, 'C', TamSX3( 'B1_DESC' )[1]	, 0 }, 'RTRIM(B1_DESC)' )	
	oSelf:AddMapFields( 'UM'	    		, 'B1_UM' 		, .T., .F., { 'B1_UM'		, 'C', TamSX3( 'B1_UM' )[1]	, 0 } )	
	oSelf:AddMapFields( 'SALDO'				, 'B2_QATU' 	, .T., .F., { 'B2_QATU'		, 'N', TamSX3( 'B2_QATU' )[1]	, 3 } )
//	oSelf:AddMapFields( 'SALDO_PED'			, 'SALDO_PED' 	, .T., .F., { 'SALDO_PED'	, 'N', 						8	, 3 } , " SUM(C7_QUANT - C7_QUJE) ")
Return 
//-------------------------------------------------------------------
/*/{Protheus.doc} GetQuery
Retorna a query usada no serviço
@param oSelf, object, Objeto da própria classe
@author  Anderson Toledo
@since   25/04/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GetQuery()
	Local cQuery AS CHARACTER
	
	//Obtem a ordem informada na requisição, a query exterior SEMPRE deve ter o id #QueryFields# ao invés dos campos fixos
	//necessáriamente não precisa ser uma subquery, desde que não contenha agregadores no retorno ( SUM, MAX... )
	//o id #QueryWhere# é onde será inserido o clausula Where informado no método SetWhere()
	cQuery := " SELECT #QueryFields#"
    cQuery +=   " FROM " + RetSqlName( 'SB1' ) + " SB1 "
    cQuery +=   " INNER JOIN " + RetSqlName( 'SB2' ) + " SB2 ON B1_COD = B2_COD "
	//cQuery +=   " LEFT JOIN " + RetSqlName( 'SC7' ) + " SC7 ON B1_COD = C7_PRODUTO AND C7_FILIAL = '01' AND D_E_L_E_T_ <> '*' "
	cQuery += " WHERE #QueryWhere#"
	
Return cQuery
