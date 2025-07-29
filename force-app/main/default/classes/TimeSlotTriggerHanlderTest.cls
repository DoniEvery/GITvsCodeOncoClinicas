@isTest
public class TimeSlotTriggerHanlderTest {
    
    @isTest
    public static void timeSlotTest(){
        
    Contact ct = new Contact();
    ct.FirstName = 'My';
    ct.LastName = 'Name';
    insert ct;
    
    Time myTime = Time.newInstance(18, 30, 2, 20);
    TimeSlot ts = new TimeSlot();
    ts.StartTime = myTime;
    ts.EndTime = myTime.addHours(2);
    ts.DayOfWeek = 'Tuesday';
    ts.Type = 'Normal';
    ts.Contato__c = ct.Id;
    insert ts;
    
    }  
}