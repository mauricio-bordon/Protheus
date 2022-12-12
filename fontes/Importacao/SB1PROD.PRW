//Bibliotecas
#Include "TOTVS.ch"
#Include "TopConn.ch"
#Include "RPTDef.ch"
#Include "FWPrintSetup.ch"
#Include "FWMVCDEF.ch"

//Posições do Array
Static nErr:=1
Static nB1_COD:=2
Static nB1_DESC:=3
Static nB1_TIPO:=4
Static nB1_UM:=5
Static nB1_LOCPA:=6
Static nB1_GRUPO:=7
Static nB1_RASTRO:=8
Static nB1_LARGURA:=9
Static nB1_CODOLD:=10

User Function zImpSB1()
	Local aArea     := GetArea()
	Private cArqOri := ""


	//Mostra o Prompt para selecionar arquivos
	cArqOri := tFileDialog( "CSV files (*.csv) ", 'Seleção de Arquivos', , , .F., )

	//Se tiver o arquivo de origem
	If ! Empty(cArqOri)

		//Somente se existir o arquivo e for com a extensão CSV
		If File(cArqOri) .And. Upper(SubStr(cArqOri, RAt('.', cArqOri) + 1, 3)) == 'CSV'
			Processa({|| fImporta() }, "Importando...")
		Else
			MsgStop("Arquivo e/ou extensão inválida!", "Atenção")
		EndIf
	EndIf

	RestArea(aArea)
Return

/*-------------------------------------------------------------------------------*
 | Func:  fImporta                                                               |
 | Desc:  Função que importa os dados                                            |
 *-------------------------------------------------------------------------------*/
 
Static Function fImporta()
    Local aArea      := GetArea()
    Local cArqLog    := "zImpCSV_" + dToS(Date()) + "_" + StrTran(Time(), ':', '-') + ".log"
    Local nTotLinhas := 0
    Local cLinAtu    := ""
    Local nLinhaAtu  := 0
    Local aLinha     := {}
    Local oArquivo
    Local aLinhas
    Local aVetor  := {}
    Local lRet      := .T.

    Private cDirLog    := GetTempPath() + "x_importacao\"
    Private cLog       := ""
    Private lMsErroAuto := .F. 
    //Se a pasta de log não existir, cria ela
    If ! ExistDir(cDirLog)
        MakeDir(cDirLog)
    EndIf
 
    //Definindo o arquivo a ser lido
    oArquivo := FWFileReader():New(cArqOri)
     
    //Se o arquivo pode ser aberto
    If (oArquivo:Open())
 
        //Se não for fim do arquivo
        If ! (oArquivo:EoF())
 
            //Definindo o tamanho da régua
            aLinhas := oArquivo:GetAllLines()
            nTotLinhas := Len(aLinhas)
            ProcRegua(nTotLinhas)
             
            //Método GoTop não funciona (dependendo da versão da LIB), deve fechar e abrir novamente o arquivo
            oArquivo:Close()
            oArquivo := FWFileReader():New(cArqOri)
            oArquivo:Open()
 
            //Enquanto tiver linhas
            While (oArquivo:HasLine())
                    aVetor  := {}
                    lMsErroAuto := .F. 
                //Incrementa na tela a mensagem
                nLinhaAtu++
                IncProc("Analisando linha " + cValToChar(nLinhaAtu) + " de " + cValToChar(nTotLinhas) + "...")
                 
                //Pegando a linha atual e transformando em array
                cLinAtu := oArquivo:GetLine()
                aLinha  := StrTokArr(cLinAtu, "#")
                 

                cB1_COD:=alltrim(aLinha[nB1_COD])   
                cB1_DESC:=alltrim(aLinha[nB1_DESC])   
                cB1_TIPO:=alltrim(aLinha[nB1_TIPO])   
                cB1_UM:=alltrim(aLinha[nB1_UM])   
                cB1_LOCPA:=alltrim(aLinha[nB1_LOCPA])   
                cB1_GRUPO:=alltrim(aLinha[nB1_GRUPO])   
                cB1_RASTRO:=alltrim(aLinha[nB1_RASTRO])   
                cB1_LARGURA:=val(aLinha[nB1_LARGURA])
                cB1_CODOLD:=alltrim(aLinha[nB1_CODOLD])   
  //----------------------------------
    // Dados do Produto 
    //----------------------------------
    
aVetor:= {		 {"B1_COD"     	,cB1_COD	    	,Nil},; 
                 {"B1_CODOLD"   ,cB1_CODOLD    	,Nil},; 
   				 {"B1_DESC"    	,cB1_DESC 			,Nil},; 
   				 {"B1_TIPO"    	,cB1_TIPO   		,Nil},; 
				 {"B1_UM"      	,cB1_UM       		,Nil},; 
                 {"B1_LOCPAD"  	,cB1_LOCPA        	,Nil},;
                 {"B1_GRUPO"   	,cB1_GRUPO       	,Nil},; 
                 {"B1_RASTRO"  	,cB1_RASTRO		   	,Nil},;
                 {"B1_LARGURA" 	,cB1_LARGURA	   	,Nil}}

conout("Antes Execauto mata010")				 
MSExecAuto({|x,y| Mata010(x,y)},aVetor,3) //Inclusao

If lMsErroAuto
	conout("ERRO Cadastro produto "+cB1_COD)      
	lRet := lMsErroAuto
    cLog += "+ Lin" + cValToChar(nLinhaAtu) + ", ERRO ->" + cB1_COD +  CRLF
    ctitulo:="Erro na execucao do AUTO010."
	cmsg:="Verificar no SIGAADV o log "+NomeAutoLog()+CHR(13)
	conout(cMsg)
	
else
     cLog += "+ Lin" + cValToChar(nLinhaAtu) + ", Cliente Ok ->" + cB1_COD +  CRLF
    
Endif  

                
                 
            EndDo
 
            //Se tiver log, mostra ele
            If ! Empty(cLog)
                cLog := "Processamento finalizado, abaixo as mensagens de log: " + CRLF + cLog
                MemoWrite(cDirLog + cArqLog, cLog)
                ShellExecute("OPEN", cArqLog, "", cDirLog, 1)
            EndIf
 
        Else
            MsgStop("Arquivo não tem conteúdo!", "Atenção")
        EndIf
 
        //Fecha o arquivo
        oArquivo:Close()
    Else
        MsgStop("Arquivo não pode ser aberto!", "Atenção")
    EndIf
 
    RestArea(aArea)
Return
