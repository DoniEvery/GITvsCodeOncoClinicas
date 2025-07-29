@isTest
public class ContactTriggersTest {
    @testSetup
    public static void setup(){
        Account hospital = DataFactory.gerarOrganizacao();
        INSERT hospital;
        
        Contact medico = DataFactory.gerarMedico(hospital.Id);
        medico.Tipo_de_Medico__c = 'Especialista Medico';
        medico.DNA__c = 'Conquista';
        medico.DNAAnoAnterior__c = 'Conquista';
        medico.DnaAnoAnteriorCompleto__c = 'Conquista';
        insert medico; 
        
        Contact medicoClinico = DataFactory.gerarMedico(hospital.Id);
        medicoClinico.Tipo_de_Medico__c = 'Corpo Clinico - Clinicas';
        medicoClinico.Especialidade_que_Atua__c = 'RADIOTERAPIA';
        medicoClinico.DNA__c = 'Conquista';
        medicoClinico.DNAAnoAnterior__c = 'Conquista';
        medicoClinico.DnaAnoAnteriorCompleto__c = 'Conquista';
        insert medicoClinico;
        
        Profile perfil = [SELECT Id, Name FROM Profile WHERE Name='Concierge' LIMIT 1]; 
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
    public static void testarTrigger(){
        test.startTest();   
        Contact medicoAtt = [SELECT id, DNA__c, DNAAnoAnterior__c, DnaAnoAnteriorCompleto__c FROM Contact WHERE Tipo_de_Medico__c = 'Especialista Medico' LIMIT 1];
        Contact medicoClinicoAtt = [SELECT id, DNA__c, DNAAnoAnterior__c, DnaAnoAnteriorCompleto__c FROM Contact WHERE Tipo_de_Medico__c = 'Corpo Clinico - Clinicas' LIMIT 1];
        system.assertEquals('Conquista', medicoAtt.DNA__c);
        system.assertEquals('Conquista', medicoAtt.DNAAnoAnterior__c);
        system.assertEquals('Conquista', medicoAtt.DnaAnoAnteriorCompleto__c);
        system.assertEquals(null, medicoClinicoAtt.DNA__c);
        system.assertEquals(null, medicoClinicoAtt.DNAAnoAnterior__c);
        system.assertEquals(null, medicoClinicoAtt.DnaAnoAnteriorCompleto__c);
        test.stopTest();
    }
    
    @isTest
    public static void testarTriggerDelete(){
        User usuarioConcierge = [SELECT Id, IsActive FROM User WHERE Profile.Name = 'Concierge' AND IsActive=TRUE LIMIT 1];
        Test.startTest();
        System.runAs(usuarioConcierge) {
            Contact medicoAtt = [SELECT id, DNA__c, DNAAnoAnterior__c, DnaAnoAnteriorCompleto__c FROM Contact WHERE Tipo_de_Medico__c = 'Especialista Medico' LIMIT 1];
            try{
                delete medicoAtt;   
            }catch (Exception ex){
                system.debug(ex.getMessage());
                //system.assertEquals('Você não tem permissão para excluir este contato.', ex.getMessage());
            }
        }
        Test.stopTest();
    }
}