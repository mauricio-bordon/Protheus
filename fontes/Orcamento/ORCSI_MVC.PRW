#Include "TOTVS.ch"
#Include "FWMVCDEF.ch"


//VALIDAR LINHA DA ZV1
// CORES
//
 
// FUNÇÃO PRINCIPAL
User Function ORCSI_MVC()
	Local oBrowse
	Private __lCopia := .F., __lAprova := .F.
	PRIVATE  aJsonLog
	PRIVATE oZV1Status := JsonObject():new()

	oZV1Status['0'] := "Aberto"
	oZV1Status['A'] := "Aprovado"
	oZV1Status['R'] := "Reprovado"
	oZV1Status['I'] := "Inativo"

	oBrowse := FwLoadBrw("ORCSI_MVC")
	oBrowse:Activate()

	FreeObj(oZV1Status)

Return (NIL)

// BROWSEDEF() SERÁ ÚTIL PARA FUTURAS HERANÇAS: FWLOADBRW()
Static Function BrowseDef()
	Local oBrowse := FwMBrowse():New()

	oBrowse:SetAlias("ZV1")
	oBrowse:SetDescription("Orçamento de Selo de Indução")

	// Legendas

	oBrowse:AddLegend("ZV1_STATUS == '0'", "BR_BRANCO"		,  oZV1Status['0'])
	oBrowse:AddLegend("ZV1_STATUS == 'A'", "BR_VERDE"		,  oZV1Status['A'])
	oBrowse:AddLegend("ZV1_STATUS == 'R'", "BR_VERMELHO"	,  oZV1Status['R'])
	oBrowse:AddLegend("ZV1_STATUS == 'I'", "BR_PRETO"		,  oZV1Status['I'])

	//TODO TELA COM AS LEGENDAS
	// DEFINE DE ONDE SERÁ RETIRADO O MENUDEF
	oBrowse:SetMenuDef("ORCSI_MVC")


Return (oBrowse)

// OPERAÇÕES DA ROTINA
Static Function MenuDef()
	// FUNÇÃO PARA CRIAR MENUDEF
	Local aRotina := {} //FwMVCMenu("ORCSI_MVC")

	ADD OPTION aRotina Title 'Visualizar' 			Action 'U_ORCSIVIS()' 	OPERATION  2 ACCESS 0
	ADD OPTION aRotina Title 'Incluir' 				Action 'VIEWDEF.ORCSI_MVC' 	OPERATION  3 ACCESS 0
	ADD OPTION aRotina Title 'Alterar' 				Action 'u_ORCSIALT()' 		OPERATION  4 ACCESS 0
	ADD OPTION aRotina Title 'Cancelar' 			Action 'u_ORCSICAN()' 		OPERATION  4 ACCESS 0
/*	if alltrim(upper(cUserName)) == 'ADMINISTRADOR'
		ADD OPTION aRotina Title 'Excluir' 				Action 'VIEWDEF.ORCSI_MVC' 	OPERATION  5 ACCESS 0
	ENDIF
*/	//ADD OPTION aRotina Title 'Liberar Orçamento' 	Action 'u_ORCSILIB()' 		OPERATION 10 ACCESS 0
	ADD OPTION aRotina Title 'Aprovar/Reprovar Orç' Action 'u_ORCSIAPV()' 		OPERATION  4 ACCESS 0
	ADD OPTION aRotina Title 'Nova Revisão' 		Action 'u_ORCSICPY()' 		OPERATION  9 ACCESS 0

	ADD OPTION aRotina Title 'Imprimir Orçamento' 	Action 'u_ORCSIPDF()' 		OPERATION 10 ACCESS 0
	ADD OPTION aRotina TITLE 'Legenda'    			Action 'u_ORCSILeg()'  	OPERATION  6 ACCESS 0

Return (aRotina)

// REGRAS DE NEGÓCIO
Static Function ModelDef()
	// INSTANCIA O MODELO
	Local oModel, aGatilhos, nAtual
	//Blocos de código nas validações
	Local bVldPre := {|| ORCSIPre()} //Antes de abrir a Tela
	Local bVldPos := {|| ORCSIPos()} //Validação ao clicar no Confirmar
	//Local bVldCom := {|| ORCSICom()} //Função chamadao ao cancelar
	Local bVldCan := {|| ORCSICan()} //Função chamadao ao cancelar

	Local bPreFldZV0 := {|oFieldModel, cAction, cIDField, xValue, a, b| valPreZV0(oFieldModel, cAction, cIDField, xValue)}
	Local bLinePre := {|oGridModel, nLine, cAction, cIDField, xValue, xCurrentValue| linePreGrid(oGridModel, nLine, cAction, cIDField, xValue, xCurrentValue)}
	Local bLinePost := {|oGridModel, nLine| linePostGrid(oGridModel, nLine)}
	// INSTANCIA OS SUBMODELOS
	Local oStruZV0 := FwFormStruct(1, "ZV0")
	Local oStruZV1 := FwFormStruct(1, "ZV1")

	aGatilhos := TRG_ZV0()
	//Percorrendo os gatilhos e adicionando na Struct
	For nAtual := 1 To Len(aGatilhos)
		oStruZV0:AddTrigger(    aGatilhos[nAtual][01],; //Campo Origem
		aGatilhos[nAtual][02],; //Campo Destino
		aGatilhos[nAtual][03],; //Bloco de código na validação da execução do gatilho
		aGatilhos[nAtual][04])  //Bloco de código de execução do gatilho
	Next

	aGatilhos := TRG_ZV1()
	//Percorrendo os gatilhos e adicionando na Struct
	For nAtual := 1 To Len(aGatilhos)
		oStruZV1:AddTrigger(aGatilhos[nAtual][01],; //Campo Origem
		aGatilhos[nAtual][02],; //Campo Destino
		aGatilhos[nAtual][03],; //Bloco de código na validação da execução do gatilho
		aGatilhos[nAtual][04] )  //Bloco de código de execução do gatilho
	Next

	//Editando características do dicionário
	oStruZV0:SetProperty('ZV0_CODIGO', MODEL_FIELD_INIT 	, FwBuildFeature(STRUCT_FEATURE_INIPAD  , 'U_ZV0CODINI()'))         //Ini Padrão
	oStruZV0:SetProperty('ZV0_CODIGO', MODEL_FIELD_WHEN 	, FwBuildFeature(STRUCT_FEATURE_WHEN    , '.F.'))
	oStruZV0:SetProperty('ZV0_REVI'	 , MODEL_FIELD_INIT 	, FwBuildFeature(STRUCT_FEATURE_INIPAD  , 'U_ZV0REVINI()'))         //Ini Padrão
	oStruZV0:SetProperty('ZV0_REVI'	 , MODEL_FIELD_WHEN 	, FwBuildFeature(STRUCT_FEATURE_WHEN    , '.F.'))
	oStruZV0:SetProperty('ZV0_STATUS', MODEL_FIELD_INIT 	, FwBuildFeature(STRUCT_FEATURE_INIPAD  , '0'))         //Ini Padrão
	oStruZV0:SetProperty('ZV0_EMISS' , MODEL_FIELD_INIT 	, FwBuildFeature(STRUCT_FEATURE_INIPAD  , 'dDatabase'))         //Ini Padrão
	oStruZV0:SetProperty('ZV0_EMISS' , MODEL_FIELD_WHEN 	, FwBuildFeature(STRUCT_FEATURE_WHEN    , '.F.'))
