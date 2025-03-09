#include 'protheus.ch'
#include "restful.ch"
#include 'rwmake.ch'
#Include "tbiconn.ch"

#define QUEBRA_LINHA chr(10)

wsrestful TrfNfEnt description "Transf NF Entrada"
	WSMETHOD post ws1;
		DESCRIPTION "Transfere material após entrada NF" ;
		wssyntax "/TrfNfEnt/v1/transfere";
		PATH "/TrfNfEnt/v1/transfere"

end wsrestful

wsmethod post ws1 wsservice TrfNfEnt
	Local cBody := ::getContent()
	Local lRet := .F.
	Local oJsonRet

	oJsonRet := transferir(cBody)

	//self:SetContentType("application/json")
	self:setStatus(200)
	::SetResponse(oJsonRet)

	conout("Resposta enviada")

	if oJsonRet['success']
		lRet := .T.
	endif

	FreeObj(oJsonRet)

	//RESET ENVIRONMENT

return lRet

user function tstTrf()
	Local cBody
	Local oJsonRet

	cBody := '{"PLANILHA":{"1":{"A":"SL","B":"ROLL NO","C":"TYPE","D":"THICK","E":"WIDTH","F":"CORE","G":"LENGTH","H":"WEIGHT","I":"BOX NO","J":"PROD. CODE"},"2":{"A":1,"B":"2303528836","C":"HSCO","D":"23.0","E":"675MM","F":6,"G":"9000MTR","H":9999,"I":"0003194393","J":"MP001009000011 "},"3":{"A":2,"B":"2303528837","C":"HSCO","D":"23.0","E":"675MM","F":6,"G":"9000MTR","H":7874,"I":"0003194393","J":"MP001009000011 "}},"NF":"000796","SERIE":"1","CODFOR":"000040","LOJAFOR":"01", "NTRANSF":2, "LOCALIZ":"R03B05N1A"}'

	oJsonRet := transferir(cBody)

	conout(oJsonRet['code'])
	conout(oJsonRet['detailedMessage'])

	FreeObj(oJsonRet)

	//RESET ENVIRONMENT

return

