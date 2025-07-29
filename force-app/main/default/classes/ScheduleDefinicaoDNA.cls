public with sharing class ScheduleDefinicaoDNA implements Schedulable{

    public void execute(SchedulableContext SC){ 
        Database.executeBatch(new BatchQuantificarEncontros(2022));
    }
}