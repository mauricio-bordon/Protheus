/*
Calcula numero de rolos da tirada a partir do produto do pedido
*/
user function C6QTDV01()
    local nPosProd  := ascan(aHeader, {|aH| alltrim(aH[2]) == "C6_PRODUTO"})
	local cProduto  := aCols[N, nPosProd]
    //busca largura de corte do grupo e nao mais do parametro
    Local nLargCrt  := getmv('IC_PIFXCRT') // Largura padrão utilizada no crote
    Local nLargProd := POSICIONE('SB1',1, XFILIAL('SB1')+cProduto,"B1_LARGURA") //Largura do produto
    Local nVal      := INT(nLargCrt/nLargProd)                                       
return nVal
