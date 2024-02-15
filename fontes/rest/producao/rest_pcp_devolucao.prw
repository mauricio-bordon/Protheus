#include "protheus.ch"
#include "restful.ch"
#include 'rwmake.ch'
#Include "tbiconn.ch"
#include "topconn.ch"


wsrestful ws_pcp_op_devolucao description "WS para DEVOLVER material da ordem"
	wsdata codBar as char OPTIONAL
	wsdata cOP as char OPTIONAL
	wsdata cLocaliz as char optional



	wsmethod get ws1;
		description "Valida Lote" ;
		wssyntax "/ws_pcp_op_devolucao/validalote/{cOp}/{codBar}";
		path "/ws_pcp_op_devolucao/validalote/{cOp}/{codBar}"

	wsmethod get ws3;
		description "Lista Lotes Consumidos na ordem" ;
		wssyntax "/ws_pcp_op_devolucao/{cOP}";
		path "/ws_pcp_op_devolucao/{cOP}"

	wsmethod post ws2;
		description "OP consome material uso de post";
		wssyntax "/ws_pcp_op_devolucao/{cOP}";
		path "/ws_pcp_op_devolucao/{cOP}"


end wsrestful

wsmethod get ws1 wsservice ws_pcp_op_devolucao

	Local lGet := .T.
	local aLote
	local nL
	local cproddev, cLote
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
	cLote := aDados[1]
	if aDados[3] == ''
		cproddev := cnslote(::cOp, cLote)
	else
		cproddev := aDados[3]
	endif


	if alltrim(cproddev) == ''
		::SetResponse('{ "message": "Não foi encontrado","detailedMessage": "Lote sem saldo ou produto não pertence à estrutura"}')
		self:setStatus(400)
		Return lGet
	endif

	// Busca lote para apresentar na tela.
	aLote:=retlote(cLote, cproddev,::cOp )

	CONOUT("Ret Lote")

	If Len(aLote) == 0

		::SetResponse('{ "message": "Ops... ocorreu problema","detailedMessage": "Ocorreu erro ao buscar o lote! "}')

		self:setStatus(400)

	else

		CONOUT("ENTROU ws_pcp_op_devolucao 200")
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
			aJson['UM']:=aLote[nL][9]
			aJson['LARGURA']:=aLote[nL][10]
			aJson['FATOR_CONVERSAO']:=aLote[nL][11]
			aJson['SEGUM']:=aLote[nL][12]
		next nL
		::SetResponse(aJson)
	endif

	FreeObj(aJson)


Return lGet


wsmethod post ws2 wsservice ws_pcp_op_devolucao
	Local lPost := .T.
	Local lok := .F.
	Local oJson
	Local cBody := ::getContent()
	Private cMsgErro := 'Ocorreu um erro não previsto'
	oJson := JsonObject():new()
	oJson:fromJSON(cBody)

//	lOk := limpaemp(::cOp)

	U_json_dbg(oJson)

	///validar se qunatidae solocitada pode ser devolvida

	// lOk := vlddev(::cOP,oJson)
	lOk := .T.
	if Lok 
		lOk := devolvelote(::cOP, oJson)
	endif

	if lOk

		::SetResponse(oJson)

		self:setStatus(200)

	else
		::SetResponse('{ "message": "Ops...","detailedMessage": "'+cMsgErro+'"}')

		self:setStatus(400)
	endif

Return lPost

