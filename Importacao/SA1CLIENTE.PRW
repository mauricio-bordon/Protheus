//Bibliotecas
#Include "TOTVS.ch"
#Include "TopConn.ch"
#Include "RPTDef.ch"
#Include "FWPrintSetup.ch"
#Include "FWMVCDEF.ch"

//Posições do Array
Static nA1_LOJA   :=1
Static nA1_COD :=2
Static nA1_NOME :=3
Static nA1_CGC :=4
Static nA1_INSCR :=5
Static nA1_EMAIL :=6
Static nA1_TEL :=7
Static nA1_NREDUZ :=8
Static nA1_TIPO :=9
Static nA1_END :=10
Static nA1_BAIRRO :=11
Static nA1_EST :=12
Static nA1_MUN :=13
Static nA1_CEP :=14
Static nA1_ENDCOB :=15
Static nA1_CEPC :=16
Static nA1_MUNC :=17
Static nA1_ESTC :=18
Static nA1_ENDENT :=19
Static nA1_BAIRROE :=20
Static nA1_CEPE :=21
Static nA1_MUNE :=22
Static nA1_ESTE :=23


User Function zImpSA1()
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
    Local aSA1Auto  := {}
    Local aAI0Auto  := {}
  Local nOpcAuto  := MODEL_OPERATION_INSERT
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
                    aSA1Auto  := {}
                    aAI0Auto  := {}
                //Incrementa na tela a mensagem
                nLinhaAtu++
                IncProc("Analisando linha " + cValToChar(nLinhaAtu) + " de " + cValToChar(nTotLinhas) + "...")
                 
                //Pegando a linha atual e transformando em array
                cLinAtu := oArquivo:GetLine()
                aLinha  := StrTokArr(cLinAtu, "#")
                 
                    cA1_LOJA := alltrim(aLinha[nA1_LOJA])   
                    //cA1_COD:= alltrim(aLinha[nA1_COD])
                    cA1_COD:= GetSXENum("SA1","A1_COD")
                    cA1_NOME:= alltrim(aLinha[nA1_NOME])
                    cA1_CGC:= alltrim(aLinha[nA1_CGC])
                    cA1_INSCR:= alltrim(aLinha[nA1_INSCR])
                    cA1_INSCR:= StrTran(cA1_INSCR, ".", "")
                    cA1_INSCR:= StrTran(cA1_INSCR, "-", "")

                    cA1_EMAIL:= alltrim(aLinha[nA1_EMAIL])
                    cA1_TEL:= alltrim(aLinha[nA1_TEL])
                    cA1_NREDUZ:= alltrim(aLinha[nA1_NREDUZ])
                    cA1_TIPO:= alltrim(aLinha[nA1_TIPO])
                    cA1_END:= alltrim(aLinha[nA1_END])
                    cA1_BAIRRO:= alltrim(aLinha[nA1_BAIRRO])
                    cA1_EST:= alltrim(aLinha[nA1_EST])
                    cA1_MUN:= alltrim(aLinha[nA1_MUN])
                    cA1_CEP:= alltrim(aLinha[nA1_CEP])
                    cA1_ENDCOB:= alltrim(aLinha[nA1_ENDCOB])
                    cA1_CEPC:= alltrim(aLinha[nA1_CEPC])
                    cA1_MUNC:= alltrim(aLinha[nA1_MUNC])
                    cA1_ESTC:= alltrim(aLinha[nA1_ESTC])
                    cA1_ENDENT:= alltrim(aLinha[nA1_ENDENT])
                    cA1_BAIRROE:= alltrim(aLinha[nA1_BAIRROE])
                    cA1_CEPE:= alltrim(aLinha[nA1_CEPE])
                    cA1_MUNE:= alltrim(aLinha[nA1_MUNE])
                    cA1_ESTE:= alltrim(aLinha[nA1_ESTE])

 //----------------------------------
    // Dados do Cliente
    //----------------------------------

              aAdd(aSA1Auto,{"A1_LOJA"     ,"01"       ,Nil})   
              aAdd(aSA1Auto,{"A1_COD"     ,cA1_COD       ,Nil})
              aAdd(aSA1Auto,{"A1_NOME"     ,cA1_NOME       ,Nil})
              aAdd(aSA1Auto,{"A1_CGC"     ,cA1_CGC       ,Nil})
              //aAdd(aSA1Auto,{"A1_INSCR"     ,cA1_INSCR       ,Nil})
              aAdd(aSA1Auto,{"A1_EMAIL"     ,cA1_EMAIL       ,Nil})
              aAdd(aSA1Auto,{"A1_TEL"     ,cA1_TEL       ,Nil})
              aAdd(aSA1Auto,{"A1_NREDUZ"     ,cA1_NREDUZ       ,Nil})
              aAdd(aSA1Auto,{"A1_TIPO"     ,cA1_TIPO       ,Nil})
              aAdd(aSA1Auto,{"A1_END"     ,cA1_END       ,Nil})
              aAdd(aSA1Auto,{"A1_BAIRRO"     ,cA1_BAIRRO       ,Nil})
              aAdd(aSA1Auto,{"A1_EST"     ,cA1_EST       ,Nil})
              aAdd(aSA1Auto,{"A1_MUN"     ,cA1_MUN       ,Nil})
              aAdd(aSA1Auto,{"A1_CEP"     ,cA1_CEP       ,Nil})
              aAdd(aSA1Auto,{"A1_ENDCOB"     ,cA1_ENDCOB       ,Nil})
              aAdd(aSA1Auto,{"A1_CEPC"     ,cA1_CEPC       ,Nil})
              aAdd(aSA1Auto,{"A1_MUNC"     ,cA1_MUNC       ,Nil})
              aAdd(aSA1Auto,{"A1_ESTC"     ,cA1_ESTC       ,Nil})
              aAdd(aSA1Auto,{"A1_ENDENT"     ,cA1_ENDENT       ,Nil})
              aAdd(aSA1Auto,{"A1_BAIRROE"     ,cA1_BAIRROE       ,Nil})
              aAdd(aSA1Auto,{"A1_CEPE"     ,cA1_CEPE       ,Nil})
              aAdd(aSA1Auto,{"A1_MUNE"     ,cA1_MUNE       ,Nil})
              aAdd(aSA1Auto,{"A1_ESTE"     ,cA1_ESTE       ,Nil})


    // Dados do Complemento do Cliente
    //---------------------------------------------------------
    aAdd(aAI0Auto,{"AI0_SALDO"  ,0                     ,Nil})
     
    //------------------------------------
    // Chamada para cadastrar o cliente.
    //------------------------------------
    MSExecAuto({|a,b,c| CRMA980(a,b,c)}, aSA1Auto, nOpcAuto, aAI0Auto)
    //MSExecAuto({|a,b,c| CRMA980(a,b,c)}, aSA1Auto, MODEL_OPERATION_INSERT, aAI0Auto)

    If lMsErroAuto  
        lRet := lMsErroAuto
        cLog += "+ Lin" + cValToChar(nLinhaAtu) + ", ERRO ->" + cA1_NOME +  CRLF
        ROLLBACKSXE()
    Else
         cLog += "+ Lin" + cValToChar(nLinhaAtu) + ", Cliente Ok ->" + cA1_NOME +  CRLF
         CONFIRMSXE()


    EndIf 
                    
                 
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
