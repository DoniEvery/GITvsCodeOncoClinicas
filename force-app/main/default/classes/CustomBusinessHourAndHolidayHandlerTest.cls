@isTest
private class CustomBusinessHourAndHolidayHandlerTest {
static testMethod void validateBusinessHours() {

    List<CustomBusinessHourAndHolidayHandler.Requests> requestList = new List<CustomBusinessHourAndHolidayHandler.Requests>();
    
    CustomBusinessHourAndHolidayHandler.Requests req = new CustomBusinessHourAndHolidayHandler.Requests();
    req.InputDateTimeField = system.now();
    requestList.add(req);
    
    Test.startTest();
    List<CustomBusinessHourAndHolidayHandler.Results> responseList = CustomBusinessHourAndHolidayHandler.execute(requestList);
    Test.stopTest();
    
    system.assert(responseList.size()>0);
}
}