static function vlddev(COP, oJson)
	local lOk := .T.
	local cProduto := oJson['PRODUTO']
	local cLote := oJson['LOTE']
	local nQtdSol := oJson['QUANTIDADE'], nQtdCsm, nQtdDev
	Local cAlias, cOpLike := cOp+'%'
	lOCAL cC2NUM := left(cOp,6), cC2ITEM := substr(cOP,7,2), cC2SEQUEN := substr(cOP,9,3)
	local nQtdPrMin, nQtdPrMax, nPrevMargem
	conout("PRODUTO = "+ CPRODUTO)
	conout("LOTE = "+ CLOTE)
	conout("op = "+ Cop)
	conout('valida se consome mais que o lote')
	cAlias := getNextAlias()

	//Pega consumo do Produto, lote
	BeginSQL alias cAlias
    SELECT COALESCE(SUM (CASE WHEN D3_CF LIKE 'D%' THEN D3_QUANT ELSE 0 END), 0) AS QUANT_DEV,
		COALESCE(SUM (CASE WHEN D3_CF LIKE 'R%' THEN D3_QUANT ELSE 0 END), 0) AS QUANT_REQ
    FROM %TABLE:SD3% 
    WHERE D_E_L_E_T_<>'*' AND D3_FILIAL=%XFILIAL:SD3%
        AND D3_OP like  %Exp:cOpLike%
		AND D3_CF <> 'PR0'
		AND D3_ESTORNO <> 'S'    
		AND D3_COD = %EXP:cProduto% and D3_LOTECTL like %EXP:CLOTE%
	EndSQL
	u_dbg_qry()

	nQtdCsm := (calias)->QUANT_REQ
	nQtdDev := nQtdSol + (calias)->QUANT_DEV //ADICIONAR A QUANTIDADE JA DEVOLVIDA A DEVOLUCAO ATUAL

	(cAlias)->(DbClosearea())

	conout("nQtdSol = "+CVALTOCHAR(nQtdSol) )
	conout("nQtddev = "+CVALTOCHAR(nQtdDev) )
	conout("nQtdCSM = "+CVALTOCHAR(nQtdCSM) )

	IF nQtdDev > nQtdCsm
		LOK := .F.
		cMsgErro := "Quantidade a ser devolvida maior que a quantidade consumida do lote"
	endif

	IF LOK
	CONOUT('VERIFICA SE QUANTIDADE TOTAL DEVOLVIDA + A SOLICITADA NAO SUPERA A JA COSNUMIDA PARA PRODUCAO')
		cAlias := getNextAlias()

		//Pega consumo do Produto, lote
		BeginSQL alias cAlias
			SELECT COALESCE(SUM (CASE WHEN D3_CF LIKE 'D%' AND D3_COD = %EXP:cProduto% THEN D3_QUANT ELSE 0 END), 0) AS QUANT_DEV,
				COALESCE(SUM (CASE WHEN D3_CF LIKE 'R%' AND D3_COD = %EXP:cProduto% THEN D3_QUANT ELSE 0 END), 0) AS QUANT_REQ,
				COALESCE(SUM (CASE WHEN D3_CF = 'PR0' THEN D3_QUANT ELSE 0 END), 0) AS QUANT_PROD
			FROM %TABLE:SD3%
			WHERE D_E_L_E_T_<>'*' AND D3_FILIAL=%XFILIAL:SD3%
				AND D3_OP like  %Exp:cOpLike%
				AND D3_ESTORNO <> 'S'    				
		EndSQL
		u_dbg_qry()

		nQtdCsm := (calias)->QUANT_REQ
		nQtdDev := nQtdSol + (calias)->QUANT_DEV //ADICIONAR A QUANTIDADE JA DEVOLVIDA A DEVOLUCAO ATUAL
		nQtdProd := (calias)->QUANT_PROD //ADICIONAR A QUANTIDADE JA DEVOLVIDA A DEVOLUCAO ATUAL
		
		(cAlias)->(DbClosearea())


	conout("nQtddev = "+CVALTOCHAR(nQtdDev) )
	conout("nQtdCSM = "+CVALTOCHAR(nQtdCSM) )
	conout("nQtdProd = "+CVALTOCHAR(nQtdProd) )
	
		cAlias := getNextAlias()

		//Pega consumo do Produto, lote
		BeginSQL alias cAlias
			SELECT B1_QB, G1_QUANT
			FROM %TABLE:SC2% C2 INNER JOIN %TABLE:SG1% G1 ON (C2_PRODUTO = G1_COD) 
				INNER JOIN %TABLE:SB1% B1 ON (B1_COD = G1_COD)
			WHERE C2.%NOTDEL% AND C2_FILIAL=%XFILIAL:SD3%
				AND G1.%NOTDEL% AND G1_FILIAL=%XFILIAL:SD3%
				AND B1.%NOTDEL% AND B1_FILIAL=%XFILIAL:SD3%
				AND C2_NUM = %exp:cC2NUM% AND C2_ITEM = %exp:cC2ITEM% AND C2_SEQUEN = %exp:cC2SEQUEN%
				AND G1_COMP = %EXP:CPRODUTO%  				
		EndSQL
		u_dbg_qry()
		conout("B1_QB = "+CVALTOCHAR((calias)->B1_QB) )
		conout("G1_QUANT = "+CVALTOCHAR((calias)->G1_QUANT) )
		nQtdPrev :=  (NQtdProd / (calias)->B1_QB ) * (CALIAS)->G1_QUANT
		(cAlias)->(DbClosearea())

		nPrevMargem := nQtdPrev * 0.05
		nQtdPrMin 	:= nQtdPrev - nPrevMargem
		nQtdPrMax 	:= nQtdPrev + nPrevMargem

		conout("nQtdPrev = "+CVALTOCHAR(nQtdPrev) )
		conout("nPrevMargem = "+CVALTOCHAR(nPrevMargem) )
		conout("nQtdPrMin = "+CVALTOCHAR(nQtdPrMin) )
		conout("nQtdPrMax = "+CVALTOCHAR(nQtdPrMax) )
		
		IF nQtdCSM-NQTDDEV < nQtdPrMin
			LOK := .F.
			cMsgErro := "Quantidade a ser devolvida é maior que a calculada baseada na estrutura"
		elseIF nQtdCSM-NQTDDEV > nQtdPrMax
			LOK := .F.
			cMsgErro := "Quantidade a ser devolvida é menor que a calculada baseada na estrutura"
		ENDIF
		
	ENDIF

