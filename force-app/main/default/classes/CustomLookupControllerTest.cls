@isTest
public class CustomLookupControllerTest {
	@isTest
    public static void testLookUp(){
        Account acc = DataFactory.gerarConvenio();
        insert acc;
        string recordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Convenio_OC_Care').getRecordTypeId();

        Test.startTest();
        CustomLookupController.searchLookupData('teste','{"sObjectApiName":"Account","recordTypeId":"'+recordType+'","field1":"Name","field2":"Industry","field3":"Phone","fieldfilter":"Name","valuefilter":"Convenio teste","fieldfilterParent":"","fieldfilterParentValue":""}', '');
        CustomLookupController.searchLookupData('teste','{"sObjectApiName":"Contact","recordTypeId":"","field1":"Name","field2":"Phone","field3":"","fieldfilter":"Name","valuefilter":"Aline","fieldfilterParent":"Name","fieldfilterParentValue":"001880000044A6jAAE"}', '');
        CustomLookupController.searchDefaultRecord(acc.id,'Account');
        CustomLookupController.searchDefaultRecord('','Account');
        Test.stopTest();
    }
}