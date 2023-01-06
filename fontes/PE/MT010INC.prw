#include "rwmake.ch"
#include "ap5mail.ch"
#include "TopConn.ch"
#include "TbiCode.ch"
#include "TbiConn.ch"

User function MT010INC()
Local l_ret:= .T.

//Classifica
u_b1fiscal()
//ajusta data de validade 
if SB1->B1_TIPO == "PA" 
		If SB1->(RecLock('SB1',.F.))
			SB1->B1_PRVALID:=365
            
			SB1->(MSUnlock())
		endif
	endif

/*
Local c_email
Local c_login
//Local l_fiscal
Local cemail
Local a_email
Local c_auxusr,afiles,arecebe,a_mens
Local lClasFisOk := .F., i

_area := {alias(),indexord(),recno()}

If SB1->B1_TIPO$'PA' .and. SB1->B1_GRUPO == "5000"
	//Classifica
	u_clsB1lbl()
	//grava associação cliente x produto no Itxerp
	u_ItxCliProd()
elseIf SB1->B1_TIPO == 'PA' .and. SB1->B1_GRUPO$"5001_6000"
		//Classifica
		u_clsb1flx()
ElseIf SB1->B1_TIPO $ ("|AD|MP|MN|MS|SL|ME|MM|PM|AT|SR|MG|MC|M3|RS|ML|MT|TT|PI|UN|MD|OI") .Or. Substr(SB1->B1_COD,1,6)  $ ( "PI0070_PI0020_PI0030")
	//Classificacao Automatica
	u_clsB1()
ElseIf SB1->B1_TIPO $ ALLTRIM(GETMV('FX_TPFLEXI'))
	//Classificacao Automatica
	u_clsB1Flx()
else
	_area := {alias(),indexord(),recno()}
Endif

If SB1->B1_FISOK == 'S'
	lClasFisOk := .T.
Endif

If EMPTY(SB1->B1_DESCCOM)
	If SB1->(RecLock('SB1',.F.))     
		SB1->B1_DESCCOM := SB1->B1_DESC
		SB1->(MSUnlock())
	endif
Endif

//Adiciona data validade produto em dias


//todo
// se produto novo nordisk 730 dias
// ???? 
//chamado #6176
if alltrim(SB1->B1_TIPO)$"PA_PI" .and. alltrim(SB1->B1_GRUPO)$"5000_5001"
	if empty(SB1->B1_PRVALID)
		If SB1->(RecLock('SB1',.F.))
			if SB1->B1_CLIENTE$'L00176_L00303_L00304'
				SB1->B1_PRVALID:=730
			ELSE
				SB1->B1_PRVALID:=365
			ENDIF
			SB1->(MSUnlock())
		endif
	endif
elseif SB1->B1_TIPO$"LD_SI_ET_FP_PA" 
	if empty(SB1->B1_PRVALID)
		If SB1->(RecLock('SB1',.F.))
			SB1->B1_PRVALID:=365
			SB1->(MSUnlock())
		endif
	endif
endif

l_ret:=.T.

c_email:=alltrim(getmv("MV_SB1EMAI"))
c_fiscal:=alltrim(getmv("MV_SB1FIS"))

c_login:=alltrim(upper(cUserName))

cemail:=U_veremail()

a_email:={}

If ! empty(cemail)
	aadd(a_email,cemail)
Endif

c_auxusr:=""
For i:=1 to len(c_email)
	If subs(c_email,i,1) <> "_"
		c_auxusr:=c_auxusr + subs(c_email,i,1)
	Endif
	
	If subs(c_email,i,1) == "_" .or. I==len(c_email)
		If !empty(c_auxusr)
			daduser:={}
			nomeuser:=padr(c_auxusr,15)
			psworder(2)
			cemail:=""
			if pswseek(nomeuser,.t.)
				daduser:=pswret(1)
				cemail:=daduser[1,14]
			endif
			aadd(a_email,cemail)
			c_auxusr:=""
		Endif
	Endif
Next

afiles:={}

arecebe:=a_email
c_emp:="Flexcoat"

If !lClasFisOk
	a_mens:={"            ",;
	"            ",;
	"Empresa     :  "+c_emp,;
	"            ",;
	"            ",;
	"Produto     :  "+sb1->b1_cod,;
	"Descricao   :  "+sb1->b1_desc,;
	"Incluido em :  "+dtoc(ddatabase)+ " "+time(),;
	"Por         :  "+c_login,;
	"             ",;
	"             ",;
	"             ",;
	"Responsaveis pelo fiscal:  "+c_fiscal,;
	"                           cadastrados no parametro MV_SB1FIS",;
	"             ",;
	"             ",;
	"Movimentacao do produto bloqueada enquanto nao liberado pelo Fiscal: ",;
	"Internos / Transferencias / Solicitacao de Compras / Pedido de compras ",;
	"Entrada e Saida de NF / Inventario !",;
	"             ",;
	"             ",;
	"Favor providenciarem a liberacao fiscal desse produto !"}
Else
	a_mens:={"            ",;
	"            ",;
	"Empresa     :  "+c_emp,;
	"            ",;
	"            ",;
	"Produto     :  "+sb1->b1_cod,;
	"Descricao   :  "+sb1->b1_desc,;
	"Incluido em :  "+dtoc(ddatabase)+ " "+time(),;
	"Por         :  "+c_login,;
	"             ",;
	"             ",;
	"             ",;
	"Responsaveis pelo fiscal:  "+c_fiscal,;
	"                           cadastrados no parametro MV_SB1FIS",;
	"             ",;
	"             ",;
	"Classificação Automatica",;
	"             ",;
	"TES Entrada	: "+Alltrim(SB1->B1_TE),;
	"TES Saída		: "+Alltrim(SB1->B1_TS),;
	"Lib. Fiscal	: "+IIf(Alltrim(SB1->B1_FISOK)=="S", "Sim","Não"),;
	"C. de Custo	: "+Alltrim(SB1->B1_CC),;
	"Perc. COFINS	: "+Alltrim(Str(SB1->B1_PCOFINS)),;
	"Perc. PIS		: "+Alltrim(Str(SB1->B1_PPIS)),;
    "Perc. ICM		: "+Alltrim(Str(SB1->B1_PICM)),;
	"Conta Contabil	: "+Alltrim(SB1->B1_CONTA),;
	"IPI			: "+Alltrim(Str(SB1->B1_IPI)),;
	"NCM			: "+Alltrim(SB1->B1_POSIPI ),;
	"Class. Prod.	: "+Alltrim(SB1->B1_CLASPRD),;
	"Custeio OP		: "+Alltrim(SB1->B1_AGREGCU),;		
	"             ",;
	"             ",;
	"Favor verifique a necessidade de aletrações no cadastro fiscal desse produto !"}
	
Endif


if !empty(alltrim(getmv("MV_MODTST")))
	arecebe:={alltrim(getmv("MV_MODTST"))}
endif
//U_SndEmail(a_mens,afiles,arecebe)

	dbSelectArea(_area[1])
	dbSetOrder(_area[2])
	dbGoto(_area[3])

    */
Return(l_ret)