return lOk
static Function devolvelote(cOp, oJson)
	Local lRet:=.T.

	//Debug do Vetor
	conout(oJson:toJson())

	conout('Executando MSExecAuto MATA241. ')

	Begin Transaction


		cMaq := POSICIONE("SC2", 1, XFILIAL("SC2")+cOP, "C2_MAQUINA")
		cMaq := substr(cMaq,1,2)

		_aCab1 := {{"D3_DOC" ,GetSxeNum("SD3","D3_DOC"), NIL},;
			{"D3_TM" ,'020' , NIL},;
			{"D3_CC" ,"   ", NIL},;
			{"D3_EMISSAO" ,ddatabase, NIL}}

		aVetor:={{"D3_OP"      ,cOP,NIL},;
			{"D3_COD",padr(oJson['PRODUTO'],15),NIL},;
			{"D3_LOCAL",oJson['LOCAL'],NIL},;
			{"D3_LOCALIZ",oJson['LOCALIZACAO'],NIL},;
			{"D3_QUANT",oJson['QUANTIDADE'],NIL},;
			{"D3_LOTECTL",oJson['LOTE'],NIL}}

		lMsErroAuto := .F.
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
			conout('D3_DOC : ' + SD3->D3_DOC)
			conout('R_E_C_N_O_: '+ STR(SD3->(RECNO())))

			if SD3->(RECLOCK("SD3", .F.))
				//CONOUT('ATUALIZADO CAMPOS D3_USUARIO E DATA/HORA. '+CUSUARIO)
				SD3->D3_USUARIO  := oJson['USUARIO']
				SD3->(MSUNLOCK())

				//Endereçar
				LRET := distdev(SD3->D3_NUMSEQ, SD3->D3_COD, SD3->D3_LOTECTL, oJson['LOCAL'], oJson['LOCALIZACAO'])

				IF !LRET
					DisarmTransaction()
					LRET := .F.
					conout('erro ao ENDEREÇAR')
				ENDIF
			else
				DisarmTransaction()
				LRET := .F.
				conout('erro ao atualizar campos D3_USUARIO')
			endif
		endif

	End Transaction
return lRet


wsmethod get ws3 wsservice ws_pcp_op_devolucao
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


	BeginSQL alias cAlias
    SELECT D3_COD, D3_LOTECTL, D3_QUANT, D3_NUMSEQ, D3_CF, D3_DTSIST, D3_HRSIST
    FROM %table:SD3% 
    WHERE D_E_L_E_T_<>'*' AND D3_FILIAL=%XFILIAL:SD3%
        AND D3_OP like  %Exp:cOpLike%
		AND D3_CF <> 'PR0'
		AND D3_ESTORNO <> 'S'    
	ORDER BY D3_NUMSEQ DESC
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

