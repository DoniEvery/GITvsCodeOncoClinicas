@isTest
public class APP_GestaoAcompanhantesServiceTest {

    static Account contaPaciente;
    static Account contaAcompanhante;
    static User paciente;
    static List<Profile> profileList;
    static Id contactId;

    @testSetup
    static void setupData() {
        List<RecordType> rts = [SELECT Id, Developername FROM RecordType WHERE IsPersonType = true AND DeveloperName IN ('PersonAccount','Acompanhante')];

        Map<String, Id> RTMap = new Map<String, Id>();
        for (RecordType rt : rts) {
            RTMap.put(rt.Developername, rt.Id);
        }

        contaPaciente = new Account(
            FirstName = 'Paciente',
            LastName = 'Teste',
            RecordTypeId = RTMap.get('PersonAccount'),
            CNPJ__c = ''
        );
        insert contaPaciente;     

        contaAcompanhante = new Account(
            FirstName = 'Acompanhante',
            LastName = 'Teste',
            RecordTypeId = RTMap.get('Acompanhante'),
            CNPJ__c = '12345678901'
        );
        insert contaAcompanhante;
        
    }

    @isTest
    static void listaAcompanhantesTest() {

          // Buscar perfis
          profileList = [SELECT Id, Name FROM Profile WHERE Name IN ('System Administrator','APP_Paciente')];
          List<Account> contaPaciente = [SELECT Id, PersonContactId FROM Account];
          PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'APP_Paciente2' LIMIT 1];
          // 2. Buscar um UserRole válido
         UserRole r = [SELECT Id FROM UserRole LIMIT 1];
          System.debug('contaPaciente '+contaPaciente);

          // Mapear os perfis para facilitar acesso
          Map<String, Id> profileMap = new Map<String, Id>();
          for (Profile p : profileList) {
              profileMap.put(p.Name, p.Id);
          }
          System.debug('contactId '+contactId);

          User adm = new User(
            FirstName = 'adm',
            LastName = 'User',
            Email = 'adm@example.com',
            Username = 'admuser' + DateTime.now().getTime() + '@example.com',
            Alias = 'pacusr',
            TimeZoneSidKey = 'America/Sao_Paulo',
            LocaleSidKey = 'pt_BR',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'pt_BR',
            ProfileId = profileMap.get('System Administrator'),
            UserRoleId = r.Id
        );

        insert adm;

        
        System.runAs(adm) {  

            paciente = new User(
                FirstName = 'Paciente',
                LastName = 'User',
                Email = 'paciente@example.com',
                Username = 'pacienteuser' + DateTime.now().getTime() + '@example.com',
                Alias = 'pacusr',
                TimeZoneSidKey = 'America/Sao_Paulo',
                LocaleSidKey = 'pt_BR',
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = 'pt_BR',
                ProfileId = profileMap.get('APP_Paciente'),
                ContactId = contaPaciente[0].PersonContactId
            );

            insert paciente;

            PermissionSetAssignment psa = new PermissionSetAssignment(
                AssigneeId = paciente.Id, // ID do User que você acabou de criar
                PermissionSetId = ps.Id
            );
            insert psa;
        }
    
        System.debug('user' + [SELECT id, isactive, profile.name from user where profileid = :profileMap.get('System Administrator')]);
        System.runAs(adm) {       

            // Inserir manualmente a junção entre user e account (mock)
            APP_JuncAcompanhante__c juncaoDummy = new APP_JuncAcompanhante__c(
                APP_Paciente__c = contaPaciente[0].Id,
                APP_Acompanhantes__c = contaPaciente[1].Id, // será preenchido na criação
                APP_Ativo__c = true
            );
            insert juncaoDummy;

            APP_GestaoAcompanhantesController.listarAcompanhantes();

            APP_GestaoAcompanhantesController.buscarAcompanhante('12345678901');
            APP_GestaoAcompanhantesController.buscarAcompanhante('12995678901');
            Test.startTest();
                

                // JSON com dados do acompanhante
                String json = JSON.serialize(new Map<String, Object>{
                    'nome' => 'Acomp Teste',
                    'cnpj' => '13345678901',
                    'telefone' => '11999999999',
                    'email' => 'acomp@example.com'
                });

                // Criar acompanhante
                APP_GestaoAcompanhantesController.criaAcompanhante(json);


                // Buscar individual
                APP_GestaoAcompanhantesService.AcompanhanteWrapper wrapper = APP_GestaoAcompanhantesService.buscarAcompanhante('13345678901');
                // System.assertEquals('Acomp Teste', wrapper.nome);
                // System.assertEquals('12345678901', wrapper.cpf);
               
                APP_GestaoAcompanhantesController.inativaAcompanhante(juncaoDummy.id);


            Test.stopTest();
        }

        
    }
    
    // @isTest
    // static void testCriarBuscarEInativarAcompanhante() {

    //       // Buscar perfis
    //       profileList = [SELECT Id, Name FROM Profile WHERE Name IN ('APP_Paciente')];
    //       List<Account> contaPaciente = [SELECT Id, PersonContactId FROM Account];
    //       System.debug('contaPaciente '+contaPaciente);

    //       // Mapear os perfis para facilitar acesso
    //       Map<String, Id> profileMap = new Map<String, Id>();
    //       for (Profile p : profileList) {
    //           profileMap.put(p.Name, p.Id);
    //       }
    //       System.debug('contactId '+contactId);
    //       User paciente = new User(
    //         FirstName = 'Paciente',
    //         LastName = 'User',
    //         Email = 'paciente@example.com',
    //         Username = 'pacienteuser' + DateTime.now().getTime() + '@example.com',
    //         Alias = 'pacusr',
    //         TimeZoneSidKey = 'America/Sao_Paulo',
    //         LocaleSidKey = 'pt_BR',
    //         EmailEncodingKey = 'UTF-8',
    //         LanguageLocaleKey = 'pt_BR',
    //         ProfileId = profileMap.get('APP_Paciente'),
    //         ContactId = contaPaciente[0].PersonContactId
    //     );
    

    //     System.runAs(paciente) {       

    //         APP_GestaoAcompanhantesController.buscarAcompanhante('12345678901');
    //         Test.startTest();
                

    //             // JSON com dados do acompanhante
    //             String json = JSON.serialize(new Map<String, Object>{
    //                 'nome' => 'Acomp Teste',
    //                 'cnpj' => '13345678901',
    //                 'telefone' => '11999999999',
    //                 'email' => 'acomp@example.com'
    //             });

    //             // Criar acompanhante
    //             APP_GestaoAcompanhantesService.criaAcompanhante(json);


    //             // Buscar individual
    //             APP_GestaoAcompanhantesService.AcompanhanteWrapper wrapper = APP_GestaoAcompanhantesService.buscarAcompanhante(juncoes[0].APP_Acompanhantes__c);
    //             System.assertEquals('Acomp Teste', wrapper.nome);
    //             System.assertEquals('12345678901', wrapper.cpf);

    //             // Inativar acompanhante
    //             APP_GestaoAcompanhantesService.inativaAcompanhante(juncoes[0].Id);

    //         // Test.stopTest();
    // }
}