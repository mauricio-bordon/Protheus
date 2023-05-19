#include 'totvs.ch'
#include 'parmtype.ch'


//-------------------------------------------------------------------
/*/{Protheus.doc} Fat2Adapter
Classe Adapter para o serviço
@author  Anderson Toledo
@since   25/04/2019
@version 1.0
/*/
//-------------------------------------------------------------------
CLASS Fat2Adapter FROM FWAdapterBaseV2
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
Method New( cVerb ) CLASS Fat2Adapter
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
Method GetList( ) CLASS Fat2Adapter
	Local aArea 	AS ARRAY
	Local cWhere	AS CHAR
	aArea   := FwGetArea()
	//Adiciona o mapa de campos Json/ResultSet
	AddMapFields( self )
	//Informa a Query a ser utilizada pela API
	::SetQuery( GetQuery() )
	//Informa a clausula Where da Query
	cWhere := " B1_FILIAL = '"+ FWxFilial('SB1') +"' AND SB1.D_E_L_E_T_ = ' ' "
	cWhere += " and A1_FILIAL = '"+ FWxFilial('SA1') +"' AND SA1.D_E_L_E_T_ = ' '"
	cWhere += " and F2_FILIAL = '"+ FWxFilial('SF2') +"' AND SF2.D_E_L_E_T_ = ' '"
	cWhere += " and D2_FILIAL = '"+ FWxFilial('SD2') +"' AND SD2.D_E_L_E_T_ = ' '"
	cWhere += " and BM_FILIAL = '"+ FWxFilial('SBM') +"' AND SBM.D_E_L_E_T_ = ' '"
	cWhere += " and D2_TES IN ( SELECT F4_CODIGO FROM " + RetSqlName( 'SF4' ) + " WHERE  F4_FILIAL = '"+ FWxFilial('SF4') +"' AND D_E_L_E_T_ = ' ' AND F4_DUPLIC = 'S') "
	::SetWhere( cWhere )
	//Informa a ordenação a ser Utilizada pela Query
	::SetOrder( "D2_EMISSAO, D2_DOC, D2_ITEM" )
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
	
	oSelf:AddMapFields( 'ID'   				, 'SD2KEY' 		, .T., .F., { 'SD2KEY'		, 'C', 13						, 0 }, 'D2_DOC+D2_ITEM' )
	oSelf:AddMapFields( 'EMISSAO_STR'       , 'D2_EMISSAO'  , .T., .T., { 'D2_EMISSAO'	, 'C', 10						, 0 }, "FORMAT(cast(D2_EMISSAO AS DATE),'dd/MM/yyyy')" )
	oSelf:AddMapFields( 'EMISSAO'           , 'D2_EMISSAO'  , .T., .T., { 'D2_EMISSAO'	, 'C', 10						, 0 } )
	oSelf:AddMapFields( 'CLIENTE'           , 'A1_COD'  	, .T., .T., { 'A1_COD'		, 'C', TamSX3( 'A1_COD' )[1]	, 0 } )
	oSelf:AddMapFields( 'NOME'		    	, 'A1_NOME' 	, .T., .F., { 'A1_NOME'		, 'C', TamSX3( 'A1_NOME' )[1]	, 0 }, 'RTRIM(A1_NOME)' )	
	oSelf:AddMapFields( 'DOC'        	    , 'D2_DOC'  	, .T., .T., { 'D2_DOC'		, 'C', TamSX3( 'D2_DOC' )[1]	, 0 } )
	oSelf:AddMapFields( 'GRUPO'             , 'B1_GRUPO'  	, .T., .T., { 'B1_GRUPO'	, 'C', TamSX3( 'B1_GRUPO' )[1]	, 0 } )
	oSelf:AddMapFields( 'PRODUTO'           , 'B1_COD'  	, .T., .T., { 'B1_COD'		, 'C', TamSX3( 'B1_COD' )[1]	, 0 } )
	oSelf:AddMapFields( 'DESCRICAO'	    	, 'B1_DESC' 	, .T., .F., { 'B1_DESC'		, 'C', TamSX3( 'B1_DESC' )[1]	, 0 }, 'RTRIM(B1_DESC)' )	
	oSelf:AddMapFields( 'LARGURA'	    	, 'B1_LARGURA' 	, .T., .F., { 'B1_LARGURA'	, 'N', TamSX3( 'B1_LARGURA' )[1], 0 } )	
	oSelf:AddMapFields( 'UNMEDIDA'	    	, 'D2_UM' 		, .T., .F., { 'D2_UM'		, 'C', TamSX3( 'D2_UM' )[1]		, 0 } )	
	oSelf:AddMapFields( 'QUANTIDADE'        , 'D2_QUANT'	, .T., .F., { 'D2_QUANT'	, 'N', TamSX3( 'D2_QUANT' )[1]	, 3 } )
	oSelf:AddMapFields( 'PRCVEN'	        , 'D2_PRCVEN'	, .T., .F., { 'D2_PRCVEN'	, 'N', TamSX3( 'D2_PRCVEN' )[1]	, 4 } )
	oSelf:AddMapFields( 'TOTAL'		        , 'D2_TOTAL'	, .T., .F., { 'D2_TOTAL'	, 'N', TamSX3( 'D2_TOTAL' )[1]	, 2 } )
	oSelf:AddMapFields( 'VALICMS'		    , 'D2_VALICM'	, .T., .F., { 'D2_VALICM'	, 'N', TamSX3( 'D2_VALICM' )[1]	, 2 } )
	oSelf:AddMapFields( 'PCICMS'		    , 'D2_PICM'		, .T., .F., { 'D2_PICM'		, 'N', TamSX3( 'D2_PICM' )[1]	, 2 } )
	//oSelf:AddMapFields( 'VALIMP5'		    , 'D2_VALIMP5'	, .T., .F., { 'D2_VALIMP5'	, 'N', TamSX3( 'D2_VALIMP5' )[1], 2 } )
	//oSelf:AddMapFields( 'ALIQIMP5'		    , 'D2_ALIQIMP5'	, .T., .F., { 'D2_ALIQIMP5'	, 'N', TamSX3( 'D2_ALIQIMP5' )[1], 2 } )
	oSelf:AddMapFields( 'PIS_COFINS'		    , 'PIS_COFINS'	, .T., .F., { 'PIS_COFINS'	, 'N', 13, 2 }, 'D2_VALIMP5+D2_VALIMP6' )
	//oSelf:AddMapFields( 'ALIQIMP6'		    , 'D2_ALIQIMP6'	, .T., .F., { 'D2_ALIQIMP6'	, 'N', TamSX3( 'D2_ALIQIMP6' )[1], 2 } )
	oSelf:AddMapFields( 'FAT_LIQUIDO'		, 'FATLIQUIDO'	, .T., .F., { 'FATLIQUIDO'	, 'N', 13						, 2 }, 'D2_TOTAL-D2_VALICM-D2_VALIMP5-D2_VALIMP6' )
	
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
	cQuery := " with abc as ( select * "
    cQuery +=   " FROM " + RetSqlName( 'SB1' ) + " SB1 "
    cQuery +=   " INNER JOIN " + RetSqlName( 'SD2' ) + " SD2"
	cQuery +=       " ON B1_COD = D2_COD "
	cQuery +=   " INNER JOIN " + RetSqlName( 'SF2' ) + " SF2"
	cQuery +=       " ON D2_DOC = F2_DOC "
	cQuery +=   " INNER JOIN " + RetSqlName( 'SA1' ) + " SA1"
	cQuery +=       " ON A1_COD = F2_CLIENTE "
	cQuery +=   " INNER JOIN " + RetSqlName( 'SBM' ) + " SBM"
	cQuery +=       " ON B1_GRUPO = BM_GRUPO )"
	cQuery += " SELECT #QueryFields# from abc WHERE #QueryWhere#"
	
Return cQuery
