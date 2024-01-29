#include "rwmake.ch"
#include "ap5mail.ch"
#include "TopConn.ch"
#include "TbiConn.ch"

User Function DIASUTEIS( c_Data, n_novosdias )     
  	conout("Data: "+c_Data)
	If c_Data <> NIL             
	    
		d_DataUtil := stod(c_Data) 	       
		c_dia := CDOW( d_DataUtil )
		n_dias := 0
		
		IF n_novosdias == 0
		 	WHILE c_dia == 'Saturday' .OR. c_dia == 'Sunday' .OR. U_FERIADO(c_Data)   
		 		n_dias += 1
		    	c_dia := CDOW(d_DataUtil + n_dias)
		    	c_data := dtos(d_DataUtil + n_dias)
		    ENDDO    
		else     
			n_x := 0
			WHILE n_x <> n_novosdias				
				
				n_dias += 1
			    c_dia := CDOW(d_DataUtil + n_dias)   
			   	c_data := dtos(d_DataUtil + n_dias)  
			    n_x += 1
				
				WHILE c_dia == 'Saturday' .OR. c_dia == 'Sunday' .OR. U_FERIADO(c_Data)   
			 		n_dias += 1
			    	c_dia := CDOW(d_DataUtil + n_dias)   
			   		c_data := dtos(d_DataUtil + n_dias)      
			   		
			    ENDDO  
			    
			ENDDO
		
		End
		
		
   		c_DataUtil := dtos(d_DataUtil + n_dias) 	 
	
	endIf
		
return c_DataUtil
