@IsTest
public class AtualizarCRMRJBatchTest {

    private static Id CONTATO_MEDICO_RTYPE = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Medico').getRecordTypeId();

    @IsTest
    public static void AtualizarCRMRJBatchTest() {

        Contact medicoSP = new Contact();
		medicoSP.FirstName = 'Medico';
		medicoSP.LastName = 'SP';
		medicoSP.Especialidade_CRM__c = 'DERMATOLOGIA - RQE Nº: 91483';
		medicoSP.CRM__c = '194528';
		medicoSP.UF_do_CRM__c = 'SP';
		medicoSP.Tipo_Inscricao_CRM__c = 'Principal';
        medicoSP.RecordTypeId = CONTATO_MEDICO_RTYPE;
		insert medicoSP;

        Contact medicoRJ = new Contact();
		medicoRJ.FirstName = 'Italo';
		medicoRJ.LastName = 'Marsili';
		medicoRJ.Especialidade_CRM__c = 'DERMATOLOGIA - RQE Nº: 91483';
		medicoRJ.CRM__c = '896691';
		medicoRJ.UF_do_CRM__c = 'RJ';
		medicoRJ.Tipo_Inscricao_CRM__c = 'Principal';
        medicoRJ.RecordTypeId = CONTATO_MEDICO_RTYPE;
		insert medicoRJ;

		Contact medicoRJ2 = new Contact();
		medicoRJ2.FirstName = 'Italo2';
		medicoRJ2.LastName = 'Marsili2';
		medicoRJ2.Especialidade_CRM__c = 'DERMATOLOGIA - RQE Nº: 91483';
		medicoRJ2.CRM__c = '8966915';
		medicoRJ2.UF_do_CRM__c = 'RJ';
		medicoRJ2.Tipo_Inscricao_CRM__c = 'Principal';
        medicoRJ2.RecordTypeId = CONTATO_MEDICO_RTYPE;
		insert medicoRJ2;

		Contact medicoRJ3 = new Contact();
		medicoRJ3.FirstName = 'Italo3';
		medicoRJ3.LastName = 'Marsili3';
		medicoRJ3.Especialidade_CRM__c = 'DERMATOLOGIA - RQE Nº: 91483';
		medicoRJ3.CRM__c = '5289978';
		medicoRJ3.UF_do_CRM__c = 'RJ';
		medicoRJ3.Tipo_Inscricao_CRM__c = 'Principal';
        medicoRJ3.RecordTypeId = CONTATO_MEDICO_RTYPE;
		insert medicoRJ3;

        Database.executeBatch(new AtualizarCRMRJBatch());
    }
}