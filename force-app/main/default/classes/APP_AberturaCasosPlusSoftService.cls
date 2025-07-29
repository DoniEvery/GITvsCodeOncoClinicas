public class APP_AberturaCasosPlusSoftService {
    private static Account conta;
       
    public static String criarCasoPlusSoft(APP_AberturaCasosPlusSoftDTO entrada) {
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint('Callout:APPPLusSoft');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');          
        req.setBody(JSON.serialize(entrada)); 
        req.setTimeout(120000); 
        
        Http http = new Http();
        HttpResponse res;
        String response ='';
        
        try {
            res = http.send(req);
            if (res.getStatusCode() == 200 || res.getStatusCode() == 201) {
                APP_AberturaCasosPlusSoftRespostaDTO resposta =  (APP_AberturaCasosPlusSoftRespostaDTO) JSON.deserialize(res.getBody(), APP_AberturaCasosPlusSoftRespostaDTO.class);
               
                response = 'Caso criado com sucesso';
             
            } else {
                response = 'Erro de integração';
                APP_Logger.logErro(req.getEndpoint(), res.getStatusCode(), 'Erro ao criar caso no PlusSoft', res.getBody());
            }
        } catch (Exception e) {
            response = 'Erro de integração';
            APP_Logger.logErro(req.getEndpoint(), res.getStatusCode(), e.getMessage(), res.getBody());
           
        }

        return response;
    }
        
}