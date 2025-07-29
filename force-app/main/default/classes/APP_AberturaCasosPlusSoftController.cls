public class APP_AberturaCasosPlusSoftController {
   
    @InvocableMethod(label='criar caso no plusSoft' description='criar caso no plusSoft')
    public static List<CasosPlusSoftWrapperOutput> criarCaso(List<CasosPlusSoftWrapperInput> inputs) {       
        
        List<CasosPlusSoftWrapperOutput> lstOutputs = new List<CasosPlusSoftWrapperOutput>();
        CasosPlusSoftWrapperOutput output = new CasosPlusSoftWrapperOutput();
        APP_AberturaCasosPlusSoftDTO dto = new APP_AberturaCasosPlusSoftDTO(inputs[0].idPlusoft, inputs[0].motivo);
        output.resultado = APP_AberturaCasosPlusSoftService.criarCasoPlusSoft(dto);  
        lstOutputs.add(output);
        return lstOutputs; 
        
    }

    public class CasosPlusSoftWrapperInput {
     
        @InvocableVariable(required=true)
        public String idPlusoft;

        @InvocableVariable()
        public String motivo;
    }

    public class CasosPlusSoftWrapperOutput {
        @InvocableVariable
        public String resultado;
    }
}