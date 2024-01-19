#include "protheus.ch"
#include "restful.ch"
#include 'rwmake.ch'
#Include "tbiconn.ch"
#include "topconn.ch"


wsrestful ws_pcp_op_consumo description "WS para consumir material na ordem"
	wsdata codBar as char optional
	wsdata cOP as char optional
	wsdata cLocal as char optional
	wsdata cLocaliz as char optional
	wsdata cLotectl as char optional
	wsdata usuario as char optional


	wsmethod get ws1;
		description "Lista material local da máquina com validações de Local\Fifo\Estrutura" ;
		wssyntax "/ws_pcp_op_consumo/validalote/{cOP}/{cLocaliz}/{codBar}";
		path "/ws_pcp_op_consumo/validalote/{cOP}/{cLocaliz}/{codBar}"

	wsmethod get ws3;
		description "Lista Lotes Consumidos na ordem" ;
		wssyntax "/ws_pcp_op_consumo/list/{cOP}";
		path "/ws_pcp_op_consumo/list/{cOP}"

	wsmethod post ws2;
		description "OP consome material uso de post";
		wssyntax "/ws_pcp_op_consumo/requisitar/{cOP}";
		path "/ws_pcp_op_consumo/requisitar/{cOP}"


end wsrestful

wsmethod get ws1 wsservice ws_pcp_op_consumo
	Local lRet := .F.
	Local lGet := .T.
	local aLote
	local nL
	local cLote, cProdEmp
	Local aJson := {}
	

	self:SetContentType("application/json")
	aDados := u_bcreader(::codBar)
	u_json_dbg(aDados)
	u_json_dbg(::cOp)
	conout('x1')
	if aDados[1] == ''
		conout('x2')
		::SetResponse('{"message": "Lote vazio","detailedMessage": "Informação de Lote vazia"}')
		self:setStatus(400)
		Return lGet
	endif
	cProdEmp := prodemp(::cOp, aDados[1], '02',::cLocaliz)

	if alltrim(cProdEmp) == ''

		::SetResponse('{ "code": "400","message": "Nao foi encontrado","detailedMessage": "Lote sem saldo no local da maquina ou produto Nao pertence a estrutura"}')
		self:setStatus(400)
		Return lGet
	endif
	//Valida se existe o material no local correto e com saldo
	lRet:=checalote(aDados[1],'02', cProdEmp,::cLocaliz)

	if !lRet
		::SetResponse('{"message": "Não foi encontrado","detailedMessage": "Lote Não encontrado com saldo no endereÃ§o da mÃ¡quina"}')

		self:setStatus(400)
		Return lGet
	endif
	//verifica se Ã© o fifo
	cLote:=checafifo('02', cProdEmp)


	if cLote<>alltrim(aDados[1])
		::SetResponse('{"message": "Lote fora do FIFO","detailedMessage": "Lote fora do FIFO lote esperado '+cLote+'"}')
		
		self:setStatus(400)
		Return lGet


	endif
	//verifica se faz parte da estrutura.

	lRet:=checaestrutura(aDados[1],::cOP, cProdEmp)

	if !lRet


		::SetResponse('{"message": "Lote fora da estrutura","detailedMessage": "Este lote Não faz parte da estrutura do produto!"}')
		conout('x6')
		self:setStatus(400)
		Return lGet
	endif

	// Busca lote para apresentar na tela.
	aLote:=retlote(aDados[1],'02', cProdEmp,::cLocaliz)

	CONOUT("Ret Lote")

	If Len(aLote) == 0

		::SetResponse('{"message": "Ops... ocorreu problema","detailedMessage": "Ocorreu erro ao buscar o lote! "}')
		conout('x7')
		self:setStatus(400)

	else
		conout('x8')
		CONOUT("ENTROU ws_pcp_op_consumo 200")
		self:setStatus(200)
		for nL := 1 to len(aLote)
			aJson:=JsonObject():new()
			aJson['LOCALIZACAO']:=aLote[nL][1]
			aJson['EMPENHO']:=aLote[nL][2]
			aJson['LOTE']:=aLote[nL][3]
			aJson['LOCAL']:=aLote[nL][4]
			aJson['PRODUTO']:=aLote[nL][5]
			aJson['DESCRICAO']:=aLote[nL][6]
			aJson['QUANTIDADE']:=aDados[2]
			aJson['SALDO']:=aLote[nL][8]
		next nL
		::SetResponse(aJson)
	endif



	FreeObj(aJson)


