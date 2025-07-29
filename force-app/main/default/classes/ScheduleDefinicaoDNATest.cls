@isTest
public with sharing class ScheduleDefinicaoDNATest {

    @isTest
    Public static void testarClass(){
        Test.startTest();
        DateTime agora = System.now().addMinutes(1);
        String cronExp = agora.second()+' '+agora.minute()+' '+agora.hour()+' '+agora.day()+' '+agora.month()+' ? '+agora.year();
        System.schedule('agendamento teste', cronExp, new ScheduleDefinicaoDNA());
        Test.stopTest();
    }
}