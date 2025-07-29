public without sharing class APP_AcompanhantesController {
    
    @AuraEnabled(cacheable=true)
    public static List<AcompanhanteWrapper> buscarAcompanhantes() {
        try {
            Id currentUserId = UserInfo.getUserId();
            Id pacienteAccountId = getAccountIdFromUser(currentUserId);
            
            if (pacienteAccountId == null) {
                throw new AuraHandledException('Usuário não possui conta de paciente associada');
            }
            
            List<APP_JuncAcompanhante__c> juncoes = [
                SELECT Id, APP_Acompanhantes__c, APP_Ativo__c,
                       APP_Acompanhantes__r.Name, 
                       APP_Acompanhantes__r.CNPJ__c,
                       APP_Acompanhantes__r.PersonMobilePhone,
                       APP_Acompanhantes__r.PersonEmail
                FROM APP_JuncAcompanhante__c 
                WHERE APP_Paciente__c = :pacienteAccountId 
                AND APP_Ativo__c = true
                ORDER BY APP_Acompanhantes__r.Name ASC
            ];
            
            List<AcompanhanteWrapper> acompanhantes = new List<AcompanhanteWrapper>();
            
            for (APP_JuncAcompanhante__c juncao : juncoes) {
                acompanhantes.add(new AcompanhanteWrapper(
                    juncao.APP_Acompanhantes__c,
                    juncao.APP_Acompanhantes__r.Name,
                    juncao.APP_Acompanhantes__r.CNPJ__c,
                    juncao.APP_Acompanhantes__r.PersonMobilePhone,
                    juncao.APP_Acompanhantes__r.PersonEmail
                ));
            }
            
            return acompanhantes;
            
        } catch (Exception e) {
            throw new AuraHandledException('Erro ao buscar acompanhantes: ' + e.getMessage());
        }
    }
    
    @AuraEnabled
    public static void criarAcompanhante(String nome, String cpf, String celular, String email) {
        try {
            // Validar se já existe um acompanhante com este CPF
            List<Account> existingAccounts = [
                SELECT Id, Name 
                FROM Account 
                WHERE CNPJ__c = :cpf 
                AND RecordType.DeveloperName = 'Acompanhante'
                LIMIT 1
            ];
            
            if (!existingAccounts.isEmpty()) {
                throw new AuraHandledException('Já existe um acompanhante cadastrado com este CPF');
            }
            
            // Obter ID do paciente atual
            Id currentUserId = UserInfo.getUserId();
            Id pacienteAccountId = getAccountIdFromUser(currentUserId);
            
            if (pacienteAccountId == null) {
                throw new AuraHandledException('Usuário não possui conta de paciente associada');
            }
            
            // Criar conta do acompanhante
            Id acompanhanteRecordTypeId = getAcompanhanteRecordTypeId();
            
            Account acompanhanteAccount = new Account(
                Name = nome,
                CNPJ__c = cpf,
                PersonMobilePhone = celular,
                PersonEmail = email,
                RecordTypeId = acompanhanteRecordTypeId,
                APP_Ativo__c = true,
                APP_IsAcompanhante__c = true
            );
            
            insert acompanhanteAccount;
            
            // Criar junção entre paciente e acompanhante
            APP_JuncAcompanhante__c juncao = new APP_JuncAcompanhante__c(
                APP_Paciente__c = pacienteAccountId,
                APP_Acompanhantes__c = acompanhanteAccount.Id,
                APP_Ativo__c = true
            );
            
            insert juncao;
            
            // Criar usuário para o acompanhante
            criarUsuarioAcompanhante(acompanhanteAccount);
            
        } catch (Exception e) {
            throw new AuraHandledException('Erro ao criar acompanhante: ' + e.getMessage());
        }
    }
    
    @AuraEnabled
    public static void atualizarAcompanhante(Id acompanhanteId, String celular, String email) {
        try {
            // Buscar a conta do acompanhante
            List<Account> acompanhanteAccounts = [
                SELECT Id, PersonMobilePhone, PersonEmail
                FROM Account 
                WHERE Id = :acompanhanteId 
                AND RecordType.DeveloperName = 'Acompanhante'
                LIMIT 1
            ];
            
            if (acompanhanteAccounts.isEmpty()) {
                throw new AuraHandledException('Acompanhante não encontrado');
            }
            
            Account acompanhanteAccount = acompanhanteAccounts[0];
            acompanhanteAccount.PersonMobilePhone = celular;
            acompanhanteAccount.PersonEmail = email;
            
            update acompanhanteAccount;
            
            // Atualizar usuário associado
            atualizarUsuarioAcompanhante(acompanhanteAccount);
            
        } catch (Exception e) {
            throw new AuraHandledException('Erro ao atualizar acompanhante: ' + e.getMessage());
        }
    }
    
    @AuraEnabled
    public static void removerAcompanhante(Id acompanhanteId) {
        try {
            // Verificar se o acompanhante pertence ao paciente atual
            Id currentUserId = UserInfo.getUserId();
            Id pacienteAccountId = getAccountIdFromUser(currentUserId);
            
            if (pacienteAccountId == null) {
                throw new AuraHandledException('Usuário não possui conta de paciente associada');
            }
            
            List<APP_JuncAcompanhante__c> juncoes = [
                SELECT Id, APP_Acompanhantes__c
                FROM APP_JuncAcompanhante__c 
                WHERE APP_Paciente__c = :pacienteAccountId 
                AND APP_Acompanhantes__c = :acompanhanteId
                AND APP_Ativo__c = true
                LIMIT 1
            ];
            
            if (juncoes.isEmpty()) {
                throw new AuraHandledException('Acompanhante não encontrado ou não autorizado');
            }
            
            // Desativar a junção
            APP_JuncAcompanhante__c juncao = juncoes[0];
            juncao.APP_Ativo__c = false;
            update juncao;
            
            // Verificar se o acompanhante ainda tem outras junções ativas
            List<APP_JuncAcompanhante__c> outrasJuncoes = [
                SELECT Id 
                FROM APP_JuncAcompanhante__c 
                WHERE APP_Acompanhantes__c = :acompanhanteId 
                AND APP_Ativo__c = true
                LIMIT 1
            ];
            
            // Se não tiver outras junções ativas, desativar o usuário
            if (outrasJuncoes.isEmpty()) {
                desativarUsuarioAcompanhante(acompanhanteId);
            }
            
        } catch (Exception e) {
            throw new AuraHandledException('Erro ao remover acompanhante: ' + e.getMessage());
        }
    }
    
    private static Id getAccountIdFromUser(Id userId) {
        List<User> users = [
            SELECT AccountId 
            FROM User 
            WHERE Id = :userId 
            AND AccountId != null
            LIMIT 1
        ];
        
        return users.isEmpty() ? null : users[0].AccountId;
    }
    
    private static Id getAcompanhanteRecordTypeId() {
        return Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Acompanhante').getRecordTypeId();
    }
    
    private static void criarUsuarioAcompanhante(Account acompanhanteAccount) {
        try {
            Profile acompanhanteProfile = [
                SELECT Id 
                FROM Profile 
                WHERE Name = 'APP_Acompanhante' 
                LIMIT 1
            ];
            
            String username = acompanhanteAccount.PersonEmail + '.acompanhante';
            
            User acompanhanteUser = new User(
                Username = username,
                Email = acompanhanteAccount.PersonEmail,
                FirstName = acompanhanteAccount.Name.split(' ')[0],
                LastName = acompanhanteAccount.Name.split(' ').size() > 1 ? 
                          acompanhanteAccount.Name.substring(acompanhanteAccount.Name.indexOf(' ') + 1) : '',
                Alias = acompanhanteAccount.Name.substring(0, Math.min(8, acompanhanteAccount.Name.length())),
                TimeZoneSidKey = 'America/Sao_Paulo',
                LocaleSidKey = 'pt_BR',
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = 'pt_BR',
                ProfileId = acompanhanteProfile.Id,
                IsActive = true
            );
            
            insert acompanhanteUser;
            
        } catch (Exception e) {
            System.debug('Erro ao criar usuário do acompanhante: ' + e.getMessage());
        }
    }
    
    private static void atualizarUsuarioAcompanhante(Account acompanhanteAccount) {
        try {
            List<User> acompanhanteUsers = [
                SELECT Id, Email, MobilePhone
                FROM User 
                WHERE AccountId = :acompanhanteAccount.Id 
                AND IsActive = true
                LIMIT 1
            ];
            
            if (!acompanhanteUsers.isEmpty()) {
                User acompanhanteUser = acompanhanteUsers[0];
                acompanhanteUser.Email = acompanhanteAccount.PersonEmail;
                acompanhanteUser.MobilePhone = acompanhanteAccount.PersonMobilePhone;
                
                update acompanhanteUser;
            }
            
        } catch (Exception e) {
            System.debug('Erro ao atualizar usuário do acompanhante: ' + e.getMessage());
        }
    }
    
    private static void desativarUsuarioAcompanhante(Id acompanhanteAccountId) {
        try {
            List<User> acompanhanteUsers = [
                SELECT Id 
                FROM User 
                WHERE AccountId = :acompanhanteAccountId 
                AND IsActive = true
            ];
            
            for (User acompanhanteUser : acompanhanteUsers) {
                acompanhanteUser.IsActive = false;
            }
            
            if (!acompanhanteUsers.isEmpty()) {
                update acompanhanteUsers;
            }
            
        } catch (Exception e) {
            System.debug('Erro ao desativar usuário do acompanhante: ' + e.getMessage());
        }
    }
    
    public class AcompanhanteWrapper {
        @AuraEnabled public String id;
        @AuraEnabled public String nome;
        @AuraEnabled public String cpf;
        @AuraEnabled public String celular;
        @AuraEnabled public String email;
        
        public AcompanhanteWrapper(String id, String nome, String cpf, String celular, String email) {
            this.id = id;
            this.nome = nome;
            this.cpf = cpf;
            this.celular = celular;
            this.email = email;
        }
    }
}