#INCLUDE "totvs.ch"
 
/*/{Protheus.doc} User Function NFG713GRV
    Realiza grava��es complementares durante a execu��o do job de transmiss�o dos boletos
    registrados online (API), na chamada do PE as tabelas envolvidas no processo estar�o posicionadas
    (SE1, SEA, SA6, SEE e etc...) Caso haja a necessidade de mexer no posicionamento das tabelas lembre-se de utilizar
    o FwGetArea e FwRestArea, garantindo assim a integridade do job
    @type  Function
    @author Totvs
    @since 26/07/2023
    @version 1.0
    @see https://tdn.totvs.com/pages/viewpage.action?pageId=780009506
/*/
User Function NFG713GRV()
    Local aArea := FwGetArea()
 
    If SEA->EA_TRANSF == 'F' //Boleto n�o foi transmitido
        /*
            Realizar grava��es complementares
        */
  //      RecLock("SE1", .F.)
   //         SE1->E1_XPTO = "Boleto n�o foi transmitido"
   //     SE1->(MsUnLock())
    Else
        /*
            Realizar grava��es complementares
        */
    //    RecLock("SE1", .F.)
   //         SE1->E1_XPTO = "Boleto transmitido"
   //     SE1->(MsUnLock())
    Endif
 
    FwRestArea(aArea)
Return