//	oStruZV0:SetProperty('ZV0_STATUS', MODEL_FIELD_WHEN 	, FwBuildFeature(STRUCT_FEATURE_WHEN    , '__lCopia'))
	oStruZV0:SetProperty('ZV0_CODCLI', MODEL_FIELD_VALID	, FwBuildFeature(STRUCT_FEATURE_VALID   , 'Vazio() .or. ExistCpo("SA1",M->ZV0_CODCLI)'))   //Validação de Campo
	oStruZV0:SetProperty('ZV0_CODCLI', MODEL_FIELD_OBRIGAT	, .T. ) //Campo Obrigatório
	oStruZV0:SetProperty('ZV0_CONTAT', MODEL_FIELD_OBRIGAT	, .T. ) //Campo Obrigatório
	oStruZV0:SetProperty('ZV0_EMAIL' , MODEL_FIELD_OBRIGAT	, .T. ) //Campo Obrigatório
	oStruZV0:SetProperty('ZV0_REVMOT', MODEL_FIELD_WHEN 	, FwBuildFeature(STRUCT_FEATURE_WHEN    , 'iif(__lCopia,.T.,.F.)'))
	oStruZV0:SetProperty('ZV0_REVMOT', MODEL_FIELD_INIT 	, FwBuildFeature(STRUCT_FEATURE_INIPAD  , ''))         //Ini Padrão
	oStruZV0:SetProperty('ZV0_USER'	 , MODEL_FIELD_WHEN 	, FwBuildFeature(STRUCT_FEATURE_WHEN    , '.F.'))
	oStruZV0:SetProperty('ZV0_USER'	 , MODEL_FIELD_INIT 	, FwBuildFeature(STRUCT_FEATURE_INIPAD  , 'cUserName'))         //Ini Padrão

	oStruZV1:SetProperty('ZV1_STATUS', MODEL_FIELD_INIT 	, FwBuildFeature(STRUCT_FEATURE_INIPAD  , '0'))         //Ini Padrão
	oStruZV1:SetProperty('ZV1_STATUS', MODEL_FIELD_WHEN 	, FwBuildFeature(STRUCT_FEATURE_WHEN    , 'IIF(__lAProva,.T.,.F.)'))
	oStruZV1:SetProperty('ZV1_DESC'	 , MODEL_FIELD_WHEN 	, FwBuildFeature(STRUCT_FEATURE_WHEN    , "EMPTY(FWFldGet('ZV1_GRUPO'))"))
	oStruZV1:SetProperty('ZV1_MOTRPV', MODEL_FIELD_WHEN 	, FwBuildFeature(STRUCT_FEATURE_WHEN    , '.F.'))
	oStruZV1:SetProperty('ZV1_LARGPI', MODEL_FIELD_WHEN 	, FwBuildFeature(STRUCT_FEATURE_WHEN    , '.F.'))
	oStruZV1:SetProperty('ZV1_MTTOT' , MODEL_FIELD_VALID	, FwBuildFeature(STRUCT_FEATURE_VALID   , 'U_ZV1VLD01()'))   //Validação de Campo
	oStruZV1:SetProperty('ZV1_LARGCR', MODEL_FIELD_VALID	, FwBuildFeature(STRUCT_FEATURE_VALID   , 'U_ZV1VLD02()'))   //Validação de Campo
//	oStruZV1:SetProperty('ZV1_FAM'	 , MODEL_FIELD_VALID	, FwBuildFeature(STRUCT_FEATURE_VALID   , 'U_ZV1VLD03()'))   //Validação de Campo
	oStruZV1:SetProperty('ZV1_GRUPO' , MODEL_FIELD_VALID	, FwBuildFeature(STRUCT_FEATURE_VALID   , 'U_ZV1VLD03()'))   //Validação de Campo
	oStruZV1:SetProperty('ZV1_PRCPI' , MODEL_FIELD_VALID	, FwBuildFeature(STRUCT_FEATURE_VALID   , 'U_ZV1VLD04()'))   //Validação de Campo
	oStruZV1:SetProperty('ZV1_CORES' , MODEL_FIELD_VALID 	, FwBuildFeature(STRUCT_FEATURE_VALID   , 'U_ZV1VLD05()'))
	oStruZV1:SetProperty('ZV1_MTLIN' , MODEL_FIELD_VALID 	, FwBuildFeature(STRUCT_FEATURE_VALID   , 'U_ZV1VLD06()'))
//	oStruZV1:SetProperty('ZV1_PRCIMP', MODEL_FIELD_WHEN 	, FwBuildFeature(STRUCT_FEATURE_WHEN    , '.F.'))
//	oStruZV1:SetProperty('ZV1_PRCLIQ', MODEL_FIELD_WHEN 	, FwBuildFeature(STRUCT_FEATURE_WHEN    , '.F.'))
	oStruZV1:SetProperty('ZV1_DESC'  , MODEL_FIELD_OBRIGAT	, .T. ) //Campo Obrigatório
	oStruZV1:SetProperty('ZV1_LARGPI', MODEL_FIELD_OBRIGAT	, .T. ) //Campo Obrigatório
	oStruZV1:SetProperty('ZV1_LARGCR', MODEL_FIELD_OBRIGAT	, .T. ) //Campo Obrigatório
	oStruZV1:SetProperty('ZV1_MTTOT' , MODEL_FIELD_OBRIGAT	, .T. ) //Campo Obrigatório
	oStruZV1:SetProperty('ZV1_TPIMPR', MODEL_FIELD_OBRIGAT	, .T. ) //Campo Obrigatório

	oModel := MPFormModel():New("ORCSI_MDL", bVldPre, bVldPos, /*bVldCom*/, bVldCan)

	// DEFINE SE OS SUBMODELOS SERÃO FIELD OU GRID
	oModel:AddFields("ZV0MASTER", NIL, oStruZV0, bPreFldZV0)
	oModel:AddGrid("ZV1DETAIL", "ZV0MASTER", oStruZV1,bLinePre, bLinePost, /*bVldPre*/, /*bVldPost*/, /*bLoad*/)

	// DEFINE A RELAÇÃO ENTRE OS SUBMODELOS
	oModel:SetRelation("ZV1DETAIL", {{"ZV1_FILIAL", "FwXFilial('ZV1')"}, {"ZV1_CODIGO", "ZV0_CODIGO"}, {"ZV1_REVI", "ZV0_REVI"}, {"ZV1_CLI", "ZV0_CODCLI"}}, ZV1->(IndexKey( 1 )))
	oModel:SetPrimaryKey({'ZV0_FILIAL', 'ZV0_CODIGO', 'ZV0_REVI' })
	// DESCRIÇÃO DO MODELO
	oModel:SetDescription("Orçamento de Selo de Inducão" )

	// DESCRIÇÃO DOS SUBMODELOS
	oModel:GetModel("ZV0MASTER"):SetDescription("Orçamento de Selo de Indução")
	oModel:GetModel("ZV1DETAIL"):SetDescription("Itens do Orçamento")

Return (oModel)

