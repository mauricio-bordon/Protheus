//validacao do campo d4_LOTECTL para permitir somente fifo
user function vldFifo()
	Local lRet:=.T.
	Local cLoteFifo:=""
	IF FUNNAME() == "MATA381" .AND. !isblind() .and. cUserName!='angela.vieira'

		cLoteFifo:=getFifo(M->D4_LOTECTL)

		IF M->D4_LOTECTL!=cLoteFifo
			Alert("Lote escolhido fora do FIFO. Lote do FIFO é "+cLoteFifo)
			lRet:=.F.
		ENDIF

	ENDIF




return lRet


static function getfifo(clote)
	local cloteFifo:=""
	local cAliasf
	local aArea:=GetArea()

	cAliasf := getNextAlias()

	BEGINSQL alias cAliasf
        SELECT TOP 1 B8_LOTECTL
        FROM %TABLE:SB8%
        WHERE  B8_FILIAL = %XFILIAL:SB8% AND %NOTDEL%
        AND B8_SALDO>0
        AND B8_PRODUTO = (SELECT TOP 1 B8_PRODUTO FROM %TABLE:SB8% WHERE %NOTDEL% AND B8_LOTECTL=%EXP:clote% )
		AND B8_LOTECTL NOT IN (SELECT DD_LOTECTL FROM %TABLE:SDD% WHERE %NOTDEL% AND DD_PRODUTO=B8_PRODUTO AND DD_QUANT>0)
        ORDER BY B8_DTVALID,B8_LOTECTL
	ENDSQL

	aDados := GetLastQuery()

	if (cAliasf)->(!eof())
		cloteFifo:=(cAliasf)->B8_LOTECTL
	ENDIF
	(cAliasf)->(DBCLOSEAREA())


	restArea(aArea)

return cloteFifo
