#include "protheus.ch"
#include "restful.ch"
#include 'rwmake.ch'
#Include "tbiconn.ch"


wsrestful ws_pcp_op_consumo description "WS para consumir material na ordem"
	wsdata codBar as char OPTIONAL
	wsdata cOP as char OPTIONAL
	wsdata cLocal as char OPTIONAL


	wsmethod get ws1;
		description "Lista material local da máquina com validações de Local\Fifo\Estrutura" ;
		wssyntax "/ws_pcp_op_consumo/{codBar}/{cOP}/{cLocal}";
		path "/ws_pcp_op_consumo/{CodBar}/{cOP}/{cLocal}"

	wsmethod get ws3;
		description "Lista Lotes Consumidos na ordem" ;
		wssyntax "/ws_pcp_op_consumo/{cOP}";
		path "/ws_pcp_op_consumo/{cOP}"

	wsmethod post ws2;
		description "OP consome material uso de post";
		wssyntax "/ws_pcp_op_consumo/{cOP}";
		path "/ws_pcp_op_consumo/{cOP}"


end wsrestful

wsmethod get ws1 wsservice ws_pcp_op_consumo
	Local lRet := .F.
	Local lGet := .T.
	local aLote
	local nL
	local cLote, cProdEmp
	Local aJson := {}

	self:SetContentType("application/json")

	cProdEmp := prodemp(::cOp, ::codBar, ::cLocal)

	
	if alltrim(cProdEmp) == ''
		::SetResponse('{ "message": "NÃ£o foi encontrado","detailedMessage": "Lote sem saldo ou produto nÃ£o pertence Ã  estrutura"}')
		self:setStatus(400)
		Return lGet
	endif
	//Valida se existe o material no local correto e com saldo
	lRet:=checalote(::codBar,::cLocal, cProdEmp)

	if !lRet

		::SetResponse('{ "message": "NÃ£o foi encontrado","detailedMessage": "Lote nÃ£o encontrado com saldo no endereÃ§o da mÃ¡quina"}')

		self:setStatus(400)
		Return lGet
	endif
	//verifica se Ã© o fifo
	cLote:=checafifo(::codBar,::cLocal, cProdEmp)


	if cLote<>alltrim(::codBar)
		::SetResponse('{ "message": "Lote fora do FIFO","detailedMessage": "Lote fora do FIFO lote esperado '+cLote+'"}')

		self:setStatus(400)
		Return lGet


	endif
	//verifica se faz parte da estrutura.

	lRet:=checaestrutura(::codBar,::cOP, cProdEmp)

	if !lRet


		::SetResponse('{ "message": "Lote fora da estrutura","detailedMessage": "Este lote nÃ£o faz parte da estrutura do produto!"}')

		self:setStatus(400)
		Return lGet
	endif

	// Busca lote para apresentar na tela.
	aLote:=retlote(::codBar,::cLocal, cProdEmp)

	CONOUT("Ret Lote")

	If Len(aLote) == 0

		::SetResponse('{ "message": "Ops... ocorreu problema","detailedMessage": "Ocorreu erro ao buscar o lote! "}')

		self:setStatus(400)

	else

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
			aJson['QUANTIDADE']:=aLote[nL][7]
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
	Private cMsgErro := 'Ocorreu um erro nÃ£o previsto'
	oJson := JsonObject():new()
	oJson:fromJSON(cBody)

//	lOk := limpaemp(::cOp)

	lOk := consomelote(::cOP, oJson)
		
	if lOk

		::SetResponse(oJson)

		self:setStatus(200)

	else
		::SetResponse('{ "message": "Ops...","detailedMessage": "'+cMsgErro+'"}')

		self:setStatus(400)
	endif

Return lPost


static Function consomelote(cOp, oJson)
	Local lRet:=.T., cDocSeq

	//Debug do Vetor
	conout(oJson:toJson())

	conout('Executando MSExecAuto MATA241. ')

	Begin Transaction

		nDocSeq	:= getmv("APP_DOCSEQ")
		cDocSeq := 'W'+strzero(nDocSeq,8)
		CONOUT('DOC SEQ APP: '+cDocSeq)
		nDocSeq++
		putmv("APP_DOCSEQ", nDocSeq)
		CONOUT('NEXT DOC SEQ APP: '+strzero(nDocSeq,8))
		cMaq := POSICIONE("SC2", 1, XFILIAL("SC2")+cOP, "C2_MAQUINA")
		cMaq := substr(cMaq,1,2)

		_aCab1 := {{"D3_DOC" ,cDocSeq, NIL},;
			{"D3_TM" ,'570' , NIL},;
			{"D3_EMISSAO" ,ddatabase, NIL}}