// INTERFACE GRÁFICA
Static Function ViewDef()
	// INSTANCIA A VIEW
	Local oView := FwFormView():New()

	// INSTANCIA AS SUBVIEWS
	Local oStruZV0 := FwFormStruct(2, "ZV0")
	Local oStruZV1 := FwFormStruct(2, "ZV1")

	// RECEBE O MODELO DE DADOS
	Local oModel := FwLoadModel("ORCSI_MVC")

	// INDICA O MODELO DA VIEW
	oView:SetModel(oModel)

	// CRIA ESTRUTURA VISUAL DE CAMPOS
	oView:AddField("VIEW_ZV0", oStruZV0, "ZV0MASTER")
	oView:AddGrid("VIEW_ZV1", oStruZV1, "ZV1DETAIL")

	// CRIA BOXES HORIZONTAIS
	oView:CreateHorizontalBox("SUPERIOR", 30)
	oView:CreateHorizontalBox("INFERIOR", 70)

	// RELACIONA OS BOXES COM AS ESTRUTURAS VISUAIS
	oView:SetOwnerView("VIEW_ZV0", "SUPERIOR")
	oView:SetOwnerView("VIEW_ZV1", "INFERIOR")

	//Removendo campos
	oStruZV1:RemoveField("ZV1_CODIGO")
	oStruZV1:RemoveField("ZV1_REVI")
	oStruZV1:RemoveField("ZV1_CLI")
	oStruZV1:RemoveField("ZV1_CLIDES")

	// DEFINE AUTO-INCREMENTO AO CAMPO
	oView:AddIncrementField("VIEW_ZV1", "ZV1_ITEM")
	//oView:AddUserButton( 'Teste Altera', 'CLIPS', { |oView| u_ORCSIAPV() } )
	// DEFINE OS TÍTULOS DAS SUBVIEWS
	oView:EnableTitleView("VIEW_ZV1","Itens")
Return (oView)

user function ZV0CODINI()
	Local nCod := 0, cCod := '', calias := getnextalias()
	Local cAnoMes := substring(dtos(dDatabase),3,4)
	Local cAnoMesLike := cAnoMes+'%'

	Begin Transaction
		IF ALTERA
			cCod := ZV1->ZV1_CODIGO
		ELSE
			BeginSql alias cAlias
				SELECT * 
				FROM %TABLE:ZV0%
				where ZV0_FILIAL = %XFILIAL:ZV0% AND %NOTDEL%
				AND ZV0_CODIGO LIKE %EXP:cAnoMesLike%
			ENdSql
			if (calias)->(!eof())
				nCod := getmv('IC_ORCSISQ')
			else
				nCod := 0
			endif
			(calias)->(DBCLOSEAREA(  ))
			nCod++
			cCod := cAnoMes + strzero(nCod,4)
			putmv('IC_ORCSISQ', nCod)
		ENDIF
	End transaction
return cCod

user function ZV0REVINI()
	Local nRev := 0, cRev := '', calias := getnextalias()
	if INCLUI
		cRev := '000'
	elseif ALTERA .AND. __lCopia

		BeginSql alias cAlias
			SELECT coalesce(max(ZV0_REVI),'000') as ultimo
			FROM %TABLE:ZV0%
			where ZV0_FILIAL = %XFILIAL:ZV0% AND %NOTDEL%
			AND ZV0_CODIGO = %EXP:ZV1->ZV1_CODIGO%
		ENdSql

		nRev := val((Calias)->ultimo)
		(calias)->(DBCLOSEAREA(  ))
		nRev++
		cRev :=  strzero(nRev,3)
	else
		cRev := ZV1->ZV1_REVI
	endif
return cRev

STATIC FUNCTION TRG_ZV0()
	Local aGatilhos := {}
	//Adicionando um gatilho, do BM_GRUPO para o BM_DESC

	aAdd(aGatilhos, FWStruTriggger(    "ZV0_CODCLI",;                                //Campo Origem
	"ZV0_NOMCLI",;                                 //Campo Destino
	"SA1->A1_NOME",;             //Regra de Preenchimento
	.T.,;                                       //Irá Posicionar?
	"SA1",;                                        //Alias de Posicionamento
	1,;                                         //Índice de Posicionamento
	'xfilial("SA1")+ZV0_CODCLI',;                                        //Chave de Posicionamento
	NIL,;                                       //Condição para execução do gatilho
	"001");                                      //Sequência do gatilho
	)
	aAdd(aGatilhos, FWStruTriggger(    "ZV0_CODCLI",;                                //Campo Origem
	"ZV0_LOJCLI",;                                 //Campo Destino
	"SA1->A1_LOJA",;             //Regra de Preenchimento
	.T.,;                                       //Irá Posicionar?
	"SA1",;                                        //Alias de Posicionamento
	1,;                                         //Índice de Posicionamento
	'xfilial("SA1")+ZV0_CODCLI',;               //Chave de Posicionamento
	NIL,;                                       //Condição para execução do gatilho
	"002");                                      //Sequência do gatilho
	)
	aAdd(aGatilhos, FWStruTriggger(    "ZV0_CODCLI",;                                //Campo Origem
	"ZV0_CONDPG",;                                 //Campo Destino
	"SA1->A1_COND",;             //Regra de Preenchimento
	.T.,;                                       //Irá Posicionar?
	"SA1",;                                        //Alias de Posicionamento
	1,;                                         //Índice de Posicionamento
	'xfilial("SA1")+ZV0_CODCLI',;               //Chave de Posicionamento
	NIL,;                                       //Condição para execução do gatilho
	"003");                                      //Sequência do gatilho
	)
	aAdd(aGatilhos, FWStruTriggger(    "ZV0_CODCLI",;                                //Campo Origem
	"ZV0_REPRES",;                                 //Campo Destino
	"SA1->A1_VEND",;             //Regra de Preenchimento
	.T.,;                                       //Irá Posicionar?
	"SA1",;                                        //Alias de Posicionamento
	1,;                                         //Índice de Posicionamento
	'xfilial("SA1")+ZV0_CODCLI',;               //Chave de Posicionamento
	NIL,;                                       //Condição para execução do gatilho
	"004");                                      //Sequência do gatilho
	)
RETURN aGatilhos

STATIC FUNCTION TRG_ZV1()
	Local aGatilhos := {}
	//Adicionando um gatilho, do BM_GRUPO para o BM_DESC

	aAdd(aGatilhos, FWStruTriggger(    "ZV1_GRUPO",;                                //Campo Origem
	"ZV1_DESC",;                                 //Campo Destino
	"SBM->BM_DESC",;                           //Regra de Preenchimento
	.T.,;                                       //Irá Posicionar?
	"SBM",;                                     //Alias de Posicionamento
	1,;                                         //Índice de Posicionamento
	"XFILIAL('SBM')+ZV1_GRUPO",;               //Chave de Posicionamento
	NIL,;                                       //Condição para execução do gatilho
	"001");                                      //Sequência do gatilho
	)
	/*
    aAdd(aGatilhos, FWStruTriggger(    "ZV1_LARGCR",;                                //Campo Origem
	"ZV1_NROLOS",;                                 //Campo Destino
	"U_ZV1TRG01()",;                           //Regra de Preenchimento
	.F.,;                                       //Irá Posicionar?
	"",;                                     //Alias de Posicionamento
	1,;                                         //Índice de Posicionamento
	"",;               //Chave de Posicionamento
	NIL,;                                       //Condição para execução do gatilho
	"001");                                      //Sequência do gatilho
	)*/
RETURN aGatilhos

/*
Retorna o Numero de rolos do item, baseado na divisão da largura de entrega pela largura do PI
*/
USER FUNCTION ZV1TRG01()
	Local nLargCrt  := FWFldGet('ZV1_LARGCR')
	LOCAL nLargPI   := FWFldGet('ZV1_LARGPI')
	Local nRolos    := 0

	if nLargPI > 0 .and. nLargCrt > 0
		nRolos := Int(nLargPI / nLargCrt)
	endif