static function retlote(cLote, cProd, cOp)
	Local cAlias
	Local aLote := {}


	cAlias := getNextAlias()


	BeginSQL alias cAlias
    SELECT D3_LOCALIZ, D3_QUANT,D3_LOTECTL,D3_LOCAL,D3_COD, B1_UM, B1_LARGURA, B1_SEGUM, B1_TIPCONV, B1_CONV
		, RTRIM(B1_DESC) DESCRICAO
		FROM %TABLE:SD3% D3 INNER JOIN %TABLE:SB1% B1 ON (B1_COD = D3_COD)
		WHERE D3.D_E_L_E_T_<>'*' AND D3_FILIAL=%XFILIAL:SD3%
		AND B1.D_E_L_E_T_<>'*' AND B1_FILIAL=%XFILIAL:SB1%
		AND D3_LOTECTL=%Exp:cLote%
		AND D3_COD = %EXP:CPROD%
		AND D3_CF LIKE 'RE%'
		AND D3_OP = %EXP:cOP%
	EndSQL
	u_dbg_qry()
	While !(cAlias)->(Eof())

		aAdd(aLote, {})
		aAdd(aLote[len(aLote)], alltrim((cAlias)->D3_LOCALIZ) )
		aAdd(aLote[len(aLote)], alltrim((cAlias)->D3_QUANT) )
		aAdd(aLote[len(aLote)], alltrim((cAlias)->D3_LOTECTL) )
		aAdd(aLote[len(aLote)], alltrim((cAlias)->D3_LOCAL) )
		aAdd(aLote[len(aLote)], alltrim((cAlias)->D3_COD) )
		aAdd(aLote[len(aLote)], alltrim((cAlias)->DESCRICAO) )
		aAdd(aLote[len(aLote)], 0)
		aAdd(aLote[len(aLote)], (cAlias)->D3_QUANT)
		aAdd(aLote[len(aLote)], alltrim((cAlias)->B1_UM) )
		aAdd(aLote[len(aLote)], (cAlias)->B1_LARGURA )
		if (calias)->B1_SEGUM == 'MT'
			if (cAlias)->B1_TIPCONV == 'D'
				nFatConv := (cAlias)->B1_CONV
			else
				nFatConv := 1 / (cAlias)->B1_CONV
			endif
			aAdd(aLote[len(aLote)], nFatConv)
			aAdd(aLote[len(aLote)], 'MT')
		elseif (calias)->B1_UM == 'M2' .and. (calias)->B1_LARGURA > 0
			nFatConv := (cAlias)->B1_LARGURA / 1000
			aAdd(aLote[len(aLote)], nFatConv)
			aAdd(aLote[len(aLote)], 'MT')
		ELSEIF (calias)->B1_UM == 'MT'
			aAdd(aLote[len(aLote)], 1)
			aAdd(aLote[len(aLote)], 'MT')
		else
			aAdd(aLote[len(aLote)], 1)
			aAdd(aLote[len(aLote)],  (cAlias)->B1_UM)
		endif

		(cAlias)->(dbSkip())
	enddo
	(cAlias)->(DbClosearea())




Return aLote


static function cnslote(cOp, cLote)

	Local cAlias := getNextAlias()

	BeginSQl alias cAlias
		SELECT TOP 1 *
		FROM %table:SD3% D3 
		WHERE D3_FILIAL = %XFILIAL:SD3% AND D3.%NOTDEL%
		AND D3_LOTECTL = %EXP:CLOTE%
		AND D3_OP = %EXP:COP%
		AND D3_CF LIKE 'R%'
		ORDER BY D3_LOTECTL DESC
	EndSQL

	u_dbg_qry()
	cProd := (calias)->D3_COD

	(calias)->(dbclosearea())

return cProd

