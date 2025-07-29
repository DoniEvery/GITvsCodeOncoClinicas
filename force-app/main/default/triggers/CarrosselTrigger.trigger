trigger CarrosselTrigger on Contact (before update) {
    
        for (Contact contact : Trigger.new)
        {
            if(contact.Engajamento__c == 'Não engajado' || contact.Engajamento__c == 'Inválido')
                CarrosselLogic.mainFunction(contact);
        }
}