static function transferir(cBody)
	Local oJsonPost := JsonObject():new()
	Local oJsonPlan, oJsonCols //dados da planilha
	Local cNF, cSerie, cCodFor, cLojaFor, nTransf, cLocaliz //dados da requisição
	Local aLinha := {}, aLinhas := {} //dados para execblk
	Local aNota, aHeadNF, aRowsNF, aRowNF, aRowsPlan //dados da NF de entrada
	Local cD3_COD, cLoteForn, nD3_QUANT, cItem, nCountProd //dados da planilha
	Local cNextLote
	Local nLinhas, nI, nJ, nPosFld
	Local bError //tratamento de erro

	private cError := '', lError := .F.

	// variável de controle interno da rotina automatica que informa se houve erro durante o processamento
	Private lMsErroAuto := .F.

	// força a gravação das informações de erro em array para manipulação da gravação ao invés de gravar direto no arquivo temporário
	//necessário para usar GetAutoGRLog
	private lAutoErrNoFile := .T.

	//salvando o bloco de erro do sistema e atribuindo tratamento personalizado
	bError := ErrorBlock( { |oError| TrataErro( oError ) } )

	PREPARE ENVIRONMENT EMPRESA "01" FILIAL "01" MODULO "EST"

	BEGIN SEQUENCE

		conout("POST TrfNfEnt!")
		conout('------------------------')
		conout(cBody)
		conout('------------------------')

		oJsonPost:FromJson(cBody)

		oJsonPlan := oJsonPost['PLANILHA']

		cNF := oJsonPost['NF']
		cSerie := oJsonPost['SERIE']
		cCodFor := oJsonPost['CODFOR']
		cLojaFor := oJsonPost['LOJAFOR']
		cLocaliz := oJsonPost['LOCALIZ']
		nTransf := oJsonPost['NTRANSF']

		conout(;
			'NF ' + cNF +;
			' SERIE: ' + cSerie +;
			' CODFOR: ' + cCodFor +;
			' LOJAFOR: ' + cLojaFor +;
			' LOCALIZ: ' + cLocaliz +;
			' NTRANSF: ' + cValToChar(nTransf);
			)

		FreeObj(oJsonPost)

		aRowsPlan := oJsonPlan:GetNames();

		nLinhas := len(aRowsPlan)

		aNota := getNfEntr(cNF, cSerie, cCodFor, cLojaFor)
		aHeadNF := aNota[1]
		aRowsNF := aNota[2]

		if len(aRowsNF) == 0
			lError := .T.
			cError := "Nota nao encontrada ou transferencia ja realizada."
			break
		endif

		cItem := "00"

		for nI := 2 to nLinhas //Pula a primeira linha que é o cabeçalho da planilha
			oJsonCols := oJsonPlan[aRowsPlan[nI]]

			cD3_COD := AllTrim(cValToChar(oJsonCols['A']))
			cLoteForn := AllTrim(cValToChar(oJsonCols['B']))
			nD3_QUANT := oJsonCols['C']
			cItem := prxItem(cItem)

			nPosFld := aScan(aHeadNF, "B1_COD")

			nCountProd := 0
			For nJ := 1 To len(aRowsNF)
				if Alltrim(aRowsNF[nJ][nPosFld]) == Alltrim(cD3_COD)
					aRowNF := aRowsNF[nJ]
					nCountProd := nCountProd + 1
				endif
			Next nJ

			if nCountProd == 0
				lError := .T.
				cError := "Produto da planilha nao encontrado na NF."
				break
			endif

			if nCountProd > 1
				lError := .T.
				cError := "Produto da planilha encontrado em mais de uma linha na NF."
				break
			endif

			aLinha := {}

			//Origem
			aadd(aLinha, {"ITEM", cItem, Nil})
			aadd(aLinha, {"D3_COD", fldVal(aHeadNF, aRowNF, 'B1_COD'), Nil}) //Cod Produto origem
			aadd(aLinha, {"D3_DESCRI", fldVal(aHeadNF, aRowNF, 'B1_DESC'), Nil}) //descr produto origem
			aadd(aLinha, {"D3_UM", fldVal(aHeadNF, aRowNF, 'B1_UM'), Nil}) //unidade medida origem
			aadd(aLinha, {"D3_LOCAL", fldVal(aHeadNF, aRowNF, 'B8_LOCAL'), Nil}) //armazem origem
			aadd(aLinha, {"D3_LOCALIZ", PadR(cLocaliz, tamsx3('D3_LOCALIZ') [1]), Nil}) //Informar endereço origem

			//Destino
			aadd(aLinha, {"D3_COD", fldVal(aHeadNF, aRowNF, 'B1_COD'), Nil}) //cod produto destino
			aadd(aLinha, {"D3_DESCRI", fldVal(aHeadNF, aRowNF, 'B1_DESC'), Nil}) //descr produto destino
			aadd(aLinha, {"D3_UM", fldVal(aHeadNF, aRowNF, 'B1_UM'), Nil}) //unidade medida destino
			aadd(aLinha, {"D3_LOCAL", fldVal(aHeadNF, aRowNF, 'B8_LOCAL'), Nil}) //armazem destino
			aadd(aLinha, {"D3_LOCALIZ", PadR(cLocaliz, tamsx3('D3_LOCALIZ') [1]), Nil}) //Informar endereço destino

			aadd(aLinha, {"D3_NUMSERI", "", Nil}) //Numero serie

			/*
			Transferência 1:
				- Origem = Lote único informado na entrada
				- Destino = Lote do fornecedor conforme a planilha
			Transferência 2:
				- Origem = Lote do fornecedor conforme a planilha
				- Destino = Lote sequencial gerado
			*/

			//Lote Origem
			if nTransf == 1
				aadd(aLinha, {"D3_LOTECTL", fldVal(aHeadNF, aRowNF, 'B8_LOTECTL'), Nil}) //lote único usado na entrada
			else
				aadd(aLinha, {"D3_LOTECTL", PadR(cLoteForn, tamsx3('D3_LOTECTL') [1]), Nil}) //Lote do fornecedor
			endif

			aadd(aLinha, {"D3_NUMLOTE", "", Nil}) //sublote origem
			aadd(aLinha, {"D3_DTVALID", stod(fldVal(aHeadNF, aRowNF, 'B8_DTVALID')), Nil}) //data validade
			aadd(aLinha, {"D3_POTENCI", 0, Nil}) // Potencia
			aadd(aLinha, {"D3_QUANT", nD3_QUANT, Nil}) //Quantidade
			aadd(aLinha, {"D3_QTSEGUM", 0, Nil}) //Seg unidade medida
			aadd(aLinha, {"D3_ESTORNO", "", Nil}) //Estorno
			aadd(aLinha, {"D3_NUMSEQ", "", Nil}) // Numero sequencia D3_NUMSEQ

			//Lote destino
			if nTransf == 1
				aadd(aLinha, {"D3_LOTECTL", PadR(cLoteForn, tamsx3('D3_LOTECTL') [1]), Nil}) //Lote do fornecedor

			else
				if empty(cNextLote)
					cNextLote := u_prxLotNF(getmv("IC_LOTSEQM"))
				else
					cNextLote := u_prxLotNF(cNextLote)
				endif

				aadd(aLinha, {"D3_LOTECTL", PadR(cNextLote, tamsx3('D3_LOTECTL') [1]), Nil}) //Lote sequencial gerado

			endif

			aadd(aLinha, {"D3_NUMLOTE", "", Nil}) //sublote destino
			aadd(aLinha, {"D3_DTVALID", stod(fldVal(aHeadNF, aRowNF, 'B8_DTVALID')), Nil}) //validade lote destino
			aadd(aLinha, {"D3_ITEMGRD", "", Nil}) //Item Grade

			aadd(aLinha, {"D3_CODLAN", "", Nil}) //cat83 prod origem
			aadd(aLinha, {"D3_CODLAN", "", Nil}) //cat83 prod destino

			aAdd(aLinhas, aLinha)

		Next nI

		FreeObj(oJsonPlan)

		//Define um ponto de recuperação, dentro do bloco de sequência, para o qual o fluxo de execução será desviado após a execução de um comando BREAK
		RECOVER

		// Fecha todas as áreas de trabalho
		DBCloseAll()

	END SEQUENCE

	//Restaurando bloco de erro do sistema
	ErrorBlock( bError )

