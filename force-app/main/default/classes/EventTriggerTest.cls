@IsTest
public class EventTriggerTest {
	@IsTest
	private static void atualizaEventoContatoTest() {
		Test.startTest();
		Contact contato = new Contact();
		contato.FirstName = 'teste';
		contato.LastName = 'teste';
		contato.Email = 'test@gmail.com';
		contato.Atribuido_a__c = UserInfo.getUserId();
		contato.Tipo_de_Medico__c = 'EspecialistaMedico';

		insert contato;

		Event evento = new Event();
		evento.WhoId = contato.Id;
		evento.DurationInMinutes = 10;
		evento.ActivityDateTime = System.now();
		evento.Painel_do_Consultor__c = null;
		evento.Tipo_de_Medico__c = null;

		insert evento;

		evento = [SELECT ID, Painel_do_Consultor__c, Tipo_de_Medico__c FROM EVENT WHERE Id = :evento.Id LIMIT 1];
        
		evento.WhoId = null;
		update evento;
        
		evento.WhoId = contato.Id;
		update evento;
        
		evento = [SELECT ID, Painel_do_Consultor__c, Tipo_de_Medico__c FROM EVENT WHERE Id = :evento.Id LIMIT 1];


		System.assertEquals(true, evento.Painel_do_Consultor__c != null && evento.Tipo_de_Medico__c != null);
	}
}