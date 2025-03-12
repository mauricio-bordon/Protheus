#include "protheus.ch"
#include "restful.ch"
#include 'rwmake.ch'
#Include "tbiconn.ch"

wsrestful ws_pcp_producao2 description "WS para incluir producao"
	wsdata NUMERO as char OPTIONAL
	wsdata ITEM as char OPTIONAL
	wsdata SEQUENCIA as char OPTIONAL
	wsdata CPARCTOT as char OPTIONAL
	wsdata LOTE as char OPTIONAL
	wsdata NVIAS as char OPTIONAL
	wsdata NROLODE as char OPTIONAL
	wsdata NROLOATE as char OPTIONAL

	wsmethod get ws1;
		description "Imprime etq identifica��o";
		wssyntax "/ws_pcp_producao2/printetqident/{NUMERO}/{ITEM}/{SEQUENCIA}/{NVIAS}/{NROLODE}/{NROLOATE}";
		path "/ws_pcp_producao2/printetqident/{NUMERO}/{ITEM}/{SEQUENCIA}/{NVIAS}/{NROLODE}/{NROLOATE}";

	wsmethod post ws2;
		description "OP inclui producao post";
		wssyntax "/ws_pcp_producao2/{NUMERO}/{ITEM}/{SEQUENCIA}";
		path "/ws_pcp_producao2/{NUMERO}/{ITEM}/{SEQUENCIA}"

	wsmethod post ws3;
		description "OP encerra producao post";
		wssyntax "/ws_pcp_producao2/encerra/{NUMERO}/{ITEM}/{SEQUENCIA}";
		path "/ws_pcp_producao2/encerra/{NUMERO}/{ITEM}/{SEQUENCIA}/"

	wsmethod get ws4;
		description "Imprime etq lote PI";
		wssyntax "/ws_pcp_producao2/print/{LOTE}";
		path "/ws_pcp_producao2/print/{LOTE}"

end wsrestful

wsmethod get ws1 wsservice ws_pcp_producao2
	Local lOk := .T.
	Local cNumero := ::NUMERO
	Local cItem := ::ITEM
	Local cSequencia := ::SEQUENCIA
	Local nVias := val(::NVIAS)
	Local nRoloDe := val(::NROLODE)
	Local nRoloAte := val(::NROLOATE)

	//{NUMERO}/{ITEM}/{SEQUENCIA}/{NVIAS}/{NROLODE}"

	private cMsg := ''

	lOk := U_etqident(cNumero, cItem, cSequencia, nVias, nRoloDe, nRoloAte)

	if !lOk
		::SetResponse('{ "message": "Erro ao tentar imprimir a etiqueta de identifica��o; verifique a impressora!","detailedMessage": "'+cMsg+'"}')

		self:setStatus(400)
	else
			self:setStatus(200)

			endif
	conout('-------------')
Return lok

