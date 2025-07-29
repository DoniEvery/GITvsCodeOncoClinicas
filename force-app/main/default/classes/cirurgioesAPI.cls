@RestResource(urlMapping='/encaminhamentoCirurgioes')
global class cirurgioesAPI {

    @HttpPost
    global static void createEncaminhamentoCase(){
    	RestRequest request = RestContext.request;
        RestResponse response = RestContext.response;
        
        String dadosMedicoPaciente = request.requestBody.toString();
        
        List<cirurgioesController.ResponseEncaminhamento> responseEncaminhamento = cirurgioesController.createCase(dadosMedicoPaciente);
        
        
        response.responseBody = Blob.valueOf(JSON.serialize(responseEncaminhamento));
    }        
}