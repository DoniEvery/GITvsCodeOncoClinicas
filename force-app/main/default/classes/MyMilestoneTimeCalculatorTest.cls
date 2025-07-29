@isTest
public class MyMilestoneTimeCalculatorTest {
	static testMethod void testMilestoneTimeCalculator() {        
        MilestoneType[] mtLst = [SELECT Id, Name FROM MilestoneType  WHERE Name= 'Total Repactuado' LIMIT 1];      
        if(mtLst.size() == 0) { return; }
        MilestoneType mt = mtLst[0];

        Case c = new Case(priority = 'High',SlaStartDate = DateTime.newInstance(2023, 03, 07, 10, 7, 12),NovaDataSLA__c = DateTime.newInstance(2023, 03, 10, 10, 7, 12));
        insert c;
        
        MyMilestoneTimeCalculator calculator = new MyMilestoneTimeCalculator();
        Integer actualTriggerTime = calculator.calculateMilestoneTriggerTime(c.Id, mt.Id);
    }
}