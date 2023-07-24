User function dbg_qry(cMsg)
    //Pega as informa??es da ?ltima query
    Local aDados := GetLastQuery()
    
    if empty(cmsg)
        cmsg := ''
    ENDIF
    //Mostra mensagem com todas as informa??es capturadas
    cMensagem := "* -- DBG_QRY --" + cmsg
    cMensagem += "* cAlias - " + aDados[1] + Chr(13) + Chr(10)
    cMensagem += "* cQuery: " + Chr(13) + Chr(10) + aDados[2] + Chr(13) + Chr(10)
    cMensagem += "* -- END --"
    conout(cMensagem)
return 
