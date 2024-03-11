/*
MT140CAB - Cabeçalho da Pré Nota
Descrição
Permite o preenchimento automático dos campos do cabeçalho da pré nota.
Observações
Ponto de entrada utilizado antes da abertura da tela de inclusão da pré nota. Tem o objetivo de preencher automaticamente as variáveis do cabeçalho e validar se prossegue ou não com a abertura da tela de inclusão.

As variáveis do cabeçalho da pré nota estão declaradas como Private e são: 
cTipo / cFormul / cNFiscal / cSerie / dDEmissao / cA100For / cLoja / cEspecie / cUfOrigP

LOCALIZAÇ‡ÃƒO: Função A140NFiscal 
EM QUE PONTO: Ao clicar no botão Incluir, antes de abrir a Browse.
*/
/*
User Function MT140CAB()
    
	cEspecie := space(5)
	//Valores Padrão
	cTipo := 'N'
	cFormul := 'N'
	cEspecie := 'SPED'+space(1)

//Alert("Teste")
//cNFiscal:="001"

	
return .T. 
*/
#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 21/11/00
#INCLUDE "TOPCONN.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "FONT.CH"

User Function MT140CAB()
//User Function A140IPED()
	Local lRet := .T.
	Public _chvNfe:=""
//cTipo / cFormul / cNFiscal / cSerie / dDEmissao / cA100For / cLoja / cEspecie / cUfOrigP
	codbar:=U_lerbarnfe()

	if	Modulo11(substr(Alltrim(codbar),1,43))<>substr(Alltrim(codbar),44,1)
		alert("Chave invalida!")
		Return(lRet)
	else
		lRet := .T.
		_chvNfe:=Alltrim(codbar)
	endif

	cSerie:= substr(Alltrim(codbar),23,3)
	cNFiscal:= substr(Alltrim(codbar),26,9)

//localiza fornecedor
	DbSelectArea("SA2")
	DbSetOrder(3)   //A2_FILIAL+A2_CGC
	SA2->(dbSeek("  "+substr(Alltrim(codbar),7,14)))
	If SA2->(found())
		cUfOrigP := SA2->A2_EST
		cA100For:= SA2->A2_COD
		cLoja:= SA2->A2_LOJA
	else
		Alert("Fornecedor não localizado atraves da chave")
	Endif


	cEspecie := 'SPED'
	//cTipo := 'N'
	//cFormul := 'N'



Return lRet
