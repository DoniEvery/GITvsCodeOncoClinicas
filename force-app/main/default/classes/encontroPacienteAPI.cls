@RestResource(urlMapping='/timelineEncontro')
global class encontroPacienteAPI {

    @HttpPost 
    global static encontroPacienteController.responseEncontro getEncontro() {
        RestRequest request = RestContext.request;
        RestResponse response = RestContext.response;
        
        String paciente = request.requestBody.toString();
        
        // Chama o método que agora retorna uma lista de encontroPacienteController.responseEncontro
        encontroPacienteController.responseEncontro getEncontroResponse = encontroPacienteController.getEncontro(paciente);
        
        // Serializa a lista para JSON antes de retornar
       // String jsonResponse = JSON.serialize(getEncontroResponse);
        
        return getEncontroResponse;
    } 
}