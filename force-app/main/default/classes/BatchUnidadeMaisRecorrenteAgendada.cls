public with sharing class BatchUnidadeMaisRecorrenteAgendada implements Schedulable {
    
    public void execute(SchedulableContext SC){ 
        Database.executeBatch(new BatchUnidadeMaisRecorrente());
    }

}