static Function distdev(cNumseq, CPRODUTO, CLOTECTL, cLocal, cLocaliz)
	LOCAL LOK:=.t.
	acab:={}
	aitem:={}

	lMsErroAuto := .F.


	Q1:="SELECT DA.DA_PRODUTO, DA.DA_LOCAL, DA.DA_SALDO, DA.DA_QTDORI, DA.DA_LOTECTL, DA.DA_NUMLOTE, "
	Q1+="DA.DA_DOC, DA.DA_SERIE, DA.DA_CLIFOR, DA.DA_LOJA, DA.DA_TIPONF, DA.DA_ORIGEM, DA.DA_NUMSEQ, DA.DA_QTDORI2, DA.DA_QTSEGUM "
	Q1+="FROM "+RETSQLNAME("SDA")+" DA "
	Q1+="WHERE DA.DA_FILIAL='"+XFILIAL("SDA")+"' AND DA.D_E_L_E_T_ <> '*' "
	Q1+="AND DA.DA_ORIGEM='SD3' AND DA.DA_SALDO > 0 "
	Q1+="AND DA.DA_DATA = '"+DTOS(DDATABASE)+"' "
	Q1+="AND DA.DA_PRODUTO = '"+CPRODUTO+"' "
	Q1+="AND DA.DA_NUMSEQ = '"+CNUMSEQ+"' "
	Q1+="AND DA.DA_LOTECTL='"+CLOTECTL+"' "

	CONOUT(Q1)
	tcquery q1 alias "query1" new

	dbselectarea("query1")
	dbgotop()


	IF QUERY1->( !eof() )
		c_locdest:=""
		cTipoB1 := POSICIONE('SB1',1,XFILIAL('SB1')+query1->da_produto, 'B1_TIPO')

		aCab:= {	{"DA_PRODUTO"	,query1->da_produto,NIL},;
			{"DA_QTDORI"	,query1->da_qtdori ,NIL},;
			{"DA_SALDO" 	,query1->da_saldo  ,NIL},;
			{"DA_DATA"	    ,ddatabase         ,NIL},;
			{"DA_LOTECTL"	,query1->da_lotectl,NIL},;
			{"DA_NUMLOTE"	,query1->da_numlote,NIL},;
			{"DA_LOCAL"	    ,query1->da_local  ,NIL},;
			{"DA_DOC"	    ,query1->da_doc    ,NIL},;
			{"DA_SERIE" 	,query1->da_serie  ,NIL},;
			{"DA_CLIFOR"	,query1->da_clifor ,NIL},;
			{"DA_LOJA"  	,query1->da_loja   ,NIL},;
			{"DA_TIPONF"	,query1->da_tiponf ,NIL},;
			{"DA_ORIGEM"	,query1->da_origem ,NIL},;
			{"DA_NUMSEQ"	,query1->da_numseq ,NIL},;
			{"DA_QTDORI2"	,query1->da_qtdori2,NIL},;
			{"DA_QTSEGUM"	,query1->da_qtsegum,NIL}}

		Q2:="SELECT MAX(DB.DB_ITEM) AS MAXNUM "
		Q2+="FROM "+RETSQLNAME("SDB")+" DB "
		Q2+="WHERE DB.DB_FILIAL='"+XFILIAL("SDB")+"' AND DB.D_E_L_E_T_ <> '*' "
		Q2+="AND DB.DB_PRODUTO='"+QUERY1->DA_PRODUTO+"' "
		Q2+="AND DB.DB_LOCAL='"+QUERY1->DA_LOCAL+"' "
		Q2+="AND DB.DB_NUMSEQ='"+QUERY1->DA_NUMSEQ+"' "

		tcquery q2 alias "query2" new

		dbselectarea("query2")
		dbgotop()


		if QUERY2->(!eof())
			n_item:=alltrim(query2->maxnum)
			n_item:=val(n_item)+1
			n_item:=strzero(n_item,4)
		else
			n_item:="0001"
		endif

		dbselectarea("query2")
		dbclosearea()

		c_locdest := QUERY1->DA_LOCAL


		Aadd(aItem,{{"DB_ITEM",n_item		,NIL},;
			{"DB_LOCALIZ"	,cLocaliz			,NIL},;
			{"DB_QUANT"		,query1->da_saldo 	,NIL},;
			{"DB_DATA"		,ddatabase		  	,NIL},;
			{"DB_OCORRE"	,space(4)		  	,NIL},;
			{"DB_AUTO"		,"S"			  	,NIL}})

		MSExecAuto({|x,y,z| mata265(x,y,z)},aCab,aItem,3) //Distribui
		conout("execauto")

		If lMsErroAuto  //Houve algum erro na execucao do SigaAuto
			conout("ERRO Cadastro produto "+QUERY1->DA_PRODUTO)
			cmsg:="Verificar no SIGAADV o log "+NomeAutoLog()+CHR(13)
			conout(cMsg)
			LoK:= .f.
		ELSE
			CONOUT('DISTRIBUIDO')
		endif

	endIF


	dbselectarea("query1")
	dbclosearea()

	//bH:=ferase("prod265.txt")

return LoK
