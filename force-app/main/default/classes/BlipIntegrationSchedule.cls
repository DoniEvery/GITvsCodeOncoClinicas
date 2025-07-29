public class BlipIntegrationSchedule implements Schedulable {
    public void execute(SchedulableContext ctx) {
        Database.executeBatch(new BlipIntegrationBatch());
    }
}