wsmethod post ws2 wsservice ws_pcp_producao2
	Local lPost := .T.
	Local lok := .T.
	Local oJson, cParcTot
	Local cOp := padr(alltrim(::NUMERO)+alltrim(::ITEM)+alltrim(::SEQUENCIA),13)
	Local cBody := ::getContent()
	Local nQuje := POSICIONE('SC2', 1, xfilial('SC2')+cOp, "C2_QUJE")
	Local nQtdeOp := POSICIONE('SC2', 1, xfilial('SC2')+cOp, "C2_QUANT")
	Local nQtdLanc := 0, nQtdTotal := 0
	private cUserRest := 'coletor'
	private cMsg := ''
	oJson := JsonObject():new()
	oJson:fromJSON(cBody)
	conout(cBody)

	nQtdLanc :=oJson['QUANTIDADE']
	//indica se parcial ou total
	conout('--- ws_pcp_producao2 --- ')
	conout('OP: '+cOp)
	conout('Quantidade OP: ' + transform( nQtdeOp, "@E 9,999,999.999"))
	conout('Quantidade Produzida: ' + transform( nQuje, "@E 9,999,999.999"))
	conout('Quantidade a Produzir: ' + transform(nQtdeOp - nQuje , "@E 9,999,999.999"))
	conout('Lançamento de Produção: ' + transform(nQtdLanc, "@E 9,999,999.999"))
	nQtdTotal := nQuje + nQtdLanc
	//TODO ver validacao total
	if nQtdTotal >= nQtdeOp
		cParcTot := 'P' //Lançamento total deve encerrar a ordem
		conout('Lançamento será total e poderá encerrar a ordem')
	else
		cParcTot := 'P'
		conout('Lancamento sera parcial.')
	endif

	if cParcTot == 'T'
		lOk := validaOp(cOp, nQtdTotal)
	endif

	if !lOk
		::SetResponse('{ "message": "Validação de Empenho","detailedMessage": "'+cMsg+'"}')
		self:setStatus(400)
	else
		lOk := incproducao(cOp, oJson , cParcTot)
		if lOk
			::SetResponse('{ "message": "Produção realizada com sucesso","detailedMessage": "Produção realizada com sucesso"}')
			self:setStatus(200)
		else
			::SetResponse('{ "message": "Ops...","detailedMessage": "'+ENCODEUTF8( cMsg )+'"}')
			self:setStatus(400)
		endif
	endif
	conout('-------------')
Return lPost

static Function incproducao(cOp, oJson, _cParcTot)
	Local lRet:=.T.
	Local aMata680 := {}

	Local cProd := POSICIONE('SC2', 1, xfilial('SC2')+cOp, "C2_PRODUTO")
	Local cMaq := POSICIONE('SC2', 1, xfilial('SC2')+cOp, "C2_MAQUINA")
	Local aDtHr := proxap(cop)
	Local cOperador := oJson['IDUSUARIO']
	Local _cOperac := '01'
	Local _cHoraIni:= aDtHr[2]
	Local _cHoraFin:= time()
	Local _nQtdProd:= oJson['QUANTIDADE']
	Local _nQtdPerd:= 0
	Local cObs := oJson['OBS']
	Local cLotectl := oJson['LOTE']

	conout(oJson:toJson())

	aadd(aMata680,{"H6_FILIAL", XFILIAL('SH6')	,NIL})
	aadd(aMata680,{"H6_OP", padr(cOp,13) 	,NIL})
	aadd(aMata680,{"H6_PRODUTO", cProd ,NIL})
	aadd(aMata680,{"H6_OPERAC", _cOperac ,NIL})
	aadd(aMata680,{"H6_DATAINI", aDtHr[1] ,NIL})
	aadd(aMata680,{"H6_HORAINI", _cHoraIni ,NIL})
	aadd(aMata680,{"H6_DATAFIN", dDataBase ,NIL})
	aadd(aMata680,{"H6_HORAFIN", _cHoraFin ,NIL})
	aadd(aMata680,{"H6_RECURSO", cMaq ,NIL})
//aadd(aMata680,{"H6_FERRAM", " " ,NIL})
	aadd(aMata680,{"H6_QTDPROD", _nQtdProd  ,NIL})
	aadd(aMata680,{"H6_QTDPERD", _nQtdPerd ,NIL})
	aadd(aMata680,{"H6_PT", _cParcTot ,NIL})
	aadd(aMata680,{"H6_DTAPONT", DDATABASE ,NIL})
	aadd(aMata680,{"H6_LOTECTL", cLotectl ,NIL})
	aadd(aMata680,{"H6_DTVALID", ddatabase+365 ,NIL})
	aadd(aMata680,{"H6_OPERADO", cOperador ,NIL})
	aadd(aMata680,{"H6_OBSERVA", cObs ,NIL})
