//Bibliotecas
#Include 'RwMake.ch'
#Include 'Protheus.ch'
 
/*------------------------------------------------------------------------------------------------------*
 | P.E.:  A410Cons                                                                                      |
 | Links: http://tdn.totvs.com/pages/releaseview.action?pageId=6784033                                  |
 *------------------------------------------------------------------------------------------------------*/
 
User Function A410Cons()
    Local aArea        := GetArea()  
    Local aBotoes    := {}
 
    //Se não for inclusão
    If ! INCLUI
        aAdd(aBotoes,{'Peso', {||u_getpeso()}, "Peso","Busca Peso Volume"} )
    Endif
     
    RestArea(aArea)
Return(aBotoes)