return nRolos


/*
Retorna o PRECO EM ML DO PRODUTO BASE DA FAMILIA
*/
USER FUNCTION ZV1TRG02()
	Local nLargCrt  := FWFldGet('ZV1_LARGCR')
	LOCAL nLargPI   := FWFldGet('ZV1_LARGPI')
	Local nRolos    := 0

	if nLargPI > 0 .and. nLargCrt > 0
		nRolos := Int(nLargPI / nLargCrt)
	endif

return nRolos

/* 
    Validacao do campo ZV1_MTTOT
    valor deve ser multiplo da metragem linear de corte da bobina
*/
User Function ZV1VLD01()
	Local nMTLin := FWFldGet("ZV1_MTLIN")
	Local nMTTot := FWFldGet("ZV1_MTTOT")
	Local nRolos := FWFldGet("ZV1_NROLOS")
	Local lRet := .F.

	if nMtLin <= 0
		Help( ,, 'Help',, 'Informe o valor em Metros Lineares da Bobina Mãe' , 1, 0 )
	elseif nRolos <= 0
		Help( ,, 'Help',, 'Informe a largura da faixa.' , 1, 0 )
	elseif mod(nMttot, nMtLin * nRolos) <> 0
		Help( ,, 'Help',, "Volume em Metros Lineares deve ser múltiplo dos metros lineares para entrega." , 1, 0 )
	else
		lRet := .T.
	endif
return lRet
/*
lARGURA DE CORTE NAO PODE SER MAIOR QUE LARGURA DA BOBINA DE PI
*/
User Function ZV1VLD02()
	Local nLargPI   := FWFldGet("ZV1_LARGPI")
	Local nLargCrt  := FWFldGet("ZV1_LARGCR")
	Local nRolos    := 0
	Local lRet := .T., nDecimal

	if  nLargCrt <= 0
		Help( ,, 'Help',, 'Informe um valor para Largura de Corte' , 1, 0 )
		Return .F.
	elseif  nLargPI <= 0
		Help( ,, 'Help',, 'A Largura do PI deve estar preenchida. ' , 1, 0 , NIL, NIL, NIL, NIL, NIL, {"Escolha uma família ou informe manualmente."})
		Return .F.
	elseif nLargCrt > nLargPI
		Help( ,, 'Help',, 'Largura de Corte não pode ser maior que largura do PI' , 1, 0 )
		Return .F.
	endif

	nDecimal := nLargCrt - int(nLargcrt)
	if nDecimal <> 0.5 .and. nDecimal <> 0
		lRet := msgyesno('Confirma a digitação da largura de '+transform(nLargcrt, "@E 999.999"),'Pergunta')
	endif

	if lret
		//Obtem numero de rolos por tirada
		if nLargPI > 0 .and. nLargCrt > 0
			nRolos := Int(nLargPI / nLargCrt)
		endif
		FWFldPut('ZV1_NROLOS', nRolos)

		calcpreco()
	endif

return lRet

/*
VALIDA FAMILIA PREENCHENDO CAMPOS 
*/
User Function ZV1VLD03()
	//Local cFamilia := FWFldGet("ZV1_FAM")
	Local cGrupo	:= FWFldGet("ZV1_GRUPO")
	Local nLarg, nMtRolo, cImp, cProdBase, nPrcMt
	Local lRet := .T.
	Local oModelPad  := FWModelActive()

	if empty(cGrupo)
		return .T.
	endif

	dbSelectArea('SBM')
	SBM->(DbSetOrder(1))
	SBM->(DBSEEK(XFILIAL('SBM')+cGrupo))

	IF SBM->(!FOUND())
		Help( ,, 'Help',, 'Grupo não encontrado' , 1, 0 )
		return .F.
	ENDIF

	nLarg   := getmv('IC_PIFXCRT')
	nMtRolo := getmv('IC_MTRLMX')
	cImp    := '0' // TODO, VERIFICAR SOBRE IMPRESSAO


	cProdBase := 'PI'+cGrupo+STRZERO(nLarg,4)

	dbSelectArea('DA1')
	DA1->(DbSetOrder(1))
	DA1->(DBSEEK(XFILIAL('DA1')+'SI '+cProdBase))

	IF DA1->(!FOUND())
		Help( ,, 'Help',, 'Produto SI não encontrado.' , 1, 0, NIL, NIL, NIL, NIL, NIL, {"Verifique a Tabela de Preço"} )
		return .F.
	ENDIF

	nPrcMt := DA1->DA1_PRCVEN

	FWFldPut('ZV1_PRCPIO', nPrcMt)
	FWFldPut('ZV1_PRCPI', nPrcMt)
	FWFldPut('ZV1_MTLIN', nMtRolo)
	//FWFldPut('ZV1_LARGPI', nLarg)
	oModelPad:loadvalue( 'ZV1DETAIL','ZV1_LARGPI', nLarg)
	FWFldPut('ZV1_IPI', POSICIONE("SB1",1,XFILIAL("SB1")+CPRODBASE,"B1_IPI"))
	IF cGrupo == alltrim(supergetmv('FX_ORCSICP', .F.,'9999'))	
		FWFldPut('ZV1_TPIMPR', 'ID')
	ELSEif cImp == '0'
		FWFldPut('ZV1_TPIMPR', 'SI')
	ELSEif cImp == '1'
		FWFldPut('ZV1_TPIMPR', 'IS')
	ENDIF
return lRet

User Function ZV1VLD04()
	Local nPrcPi 	:= FWFldGet("ZV1_PRCPI")
	Local nPrcPiOrig:= FWFldGet("ZV1_PRCPIO")
	Local nPrcPiUltimo:= FWFldGet("ZV1_PRCPIu")
	Local lRet := .T.//, cAlias

	IF nPrcPI <> nPrcPiOrig
		lRet := MsgYesNo('Confirma a liberação do preço diferente da tabela de preço?'+CHAR(13)+CHAR(10)+' Preço Tabela: '+transform(nPrcPiOrig, "@E 999,999.99999")+CHAR(13)+CHAR(10)+' Último Preço: '+transform(nPrcPiUltimo, "@E 999,999.99999"), 'Pergunta')
	endif
/*
	BEGINSQL alias CALIAS
		SELECT TOP 1 * 
				FROM %TABLE:ZV1%
				WHERE ZV1_FILIAL = %XFILIAL:ZV1% AND %NOTDEL%
					AND ZV1_CODIGO = %EXP:ZV0->ZV0_CODIGO%
					AND ZV1_STATUS = 'A'
				ENDSQL
	ENDSQL
*/
	calcpreco()
return lRet

User Function ZV1VLD05()
	Local cTipoImp 	:= FWFldGet("ZV1_TPIMPR")
	Local NCores 	:= FWFldGet("ZV1_CORES")
	Local lRet := .T.

	IF cTipoImp == 'SI' .AND. nCores > 0
		Help( ,, 'Help',, 'Não informar número de cores para produto sem impressão. ' , 1, 0 )
		lret := .F.
	endif

return lRet


User Function ZV1VLD06()
	//Local oModelPad  := FWModelActive()
	Local nMtTot 	:= FWFldGet("ZV1_MTTOT")
	Local lRet := .T.

	if nMtTot > 0
		MsgInfo('Ao alterar o valor dos metros lineares, informar novamente a metragem total', 'Aviso')
		nMtTot := 0
	endif

	FWFldPut('ZV1_MTTOT', nMtTot)