//	aadd(aMata680,{"PENDENTE", "1" ,NIL})
//aadd(aMata680,{"H6_LOCAL", _cLocal ,NIL})
//	aadd(aMata680,{"H6_LOCAL", '' ,NIL})

	U_JSON_DBG(aMAta680)
	lMsErroAuto :=.F.
	MsExecAuto({|x,y|MATA681(x,y)},aMata680,3)

	If lMsErroAuto
		lRet :=.F.//deu erro
		ctitulo:="Erro na execucao do MATA681. produz APP"
		cmsg:="Erro ao lancar producao. Informar codigo "+NomeAutoLog()
		conout(cMsg)
	ELSE
		//u_flexdist(.F.)
	endif

return lRet

static function proxap(cop)
	Local cAlias
	Local aDtHr := {}
	cProd := POSICIONE('SC2', 1, xfilial('SC2')+cOp, "C2_PRODUTO")
	nQb := POSICIONE('SB1', 1, xfilial('SB1')+cProd, "B1_QB")

	cAlias := getNextAlias()

	BeginSQL alias cAlias
        SELECT TOP 1 *
        FROM %table:SH6% H6
        where H6_FILIAL = %XFILIAL:SH6% AND H6.D_E_L_E_T_<>'*'
            AND H6_OP=%Exp:cOP%
			order BY H6_DATAFIN desc, H6_HORAFIN desc
	EndSQL
	u_dbg_qry()
	if (calias)->(!eof())
		aAdd(aDtHr , stod((caLias)->H6_DATAFIN))
		aAdd(aDtHr , (caLias)->H6_HORAFIN)
	endif
	(cAlias)->(DbClosearea())
	if len(aDtHr) == 0
		cAlias := getNextAlias()

		BeginSQL alias cAlias
			SELECT TOP 1 *
			FROM %table:SD3% D3
			where D3_FILIAL = %XFILIAL:SD3% AND D3.D_E_L_E_T_<>'*'
				AND D3_OP=%Exp:cOP%
				AND D3_ESTORNO <> 'S'
				AND D3_CF LIKE 'RE%'
				order BY D3_NUMSEQ
		EndSQL
		u_dbg_qry()
		if (calias)->(!eof())
			if alltrim((caLias)->D3_DTSIST) <> ''
				aAdd(aDtHr , stod((caLias)->D3_DTSIST))
			else
				aAdd(aDtHr , stod((caLias)->D3_EMISSAO))
			ENDIF
			if alltrim((caLias)->D3_HRSIST) <> ''
				aAdd(aDtHr , (caLias)->D3_HRSIST)
			else
				aAdd(aDtHr , '00:00')
			endif
		endif
		(cAlias)->(DbClosearea())

	endif
return aDtHr

