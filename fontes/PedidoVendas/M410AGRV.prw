#INCLUDE 'PROTHEUS.CH'
#INCLUDE "FWMVCDEF.CH"
   
User Function M410AGRV()
 
Local aArea     := GetArea() //Armazena o ambiente ativo para restaurar ao fim do processo
Local nOpcao    := PARAMIXB[1]
Local nContI    := 0
Local nTotItens := 1
Local cProd     := aScan(aHeader,{|x| Alltrim(x[2])== "C6_PRODUTO"})
 
//aCols     - Variável Private que contém os itens da SC6 antes de iniciar a gravação
//aHeader   - Variável Private que contém as estruturas dos campos da SC6 antes de iniciar a gravação
If nOpcao == 1
    For nContI := 1 To nTotItens
        If aCols[nContI][cProd] == "000001"
            Alert("Encontrado o Produto 000001")
        EndIf
    Next nContI
EndIf 
  
RestArea(aArea) //Restaura o ambiente ativo no início da chamada
       
Return
