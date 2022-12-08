/*
Calcula numero de rolos da tirada a partir do produto do pedido
*/
user function C6QTDV01()
    Local nLargCrt  := getmv('IC_PIFXCRT') // Largura padrão utilizada no crote
    Local nLargProd := POSICIONE('SB1',1, XFILIAL('SB1')+M->C6_PRODUTO,"B1_LARGURA") //Largura do produto
    Local nVal      := INT(nLargCrt/nLargProd)                                       
return nVal
