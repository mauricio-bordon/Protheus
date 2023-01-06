user function etqrolo()
local cStrEtq
//    Alert('TESTE')

// SE O PRODUTO FOR PI IMPRIME E FABRICACAO IMPRIME
IF SD3->D3_TIPO=="PI" .AND. D3_CF$"PR0_DE0"

CURDIR( 'etq' )
cStrEtq := MemoRead( "etq_rolo_pi.txt" )

dbSelectArea("SB1")
dbSeek(xFilial("SB1")+SD3->D3_COD)





cStrEtq := STRTRAN(cStrEtq, "%B1_COD%", SB1->B1_COD)
cStrEtq := STRTRAN(cStrEtq, "%B1_DESC%", SB1->B1_DESC)
cStrEtq := STRTRAN(cStrEtq, "%D3_UM%", SD3->D3_UM)
cStrEtq := STRTRAN(cStrEtq, "%D3_QUANT%", transform(SD3->D3_QUANT, "@E 999,999.999"))
cStrEtq := STRTRAN(cStrEtq, "%D3_EMISSAO%", dtoc(SD3->D3_EMISSAO))
cStrEtq := STRTRAN(cStrEtq, "%D3_LOTECTL%", SD3->D3_LOTECTL)
cStrEtq := STRTRAN(cStrEtq, "%BARRA%", SB1->B1_COD+';'+SD3->D3_LOTECTL+';'+transform(SD3->D3_QUANT, "@E 999,999.999"))

//imprime 2 etq		
//cStrEtq += cStrEtq +chr(10)+chr(13)

cPort := 'LPT1' // prnLPTPort()
FERASE("c:\windows\temp\etq_rolo_pi.prn" )
MemoWrite("c:\windows\temp\etq_rolo_pi.prn", cStrEtq)

Copy File "c:\windows\temp\etq_rolo_pi.prn" To LPT1
		
ENDIF

return