return execBlk(aLinhas, cNextLote, nTransf)

static function execBlk(aLinhas, cNextLote, nTransf)
	Local aAuto := {} //Cabecalho e itens
	Local nOpcAuto := 3 // Inclusao
	Local cDocSD3 := ""
	Local cMsg := ''
	Local nI
	Local oJsonRet

	if !lError

		//Cabecalho
		cDocSD3 := GetSxeNum("SD3", "D3_DOC")
		aadd(aAuto, {cDocSD3, dDataBase})

		//Itens
		for nI := 1 to len(aLinhas)
			aadd(aAuto, aLinhas[nI])
		Next nI

		conout('--- MSExecAuto ---')
		conout('Etapa ' + cValToChar(nTransf))
		conout(VarInfo("aAuto", aAuto, , .F.))

		BEGIN TRANSACTION

			MSExecAuto({|x,y| mata261(x,y)}, aAuto, nOpcAuto)

			If lMsErroAuto
				RollbackSX8()
				lError := .T.
				DisarmTransaction()
			else
				ConfirmSX8()
				if nTransf == 2
					putmv("IC_LOTSEQM", cNextLote)
				endif
			endif

		END TRANSACTION

	endif

	If lError
		If lMsErroAuto //erro do execauto
			aLog := GetAutoGRLog()
			For nI := 1 To Len(aLog)
				If !Empty(aLog[nI])
					cMsg += aLog[nI]
					cMsg += QUEBRA_LINHA
				endif
			Next
			cMsg := Alltrim(cMsg)
		else //erro capturado pelo manipulador ou tratado no programa
			cMsg += cError
		endif
		conout(cMsg)
	endif

    oJsonRet := JsonObject():new()

	if lError
		oJsonRet['success'] := .F.
		oJsonRet['message'] := 'Erro ao executar a transferencia.'
		oJsonRet['detailedMessage'] := ENCODEUTF8(cMsg)
	else
		oJsonRet['success'] := .T.
		oJsonRet['message'] := 'Numero do documento da transferencia: ' + cDocSD3
		oJsonRet['detailedMessage'] := ' '
	endif

	conout("Finalizada a rotina de transferência")

return oJsonRet

static function fldVal(aHeadNF, aRowNF, cField)
	Local nPosFld := aScan(aHeadNF, cField)

return aRowNF[nPosFld]

