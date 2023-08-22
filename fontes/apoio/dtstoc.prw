user function DTSTOC(cStr)
    Local cRet := '', cAno, cmes, cDia

    cStr := alltrim(cStr)
    cAno := left(cStr,4)
    cDia := right(cStr,2)
    cMes := substr(cStr,5,2)

    cret := cDia+'/'+cMes+'/'+cAno
return cRet
