public without sharing class APP_UserProfileController {
    @AuraEnabled
    public static void atualizarPerfil(String firstName, String lastName, String phone, String mobilePhone, String email) {
        Id userId = UserInfo.getUserId();
        User u = [
            SELECT Id, ContactId, AccountId, Email
            FROM User
            WHERE Id = :userId
            LIMIT 1
        ];

        if (String.isNotBlank(email) && email.containsIgnoreCase('cliente.onco.')) {
            email = null;
        }

        User userToUpdate = new User(
            Id = u.Id,
            FirstName = firstName,
            LastName = lastName,
            Phone = phone,
            MobilePhone = mobilePhone
        );

        if (String.isNotBlank(email)) {
            userToUpdate.Email = email;
        }

        try {
            update userToUpdate;
        } catch (Exception ex) {
            System.debug('Erro ao atualizar o User: ' + ex.getMessage());
            //throw new AuraHandledException('Erro ao atualizar o perfil do usuário. Verifique permissões ou política de segurança.');
        }

        List<SObject> relatedUpdates = new List<SObject>();

        if ((u.ContactId != null || u.AccountId != null) && String.isNotBlank(email)) {
            if (u.ContactId != null) {
                relatedUpdates.add(new Contact(Id = u.ContactId, Email = email));
            }
            if (u.AccountId != null) {
                relatedUpdates.add(new Account(Id = u.AccountId, PersonEmail = email));
            }

            try {
                update relatedUpdates;
            } catch (Exception ex) {
                System.debug('Erro ao atualizar Contact ou Account: ' + ex.getMessage());
                //throw new AuraHandledException('Erro ao atualizar dados relacionados (Contato ou Conta): ' + ex.getMessage());
            }
        }
    }
}