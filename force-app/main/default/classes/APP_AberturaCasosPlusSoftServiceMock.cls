@isTest
global class APP_AberturaCasosPlusSoftServiceMock implements HttpCalloutMock{
    
    public static Boolean IsError { get; set; }
    
    public APP_AberturaCasosPlusSoftServiceMock(Boolean error){
        IsError = error;      
    }
    
    global HttpResponse respond(HttpRequest req){
        
        String responseBody = '';     
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type','application/json');
        res.setBody(responseBody);
        
        if(IsError){
            responseBody = '{"message": "Forma de contato não encontrada. Registro não realizado."}';
            res.setStatusCode(400);
        }else{
            res.setBody('{"personid":1015967,"protocolo":"20250723000437"}');
            res.setStatusCode(200);
        }  
        
        
        
        return res;
    }
}