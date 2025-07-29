global with sharing class EnviaEmailAlternativoMktBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.stateful{
 
    set<String> setCasosEmailAlt;
    MarketingCloudAcesso__mdt mktData;

    global EnviaEmailAlternativoMktBatch(set<String> setCasosId){
        this.setCasosEmailAlt = setCasosId;
    }
    global Database.QueryLocator start(Database.BatchableContext context) {
        this.mktData = MarketingCloudAcesso__mdt.getInstance('Marketing_Cloud');
        return Database.getQueryLocator('SELECT Id, EmailAlternativo__c, AccountId, Account.FirstName, Protocolo__c, EnvioProtocoloEmailAlternativo__c FROM Case WHERE Id IN :setCasosEmailAlt');
    }

    global void execute(Database.BatchableContext context, List<Case> scope) {
        List<Case> listaCasosUpdate = new List<Case>();

        String bodyToken = 'grant_type=client_credentials&client_secret=' + this.mktData.client_Secret__c + '&client_id=' + this.mktData.Client_Id__c;
		MarketingCloudService mktService = new MarketingCloudService();
        for(Case caso : scope){
            try{
                //Buscar Token
                MarketingCloudServiceUtils.responseToken responseToken =  mktService.buscarToken();
                
                if(responseToken.statusCode == 200){
                    String body = montarJsonRequest(caso);
                    
                    //Envia para Integração
                    MarketingCloudServiceUtils.responseEmailAlt resp = mktService.insereEmailAlternativoExtension(responseToken.rest_instance_url, responseToken.access_token, body);

                    if(String.isBlank(resp.mensagemErro)){
                        if(resp.statusCode == 202){
                            caso.RetornoEmailAlternativoMKT__c = 'Integrado com Sucesso: ' + System.today().format();
                            caso.Envio_MKT_Cloud_RequestId__c = resp.requestId;
                        }else{
                            caso.RetornoEmailAlternativoMKT__c = Json.serialize(resp.responses);
                        }
                    }else{
                        caso.RetornoEmailAlternativoMKT__c = 'Erro API: ' + resp.mensagemErro;
                    }
                    caso.EnvioProtocoloEmailAlternativo__c = false;
                    listaCasosUpdate.add(caso);
                }else{
                    //Erro token de acesso.
                    caso.RetornoEmailAlternativoMKT__c = 'Erro API buscar o token: ' + (!String.isblank(responseToken.error) 
                                                        ? responseToken.error + '\n' + responseToken.error_description
                                                        : 'Ocorreu um erro Interno na API');

                    caso.EnvioProtocoloEmailAlternativo__c = false;
                }
            }catch(Exception e){
                //Erro interno Salesforce
                caso.RetornoEmailAlternativoMKT__c = 'Erro Interno Salesforce: \n' + e.getMessage();
                caso.EnvioProtocoloEmailAlternativo__c = false;
                listaCasosUpdate.add(caso);
            }
        }
        if(!listaCasosUpdate.isEmpty()) Database.update(listaCasosUpdate, false);
    }

    global void finish(Database.BatchableContext context) {}


    private static String montarJsonRequest(Case caso){
        MarketingCloudServiceUtils.RequestBody req = new MarketingCloudServiceUtils.RequestBody();
        MarketingCloudServiceUtils.To to = new MarketingCloudServiceUtils.To();
        to.Address = caso.EmailAlternativo__c;
        to.SubscriberKey = caso.EmailAlternativo__c;
        
        MarketingCloudServiceUtils.ContactAtt cont = new MarketingCloudServiceUtils.ContactAtt();
        MarketingCloudServiceUtils.Subscriber sub = new MarketingCloudServiceUtils.Subscriber();
        sub.PrimeiroNome = caso.Account.FirstName;
        sub.NumeroProtocolo = caso.Protocolo__c;
        sub.dataEnvio = System.now().format('MM-dd-YYYY H:mm');
        cont.SubscriberAttributes = sub;
        to.ContactAttributes = cont;
        req.To = to;

        return Json.serialize(req);
    }

}