#INCLUDE "totvs.ch"
 
/*/{Protheus.doc} User Function NFG713GRV
    Realiza gravações complementares durante a execução do job de transmissão dos boletos
    registrados online (API), na chamada do PE as tabelas envolvidas no processo estarão posicionadas
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
 
    If SEA->EA_TRANSF == 'F' //Boleto não foi transmitido
        /*
            Realizar gravações complementares
        */
  //      RecLock("SE1", .F.)
   //         SE1->E1_XPTO = "Boleto não foi transmitido"
   //     SE1->(MsUnLock())
    Else
        /*
            Realizar gravações complementares
        */
    //    RecLock("SE1", .F.)
   //         SE1->E1_XPTO = "Boleto transmitido"
   //     SE1->(MsUnLock())
    Endif
 
    FwRestArea(aArea)
Return