Return lGet


wsmethod post ws2 wsservice ws_pcp_op_consumo
	Local lPost := .T.
	Local lok := .T.
	Local oJson
	Local cBody := ::getContent()
	Private cMsgErro := 'Ocorreu um erro Não previsto'
	oJson := JsonObject():new()
	oJson:fromJSON(cBody)
	u_json_dbg(oJson);
//	lOk := limpaemp(::cOp)

	lOk := consomelote(::cOP, oJson)

	if lOk

		::SetResponse('{ "message": "Lote consumido com sucesso.","detailedMessage": "Lote consumido com sucesso"}')

		self:setStatus(200)

	else
		::SetResponse('{ "message": "Erro ao consumir lote.","detailedMessage": "'+ENCODEUTF8(cMsgErro)+'"}')

		self:setStatus(400)
	endif

Return lPost


static Function consomelote(cOp, oJson)
	Local lRet:=.T.

	//Debug do Vetor
	conout(oJson:toJson())

	conout('Executando MSExecAuto MATA241. ')

	Begin Transaction


		cMaq := POSICIONE("SC2", 1, XFILIAL("SC2")+cOP, "C2_MAQUINA")
		cMaq := substr(cMaq,1,2)

		_aCab1 := {{"D3_DOC" ,GetSxeNum("SD3","D3_DOC"), NIL},;
			{"D3_TM" ,'505' , NIL},;
			{"D3_EMISSAO" ,ddatabase, NIL}}
//{"D3_CC" ," ", NIL},;
		aVetor:={;
			{"D3_OP"      ,cOP,NIL},;
			{"D3_COD",padr(oJson['PRODUTO'],15),NIL},;
			{"D3_LOCAL",oJson['LOCAL'],NIL},;
			{"D3_LOCALIZ",oJson['LOCALIZACAO'],NIL},;
			{"D3_QUANT",oJson['QUANTIDADE'],NIL},;
			{"D3_LOTECTL",padr(oJson['LOTE'], tamsx3('D3_LOTECTL') [1]),NIL};
			}
		_atotitem := {}
		aadd(_atotitem,aVetor)
		lMsErroAuto := .F.
		u_json_dbg(AVETOR)
		MSExecAuto({|x,y,z| MATA241(x,y,z)},_aCab1,_atotitem,3)

		If lMsErroAuto
			lRet :=.F.//deu erro
			ctitulo:="Erro na execucao"
			cMsgErro:=memoread (NomeAutoLog())
			conout(cMsgErro)
			DisarmTransaction()
		endif

	End Transaction
return lRet


wsmethod get ws3 wsservice ws_pcp_op_consumo
	Local lGet := .T.
	local aLotes, aRmaterial
	local i
	Local oJson := JsonObject():new()
	Local oJson2

	self:SetContentType("application/json")
	// Busca lote para apresentar na tela.
	aRmaterial:=retListCsm(::cOp)

	CONOUT("Ret Lote")

	CONOUT("ENTROU listconsumo 200")

	aLotes := {}

	for i:=1 to len(aRmaterial)
		//aadd(aLotes, {})
		oJson2 := JsonObject():new()
		oJson2['PRODUTO']:= aRmaterial[i,3]
		oJson2['LOTE']:=aRmaterial[i,1]
		oJson2['DESCRICAO']:= ''
		oJson2['QUANTIDADE']:= 0
		oJson2['EMPENHO']:=aRmaterial[i,2]
		oJson2['LOCAL']:=''
		oJson2['LOCALIZACAO']:=''
		oJson2['UM']:=''
		oJson2['CF']:= aRmaterial[i,4]
		oJson2['DTSIST']:= aRmaterial[i,5]
		oJson2['HRSIST']:= aRmaterial[i,6]
		aadd(aLotes, oJson2)
		FreeObj(oJson2)

	next
	oJson:set(aLotes)
	self:setStatus(200)
	::SetResponse(oJson)


	FreeObj(oJson)


Return lGet

static function retListCsm(cop)
	local aLotes := {}
	Local cAlias, cOpLike := cOp+'%'

	cAlias := getNextAlias()

