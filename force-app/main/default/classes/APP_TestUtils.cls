@isTest
public class APP_TestUtils {
    public interface ISelector {
        List<ServicePath__mdt> getServicePaths();
    }
    
    public class Selector implements ISelector {
        public List<ServicePath__mdt> getServicePaths() {
            return [SELECT Service_Path__c 
                    FROM ServicePath__mdt 
                    WHERE Service_Name__c = 'patients records' 
                    AND Service_Org_Domain_URL__c = :URL.getOrgDomainURL().toExternalForm()];
        }
    }
    
    public class MockSelector implements ISelector {
        public List<ServicePath__mdt> returnRecords;
        
        public List<ServicePath__mdt> getServicePaths() {
            return returnRecords;
        }
    }
    
    public static ISelector selector = new Selector();
    
    public static List<ServicePath__mdt> getServicePaths() {
        return selector.getServicePaths();
    }
}