//{"D3_CC" ," ", NIL},;
		aVetor:={;
			{"D3_OP"      ,cOP,NIL},;
			{"D3_COD",padr(oJson['PRODUTO'],15),NIL},;
			{"D3_LOCAL",oJson['LOCAL'],NIL},;
			{"D3_LOCALIZ",oJson['LOCAL'],NIL},;
			{"D3_QUANT",oJson['QUANTIDADE'],NIL},;
			{"D3_LOTECTL",padr(oJson['LOTE'],10),NIL};
			}
		_atotitem := {}
		aadd(_atotitem,aVetor)
		lMsErroAuto := .F.

		MSExecAuto({|x,y,z| MATA241(x,y,z)},_aCab1,_atotitem,3)
		
		If lMsErroAuto
			lRet :=.F.//deu erro
			ctitulo:="Erro na execucao"
			cmsg:="Verificar no SIGAADV o log "+NomeAutoLog()
			conout(cMsg)
			DisarmTransaction()
		else
			conout("cDocSeq : " + cDocSeq)
			conout('D3_DOC : ' + SD3->D3_DOC)
			conout('R_E_C_N_O_: '+ STR(SD3->(RECNO())))
			if SD3->(RECLOCK("SD3", .F.))
				//CONOUT('ATUALIZADO CAMPOS D3_USUARIO E DATA/HORA. '+CUSUARIO)
				SD3->D3_USUARIO  := oJson['USUARIO']
				SD3->(MSUNLOCK())
			else
				DisarmTransaction()
				LRET := .F.
				conout('erro ao atualizar campos D3_USUARIO')
			endif
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
    SELECT D3_COD, D3_LOTECTL, D3_CF, '' as D3_DTSIST, '' as D3_HRSIST,
	 SUM(D3_QUANT) AS D3_QUANT
    FROM %TABLE:SD3% 
    WHERE D_E_L_E_T_<>'*' AND D3_FILIAL=%XFILIAL:SD3%
        AND D3_OP like  %Exp:cOpLike%
		AND D3_CF <> 'PR0'
		AND D3_ESTORNO <> 'S'    
		AND LEFT(D3_COD,3) NOT IN ('MOD')
	GROUP BY D3_COD, D3_LOTECTL, D3_CF
	ORDER BY D3_COD, D3_LOTECTL DESC
	EndSQL
	u_dbg_qry()
	While (cAlias)->(!Eof())

		aAdd(aLotes, {})
		aAdd(aLotes[len(aLotes)], alltrim((cAlias)->D3_LOTECTL) )
		aAdd(aLotes[len(aLotes)], (cAlias)->D3_QUANT)
		aAdd(aLotes[len(aLotes)], (cAlias)->D3_COD)
		aAdd(aLotes[len(aLotes)], (cAlias)->D3_CF)
		aAdd(aLotes[len(aLotes)], DTOC(STOD((cAlias)->D3_DTSIST)))
		aAdd(aLotes[len(aLotes)], (cAlias)->D3_HRSIST)
		(cAlias)->(dbSkip())
	enddo
	(cAlias)->(DbClosearea())


return aLotes



static Function checalote(codBar,cLocal, cProd)

	Local cAlias
	Local lRet:=.F.



	cAlias := getNextAlias()
	BeginSQL alias cAlias

    SELECT BF_LOTECTL FROM SBF070
    WHERE D_E_L_E_T_<>'*'
    AND BF_FILIAL= %XFILIAL:SBF%
    AND BF_LOCAL=%Exp:cLocal%
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

static Function checafifo(codBar,cLocal, cProd)

	Local cAlias
	Local cLote


	cAlias := getNextAlias()
	BeginSQL alias cAlias

   SELECT TOP 1 BF_LOTECTL FROM SBF070 BF 
	    WHERE BF.D_E_L_E_T_<>'*' 
		AND	BF_FILIAL = %XFILIAL:SBF%
        AND BF_QUANT - BF_EMPENHO > 0
		AND BF_LOCAL = %Exp:cLocal%
		AND BF_PRODUTO= %EXP:CPROD%
		ORDER BY BF_LOTECTL
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

SELECT C2_NUM FROM SC2070 C2
INNER JOIN SG1070 G1
ON G1_COD=C2_PRODUTO
WHERE C2.D_E_L_E_T_<>'*'
AND C2_FILIAL=%XFILIAL:SC2%
AND G1.D_E_L_E_T_<>'*'
AND G1_FILIAL=%XFILIAL:SG1%
AND C2_NUM=%Exp:cOrdem% and C2_ITEM = %EXP:CitemOp%
AND G1_COMP=(
	SELECT top 1 BF_PRODUTO FROM SBF070 BF 
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

static function retlote(codBar,cLocal, cProd)
	Local cAlias
	Local aLote := {}


	cAlias := getNextAlias()


	BeginSQL alias cAlias
    SELECT BF_LOCALIZ,BF_EMPENHO,BF_LOTECTL,BF_QUANT,BF_LOCAL,BF_PRODUTO,
		(SELECT B1_DESC FROM SB1070 B1 WHERE B1.D_E_L_E_T_<>'*' AND B1_FILIAL=%XFILIAL:SB1% AND B1_COD=BF_PRODUTO) DESCRICAO 
		FROM 
		SBF070 BF
		WHERE BF.D_E_L_E_T_<>'*'
		AND BF_FILIAL=%XFILIAL:SBF%
		AND BF_LOCAL=%Exp:cLocal%
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


static function prodemp(cOp, cLote, cLocal)

	Local cAlias := getNextAlias()

	BeginSQl alias cAlias
		SELECT TOP 1 G1_COMP
		FROM SG1070 G1 INNER JOIN SC2070 C2 ON (C2_PRODUTO = G1_COD) 
		INNER JOIN SBF070 BF ON (BF_PRODUTO = G1_COMP)
		WHERE G1_FILIAL = '00' AND G1.D_E_L_E_T_ <> '*'
		AND C2_FILIAL = '00' AND C2.D_E_L_E_T_ <> '*'
		AND BF_FILIAL = '00' AND BF.D_E_L_E_T_ <> '*'
		AND BF_LOTECTL = %EXP:CLOTE%
		AND BF_LOCAL = %EXP:CLOCAL%
		AND BF_QUANT > 0
		AND C2_NUM+C2_ITEM+C2_SEQUEN = %EXP:COP%
	EndSQL

	u_dbg_qry()
	cProd := (calias)->G1_COMP

	(calias)->(dbclosearea())

return cProd