//todo data sistema / hora sistema
	BeginSQL alias cAlias
    SELECT D3_COD, D3_LOTECTL, '' as D3_DTSIST, '' as D3_HRSIST,
	 SUM(CASE WHEN D3_CF LIKE 'RE%' THEN D3_QUANT WHEN D3_CF LIKE 'DE%' THEN -D3_QUANT ELSE 0 END ) AS D3_QUANT
    FROM %TABLE:SD3% 
    WHERE D_E_L_E_T_<>'*' AND D3_FILIAL=%XFILIAL:SD3%
        AND D3_OP like  %Exp:cOpLike%
		AND D3_CF <> 'PR0'
		AND D3_ESTORNO <> 'S'    
		AND LEFT(D3_COD,3) NOT IN ('MOD')
	GROUP BY D3_COD, D3_LOTECTL
	ORDER BY D3_COD, D3_LOTECTL DESC
	EndSQL
	u_dbg_qry()
	While (cAlias)->(!Eof())

		aAdd(aLotes, {})
		aAdd(aLotes[len(aLotes)], alltrim((cAlias)->D3_LOTECTL) )
		aAdd(aLotes[len(aLotes)], (cAlias)->D3_QUANT)
		aAdd(aLotes[len(aLotes)], (cAlias)->D3_COD)
		aAdd(aLotes[len(aLotes)], '')
		aAdd(aLotes[len(aLotes)], DTOC(STOD((cAlias)->D3_DTSIST)))
		aAdd(aLotes[len(aLotes)], (cAlias)->D3_HRSIST)
		(cAlias)->(dbSkip())
	enddo
	(cAlias)->(DbClosearea())


return aLotes



static Function checalote(codBar,cLocal, cProd,cLocaliz)

	Local cAlias
	Local lRet:=.F.



	cAlias := getNextAlias()
	BeginSQL alias cAlias

    SELECT BF_LOTECTL FROM %TABLE:SBF%
    WHERE D_E_L_E_T_<>'*'
    AND BF_FILIAL= %XFILIAL:SBF%
    AND BF_LOCAL=%Exp:cLocal%
	AND BF_LOCALIZ=%Exp:cLocaliz%
    AND BF_LOTECTL=%Exp:codBar%
	AND BF_PRODUTO = %EXP:CPROD%
    AND BF_QUANT>0


	EndSQL
	u_dbg_qry()
	While !(cAlias)->(Eof())

		lRet:=.T.

		(cAlias)->(dbSkip())
	enddo
	(cAlias)->(DbClosearea())



return lRet

static Function checafifo(cLocal, cProd)

	Local cAlias
	Local cLote


	cAlias := getNextAlias()
	BeginSQL alias cAlias

   SELECT TOP 1 BF_LOTECTL FROM %TABLE:SBF% BF 
		   INNER JOIN %TABLE:SB8% B8
		   ON B8_LOCAL=BF_LOCAL
   		   AND BF_PRODUTO=B8_PRODUTO
   		   AND BF_LOTECTL=B8_LOTECTL
	    WHERE BF.D_E_L_E_T_<>'*'
		AND B8.D_E_L_E_T_<>'*' 
		AND	BF_FILIAL = %XFILIAL:SBF%
        AND BF_QUANT - BF_EMPENHO > 0
		AND BF_LOCAL = %Exp:cLocal%
		AND BF_PRODUTO= %EXP:CPROD%
		ORDER BY B8_DTVALID,BF_LOTECTL ASC
	EndSQL
	u_dbg_qry()
	While !(cAlias)->(Eof())

		cLote:=alltrim((cAlias)->BF_LOTECTL)
		(cAlias)->(dbSkip())

	enddo
	(cAlias)->(DbClosearea())



return cLote


static Function checaestrutura(codBar, cOP, cProdEmp)

	Local cAlias
	Local lRet:=.F.
	Local cOrdem := left(cOp, 6)
	Local CitemOp := substr(cOp,7,2)
	cAlias := getNextAlias()


	BeginSQL alias cAlias

