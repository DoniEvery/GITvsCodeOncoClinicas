@isTest
global class IntegracaoTasyServiceMock implements HttpCalloutMock{
    private Integer statusTokenMock;
    private Integer statusEnvioMock;
    
    global IntegracaoTasyServiceMock(Integer statusToken, Integer statusEnvio){
        this.statusTokenMock = statusToken;
        this.statusEnvioMock = statusEnvio;
    }
    
    global HttpResponse respond(HttpRequest req){
        HttpResponse res = new HttpResponse();
        if(req.getEndpoint().endsWith('patient/oauth2/authorize')){
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"redirect_uri":"https://synapse-dev.oncoclinicas.com.br:8443/service#access_token=8KbF9asc99JAV0ygjeVNAGN8kHIfuPxU&expires_in=7200&token_type=bearer"}');
            res.setStatusCode(this.statusTokenMock);
        }else if(req.getEndpoint().endsWith('/v1/patient')){
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"createdId":"1349560"}');
            res.setStatusCode(this.statusEnvioMock);
        }
        return res;
    }
    
}