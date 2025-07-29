@isTest
public class CampaignMemberTriggerHandlerTest {
    private static final Id recordTypeIdSchema = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
    
    @testSetup
    static void MakeData(){

        Account conta =  new Account();
        conta.RecordTypeId = recordTypeIdSchema;
        conta.FirstName = 'Teste';
        conta.lastName = 'Conta';
        conta.PersonAssistantPhone = '1231243532342';
        conta.logIntegracaoVerificacaoWhatsApp__c = '';
        conta.CNPJ__c = '68086898229';
        conta.StatusVerificacaoWhatsApp__c = '';
        conta.UltimaIntegracaoBlip__c =  null;
        
        insert conta;
        
        Campaign campanha = new Campaign();
        campanha.name = 'Cuidados paliativos';
        campanha.Type = 'Outros';
        campanha.Status = 'In Progress';
        campanha.IntegraBlip__c = true;
        
        campanha.IsActive = true;
        insert campanha;
     
        
    }
    @isTest
    static void verificarTelefoneTest(){
        Campaign campanha = [SELECT Id FROM Campaign LIMIT 1];
        Contact contato = [SELECT Id FROM Contact LIMIT 1];
        
        VerificarTelefoneEntity.Reason rs = new VerificarTelefoneEntity.Reason();
        rs.code = '83';
        rs.description = 'Could not determine the contact username';
        
        VerificarTelefoneEntity.Retorno retorno = new VerificarTelefoneEntity.Retorno();
        retorno.status = 'success';
        retorno.reason = rs;
        
        CampaignMember membroCampanha = new CampaignMember();
        membroCampanha.CampaignId = campanha.id;
        membroCampanha.ContactId = contato.id;
        insert membroCampanha;
        
        try{
            Test.setMock(HttpCalloutMock.class, new MockHttpResponse(JSON.serialize(null), 200, 'OK'));
            Database.executeBatch(new BlipIntegrationBatch());
        }
        catch(Exception e){
            System.debug(e.getMessage());
        }
        
        try{
            Test.setMock(HttpCalloutMock.class, new MockHttpResponse(JSON.serialize(retorno), 200, 'OK'));
            Database.executeBatch(new BlipIntegrationBatch());
        }
        catch(Exception e){
            System.debug(e.getMessage());
        }
    }
    /*@isTest
    static void verificarTelefoneTestFail(){
        Campaign campanha = [SELECT Id FROM Campaign LIMIT 1];
        
        
        VerificarTelefoneEntity.Reason rs = new VerificarTelefoneEntity.Reason();
        rs.code = '83';
        rs.description = 'Could not determine the contact username';
        
        VerificarTelefoneEntity.Retorno retorno = new VerificarTelefoneEntity.Retorno();
        retorno.status = 'success';
        retorno.reason = rs;
        
        Account conta =  new Account();
        conta.RecordTypeId = recordTypeIdSchema;
        conta.FirstName = 'Teste Teste1';
        conta.lastName = 'Teste Teste1';
        conta.PersonAssistantPhone = '12345678953';
        conta.logIntegracaoVerificacaoWhatsApp__c = '';
        conta.CNPJ__c = '34462183860';
        conta.StatusVerificacaoWhatsApp__c = 'Success';
        conta.UltimaIntegracaoBlip__c =  DateTime.now();
        insert conta;
        Contact contato = [SELECT Id FROM Contact WHERE AccountId =:conta.Id LIMIT 1];
        
        
        CampaignMember membroCampanha = new CampaignMember();
        membroCampanha.CampaignId = campanha.id;
        membroCampanha.ContactId = contato.id;
        
        insert membroCampanha;
        
        
        
            
    }*/
    @isTest
    static void ValidaSchedule(){
        BlipIntegrationSchedule reminder = new BlipIntegrationSchedule();
        // Seconds Minutes Hours Day_of_month Month Day_of_week optional_year
        String sch = '20 30 8 10 2 ?';
        String jobID = System.schedule('TestBlipIntegrationSchedule', sch, reminder);
    
    }
}