return lRet

user function ORCSILIB()
	Local nErro := 0
	ZV0->(DbSetOrder(1))
	ZV0->(DBSEEK(XFILIAL('ZV0')+ZV1->ZV1_CODIGO+ZV1->ZV1_REVI))
	if ZV0->ZV0_STATUS <> '0'
		Help( ,, 'Help',, "Apenas orçamentos em emissão podem ser liberados." , 1, 0 )
	ELSEIF MsgYesNo('Deseja Liberar o Orçamento para envio ao cliente? Após liberado, ele não poderá ser alterado e será necessário criar nova revisão.', 'Liberação do Orçamento para Envio ao Cliente')
		Begin Transaction
			ZV0->(RecLock('ZV0', .F.))
			ZV0->ZV0_STATUS := '1'
			ZV0->ZV0_USRLIB := cUserName
			ZV0->ZV0_DTLIB  := dDatabase
			ZV0->(MsUnlock())

			//Monta o Update
			cQryUpd := " UPDATE " + RetSqlName("ZV1") + " "
			cQryUpd += "     SET ZV1_STATUS = 'L' "
			cQryUpd += " WHERE "
			cQryUpd += "     ZV1_FILIAL = '" + FWxFilial('ZV1') + "' "
			cQryUpd += "     AND ZV1_CODIGO = '" + ZV0->ZV0_CODIGO + "' AND ZV1_REVI = '" + ZV0->ZV0_REVI + "' "
			cQryUpd += "     AND D_E_L_E_T_ = ' ' "

			//Tenta executar o update
			nErro := TcSqlExec(cQryUpd)

			//Se houve erro, mostra a mensagem e cancela a transação
			If nErro != 0
				Help( ,, 'Help',, "Erro ao liberar orçamento. "+TcSqlError() , 1, 0 )
				DisarmTransaction()
			EndIf
		End Transaction
	ENDIF

return .T.


user function ORCSICan()
	ZV0->(DbSetOrder(1))
	ZV0->(DBSEEK(XFILIAL('ZV0')+ZV1->ZV1_CODIGO+ZV1->ZV1_REVI))
	if ZV0->ZV0_STATUS <> '0'
		Help( ,, 'Help',, "Apenas orçamentos em emissão podem ser Cancelados." , 1, 0 )
	ELSEIF MsgYesNo('Deseja cancelar o Orçamento? Após cancelado, ele não poderá ser alterado e será necessário criar novo orçamento.', 'Liberação do Orçamento para Envio ao Cliente')
		ZV0->(RecLock('ZV0', .F.))
		ZV0->ZV0_STATUS := 'C'
		ZV0->ZV0_USRLIB := cUserName
		ZV0->ZV0_DTLIB  := dDatabase
		ZV0->(MsUnlock())

		Begin Transaction
			ZV0->(RecLock('ZV0', .F.))
			ZV0->ZV0_STATUS := 'C'
			ZV0->ZV0_USRLIB := cUserName
			ZV0->ZV0_DTLIB  := dDatabase
			ZV0->(MsUnlock())

			//Monta o Update
			cQryUpd := " UPDATE " + RetSqlName("ZV1") + " "
			cQryUpd += "     SET ZV1_STATUS = 'C' "
			cQryUpd += " WHERE "
			cQryUpd += "     ZV1_FILIAL = '" + FWxFilial('ZV1') + "' "
			cQryUpd += "     AND ZV1_CODIGO = '" + ZV0->ZV0_CODIGO + "' AND ZV1_REVI = '" + ZV0->ZV0_REVI + "' "
			cQryUpd += "     AND D_E_L_E_T_ = ' ' "

			//Tenta executar o update
			nErro := TcSqlExec(cQryUpd)

			//Se houve erro, mostra a mensagem e cancela a transação
			If nErro != 0
				Help( ,, 'Help',, "Erro ao liberar orçamento. "+TcSqlError() , 1, 0 )
				DisarmTransaction()
			EndIf
		End Transaction
	ENDIF

return .T.

User Function OrcSILeg()
	Local aLegenda := {}

	//Monta as cores
	AADD(aLegenda,{ "BR_BRANCO"		,  "Em Elaboração"  })
	AADD(aLegenda,{ "BR_VERDE"		,  "Aprovado"})
	AADD(aLegenda,{ "BR_VERMELHO"	,  "Reprovado"  })
	AADD(aLegenda,{ "BR_PRETO"		,  "Inativo"  })


	BrwLegenda("Orçamento", "Orçamento", aLegenda)
Return

/*/{Protheus.doc} zM1bPre
Função chamada na criação do Modelo de Dados (pré-validação)
@type function
@author Atilio
@since 03/09/2016
@version 1.0
/*/

STATIC Function ORCSIPre()
	Local oModelPad  := FWModelActive()
	Local nOpc       := oModelPad:GetOperation()
	Local lRet       := .T.
	//Se for inclusão ou exclusão
	If nOpc == MODEL_OPERATION_INSERT
		If RetCodUsr() == '000000'
			//oModelPad:GetModel('FORMZZ1'):GetStruct():SetProperty('ZZ1_COD',   MODEL_FIELD_WHEN,    FwBuildFeature(STRUCT_FEATURE_WHEN,    '.T.'))
		EndIf
	EndIf
Return lRet

/*/{Protheus.doc} zM1bPos
Função chamada no clique do botão Ok do Modelo de Dados (pós-validação)
@type function
@author Atilio
@since 03/09/2016
@version 1.0
/*/

STATIC Function ORCSIPos()
	Local oModelPad  := FWModelActive()
	Local nOpc       := oModelPad:GetOperation()
	Local lRet       := .T.

	ZV0->(DbSetOrder(1))
	ZV0->(DBSEEK(XFILIAL('ZV0')+ZV1->ZV1_CODIGO+ZV1->ZV1_REVI))
	if nOpc == MODEL_OPERATION_INSERT .and. __lCopia .AND. empty(oModelPad:GetValue('ZV0MASTER', 'ZV0_REVMOT'))
		cRevMot := FWINPUtbox('Informe o motivo de uma nova revisão',' ')

		if empty(cRevMot)
			Help( ,, 'Help',, "Para gerar nova revisão é necessário informar o motivo" , 1, 0 )
			lRet := .F.
		else
			oModelPad:SetValue('ZV0MASTER', 'ZV0_REVMOT', cRevMot)
			oModelPad:SetValue('ZV0MASTER', 'ZV0_STATUS', '0')
		endif
	elseif nopc == MODEL_OPERATION_UPDATE .AND. __lAProva
		lRet := APVOK()
		if lRet
			BEGIN TRANSACTION
				oModelPad:SetValue("ZV0MASTER", "ZV0_STATUS", 'F')

				//Inativa orçamentos anteriores

				CALIAS := GETNEXTALIAS()
				BEGINSQL ALIAS CALIAS
				SELECT * 
				FROM %TABLE:ZV1%
				WHERE ZV1_FILIAL = %XFILIAL:ZV1% AND %NOTDEL%
					AND ZV1_CODIGO = %EXP:ZV0->ZV0_CODIGO%
					AND ZV1_STATUS = 'A'
				ENDSQL

				WHILE (CALIAS)->(!EOF())

					//Monta o Update
					cQryUpd := " UPDATE " + RetSqlName("ZV1") + " "
					cQryUpd += "     SET ZV1_STATUS = 'I' "
					cQryUpd += " WHERE "
					cQryUpd += "     ZV1_FILIAL = '" + FWxFilial('ZV1') + "' "
					cQryUpd += "     AND ZV1_STATUS = 'A' AND ZV1_GRUPO = '" + (CALIAS)->ZV1_GRUPO + "' "
					cQryUpd += "     AND ZV1_LARGCR = '" + alltrim(str((CALIAS)->ZV1_LARGCR)) + "' AND ZV1_CLI = '" + (CALIAS)->ZV1_CLI + "' "
					cQryUpd += "     AND D_E_L_E_T_ = ' ' "

					//Tenta executar o update
					nErro := TcSqlExec(cQryUpd)

					//Se houve erro, mostra a mensagem e cancela a transação
					If nErro != 0
						Help( ,, 'Help',, "Erro ao Inativar orçamento. "+TcSqlError() , 1, 0 )
						DisarmTransaction()
						lRet := .F.
						exit
					EndIf

					(CALIAS)->(DBSKIP())
				ENDDO
				(CALIAS)->(DBCLOSEAREA())
			END TRANSACTION
		endif
	endif

	lRet := INCOK()
	if nopc == MODEL_OPERATION_UPDATE .and. lRet
		//Log Operação
		LOGZV0(oModelPad)
	endif

