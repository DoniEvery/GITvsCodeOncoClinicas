public class APP_ApiIdentificacaoClienteService {

    private static Account conta;
       
    public static void identificarOuCriarPessoa(APP_ApiIdentificacaoClienteDTO entrada) {
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint('Callout:APPTasy');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');          
        req.setBody(JSON.serialize(entrada)); 
        req.setTimeout(120000); 
        
        Http http = new Http();
        HttpResponse res;
        
        try {
            res = http.send(req);
            if (res.getStatusCode() == 200 || res.getStatusCode() == 201) {
                APP_ApiIdentificacaoClienteRespostaDTO resposta =  (APP_ApiIdentificacaoClienteRespostaDTO) JSON.deserialize(res.getBody(), APP_ApiIdentificacaoClienteRespostaDTO.class);
                atualizaIdPlusoftFuture(String.valueOf(conta.Id), String.valueOf(resposta.id_person));
                // atualizaIdPlusoft(String.valueOf(resposta.id_person));
             
            } else {
                APP_Logger.logErro(req.getEndpoint(), res.getStatusCode(), 'Erro ao identificar pessoa no Tasy', res.getBody());
            }
        } catch (Exception e) {
            APP_Logger.logErro(req.getEndpoint(), res.getStatusCode(), 'Erro ao identificar pessoa no Tasy', res.getBody());
           
        }
    }    
   

     public static String validaIdPlusoft() {
        User usr = [SELECT Id, Account.CNPJ__c, Account.APP_Id_Plusoft__c, AccountId FROM User WHERE Id=: UserInfo.getUserId()];

        if (String.isBlank(usr.Account.APP_Id_Plusoft__c)) {
            String cnpj = !Test.isRunningTest() ? usr.Account.CNPJ__c : '35027036809';
            conta = new Account ( Id = usr.AccountId, CNPJ__c = usr.Account.CNPJ__c, APP_Id_Plusoft__c ='');
            return cnpj;
        }else{
            return null;
        }        
    }

    @future(callout=false)
    private static void atualizaIdPlusoftFuture(String accountId, String idPlusoft) {
        try {
            conta = new Account(Id = accountId);
            APP_ApiIdentificacaoClienteService.atualizaIdPlusoft(idPlusoft);
        } catch (Exception e) {
            System.debug('Erro ao atualizar ID Plusoft: ' + e.getMessage());
            // opcional: registrar no objeto Log__c
        }
    }
   
    private static void atualizaIdPlusoft(String idPlussoft) {
        
        try {
            conta.APP_Id_Plusoft__c = idPlussoft;
            update conta;       
        } catch (Exception e) {
            System.debug('error '+ e.getMessage());
        
        }
    }
}