static function validaOp(cOp, nQuant)
	Local lOk := .T.

	//Valida se h? empenho sem lote
	Local cAliasSD3 := getNextAlias()
	Local nLin, cMsgErro := ''
	Local aEmpFora := {}
	Local cAliasG1 := getNextAlias()
	Local aEstr, nPos, cUnMed, nMin, nMax
	dbSelectArea('SC2')
	SC2->(DBSEEK(XFILIAL('SC2')+cOP))

	conout(' --- INICIO ws_pcp_producao2 VALIDA ---')

		lOk := .T. //u_m681vldMO(cOp)
		if !LOk
			cMsgErro := 'Inconsitência no total de mão de obra da ordem. Verificar e efetuar ajustes antes de encerrar'
		else

		CONOUT('QTD total:'+Transform(nQuant, "@E 999,999,999.999"))
		nQtdBase := POSICIONE("SB1", 1, XFILIAL("SB1")+SC2->C2_PRODUTO, "B1_QB")
		CONOUT('QTD BASE:'+Transform(nQtdBase, "@E 999,999,999.999"))
		nRazao := nQuant / nQtdBase
		CONOUT('razao:'+Transform(nrazao, "@E 999,999,999.999"))
		nToler := 0.05

		BeginSQL alias cAliasG1
			SELECT *
			FROM %TABLE:SG1%
			WHERE G1_FILIAL = %XFILIAL:SG1% AND %NOTDEL%
			AND G1_COD = %EXP:SC2->C2_PRODUTO%
			AND G1_REVINI <= %EXP:SC2->C2_REVISAO% AND G1_REVFIM >= %EXP:SC2->C2_REVISAO%
			ORDER BY G1_COMP
		EndSQL
		u_dbg_qry('QUERY ESTRUTURA')

		aEstr := {} // {COD, QTD ESTR, QTD PREVISTA, QTD MAXIMA}
		while (cAliasG1)->(!Eof())
			CONOUT('Componente: '+(cAliasG1)->G1_COMP)
			cUnMed := POSICIONE('SB1',1, XFILIAL('SB1')+(cAliasG1)->G1_COMP,"B1_UM")
			if cUnMed == 'KG'
				nMin := (cAliasG1)->G1_QUANT * nRazao  * (1 - nToler)
				nMax := (cAliasG1)->G1_QUANT * nRazao  * (1 + nToler)
			else
				nMin := (cAliasG1)->G1_QUANT * nRazao
				nMax := (cAliasG1)->G1_QUANT * nRazao * (1 + nToler)
			endif
			CONOUT('Minimo: '+Transform(nMin, "@E 999,999,999.999"))
			CONOUT('Maximo: '+Transform(nMax, "@E 999,999,999.999"))
			aAdd(aEstr, {(cAliasG1)->G1_COMP, (cAliasG1)->G1_QUANT, nMin, nMax})
			(cAliasG1)->(DBSkip())
		enddo
		(cAliasG1)->(DbClosearea())
		U_JSON_DBG(aEstr)
		cAliasSD3 := getNextAlias()
		BeginSQL alias cAliasSD3
				SELECT D3_COD, sum( CASE WHEN D3_CF = 'DE0' THEN - D3_QUANT ELSE D3_QUANT END  ) as D3_QUANT
				FROM  %TABLE:SD3% D3
				WHERE D3_FILIAL = %XFILIAL:SD3% AND D3.D_E_L_E_T_ <> '*'
				AND D3_OP = %EXP:cOP%
				AND D3_COD NOT LIKE 'MOD%' AND D3_COD NOT LIKE 'MOI%' AND D3_COD NOT LIKE 'GGF%'
				AND D3_CF IN ( 'RE0', 'RE1', 'DE0' )
				and D3_ESTORNO <> 'S'
				GROUP BY D3_COD
				ORDER BY 1
		EndSQL

		u_dbg_qry('QUERY CONSUMO')

		aEmpFora := {}
		aEstFora := {}
		nLin := 0
		while (cAliasSD3)->(!eof())
			nPos := ASCAN(aEstr,{ |x| x[1] == (cAliasSD3)->D3_COD })
			if nPos == 0
				aAdd(aEstFora, (cAliasSD3)->D3_COD)
			else
				nMin := aEstr[nPos, 3]
				nMax := aEstr[nPos, 4]

				if (cAliasSD3)->D3_QUANT < nMin .or. (cAliasSD3)->D3_QUANT > nMax
					CONOUT('Produto: '+ aEstr[nPos,1])
					CONOUT('Produto: '+ (cAliasSD3)->D3_COD)
					CONOUT('Minimo: '+ cvaltochar(nMin))
					CONOUT('Maximo: '+ cvaltochar(nMax))
					CONOUT('Total: '+ cvaltochar((cAliasSD3)->D3_QUANT))
					aAdd(aEmpFora, (cAliasSD3)->D3_COD)
				endif
			endif
			(cAliasSD3)->(DBSkip())
		enddo
		(cAliasSD3)->(dbclosearea())

		if len(aEstFora) > 0
			LoK := .f.
			cMsgErro += "Os Produtos "+ u_implode(', ',aEstFora)+  " foram consumidos mas não estão na estrutura. Não é possivel encerrar a ordem. "
		endif
		if len(aEmpFora) > 0
			LoK := .f.
			U_JSON_DBG(aEmpFora)
			cMsgErro += "Os Produtos "+ u_implode(', ',aEmpFora)+  " não estão com o consumo de acordo com a estrutura. Não é possivel encerrar a ordem."
			//cMsgErro += "Existem Produtos que não estão com o consumo de acordo com a estrutura.\nNão é possivel encerrar a ordem."
		endif

	endif

	cMsg := cMsgErro
	CONOUT(cmsg)
	conout(' --- FIM ws_pcp_producao2 VALIDA ---')