Return lRet

STATIC FUNCTION LOGZV0(oModelPad)
	Local cLog := oModelPad:getValue('ZV0MASTER', 'ZV0_LOG')
	Local wrk := JsonObject():new(), wrknovo := JsonObject():new()
	Local aLog := {}, cType := "", nPos := 0
	if EMPTY(cLog)
		cLog := '{"log": []}'
	endif
	wrk:fromJson(cLog)
	wrk:getJsonValue("log",@aLog,@cType)

	aAdd(aLog, JsonObject():new() )
	nPos := len(aLog)
	aLog[nPos]['usuario'] := cusername
	aLog[nPos]['data'] := dDatabase
	aLog[nPos]['hora'] := time()
	aLog[nPos]['alteracoes'] := aJsonLog
	wrknovo["log"] := aLog
	oModelPad:setValue('ZV0MASTER', 'ZV0_LOG', wrknovo:toJson())
RETURN


static function valPreZV0(oFieldModel, cAction, cIDField, xValue)
	Local oModelPad  := FWModelActive()
	Local nPos
	if cAction == "SETVALUE" .and. ALTERA
		aAdd(aJsonLog['ZV0'], JsonObject():new())
		nPos := len(aJsonLog['ZV0'])
		aJsonLog['ZV0'][nPos][cIdField] := JsonObject():new()
		aJsonLog['ZV0'][nPos][cIdField]['antigo'] := alltrim(cValtoChar(OMODELPAD:GETVALUE('ZV0MASTER', CIDFIELD)))
		aJsonLog['ZV0'][nPos][cIdField]['novo'] := alltrim(cValtoChar(xValue))
	endif
return .T.

Static Function linePreGrid(oGridModel, nLine, cAction, cIDField, xValue, xCurrentValue)
	Local lRet := .T.
	Local nPos
	if cAction == "SETVALUE"  .and. ALTERA
		aAdd(aJsonLog['ZV1'], JsonObject():new())
		nPos := len(aJsonLog['ZV1'])
		aJsonLog['ZV1'][nPos][cIdField] := JsonObject():new()
		aJsonLog['ZV1'][nPos][cIdField]['linha'] := nLine
		aJsonLog['ZV1'][nPos][cIdField]['antigo'] := alltrim(cValtoChar(xCurrentValue))
		aJsonLog['ZV1'][nPos][cIdField]['novo'] := alltrim(cValtoChar(xValue))
	elseif cAction == "CANSETVALUE"
		if cIDField == "ZV1_PRCPIO"
			lRet := .F.
		endif
	endif

Return lRet

Static Function linePostGrid(oGridModel, nLine)
	Local lRet := .T.
	Local cAlias := getNextAlias()
	//Local cFamilIa := FwFLdGet('ZV1_FAM')
	Local cGrupo   := FwFLdGet('ZV1_GRUPO')
	Local cCliente := FwFLdGet('ZV1_CLI')
	Local nLargCrt := FwFLdGet('ZV1_LARGCR')
	Local cCodigo  := FwFLdGet('ZV1_CODIGO')



	BeginSQL alias CALIAS
		SELECT *
		FROM %TABLE:ZV1%
		WHERE ZV1_FILIAL = %XFILIAL:ZV1% AND %NOTDEL%
		AND ZV1_GRUPO = %EXP:cGrupo% 
		AND ZV1_CLI = %EXP:cCliente% AND ZV1_LARGCR = %exp:nLargCrt%
		AND ZV1_CODIGO <> %EXP:cCodigo%
	ENDSQL

	if (calias)->(!eof())
		Help( ,, 'Help',, 'Já existe orçamento para o cliente '+cCliente+', família '+cFamilia+' e largura '+transform(nLArgCrt, "@E 999.999")+'. ('+(calias)->ZV1_CODIGO+')' , 1, 0 )
		lRet := .f.
	endif
	(calias)->(dbclosearea())

Return lRet


/*/{Protheus.doc} zM1bCom
Função chamada após validar o ok da rotina para os dados serem salvos
@type function
@author Atilio
@since 03/09/2016
@version 1.0
/*/

STATIC Function ORCSICom()
	//   Local oModelPad  := FWModelActive()
	Local lRet       := .T.
    /*
	Local cCodigo    := oModelPad:GetValue('FORMZZ1', 'ZZ1_COD')
    Local cDescri    := oModelPad:GetValue('FORMZZ1', 'ZZ1_DESC')
    Local nOpc       := oModelPad:GetOperation()
     
    //Se for Inclusão
    If nOpc == MODEL_OPERATION_INSERT
        RecLock('ZZ1', .T.)
            ZZ1_FILIAL := FWxFilial('ZZ1')
            ZZ1_COD    := cCodigo
            ZZ1_DESC   := cDescri
        ZZ1->(MsUnlock())
        ConfirmSX8()
         
        Aviso('Atenção', 'Inclusão realizada!', {'OK'}, 03)
         
    //Se for Alteração
    ElseIf nOpc == MODEL_OPERATION_UPDATE
        RecLock('ZZ1', .F.)
            ZZ1_DESC := cDescri
        ZZ1->(MsUnlock())
         
        Aviso('Atenção', 'Alteração realizada!', {'OK'}, 03)
         
    //Se for Exclusão
    ElseIf nOpc == MODEL_OPERATION_DELETE
        RecLock('ZZ1', .F.)
            DbDelete()
        ZZ1->(MsUnlock())
         
        Aviso('Atenção', 'Exclusão realizada!', {'OK'}, 03)
    EndIf
	*/
Return lRet


STATIC Function ORCSICan()
	//   Local oModelPad  := FWModelActive()
	Local lRet       := .T.

	//Somente permite cancelar se o usuário confirmar
	//lRet := MsgYesNo("Deseja cancelar a operação?", "Atenção")
Return lRet

User Function ORCSIVIS()
	ZV0->(DbSetOrder(1))
	ZV0->(DBSEEK(XFILIAL('ZV0')+ZV1->ZV1_CODIGO+ZV1->ZV1_REVI))
	FWExecView("Visualização","ORCSI_MVC",MODEL_OPERATION_VIEW,,{|| .T.})
