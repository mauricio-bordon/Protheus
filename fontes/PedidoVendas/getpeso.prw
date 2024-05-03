
//Bibliotecas
#Include 'RwMake.ch'
#Include 'Protheus.ch'

user function getpeso()
	local i,cLote,nPesol:=0,nPesob:=0,nPallet:=0
	Local cAlias

//ACOLS[i][17] --- item liberado
// ACOLS[i][40] --- lote do produto 00057302 00595

	for i:=1 to len(ACOLS)
	
		if ACOLS[i][17]>0 .AND. !Empty(ACOLS[i][40])
		cAlias := getNextalias()
	
			//Alert("Lote "+ACOLS[i][40])
			cLote:=ACOLS[i][40]

			BeginSql alias CALIAS
			
		SELECT COUNT(ZD2_PALLET) PALLET,SUM(ZD2_PESOLI) PESOL,SUM(ZD2_PESOBR) PESOB 
		FROM %TABLE:ZD2% ZD2
		WHERE ZD2.D_E_L_E_T_<>'*'
		AND ZD2_OP=(SELECT DISTINCT ZD3_OP FROM %TABLE:ZD3% WHERE D_E_L_E_T_<>'*' AND ZD3_LOTE=%EXP:cLote% )

			ENDSQL

			while (calias)->(!eof())
				nPesol+=(calias)->PESOL
				nPesob+=(calias)->PESOB
				nPallet+=(calias)->PALLET
				(calias)->(DBSKIP())
			enddo


		endif

	next

	M->C5_VOLUME1:=nPallet
	M->C5_PBRUTO:=nPesob
	M->C5_PESOL:=nPesol
	M->C5_ESPECI1:="PALLET"
 

return
