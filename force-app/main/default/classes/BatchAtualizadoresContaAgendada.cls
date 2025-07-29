public with sharing class BatchAtualizadoresContaAgendada implements Schedulable {
    
    public void execute(SchedulableContext SC){ 
        Database.executeBatch(new BatchAtualizadoresConta(), 50);
    }
    
}