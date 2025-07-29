trigger TaskTrigger on Task (before delete, before insert, after insert, before update, after update)
{       
    new TaskTriggerHandler().run(); 
}