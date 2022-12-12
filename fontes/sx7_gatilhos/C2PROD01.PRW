/*
Calcula numero de rolos da tirada a partir do produto do pedido
*/
user function C2PROD01()
    Local nLargCrt  := getmv('IC_PIFXCRT') // Largura padrão utilizada no crote
    Local nLargProd := POSICIONE('SB1',1, XFILIAL('SB1')+M->C2_PRODUTO,"B1_LARGURA") //Largura do produto
    Local nVal      := 0

    if left(M->C2_PRODUTO,2) == 'PA'                  
        nVal  := INT(nLargCrt/nLargProd)        
    endif             
return nVal
