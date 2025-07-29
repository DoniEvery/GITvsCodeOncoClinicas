@IsTest
public class MergeContactBatchTest {
    @TestSetup
    public static void MakeData(){
        Account acc = new Account();
        acc.Name = 'teste';
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('AccountRT').getRecordTypeId();
        insert acc;
        
        Contact contactObj = new Contact(
            AccountId = acc.Id,
            LastName = 'Freire',
            FirstName = 'João',
            MiddleName = 'Silva',
            RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Medico').getRecordTypeId(),
            CPF__c = '123456',
            CRM_UF__c = '1111SP',
            CRM__c = '1111'
        );
        insert contactObj;

        Contact contactObj2 = new Contact(
            AccountId = acc.Id,
            LastName = 'Freire',
            FirstName = 'João',
            MiddleName = 'Silva',
            RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('MedicoCorpoClinico').getRecordTypeId(),
            CPF__c = '123456',
            CRM_UF__c = '1111BA',
            CRM__c = '1111'
        );
        insert contactObj2;
        
        CRMMedico__c crm = new CRMMedico__c(
        	Name = '1111SP',
            Medico__c = contactObj.Id
        );
        insert crm;

        insert new Case (
            Nome_Medico__c  = contactObj.Id
        );
        insert new Case (
            ContactId  = contactObj.Id
        );
        insert new Event (
            WhoId  = contactObj.Id,
            DurationInMinutes = 1,
            ActivityDateTime = system.today()
        );
        
        insert new DNA__c(
            Medico__c  = contactObj.Id
        );
        insert new Emails_do_Contato__c(
            Contato__c  = contactObj.Id
        );
        insert new TimeSlot(
            StartTime = Time.newInstance(18,0,0 ,0),
            EndTime  = Time.newInstance(19,0,0 ,0),
            Contato__c  = contactObj.Id
        );
        insert new Log__c(
            ContactID__c  = contactObj.Id
        );
        Survey__c s = new Survey__c(Name = 'test survey');
        insert s;
        insert new SurveyTaker__c(
            Survey__c = s.Id,
            Contact__c  = contactObj.Id
        );
        insert new Tratamento__c(
            Paciente__c = acc.Id,
            MedicoResponsavel__c  = contactObj.Id
        );
        /*Campaign campanha = new Campaign(
            name = 'Cuidados paliativos',
            Type = 'Outros',
            Status = 'In Progress',
            IntegraBlip__c = true,
            IsActive = true
        );
        insert campanha;

        insert new CampaignMember(
            CampaignId = campanha.id,
            ContactId = contactObj.id
        );*/

    }
    @IsTest
    public static void testCreateCrmMedicoBatch(){
        //Database.executeBatch(new CreateCrmMedicoBatch());
    }
    @IsTest
    public static void testCreateCrmMedicoBatch2(){
        //Database.executeBatch(new CreateCrmMedicoBatch('123456'));
    }
    @IsTest
    public static void testMergeContactBatch(){
        Database.executeBatch(new MergeContactBatch());
    }
    @IsTest
    public static void testMergeContactBatch2(){
        Database.executeBatch(new MergeContactBatch('123456'));
    }
}