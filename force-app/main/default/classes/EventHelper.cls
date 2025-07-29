public with sharing class EventHelper {

        public static String createEvents (EventVO vo) {
        ContactRepository contactRepository = new ContactRepository();
        List<Event> events = new List<Event>();
        Set<String> cttoIds = new Set<String>();
        cttoIds.addAll(vo.contactIds);
        Map<String, Contact> mapContacts = new Map<String, Contact>();

        List<Contact> contacts = contactRepository.findByIds(cttoIds);
        for(Contact ctto : contacts) {
            mapContacts.put(ctto.Id, ctto);
        }
        

        for (String cttoId : cttoIds) {
            Contact ctto = mapContacts.get(cttoId);
            Event evt = new Event();
            evt.subject = vo.subjectValue;
            evt.Tipo_Assunto__c = vo.subjectValue;
            evt.StartDateTime = vo.startDate;
            evt.EndDateTime = vo.endDate;
            evt.Canal_de_comunicacao__c  = vo.communicationChannelValue;
            evt.Acao__c  = vo.actionValue;
            evt.WhoId = cttoId;
            evt.Description = vo.description;
            evt.Status_Reuniao__c = vo.meetingStatusValues;

            if (!vo.selected.isEmpty()) {
                String strProducts = String.join(vo.selected, ';'); 
                evt.Produto__c = String.join(vo.selected, ';');
                if (strProducts.contains('Convite') && String.isNotEmpty(vo.typeValue)) {
                    evt.Tipo_Convite__c = vo.typeValue;
                }
            }

            if(String.isNotEmpty(ctto.Atribuido_a__c)) {
                evt.Painel_do_Consultor__c = 'Sim';
            }

            evt.Tipo_de_Medico__c = String.isNotEmpty(ctto.Tipo_de_Medico__c) ? ctto.Tipo_de_Medico__c : null;


            events.add(evt);
        }

        if(!events.isEmpty()) {
            insert events;
            return 'ok';
        } else {
            return 'nok';
        }
    }

}