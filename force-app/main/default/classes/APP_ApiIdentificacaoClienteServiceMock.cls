@isTest
global class APP_ApiIdentificacaoClienteServiceMock implements HttpCalloutMock{
    
    public static Boolean IsError { get; set; }
    
    public APP_ApiIdentificacaoClienteServiceMock(Boolean error){
        IsError = error;      
    }
    
    global HttpResponse respond(HttpRequest req){
        
        String responseBody = '';     
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type','application/json');
        res.setBody(responseBody);
        
        if(IsError){
            responseBody = '{"message": "Pessoa não localizada para o CPF."}';
            res.setStatusCode(400);
        }else{
            res.setBody('{"id_person":1015967,"ds_person":"Gabriela Borges","ds_docnumber2":"35027036809","dt_born":"2023-03-21 00:00:00","ds_emailprincipal":"gabriela.borges@oncoclinicas.com","ds_emailalternativo":null,"ds_ddicel":"55","ds_dddcel":"21","ds_numcel":"999999999"}');
            res.setStatusCode(200);
        }  
        
        
        
        return res;
    }
}