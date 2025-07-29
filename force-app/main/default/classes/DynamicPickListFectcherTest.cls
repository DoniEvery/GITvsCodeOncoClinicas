@isTest
public class DynamicPickListFectcherTest {

    @isTest
    static void getPickListLabels() {
        List<String> labels = new List<String>();

        Test.startTest();
        labels = DynamicPickListFectcher.getPickListLabels('Event', 'Status_Reuniao__c');
        Test.stopTest();

        System.assert(!labels.isEmpty());
    }
}