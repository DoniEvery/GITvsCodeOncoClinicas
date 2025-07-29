@isTest
global class MarketingCloudServiceMock implements HttpCalloutMock{
    private Integer statusTokenMock;
    private Integer statusEnvioMock;
    
    global MarketingCloudServiceMock(Integer statusToken, Integer statusEnvio){
        this.statusTokenMock = statusToken;
        this.statusEnvioMock = statusEnvio;
    }
    
    global HttpResponse respond(HttpRequest req){
        HttpResponse res = new HttpResponse();
        if(req.getEndpoint().endsWith('marketingcloudapis.com/v2/token')){
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"access_token":"eyJhbGciOiJIUzI1NiIsImtpZCI6IjQiLCJ2ZXIiOiIxIiwidHlwIjoiSldUIn0.eyJhY2Nlc3NfdG9rZW4iOiJZRjlPb0x3WWR0NlpmYjY0ZTlJdjdBNWciLCJjbGllbnRfaWQiOiJkaXByd3B5M2d6dG15cWl2OGRybXlyeHEiLCJlaWQiOjUxNDAxMzg3OSwic3RhY2tfa2V5IjoiUzExIiwicGxhdGZvcm1fdmVyc2lvbiI6MiwiY2xpZW50X3R5cGUiOiJTZXJ2ZXJUb1NlcnZlciIsInBpZCI6MzAxfQ.WhAr9Pyvrwmm3O-v4RCsIuWDD4613oCSLRQa6I0-J5k.SxDKHErLcwAMYPweSzLJmNvVDIYIpB5kCngoIUlDp8FVlfxpB-p-PF2Z79gnbjrPirwgBPPV7qbxZhLRolG3ybk7yLY1YJDwV9ApbrVGPJs-WZaMI6LNgKdVd6DYrZoL4SUf7KaEmSorL60jrH_xqyl2k0i7KqUWbUgP4","token_type":"Bearer","expires_in":1079,"scope":"offline email_read email_send data_extensions_read data_extensions_write","soap_instance_url":"https://mc4khcg43vb92vcd4gx555c9rqv1.soap.marketingcloudapis.com/","rest_instance_url":"https://mc4khcg43vb92vcd4gx555c9rqv1.rest.marketingcloudapis.com/"}}');
            res.setStatusCode(this.statusTokenMock);
        }else if(req.getEndpoint().endsWith('messaging/v1/messageDefinitionSends/key:VALTECHDEVTRIGGERED/send')){
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"requestId":"c68be9ca-c5d8-4a07-8b45-8bd03e274741","responses":[{"recipientSendId":"","hasErrors":false,"messages":["queued"]}]}}');
            res.setStatusCode(this.statusEnvioMock);
        }else if(req.getEndpoint().endsWith('Service.asmx')){
            res.setHeader('Content-Type', 'application/json');
            StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name = 'testMarketingCloudRetrieveXml' LIMIT 1];
            res.setBody(sr.Body.toString());
            res.setStatusCode(this.statusEnvioMock);
        }
        return res;
    }
    
}