return lOk

wsmethod post ws3 wsservice ws_pcp_producao2
	Local lPost := .T.
	Local lok := .T.
	Local oJson
	Local cOp := padr(alltrim(::NUMERO)+alltrim(::ITEM)+alltrim(::SEQUENCIA),13)
	Local cBody := ::getContent()
	//Local nQuje := POSICIONE('SC2', 1, xfilial('SC2')+cOp, "C2_QUJE")
	private cUserRest := 'coletor'
	private cMsg := ''
	oJson := JsonObject():new()
	oJson:fromJSON(cBody)
	conout(cBody)

	lOk := .T. // validaOp(cOp, nQuje)

	if !lOk
		::SetResponse('{ "message": "Erro ao encerrar ordem.","detailedMessage": "'+cMsg+'"}')

		self:setStatus(400)
	else
		lOk := rEnc681(cOp)
		if lOk

			::SetResponse(oJson)

			self:setStatus(200)

		else
			::SetResponse('{ "message": "Ops...","detailedMessage": "'+cMsg+'"}')

			self:setStatus(400)
		endif
	endif
	conout('-------------')
Return lPost

wsmethod get ws4 wsservice ws_pcp_producao2
	Local lOk := .T.
	Local cLote := ::LOTE
	private cMsg := ''

	lOk := U_etqpim2(cLote) // validaOp(cOp, nQuje)

	if !lOk
		::SetResponse('{ "message": "Erro ao tentar imprimir, verifique a impressora.","detailedMessage": "'+cMsg+'"}')

		self:setStatus(400)
	else

			self:setStatus(200)

			endif
	conout('-------------')
Return lok

static Function rEnc681(cOp)

	Local xRotAuto := {}
	Local cAlias := getNextAlias()
	local cProd, cOperac, cRecno, lRet := .T., cIdent
	PRIVATE lMsErroAuto := .F.

	dData := dDataBase

//obtem ultimo apontamento
	dbSelectArea("SC2")
	SC2->(DBSETORDER(1))
	SC2->(DBSEEK(XFILIAL('SC2')+COP))

	BeginSQL alias calias
	SELECT TOP 1 *
	FROM %TABLE:SH6%
	WHERE H6_FILIAL = %XFILIAL:SH6% AND %NOTDEL%
	AND H6_OP = %EXP:COP%
	ORDER BY H6_IDENT DESC
	EndSql

	u_dbg_qry()

	cOp         := (CALIAS)->H6_OP
	cProd       := (CALIAS)->H6_PRODUTO
	cOperac     := (CALIAS)->H6_OPERAC
	cRecno      := (CALIAS)->R_E_C_N_O_
	cIdent		:= (calias)->H6_IDENT

	(cAlias)->(dbclosearea())

	conout('Encerrando ordem '+cOp)
	conout('Movimento '+cIdent)
	xRotAuto := {;
		{"H6_FILIAL"    , xFilial("SH6")  ,Nil},;
		{"H6_OP"        , cOp             ,Nil},;
		{"H6_PRODUTO"   , cProd           ,Nil},;
		{"H6_OPERAC"    , cOperac         ,Nil},;
		{"AUTRECNO"     , cRecno          ,Nil};
		}

	msExecAuto({|x,y| MATA681(x,y)},xRotAuto,7)

	If lMsErroAuto
		lRet :=.F.//deu erro
		ctitulo:="Erro na execucao do mata250. produz APP"
		cmsg:="Erro ao encerrar ordem. Informar codigo "+NomeAutoLog()
		conout(cMsg)
	Endif

Return lRet
