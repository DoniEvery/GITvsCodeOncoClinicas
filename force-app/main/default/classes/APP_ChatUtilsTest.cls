@isTest
public class APP_ChatUtilsTest {

    @isTest
    static void testGetUserTypeWithAccountId() {
        Account acc = new Account(Name = 'Conta Teste');
        insert acc;

        String result = APP_ChatUtils.getUserType(acc.Id);
        System.assertEquals('Account', result, 'Deveria retornar Account');
    }

    @isTest
    static void testGetUserTypeWithContactId() {
        Contact c = new Contact(LastName = 'Contato Teste');
        insert c;

        String result = APP_ChatUtils.getUserType(c.Id);
        System.assertEquals('Contact', result, 'Deveria retornar Contact');
    }

    @isTest
    static void testGetUserTypeWithNullId() {
        String result = APP_ChatUtils.getUserType(null);
        System.assertEquals('Unknown', result, 'Deveria retornar Unknown para null');
    }

    @isTest
    static void testGetUserTypeWithInvalidPrefix() {
        // Cria um ID fake com prefixo diferente
        Id fakeId = '005000000000000AAA'; // Prefixo de User
        String result = APP_ChatUtils.getUserType(fakeId);
        System.assertEquals('Unknown', result, 'Deveria retornar Unknown para prefixo inválido');
    }
}