return

User Function ORCSIALT()
	ZV0->(DbSetOrder(1))
	ZV0->(DBSEEK(XFILIAL('ZV0')+ZV1->ZV1_CODIGO+ZV1->ZV1_REVI))

	if ZV1->ZV1_STATUS <> '0'
		MsgStop('Apenas orçamentos em emissão podem ser alterados.', 'Aviso')
	ELSE
		aJsonLog := JsonObject():new()
		aJsonLog['ZV0'] := {}
		aJsonLog['ZV1'] := {}
		nRet := FWExecView("Alteração","ORCSI_MVC",MODEL_OPERATION_UPDATE,,{|| .T.})
		FREEOBJ( aJsonLog )
	ENDIF
return

User Function ORCSICPY()
	Local aArea        := GetArea()
	Local cTitulo      := "Cópia"
	Local cPrograma    := "ORCSI_MVC"
	Local nOperation   := MODEL_OPERATION_INSERT
	Local nLin         := 0
	Local nTamanGrid   := 0
	Local cAlias, cMaxRev

	ZV0->(DbSetOrder(1))
	ZV0->(DBSEEK(XFILIAL('ZV0')+ZV1->ZV1_CODIGO+ZV1->ZV1_REVI))

	cAlias := getNextAlias()
	BEGINSQL alias CALIAS
		SELECT MAX(ZV1_REVI) as rev
		FROM %TABLE:ZV1%
		WHERE ZV1_FILIAL = %XFILIAL:ZV1% AND %NOTDEL%
		AND ZV1_CODIGO = %EXP:ZV1->ZV1_CODIGO%
	ENDSQL

	cMaxRev := (calias)->rev

	(calias)->(dbclosearea())
	if ZV1->ZV1_REVI <> cMaxRev
		MsgStop('Utilize a última revisão deste orçamento ('+cMaxRev+') para gerar nova revisão. ', 'Aviso')
		return .F.
	elseif ZV1->ZV1_STATUS == '0'
		MsgStop('Não é possível gerar revisão de um orçamento em elaboração. ', 'Aviso')
		return .F.
	elseif ZV1->ZV1_STATUS == 'L'
		MsgStop('Não é possível gerar revisão de um orçamento não finalizado (Aprove ou reprove os itens). ', 'Aviso')
		return .F.
	endif
	//Caso precise testar em algum lugar
	__lCopia     := .T.

	//Carrega o modelo de dados
	oModel := FWLoadModel(cPrograma)
	oModel:SetOperation(nOperation) // Inclusão
	oModel:Activate(.T.) // Ativa o modelo com os dados posicionados

	//Setando os campos do cabeçalho
	//	oModel:SetValue("ZZ2MASTER", "ZZ2_CODCD",  cCodCd)
	oModel:SetValue("ZV0MASTER", "ZV0_REVI"  , U_ZV0REVINI())
	oModel:SetValue("ZV0MASTER", "ZV0_STATUS", '0')
	oModel:SetValue("ZV0MASTER", "ZV0_REVMOT", '')
	oModel:SetValue("ZV0MASTER", "ZV0_USRLIB", '')
	oModel:SetValue("ZV0MASTER", "ZV0_LOG", '')
	oModel:SetValue("ZV0MASTER", "ZV0_DTLIB" , stod(""))

	//Pegando os dados do filho
	oModelGrid := oModel:GetModel("ZV1DETAIL")
	oStruct    := oModelGrid:GetStruct()
	aCampos    := oStruct:GetFields()

	//Se não for P12, pega do aCols, senão pega do aDataModel
	nTamanGrid := Len(oModelGrid:aDataModel)
	oModel:GetModel('ZV1DETAIL'):GetStruct():SetProperty('ZV1_STATUS', MODEL_FIELD_WHEN 	, FwBuildFeature(STRUCT_FEATURE_WHEN    , '.T.'))
	//Zerando os campos da grid
	For nLin := 1 To nTamanGrid

		//Setando a linha atual
		oModelGrid:SetLine(nLin)
		oModel:SetValue("ZV1DETAIL", "ZV1_STATUS", "0")
		oModel:SetValue("ZV1DETAIL", "ZV1_PRCPIU", FWFldGet( "ZV1_PRCPI") )
	Next nLin
	oModelGrid:SetLine(1)
	oModel:GetModel('ZV1DETAIL'):GetStruct():SetProperty('ZV1_STATUS', MODEL_FIELD_WHEN 	, FwBuildFeature(STRUCT_FEATURE_WHEN    , '.F.'))
	oModel:GetModel('ZV0MASTER'):GetStruct():SetProperty('ZV0_STATUS', MODEL_FIELD_WHEN 	, FwBuildFeature(STRUCT_FEATURE_WHEN    , '.F.'))
	//Executando a visualização dos dados para manipulação
	nRet     := FWExecView( cTitulo , cPrograma, nOperation, /*oDlg*/, {|| .T. } ,/*bOk*/ , /*nPercReducao*/, /*aEnableButtons*/, /*bCancel*/ , /*cOperatId*/, /*cToolBar*/, oModel )
	__lCopia := .F.
	oModel:DeActivate()

	//Se a cópia for confirmada
	If nRet == 0
		MsgInfo("Revisão Criada!", "Atenção")
	EndIf

	RestArea(aArea)
RETURN

User Function ORCSIAPV()
	//Caso precise testar em algum lugar
	Local oModelPad  := FWLoadModel('ORCSI_MVC')

	ZV0->(DbSetOrder(1))
	ZV0->(DBSEEK(XFILIAL('ZV0')+ZV1->ZV1_CODIGO+ZV1->ZV1_REVI))

	if ZV1->ZV1_STATUS$'A_R'
		MsgStop('Orçamento já aprovado/reprovado. ', 'Aviso')
		return .F.
	/*elseif ZV1->ZV1_STATUS <>  'L'
		MsgStop('Não é possível aprovar um orçamento que não esteja liberado. ', 'Aviso')
		return .F.*/
	endif
	__lAprova     := .T.

	oModelPad:SetOperation(MODEL_OPERATION_UPDATE) // Inclusão
	oModelPad:Activate() // Ativa o modelo com os dados posicionados

	oModelPad:GetModel('ZV0MASTER'):GetStruct():SetProperty('*', MODEL_FIELD_WHEN 	, FwBuildFeature(STRUCT_FEATURE_WHEN    , '.F.'))
	oModelPad:GetModel('ZV1DETAIL'):GetStruct():SetProperty('*', MODEL_FIELD_WHEN 	, FwBuildFeature(STRUCT_FEATURE_WHEN    , '.F.'))
	oModelPad:GetModel('ZV1DETAIL'):GetStruct():SetProperty('ZV1_STATUS', MODEL_FIELD_WHEN 	, FwBuildFeature(STRUCT_FEATURE_WHEN    , '.T.'))
	oModelPad:GetModel('ZV0MASTER'):GetStruct():SetProperty('ZV0_STATUS', MODEL_FIELD_WHEN 	, FwBuildFeature(STRUCT_FEATURE_WHEN    , '.T.'))
	oModelPad:GetModel('ZV0MASTER'):GetStruct():SetProperty('ZV0_LOG'   , MODEL_FIELD_WHEN 	, FwBuildFeature(STRUCT_FEATURE_WHEN    , '.T.'))

	aJsonLog := JsonObject():new()
	aJsonLog['ZV0'] := {}
	aJsonLog['ZV1'] := {}

	nRet	:= FWExecView("Aprovação","ORCSI_MVC",MODEL_OPERATION_UPDATE,,{|| .T.},/*bOk*/ , /*nPercReducao*/, /*aEnableButtons*/, /*bCancel*/ , /*cOperatId*/, /*cToolBar*/, oModelPad)
	FREEOBJ( aJsonLog )
	oModelPad:DeActivate()
	__lAprova := .F.
