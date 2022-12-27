/*
MV_APTEMP := .T.

https://tdn.totvs.com/pages/releaseview.action?pageId=325845355

Descrição:	
O parâmetro MT650PISC é utilizado para controlar as mensagens de validação de Geração de OPs Intermediárias e Empenhos ao realizar um Apontamento de Produção(MATA250) ou uma Produção PCP Mod1(MATA680).

Localização:	
Function A650OpBatch - Efetua validação de Geração de OPs Intermediárias e Empenhos

Quando o parâmetro 'MV_APTEMP' está marcado é apresentada a pergunta "A OP informada não teve as OPs intermediárias criadas. Deseja mesmo produzi-la?".

O ponto de entrada MT650PISC define se mostra ou não esta pergunta de confirmação.

Quando o parâmetro 'MV_APTEMP' está desmarcado é apresentada a mensagem 'Não é possível registrar o apontamento pois não foi gerado empenho para a OP. Ordem de produção sem empenho.' e não permite realizar o apontamento.

O ponto de entrada MT650PISC define se mostra ou não esta mensagem.

*/
User Function MT650PISC()
Local lRet     := .F.
 
Return lRet
