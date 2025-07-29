trigger TimeSlotTrigger on TimeSlot (before insert) {
    
    if(Trigger.isBefore && Trigger.IsInsert){
        
        TimeSlotTriggerHandler.updateOperatingHoursId(Trigger.new);
    }

}