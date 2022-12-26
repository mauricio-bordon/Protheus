#include "topconn.ch"
#include "rwmake.ch"

USER FUNCTION PRXLOTE()
	Local cLotectl := ''
	Local nSeqOp, nSeqDia
	conout('prxlote')

	if FWISINCALLSTACK('mata103') // Entrada de materiais (Exemplo: MP)
		//consulta na sd1 se houve entrada hoje
		cAlias := getnextalias()

		BeginSql alias CALIAS
            SELECT *
            FROM %TABLE:SD1%
            WHERE D1_FILIAL = %XFILIAL:SD1% AND %NOTDEL%
            AND D1_DTDIGIT = %exp:dtos(ddatabase)%
		EndSql
		if (CALIAS)->(EOF()) //Nenhuma entrada, zera sequencial diário
			nSeqDia := 0
		else
			nSeqDia := getmv("IC_LOTSEQM") //existe entrada, obtem sequencia do dia
		endif
		(CALIAS)->(DBCLOSEAREA())
		nSeqDia++
		cLotectl := dtos(ddatabase)+'M'+strzero(nSeqDia,3)
		putmv("IC_LOTSEQM", nSeqDia)
	elseif FWISINCALLSTACK('mata250') // Produção Simples
		IF M->D3_TIPO == 'PA'
			cLotectl := left(M->D3_OP,8)
		ELSEIF M->D3_TIPO == 'PI'

			cAlias := getnextalias()

			BeginSql alias CALIAS
                SELECT MAX(D3_LOTECTL) AS LOTEMAX
                FROM %TABLE:SD3%
                WHERE D3_FILIAL = %XFILIAL:SD3% AND %NOTDEL%
                AND D3_OP = %exp:M->D3_OP% 
                AND D3_CF = 'PR0'
                AND D3_ESTORNO <> 'S'
			EndSql
			if (CALIAS)->(EOF())
				nSeqOp := 0
			else
				nSeqOp := VAL( SUBSTR((CALIAS)->LOTEMAX,12,3) )
			endif
			(CALIAS)->(DBCLOSEAREA())
			nSeqOp++
			cLotectl := alltrim(M->D3_OP) + STRZERO(nSeqOp, 3)
		ENDIF
	elseif  FWISINCALLSTACK('mata681') //Produção Modelo 2

		cAlias := getnextalias()

		BeginSql alias CALIAS
                SELECT MAX(D3_LOTECTL) AS LOTEMAX
                FROM %TABLE:SD3%
                WHERE D3_FILIAL = %XFILIAL:SD3% AND %NOTDEL%
                AND D3_OP = %exp:SH6->H6_OP% 
                AND D3_CF = 'PR0'
                AND D3_ESTORNO <> 'S'
		EndSql
		if (CALIAS)->(EOF())
			nSeqOp := 0
		else
			nSeqOp := VAL( SUBSTR((CALIAS)->LOTEMAX,12,3) )
		endif
		(CALIAS)->(DBCLOSEAREA())
		nSeqOp++
		cLotectl := alltrim(SH6->H6_OP) +  STRZERO(nSeqOp, 3)

	endif
return cLotectl
