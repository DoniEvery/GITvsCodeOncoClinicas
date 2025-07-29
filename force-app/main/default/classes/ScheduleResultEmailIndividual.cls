public class ScheduleResultEmailIndividual implements Schedulable {
    public void execute(SchedulableContext SC) {
        // Nome API do Flow
        String flowName = 'ExclusaoResultEmailIndividual';
        Map<String, Object> params = new Map<String, Object>();
        // Executa o Flow
        Flow.Interview flowInterview = Flow.Interview.createInterview(flowName, params);
        flowInterview.start();
    }
}