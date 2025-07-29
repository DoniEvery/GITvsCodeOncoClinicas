public without sharing class EventTriggerHandler {
	// * * * * * * * * * * * * * * * * * * * * * *
	//!* * * PUBLIC TRIGGER BUSINESS METHODS * * *
	// * * * * * * * * * * * * * * * * * * * * * *

	public void atualizaEventoContato(List<Event> eventosNew, Map<Id, Event> eventsOldMap) {
		Map<Id, Contact> contatosMap = new Map<Id, Contact>();

		List<Event> eventsToUpdate = filterEventsPendingContactUpdate(eventosNew, eventsOldMap);

		if (eventsToUpdate.size() > 0) {
			contatosMap = getContatosByEvents(eventsToUpdate);

			if (contatosMap.values().size() > 0) {
				for (Event evento : eventsToUpdate) {
					if (contatosMap.containsKey(evento.WhoId)) {
						Contact contato = contatosMap.get(evento.WhoId);

						evento.Painel_do_Consultor__c = contato.Atribuido_a__c != null ? 'Sim' : 'Não';
						evento.Tipo_de_Medico__c = contato.Tipo_de_Medico__c;
					}
				}
			}
		}
	}

	// * * * * * * * * * * * * * *
	//!* * * PRIVATE METHODS * * *
	// * * * * * * * * * * * * * *

	private Map<Id, Contact> getContatosByEvents(List<Event> eventos) {
		Map<Id, Contact> result = new Map<Id, Contact>();
		Set<Id> contactIdSet = new Set<Id>();

		if (eventos.size() > 0) {
			for (Event evento : eventos) {
				contactIdSet.add(evento.WhoId);
			}

			result = new Map<ID, Contact>(
				[SELECT Id, Tipo_de_Medico__c, Atribuido_a__c FROM Contact WHERE Id IN :contactIdSet ORDER BY createddate DESC LIMIT 2000]
			);
		}

		return result;
	}

	private static List<Event> filterEventsPendingContactUpdate(List<Event> eventosNew, Map<Id, Event> eventsOldMap) {
		List<Event> result = new List<Event>();

		for (Event evento : eventosNew) {
			if (
				//É evento de Contato E
				evento.WhoId != null && String.ValueOf(evento.WhoId).startsWith('003')
			) // &&
			//Não preencheu Painel do Consultor ou Tipo de Médico OU
			// ((evento.Painel_do_Consultor__c == null || evento.Tipo_de_Medico__c == null) ||
			//É Novo Evento ou O WhoId Mudou
			// contatoMudou(evento, eventsOldMap))
			{
				result.add(evento);
			}
		}

		return result;
	}

	//     private static Boolean contatoMudou(Event evento, Map<Id, Event> eventsOldMap) {
	//         return eventsOldMap == null || eventsOldMap.containsKey(evento.Id) && eventsOldMap.get(evento.Id).WhoId != evento.WhoId;
	//     }
}