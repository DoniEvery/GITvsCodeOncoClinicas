global class LeadBatchSchedulable implements Schedulable {
 
    global void execute (SchedulableContext sc) {
        abortarTrabalho(sc.getTriggerId());
        scheduleNext();
        Database.executebatch(new LeadBatch(), 100);
    }
    
    private void abortarTrabalho(String pId) {
        try {
            System.abortJob(pId);
        }
        catch (Exception ex) {
            System.debug('DEBUG: ' + ex.getStackTraceString());
        }
    }
 
    //caso for necesário apenas agendar
    public static void scheduleNext () {
        Datetime dataProxAgendamento = Datetime.now().addHours(1);
        String str = dataProxAgendamento.format('s m H d M ? yyyy');  
        Id jobId = System.schedule('LeadBatchSchedulable : ' + dataProxAgendamento.format('dd/MM/yyyy HH:mm:ss'), str, new LeadBatchSchedulable());
        System.debug('ScheduleId : ' + jobId);
    }
}