SELECT C2_NUM FROM %TABLE:SC2% C2
INNER JOIN %TABLE:SG1% G1
ON G1_COD=C2_PRODUTO
WHERE C2.D_E_L_E_T_<>'*'
AND C2_FILIAL=%XFILIAL:SC2%
AND G1.D_E_L_E_T_<>'*'
AND G1_FILIAL=%XFILIAL:SG1%
AND C2_NUM=%Exp:cOrdem% and C2_ITEM = %EXP:CitemOp%
AND G1_COMP=(
	SELECT top 1 BF_PRODUTO FROM %TABLE:SBF% BF 
	WHERE BF.D_E_L_E_T_<>'*' AND BF_FILIAL=%XFILIAL:SBF% 
	AND BF_LOTECTL=%Exp:codBar%
	AND BF_PRODUTO=%EXP:cProdEmp%)

	EndSQL
	u_dbg_qry()
	While !(cAlias)->(Eof())

		lRet:=.T.

		(cAlias)->(dbSkip())
	enddo
	(cAlias)->(DbClosearea())



Return lRet

static function retlote(codBar,cLocal, cProd,cLocaliz)
	Local cAlias
	Local aLote := {}


	cAlias := getNextAlias()


	BeginSQL alias cAlias
    SELECT BF_LOCALIZ,BF_EMPENHO,BF_LOTECTL,BF_QUANT,BF_LOCAL,BF_PRODUTO,
		(SELECT B1_DESC FROM %TABLE:SB1% B1 
		WHERE B1.D_E_L_E_T_<>'*' AND B1_FILIAL=%XFILIAL:SB1% AND B1_COD=BF_PRODUTO) DESCRICAO 
		FROM 
		%TABLE:SBF% BF
		WHERE BF.D_E_L_E_T_<>'*'
		AND BF_FILIAL=%XFILIAL:SBF%
		AND BF_LOCAL=%Exp:cLocal%
		AND BF_LOCALIZ=%Exp:cLocaliz%
		AND BF_LOTECTL=%Exp:codBar%
		AND BF_PRODUTO = %EXP:CPROD%
	EndSQL
	u_dbg_qry()
	While !(cAlias)->(Eof())

		aAdd(aLote, {})
		aAdd(aLote[len(aLote)], alltrim((cAlias)->BF_LOCALIZ) )
		aAdd(aLote[len(aLote)], alltrim((cAlias)->BF_EMPENHO) )
		aAdd(aLote[len(aLote)], alltrim((cAlias)->BF_LOTECTL) )
		aAdd(aLote[len(aLote)], alltrim((cAlias)->BF_LOCAL) )
		aAdd(aLote[len(aLote)], alltrim((cAlias)->BF_PRODUTO) )
		aAdd(aLote[len(aLote)], alltrim((cAlias)->DESCRICAO) )
		if left(CPROD,2 ) == 'MP'
			aAdd(aLote[len(aLote)], 0)
		else
			aAdd(aLote[len(aLote)], (cAlias)->BF_QUANT)
		endif
		aAdd(aLote[len(aLote)], (cAlias)->BF_QUANT)
		(cAlias)->(dbSkip())
	enddo
	(cAlias)->(DbClosearea())




Return aLote


static function prodemp(cOp, cLote, cLocal,cLocaliz)

	Local cAlias := getNextAlias()

	BeginSQl alias cAlias
		SELECT TOP 1 G1_COMP
		FROM %TABLE:SG1% G1 INNER JOIN %TABLE:SC2% C2 ON (C2_PRODUTO = G1_COD) 
		INNER JOIN %table:SBF% BF ON (BF_PRODUTO = G1_COMP)
		WHERE G1_FILIAL = %xfilial:SG1% AND G1.D_E_L_E_T_ <> '*'
		AND C2_FILIAL = %xfilial:SC2% AND C2.D_E_L_E_T_ <> '*'
		AND BF_FILIAL = %xfilial:SBF% AND BF.D_E_L_E_T_ <> '*'
		AND BF_LOTECTL = %EXP:CLOTE%
		AND BF_LOCAL = %EXP:CLOCAL%
		AND BF_LOCALIZ = %EXP:cLocaliz%
		AND BF_QUANT > 0
		AND C2_NUM+C2_ITEM+C2_SEQUEN = %EXP:COP%
	EndSQL

	u_dbg_qry()
	cProd := (calias)->G1_COMP

	(calias)->(dbclosearea())

return cProd

