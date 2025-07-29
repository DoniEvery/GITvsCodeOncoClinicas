/**
 * @description: Classe responsável pelo controle de login de Paciente e Acompanhante
 * @author: Claudio Baraza - Everymind
 */
public without sharing class APP_LoginController {

    @AuraEnabled(cacheable=false)
    public static Account existAccount(String tipoDocumento, String numeroDocumento, String tipoUsuario) {
        String fieldName;
        //tipoUsuario = 'PersonAccount'; // Fixado para Acompanhante e Paciente.
        if (tipoDocumento == 'CPF') {
            fieldName = 'CNPJ__c';
        } else if (tipoDocumento == 'Passaporte') {
            fieldName = 'APP_Passaporte__c';
        } else if (tipoDocumento == 'RNE') {
            fieldName = 'RNE__c';
        } else {
            throw new AuraHandledException('Tipo de documento inválido.');
        }

        String valorDocumento = String.escapeSingleQuotes(numeroDocumento);
        String valorTipoUsuario = String.escapeSingleQuotes(tipoUsuario) == 'Acompanhante' ? 'Acompanhante' : 'PersonAccount';

        String query = 'SELECT Id, Name, APP_Ativo__c, Ativo__c FROM Account WHERE ' + fieldName + ' = \'' + valorDocumento + '\' AND RecordType.DeveloperName = \'' + valorTipoUsuario + '\' LIMIT 1';
        List<Account> accounts = Database.query(query);
        System.debug('Accont >> ' + query);
        System.debug('Accont is empty >> ' + accounts.isEmpty());
        if (accounts.isEmpty()) {
            throw new AuraHandledException('Conta não encontrada.');
        }

        Account acc = accounts[0];
        if (acc.APP_Ativo__c != true) {
            throw new AuraHandledException('Conta inativa.');
        }

        return acc;
    }

    @AuraEnabled(cacheable=true)
    public static User getUserData(Id accountId) {
        List<User> users = [
            SELECT Id, Name, Email, IsActive, Username
            FROM User
            WHERE AccountId = :accountId
            LIMIT 1
        ];

        if (users.isEmpty()) {
            throw new AuraHandledException('Usuário não encontrado.');
        }

        User u = users[0];
        if (!u.IsActive) {
            throw new AuraHandledException('Usuário inativo.');
        }

        return u;
    }

    @AuraEnabled
    public static String login(String username, String password) {
        PageReference result = Site.login(username, password, '/s/');
        if (result != null) {
            return result.getUrl();
        } else {
            throw new AuraHandledException('Usuário ou senha inválidos.');
        }
    }


    /*@AuraEnabled
    public static void iniciarMFA(String userId) {
        if (String.isBlank(userId)) {
            throw new AuraHandledException('ID do usuário é obrigatório.');
        }

        Integer codigo = Math.mod(Math.abs(Crypto.getRandomInteger()), 1000000);
        Datetime expiracao = Datetime.now().addMinutes(10);

        
        // Comentado porque o objeto APP_MFAToken__c ainda não existe
        List<APP_MFAToken__c> tokensAntigos = [
            SELECT Id FROM APP_MFAToken__c WHERE User__c = :userId
        ];
        delete tokensAntigos;

        APP_MFAToken__c token = new APP_MFAToken__c(
            User__c = userId,
            Codigo__c = codigo,
            Expiracao__c = expiracao
        );
        insert token;
        

        User u = [SELECT Email, Name FROM User WHERE Id = :userId LIMIT 1];
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new String[] { u.Email });
        mail.setSubject('Código de verificação');
        mail.setPlainTextBody('Olá ' + u.Name + ',\n\nSeu código de verificação é: ' + codigo + '\n\nO código expira em 10 minutos.');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }*/

    @AuraEnabled
    public static void trocarSenha(Id userId, String novaSenha) {
        alterarSenhaInternamente(userId, novaSenha);
    }

    private static void alterarSenhaInternamente(Id userId, String novaSenha) {
        try {
            System.setPassword(userId, novaSenha);
        } catch (Exception e) {
            throw new AuraHandledException('Erro ao alterar a senha: ' + e.getMessage());
        }
    }

    @AuraEnabled
    public static User newUser(Id accountId, String tipoPerfil){
        
        Contact contato = [SELECT Id, LastName, Email FROM Contact WHERE AccountId = :accountId LIMIT 1];

        List<User> usuariosExistentes = [SELECT Id FROM User WHERE ContactId = :contato.Id LIMIT 1];
        if (!usuariosExistentes.isEmpty()) {
            return usuariosExistentes[0];
        }

        if (accountId == null) {
            throw new AuraHandledException('ID da conta é obrigatório.');
        }
        if (String.isBlank(tipoPerfil)) {
            throw new AuraHandledException('Tipo de perfil não informado para criação do usuário.');
        }

        String aliasDaOrg = System.currentTimeMillis().format().remove('.');

        List<Account> accs = [
            SELECT Id, Name, PersonEmail, CNPJ__c, APP_Passaporte__c, RNE__c, RecordType.DeveloperName, OwnerId
            FROM Account
            WHERE Id = :accountId
            LIMIT 1
        ];

        if (accs.isEmpty()) {
            throw new AuraHandledException('Conta não encontrada para criação do usuário.');
        }

        Account acc = accs[0];

        User owner = [SELECT Id, UserRoleId FROM User WHERE Id = :acc.OwnerId LIMIT 1];
        if (owner.UserRoleId == null) {
            throw new AuraHandledException('O proprietário da conta precisa ter um cargo (User Role) para que o usuário possa ser criado.');
        }

        String nomeConta = acc.Name;
        String email = acc.PersonEmail;
        String documento = acc.CNPJ__c != null ? acc.CNPJ__c :
                        acc.APP_Passaporte__c != null ? acc.APP_Passaporte__c :
                        acc.RNE__c;

        if (String.isBlank(documento)) {
            throw new AuraHandledException('Documento não encontrado na conta.');
        }

        /*Contact contato;
        List<Contact> contatos = [SELECT Id, LastName, Email FROM Contact WHERE AccountId = :acc.Id LIMIT 1];
        contato = contatos[0];
        if (!contatos.isEmpty()) {
            contato = contatos[0];
        } else {
            contato = new Contact(
                LastName = nomeConta,
                AccountId = acc.Id
            );
            insert contato;
        }*/
        
        Boolean emailGerado = false;
        if (String.isBlank(email)) {
            String sufixo = acc.RecordType.DeveloperName == 'Acompanhante' ? 'acompanhante' : 'paciente';
            email = documento + sufixo + '@cliente.onco.' + aliasDaOrg;
            emailGerado = true;
        }

        String username = email + '.' + aliasDaOrg;

        String perfilLabel = tipoPerfil == 'Acompanhante' ? 'APP_Acompanhante' : 'APP_Paciente';

        List<Profile> perfis = [SELECT Id FROM Profile WHERE Name = :perfilLabel LIMIT 1];
        Integer tamanho = perfis.size();
        if (perfis.isEmpty()) {
            throw new AuraHandledException('Perfil não encontrado: ' + perfilLabel);
        }
        Profile perfil = perfis[0];

        User novoUsuario = new User(
            FirstName = null,
            LastName = nomeConta,
            Email = email,
            Username = username,
            Alias = documento.length() >= 8 ? documento.substring(0, 8) : documento,
            TimeZoneSidKey = 'America/Sao_Paulo',
            LocaleSidKey = 'pt_BR',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'pt_BR',
            ProfileId = perfil.Id,
            //ProfileId = '00eHa000004GHVdIAO',00eHa000004GHVdIAO
            ContactId = contato.Id
        );

        try {
            insert novoUsuario;
        } catch (Exception e) {
            throw new AuraHandledException('Falha ao criar o usuário: ' + e.getMessage());
        }

        if (emailGerado) {
            try {
                atualizarEmailsFuturo(acc.Id, contato.Id, email);
            } catch (Exception e) {
                System.debug('Erro ao chamar atualizarEmailsFuturo: ' + e.getMessage());
            }
        }

        try {
            atribuirPermissaoAsync(novoUsuario.Id, perfilLabel);
        } catch (Exception e) {
            System.debug('Erro ao chamar atribuirPermissaoAsync: ' + e.getMessage());
        }

        return novoUsuario;
    }

    @future
    public static void atribuirPermissaoAsync(Id userId, String nomePermissao) {
        if (String.isBlank(userId) || String.isBlank(nomePermissao)) {
            return;
        }

        try {
            PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = :nomePermissao LIMIT 1];

            List<PermissionSetAssignment> existentes = [
                SELECT Id
                FROM PermissionSetAssignment
                WHERE AssigneeId = :userId AND PermissionSetId = :ps.Id
                LIMIT 1
            ];

            if (existentes.isEmpty()) {
                PermissionSetAssignment psa = new PermissionSetAssignment(
                    AssigneeId = userId,
                    PermissionSetId = ps.Id
                );
                insert psa;
            }
        } catch (Exception e) {
            System.debug('Erro ao atribuir permissão: ' + e.getMessage());
        }
    }

    @future
    public static void atualizarEmailsFuturo(Id accountId, Id contactId, String email) {
        List<SObject> registrosParaAtualizar = new List<SObject>();

        if (!String.isBlank(accountId)) {
            registrosParaAtualizar.add(new Account(Id = accountId, PersonEmail = email));
        }

        if (!String.isBlank(contactId)) {
            registrosParaAtualizar.add(new Contact(Id = contactId, Email = email));
        }

        if (!registrosParaAtualizar.isEmpty()) {
            update registrosParaAtualizar;
        }
    }

    @AuraEnabled(cacheable=false)
    public static List<PacienteDTO> getPacientesPorAcompanhante(Id acompanhanteId) {
        // Consulta os pacientes vinculados ao acompanhante
        List<APP_JuncAcompanhante__c> juncoes = [
            SELECT APP_Paciente__c, 
                APP_Paciente__r.Name, 
                APP_Paciente__r.CNPJ__c,
                APP_Paciente__r.PersonContactId
            FROM APP_JuncAcompanhante__c
            WHERE APP_Acompanhantes__c = :acompanhanteId
        ];

        Set<Id> contactIds = new Set<Id>();
        for (APP_JuncAcompanhante__c j : juncoes) {
            if (j.APP_Paciente__r.PersonContactId != null) {
                contactIds.add(j.APP_Paciente__r.PersonContactId);
            }
        }

        // Map de ContactId para URL da foto do User
        Map<Id, String> contactIdToUserPhoto = new Map<Id, String>();

        if (!contactIds.isEmpty()) {
            for (User u : [
                SELECT ContactId, FullPhotoUrl, SmallPhotoUrl
                FROM User
                WHERE ContactId IN :contactIds
            ]) {
                if (u.FullPhotoUrl != null) {
                    contactIdToUserPhoto.put(u.ContactId, u.FullPhotoUrl);
                } else if (u.SmallPhotoUrl != null) {
                    contactIdToUserPhoto.put(u.ContactId, u.SmallPhotoUrl);
                }
            }
        }

        // Monta os DTOs com a imagem
        List<PacienteDTO> pacientes = new List<PacienteDTO>();

        for (APP_JuncAcompanhante__c junc : juncoes) {
            PacienteDTO paciente = new PacienteDTO();
            paciente.id = junc.APP_Paciente__c;
            paciente.nome = junc.APP_Paciente__r.Name;
            paciente.cpf = junc.APP_Paciente__r.CNPJ__c;
            paciente.dataNascimento = '';

            Id contactId = junc.APP_Paciente__r.PersonContactId;
            String photoUrl;

            if (contactId != null && contactIdToUserPhoto.containsKey(contactId)) {
                photoUrl = contactIdToUserPhoto.get(contactId);
            } else if (contactId != null) {
                photoUrl = '/sfsites/c/photo/profilephoto/' + contactId + '/T';
            } else {
                photoUrl = '/img/default/user_120.png';
            }

            paciente.icon = photoUrl;
            pacientes.add(paciente);
        }

        return pacientes;
    }

    public class PacienteDTO {
        @AuraEnabled public String id;
        @AuraEnabled public String nome;
        @AuraEnabled public String cpf;
        @AuraEnabled public String dataNascimento;
        @AuraEnabled public String icon;
    }




}