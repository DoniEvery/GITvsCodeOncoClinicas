@IsTest
public with sharing class LeadTriggerConvertedToContactTest {
    
    private static Id CONTATO_MEDICO_RTYPE = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Medico').getRecordTypeId();
    private static Id LEAD_MEDICO_RTYPE = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Medico').getRecordTypeId();
    private static Id ACCOUNT_EMPRESARIAL_RTYPE = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('IndustriesBusiness').getRecordTypeId();

    @IsTest
    public static void converterLead() {
        
        Account contaNew = new Account();
        contaNew.RecordTypeId = ACCOUNT_EMPRESARIAL_RTYPE;
        contaNew.Name = 'ContaTeste';
        insert contaNew;

        Contact medico = new Contact();
        medico.RecordTypeId = CONTATO_MEDICO_RTYPE;
        medico.FirstName = 'Filipe';
        medico.LastName = 'Magarotto';
        medico.CRM__c = '192168';
        medico.UF_do_CRM__c = 'SP';
        medico.Situacao_do_CRM__c = 'Regular';
        medico.Tipo_Inscricao_CRM__c = 'Principal';
        medico.Especialidade_que_Atua__c = 'PSIQUIATRIA';
        medico.Nome_da_Campanha__c = 'Médicos Sem Fronteiras';
        insert medico;

        Lead lead = new Lead();
        lead.RecordTypeId = LEAD_MEDICO_RTYPE;
        lead.FirstName = 'Filipe';
        lead.LastName = 'Magarotto';
        lead.Tipo_de_Registro__c = 'CRM';
        lead.CRM__c = '192168';
        lead.UF_do_CRM__c = 'SP';
        lead.Nome_da_Campanha__c = 'Evento 08/10/2021';
        insert lead;
		
        /* -------------------------------------------------------------------------- */
        /*                               CONVERTER LEAD                               */
        /* -------------------------------------------------------------------------- */

        Id conta;

        List<Database.LeadConvert> lcs = new List<Database.LeadConvert>();
        
        
        final String convertedLeadStatus = LeadUtils.convertedLeadStatus;

        try {
            if (conta == null) {
                List<Account> contaParaContato = [
                    SELECT Id 
                    FROM Account 
                    WHERE RecordTypeId =:ACCOUNT_EMPRESARIAL_RTYPE AND Name = 'ContaTeste' LIMIT 1
                ];
                conta = contaParaContato.get(0).Id;
            }
        } catch (Exception ex) {
            System.debug('error account ' +ex.getMessage() + ' . ' + ex.getStackTraceString());
        }
        

        System.debug('Converting lead: ' + lead.Id);
        Database.LeadConvert lc = new Database.LeadConvert();
        lc.setLeadId(lead.Id);
        lc.setDoNotCreateOpportunity(true);
        lc.setConvertedStatus(convertedLeadStatus);
        lc.setAccountId(conta);

        try {
            List<Contact> medicoExistente = [
                SELECT Id 
                FROM Contact 
                WHERE CRM__c =: lead.CRM__c AND UF_do_CRM__c =: lead.UF_do_CRM__c AND 
                RecordTypeId =: CONTATO_MEDICO_RTYPE LIMIT 1
            ];
            
            if(medicoExistente.size() > 0) lc.setContactId(medicoExistente.get(0).Id);
        } catch (Exception ex) {
            System.debug('error contact ' +ex.getMessage() + ' . ' + ex.getStackTraceString());
        }
        

        lcs.add(lc);
        try {
            Database.convertLead(lcs);
        } catch (Exception e) {
            System.debug('error conversao ' +e.getMessage() + ' . ' + e.getStackTraceString());
        }
    Test.startTest();
    List<Lead> lstLead = [SELECT id, convertedContactId, IsConverted, CRM__c, UF_do_CRM__c, Nome_da_Campanha__c from Lead WHERE IsConverted = true AND id=:lead.id LIMIT 1];
    LeadTriggerConvertedToContact ltcc = new LeadTriggerConvertedToContact();
    ltcc.leadsConvertidos(lstLead);
	Test.stopTest();
    }
}