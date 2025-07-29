@isTest
global class WppMensagemContatoIntegracaoMock implements HttpCalloutMock{

    global HttpResponse respond(HttpRequest req){
        HttpResponse res = new HttpResponse();

        if(req.getEndpoint().endsWith('http.msging.net/commands')){
            res.setHeader('Authorization', 'Key 123456=');
            res.setHeader('Accept', 'application/json');
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"status":"success", "resource": {"alternativeAccount":"1223345676","identity":"5599999999"}}');
            res.setStatusCode(200);

        }else if(req.getEndpoint().endsWith('http.msging.net/messages')){
            res.setHeader('Authorization', 'Key 123456=');
            res.setHeader('Accept', 'application/json');
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(202);
        
        }else if(req.getEndpoint().endsWith('//msging.net/commands')){
            res.setHeader('Authorization', 'Key 123456=');
            res.setHeader('Accept', 'application/json');
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"status":"success"}');
            res.setStatusCode(200);

        }

        return res;
    }

}