return

Static Function INCOK()
	Local oModelPad  := FWModelActive()
	Local oModelGrid := oModelPad:GetModel("ZV1DETAIL")
	Local oStructZV1    := oModelGrid:GetStruct()
	Local nLin, nTamanGrid, lOk := .T.

	aCampos    := oStructZV1:GetFields()

	//Se não for P12, pega do aCols, senão pega do aDataModel
	nTamanGrid := Len(oModelGrid:aDataModel)


	aIndex := {}
	cIndex := ''
	//Zerando os campos da grid
	For nLin := 1 To nTamanGrid

		//Setando a linha atual
		oModelGrid:SetLine(nLin)

		cIndex := Fwfldget('ZV1_GRUPO')+Fwfldget('ZV1_CLI')+transform(Fwfldget('ZV1_LARGCR'),"@E 999.999")
		if ascan(aindex, cindex) == 0
			aAdd(aindex, cindex)
		else
			Help( ,, 'Help',, 'Item repetido no orçamento: Cliente '+Fwfldget('ZV1_CLI')+', família '+ Fwfldget('ZV1_GRUPO')+' e largura '+transform(Fwfldget('ZV1_LARGCR'), "@E 999.999")+'. ' , 1, 0 )	
			lOk := .F.
		endif

	Next nLin
	
return lOk


Static Function APVOK()
	Local oModelPad  := FWModelActive()
	Local oModelGrid := oModelPad:GetModel("ZV1DETAIL")
	Local oStructZV1    := oModelGrid:GetStruct()
	Local nLin, nTamanGrid, lOk := .T.,cStr, cMotRpv

	aCampos    := oStructZV1:GetFields()

	//Se não for P12, pega do aCols, senão pega do aDataModel
	nTamanGrid := Len(oModelGrid:aDataModel)
	aLinErro := {}
	aMotErro := {}

	oStructZV1:SetProperty('ZV1_USRAPR', MODEL_FIELD_WHEN 	, FwBuildFeature(STRUCT_FEATURE_WHEN    , '.T.'))
	oStructZV1:SetProperty('ZV1_DTAPRO', MODEL_FIELD_WHEN 	, FwBuildFeature(STRUCT_FEATURE_WHEN    , '.T.'))
	oStructZV1:SetProperty('ZV1_MOTRPV', MODEL_FIELD_WHEN 	, FwBuildFeature(STRUCT_FEATURE_WHEN    , '.T.'))

	//Zerando os campos da grid
	For nLin := 1 To nTamanGrid

		//Setando a linha atual
		oModelGrid:SetLine(nLin)

		//informando sobre orçamento aprovado ser inativado
		/*
		nLargCrt := oModelPad:getValue("ZV1DETAIL", "ZV1_LARGCR")
		cFam 	 := oModelPad:getValue("ZV1DETAIL", "ZV1_FAM")
		
		calias := getNextAlias()
		BEGINSQL alias cAlias 
			SELECT *
			FROM %TABLE:ZV1%
			WHERE ZV1_FILIAL = %XFILIAL:ZV1% AND %NOTDEL%
			AND ZV1_CODIGO = %ZV0->ZV0_CODIGO% AND ZV1_REVI = %ZV0->ZV0_REVI%
			AND ZV1_CLI = %ZV0->ZV0_CODCLI% AND ZV1_LARGCR = %nLargCrt%
			AND ZV1_FAM = %cFam% AND ZV1_STATUS = 'A'
		ENDSQL
		*/
		//if (cAlias)->(!eof())
//aviso inativar
		//endif

		if !oModelPad:getValue("ZV1DETAIL", "ZV1_STATUS")$"A_R"
			aAdd (aLinErro, oModelPad:getValue("ZV1DETAIL", "ZV1_ITEM"))
			lOk := .F.
		else
			oModelPad:SetValue("ZV1DETAIL", "ZV1_USRAPR", cUserName)
			oModelPad:SetValue("ZV1DETAIL", "ZV1_DTAPRO", dDatabase)
			cMotRpv := ''
			if oModelPad:getValue("ZV1DETAIL", "ZV1_STATUS") == "R"
				cMotRpv := FWINPUtbox('Informe o motivo da reprovação do item '+oModelPad:getValue("ZV1DETAIL", "ZV1_ITEM")+': ','')
				if Empty(cMotRpv)
					aAdd (aMotErro, oModelPad:getValue("ZV1DETAIL", "ZV1_ITEM"))
					lOk := .F.
				endif
			else
				oModelPad:SetValue("ZV1DETAIL", "ZV1_MOTRPV", cMotRpv)
			endif
		endif

	Next nLin
	if !lOk
		if len(aLinErro) > 0
			cStr := 'Necessário Informar a aprovação/reprovação do(s) item(ns) '+u_implode(', ', aLinErro)
			oModelPad:GetModel():SetErrorMessage('ZV1DETAIL', 'ZV1_STATUS' , 'ZV1DETAIL', 'ZV1_STATUS' , 'Erro', cStr, 'Aprove ou reprove os itens indicados.', /*xValue*/, /*xOldvalue*/)
		ELSEif len(aMotErro) > 0
			cStr := 'Necessário Informar a motivo da reprovação do(s) item(ns) '+u_implode(', ', aMotErro)
			oModelPad:GetModel():SetErrorMessage('ZV1DETAIL', 'ZV1_STATUS' , 'ZV1DETAIL', 'ZV1_STATUS' , 'Erro', cStr, 'Informe o motivo da reprovação.', /*xValue*/, /*xOldvalue*/)
		ENDIF
		//Help( ,, 'Help',, cStr, 1, 0 )
	else
		oModelPad:SetValue("ZV0MASTER", "ZV0_STATUS", 'F')
	endif
return lOk

static function calcpreco()
	Local nROlos 	:= FWFldGet('ZV1_NROLOS')
	Local nPrcPi 	:= FWFldGet("ZV1_PRCPI")
	//Local nLargCrt  := FWFldGet("ZV1_LARGCR")
	Local nPrcImp := 0, cEstCli, nFatIcms, nPrcLiq
	//obtendo o preco de venda em MT
	nPrcImp := nPrcpi / nRolos
	FWFldPut('ZV1_PRCIMP', nPrcImp)

/*
//obtendo o preco de venda em M2
	nPrcImpM2 := nPrcImp / ( nLargCrt / 1000 )
	FWFldPut( 'ZV1_PRIMP2', nPrcImpM2)
*/
//obtendo o preço liquido EM mt
	cEstCli := POSICIONE('SA1', 1, XFILIAL('SA1')+ZV0_CODCLI,"A1_EST")
	if cEstCli$'RS,RJ,PR,MG,SC'
		nFatIcms := 0.88
	elseif  cEstCli$'SP'
		nFatIcms := 0.82
	else
		nFatIcms := 0.93
	endif
	nPrcLiq := ( nPrcImp * nFatIcms ) *  0.9075
	FWFldPut('ZV1_PRCLIQ', nPrcLiq)
return