/*
ùltima sequencia de lotes
*/
static function getNfEntr(cNF, cSerie, cCodFor, cLojaFor)
	Local cAlias := getNextAlias()
	Local aArray := {}
	Local aRowsNF := {}
	Local aHeadNF := {}
	Local nI

	BeginSql Alias cAlias

	SELECT B1_COD,
		B1_DESC,
		B1_UM,
		D1_QUANT,
		B8_LOCAL,
		B8_SALDO,
		B8_LOTECTL,
		B8_DTVALID
	FROM SD1010 SD1
		INNER JOIN SB1010 SB1 ON B1_FILIAL = %XFILIAL:SB1%
		AND B1_COD = D1_COD
		AND SB1.D_E_L_E_T_ = ' '
		INNER JOIN SB8010 SB8 ON B8_FILIAL = D1_FILIAL
		AND B8_PRODUTO = D1_COD
		AND B8_LOCAL = '02'
		AND B8_LOTECTL = D1_LOTECTL
		AND SB8.D_E_L_E_T_ = ' '
	WHERE D1_FILIAL = %XFILIAL:SD1%
		AND D1_DOC = %EXP:cNF%
		AND D1_SERIE = %EXP:cSerie%
		AND D1_FORNECE = %EXP:cCodFor%
		AND D1_LOJA = %EXP:cLojaFor%
		AND SD1.D_E_L_E_T_ = ' '

	EndSql

	u_dbg_qry()

	if !(cAlias)->(Eof())
		for nI := 1 to (cAlias)->(FCount())
			AAdd(aHeadNF, (cAlias)->(FieldName(nI)))
		next
	endif


	While !(cAlias)->(Eof())
		aArray := {}

		for nI := 1 to (cAlias)->(FCount())
			AAdd(aArray, (cAlias)->(FieldGet(nI)) )
		next

		AAdd(aRowsNF, aArray)

		(cAlias)->(dbSkip())

	Enddo

	(cAlias)->(DbCloseArea())

return {aHeadNF, aRowsNF}

/*
Explanation:

Function ProximoItem(cItem): Defines a function named ProximoItem that accepts the current item (cItem) as a string parameter. It's crucial that the input cItem follows the base36 format (0-9 and A-Z).

Local nItem := Val(cItem): Converts the input string cItem (which is in base36) into its numeric equivalent. ADVPL's VAL() function handles base36 just fine if you stick to the standard encoding (0-9, A-Z).

nItem++: Increments the numeric value of nItem to get the next item's numeric representation.

cProximoItem := Alltrim(StrZero(Int(nItem/36),1)) + Chr(iif(mod(nItem,36) <= 9, mod(nItem,36) + 48, mod(nItem,36) + 87 )): This is where the base36 conversion back to a string happens. It's broken down as follows:

Int(nItem/36): Gets the integer part of the division by 36 (this will represent the "tens" digit in base36, although it could also be A, B, C... etc.)
StrZero(...,1): Converts the integer part to a string, padding with a leading zero if necessary, ensuring it's always one character. Important for cases like "0A", "0B", etc.
Alltrim(...): Removes any leading or trailing spaces. Although probably not strictly necessary here, it's a good habit.
mod(nItem,36): Gets the remainder of the division by 36, representing the "units" digit in base36.
iif(mod(nItem,36) <= 9, mod(nItem,36) + 48, mod(nItem,36) + 87 ): Checks if the remainder is less than or equal to 9. If so, it adds 48 (ASCII for '0') to it, resulting in the ASCII for the digit. If greater than 9, it adds 87 (ASCII for 'A' - 10) which gives us the correct ASCII value for the letters A-Z.
Chr(...): Converts the calculated ASCII value back to its character representation.
+: Concatenates the "tens" digit and the "units" digit to form the final base36 string.
Return cProximoItem: Returns the next item as a base36 string.
*/
static Function prxItem(cItem)
	Local nItem := Val(cItem)
	Local cProximoItem := ""

	nItem++

	cProximoItem := Alltrim(StrZero(Int(nItem/36),1)) + Chr(iif(mod(nItem,36) <= 9, mod(nItem,36) + 48, mod(nItem,36) + 87 ))

return cProximoItem

/***
Tratamento de erro dentro de BEGIN SEQUENCE, END SEQUENCE
***/
Static Function TrataErro(oError)
	lError := .T.
	cError := oError:Description

	//conout(oError:Description)
	//conout(oError:ErrorStack)

	break
return

/*
user function tstJs()

Local str := '{"PLANILHA":{"1":{"A":"C2_NUM","B":"C2_ITEM","C":"C2_SEQUEN"},"2":{"A":"000001","B":"01","C":"001"},"3":{"A":"000002","B":"01","C":"001"},"4":{"A":"000003","B":"01","C":"001"}}}'

Local oJsonPost := JsonObject():new()
Local oJson
Local oJsonCols
Local aRowsPlan
Local nLinhas
Local nI

oJsonPost:FromJson(str)

oJson := oJsonPost['PLANILHA']

aRowsPlan := oJson:GetNames()

nLinhas := len(aRowsPlan)

for nI := 1 to nLinhas
	oJsonCols := oJson[aRowsPlan[nI]]
	conout(oJsonCols['A'])
	conout(oJsonCols['B'])
	conout(oJsonCols['C'])
next nI

return
*/
