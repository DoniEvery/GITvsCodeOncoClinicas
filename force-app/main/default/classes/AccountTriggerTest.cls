@isTest
public class AccountTriggerTest {
    
    @TestSetup
    public static void setup(){
        Account hospital = DataFactory.gerarOrganizacao();
        INSERT hospital;
        
        Profile perfil = [SELECT Id, Name, PermissionsModifyAllData FROM Profile WHERE Name='Concierge' LIMIT 1]; 
        User user = new User();
        user.Alias = 'standt';
        user.Email='standarduser@testorg.com';
        user.EmailEncodingKey='UTF-8';
        user.LastName='Testing';
        user.LanguageLocaleKey='pt_BR';
        user.LocaleSidKey='pt_BR';
        user.ProfileId = perfil.Id;
        user.TimeZoneSidKey='America/Argentina/Buenos_Aires';
        user.UserName='testeonco@teste.com';
        user.Praca_usuario__c='SÃO PAULO';
        user.IsActive=true;
        insert user;
        
    }
    
    @isTest    
    public static void testarExclusaoConta(){
        User usuarioConcierge = [SELECT Id, IsActive FROM User WHERE Profile.Name = 'Concierge' AND IsActive=TRUE LIMIT 1];
        
        Test.startTest();
        System.runAs(usuarioConcierge) {
            Account conta = [SELECT Id FROM Account LIMIT 1];
            try{
                delete conta;    
            }catch (Exception ex){
                system.debug(ex.getMessage());
            }
        }
        
        Test.stopTest();
        
    }
    
    @isTest 
    public static void testaIntegracao(){
        Account paciente = DataFactory.gerarPaciente();
        paciente.CNPJ__c ='13369327406';
        paciente.CPF__pc ='13369327406';
        paciente.CRM_UF_CART__c ='99999AM';
        paciente.KeyTasy__c = '123qwe';
        insert paciente;
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new IntegracaoTasyServiceMock(200, 200));
        
        paciente.PersonEmail = 'teste@teste.com.br';
        paciente.PersonMobilePhone = '11941414141';
        paciente.IntegrarTasy__c = true;     
        update paciente;
        Test.stopTest();
    }
    
}