public class TaskTriggerHandler extends TriggerHandler    {

    private List<Task> newTaskList;    
    private Map<Id, Task> newTaskMap;  
    private Map<Id, Task> newOldMap;  

    public TaskTriggerHandler() {
        this.newTaskList = (List<Task>) Trigger.new;
        this.newTaskMap = (Map<Id, Task>) Trigger.newMap;
        this.newOldMap = (Map<Id, Task>) Trigger.oldMap;
        this.setMaxLoopCount(30);
    } 

    public override void beforeInsert() 
    {     
        TaskTriggerHelper.verificarViolacaoCaso(this.newTaskList); 
    }  
    
    public override void afterInsert() 
    {     
        //TaskTriggerHelper.updateCaseReChegada(this.newTaskList);
    }      
    
    public override void beforeDelete() 
    {     
        TaskTriggerHelper.verificaTarefasDatas(this.newOldMap);
    }      
    
    public override void afterUpdate() 
    {      
        TaskTriggerHelper.enviarNotificacao(this.newTaskMap, this.newOldMap);        
    }            

}