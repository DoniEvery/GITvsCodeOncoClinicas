public class TimeSlotTriggerHandler {
    
  public static void updateOperatingHoursId(List<TimeSlot> timeSloList){
     Set<Id> contactIds = new Set<Id>();
     Map<String, Id> operatingHoursMap = new Map<String, Id>();
     Map<Id, String> contactMap = new Map<Id, String>();
     Map<Id, OperatingHours> timeSlotAndOperatingMap = new Map<Id, OperatingHours>();
     for(TimeSlot ts : timeSloList){
       if(ts.Contato__c == null) continue;
        contactIds.add(ts.Contato__c);       
     }
     List<Contact> contactList = [SELECT Id, Name FROM Contact WHERE Id =: contactIds ];    
     List<OperatingHours> operatingHoursList = [SELECT Id, Chave__c FROM OperatingHours WHERE Chave__c =: contactIds ]; 
     for(OperatingHours oph : operatingHoursList){
       if(String.isBlank(oph.Chave__c)) continue;   
         operatingHoursMap.put(oph.Chave__c, oph.Id);
     }
     for(Contact ct : contactList) 
         contactMap.put(ct.Id, ct.Name); 
     
     for(TimeSlot tsl : timeSloList){
      if(tsl.Contato__c == null) continue;
       if(operatingHoursMap.containsKey(tsl.Contato__c)){
         tsl.OperatingHoursId = operatingHoursMap.get(tsl.Contato__c);
       }else{
         OperatingHours oph = new OperatingHours();
         oph.Name = contactMap.get(tsl.Contato__c);
         oph.Description = 'Horário de Atendimento do Médico: ' + contactMap.get(tsl.Contato__c) + '\n Id: ' + tsl.Contato__c;
         oph.TimeZone = 'America/Sao_Paulo';
         oph.Chave__c = tsl.Contato__c;
         timeSlotAndOperatingMap.put(tsl.Id, oph);
       }
	}
    if(timeSlotAndOperatingMap.values().size() > 0) insert timeSlotAndOperatingMap.values();
    else return;
      
      for(TimeSlot ts : timeSloList){
          if(timeSlotAndOperatingMap.containsKey(ts.Id))
              ts.OperatingHoursId = timeSlotAndOperatingMap.get(ts.Id).Id;             
      }      
  }
}