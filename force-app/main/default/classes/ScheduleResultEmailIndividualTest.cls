@isTest
public class ScheduleResultEmailIndividualTest {
    @isTest
    static void testExecute() {
        // Define a data de execução do job
        String schedule = '0 0 0 1 1 ? 2050';
        // Instancia a classe a ser testada
        ScheduleResultEmailIndividual job = new ScheduleResultEmailIndividual();
        // Agende o job
        String jobId = System.schedule('Test Scheduled Job', schedule, job);
        // Execute os jobs agendados
        Test.startTest();
        System.runAs(new User(Id = UserInfo.getUserId())) {
            CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime
                              FROM CronTrigger WHERE Id = :jobId];
            System.assertEquals(0, ct.TimesTriggered);
        }
        Test.stopTest();
    }
}