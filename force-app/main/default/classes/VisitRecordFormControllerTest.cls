@isTest
public class VisitRecordFormControllerTest {

    @isTest
    static void getPickListLabels() {
        List<String> labels = new List<String>();
        Contact ctto = new Contact(
            FirstName = 'Medico',
            LastName = 'Mock',
            Especialidade_CRM__c = 'DERMATOLOGIA - RQE Nº: 91483',
            CRM__c = '194528',
            UF_do_CRM__c = 'SP',
            Tipo_Inscricao_CRM__c = 'Principal',
            Situacao_do_Medico__c = 'Regular',
            Tipo_de_Medico__c = 'Corpo Clinico - Clinicas',
            Atribuido_a__c = UserInfo.getUserId(),
            RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Medico').getRecordTypeId()
        ); 
        insert ctto;
        GruposUnidade__c gu = new GruposUnidade__c(Name ='teste',
        RecordTypeId = Schema.SObjectType.GruposUnidade__c.getRecordTypeInfosByDeveloperName().get('GruposMedicos').getRecordTypeId()
        );
        insert gu;
        ContatoGrupo__c cg = new ContatoGrupo__c(Grupo__c = gu.id,
        Medico__c = ctto.id);
        insert cg;

        Test.startTest();
        VisitRecordFormController.getPickListLabels('Event', 'Status_Reuniao__c');
        VisitRecordFormController.getDependentPickListLabels('Event', 'Canal_de_comunicacao__c', 'Visita');
        VisitRecordFormController.getMultiPickListContacts();
        Test.stopTest();

    }
    // @isTest
    // static void getPickListLabelsCath() {
    //     Test.startTest();
    //     try {
            
    //         VisitRecordFormController.getPickListLabels('Event', 'zzz');
    //     } catch (Exception e) {
    //         System.debug('test ' + e.getMessage());
    //     }
    //     Test.stopTest();
    // }

    @isTest
    static void save() {
        ContactRepository repository = new ContactRepository();
        Contact ctto = new Contact(
			FirstName = 'Medico',
			LastName = 'Mock',
			Especialidade_CRM__c = 'DERMATOLOGIA - RQE Nº: 91483',
			CRM__c = '194528',
			UF_do_CRM__c = 'SP',
			Tipo_Inscricao_CRM__c = 'Principal',
			Situacao_do_Medico__c = 'Regular',
            Tipo_de_Medico__c = 'Corpo Clinico - Clinicas',
			RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Medico').getRecordTypeId()
		); 
		insert ctto;
        EventVO vo = new EventVo();
        vo.startDate = DateTime.now().addDays(1);
        vo.endDate = DateTime.now().addDays(2);
        vo.communicationChannelValue = 'Presencial';
        vo.subjectValue = 'Visita';
        vo.actionValue = 'Corpo Clinico';
        vo.description = 'description';
        vo.typeValue = '';
        vo.medicTypeValue = '';
        vo.advisorPanelValue = '';
        vo.contactIds = new List<String>{ctto.Id};
        vo.selected = new List<String>{'OC Care'};

        
        String jsonStr  = JSON.serialize(vo);

        String response = '';

        Test.startTest();
        response = VisitRecordFormController.save(jsonStr);
        Test.stopTest();

        System.assertEquals('ok' , response);
    }

}