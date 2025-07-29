@isTest
public with sharing class LeadTriggerTest {

        private static Id LEAD_MEDICO_RTYPE = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Medico').getRecordTypeId();

        @isTest
        static void leadConsultaMedicoExistente() {

                List<Lead> listLead = new List<Lead>();

                Test.startTest();

                Test.setMock(WebServiceMock.class, new MedicoServiceMock.MockServicoConsultaMedicosPort());

                Lead lead = new Lead();
                lead.LastName = 'testeLead';
                lead.Company = 'Empresa 2';
                lead.CRM__c = '123456789';
                lead.UF_do_CRM__c = 'RJ';
                lead.Lead_Novo__c = true;
                lead.RecordTypeId = LEAD_MEDICO_RTYPE;
                listLead.add(lead);
                insert listLead;

                Datetime dataProxAgendamento = Datetime.now().addHours(1);
                String str = dataProxAgendamento.format('s m H d M ? yyyy');  
                Id jobId = System.schedule('LeadBatchSchedulable : ' + dataProxAgendamento.format('dd/MM/yyyy HH:mm:ss'), str, new LeadBatchSchedulable());

                new LeadTriggerHandler().verificaCrmValido(listLead);
                Test.stopTest();
        }

        @isTest
        static void leadConsultaMedicoNaoExistente() {

                List<Lead> listLead = new List<Lead>();

                Test.startTest();

                Test.setMock(WebServiceMock.class, new MedicoServiceMock.MockServicoConsultaMedicosErro());

                Lead lead = new Lead();
                lead.LastName = 'testeLead';
                lead.Company = 'Empresa 2';
                lead.CRM__c = '1234567';
                lead.UF_do_CRM__c = 'SP';
                lead.Lead_Novo__c = true;
                lead.RecordTypeId = LEAD_MEDICO_RTYPE;
                listLead.add(lead);
                insert listLead;

                new LeadTriggerHandler().verificaCrmValido(listLead);
                Test.stopTest();
        }

        @isTest
        static void leadInsertMedicoJaExistente() {

                List<Lead> listLead = new List<Lead>();

                Test.startTest();

                Test.setMock(WebServiceMock.class, new MedicoServiceMock.MockServicoConsultaMedicosPort());

                Lead lead = new Lead();
                lead.LastName = 'testeLead';
                lead.Company = 'Empresa 2';
                lead.CRM__c = '12345';
                lead.UF_do_CRM__c = 'SP';
                lead.Lead_Novo__c = true;
                lead.RecordTypeId = LEAD_MEDICO_RTYPE;
                listLead.add(lead);

                Lead lead2 = new Lead();
                lead2.LastName = 'testeLead';
                lead2.Company = 'Empresa 2';
                lead2.CRM__c = '12345';
                lead2.UF_do_CRM__c = 'SP';
                lead2.Lead_Novo__c = true;
                lead2.RecordTypeId = LEAD_MEDICO_RTYPE;
                listLead.add(lead2);

                insert listLead;

                Datetime dataProxAgendamento = Datetime.now().addHours(1);
                String str = dataProxAgendamento.format('s m H d M ? yyyy');  
                Id jobId = System.schedule('LeadBatchSchedulable : ' + dataProxAgendamento.format('dd/MM/yyyy HH:mm:ss'), str, new LeadBatchSchedulable());
                
                new LeadTriggerHandler().verificaCrmValido(listLead);
                Test.stopTest();
        }

        @IsTest
	public static void getMedicoTest() {

                List<Lead> listLead = new List<Lead>();

                Test.startTest();

		Lead lead = new Lead(
                FirstName = 'Medico',
                LastName = 'Mock',
                Especialidade_CRM__c = 'DERMATOLOGIA - RQE Nº: 91483',
                CRM__c = '194528',
                UF_do_CRM__c = 'SP',
                Tipo_Inscricao_CRM__c = 'Principal',
                Lead_Novo__c = true,
                RecordTypeId = LEAD_MEDICO_RTYPE
		//RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Medico').getRecordTypeId()
		); 
                listLead.add(lead);
		insert listLead;

                Datetime dataProxAgendamento = Datetime.now().addHours(1);
                String str = dataProxAgendamento.format('s m H d M ? yyyy');  
                Id jobId = System.schedule('LeadBatchSchedulable : ' + dataProxAgendamento.format('dd/MM/yyyy HH:mm:ss'), str, new LeadBatchSchedulable());

                new LeadTriggerHandler().verificaCrmValido(listLead);
                Test.stopTest();
	}
}