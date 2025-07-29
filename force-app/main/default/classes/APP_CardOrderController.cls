public without sharing class APP_CardOrderController {

    @AuraEnabled(cacheable=true)
    public static List<ConfigurableCardWrapper> getAvailableCards() {

        // Obtém o nome do perfil do usuário logado
        String userProfile = [
            SELECT Profile.Name 
            FROM User 
            WHERE Id = :UserInfo.getUserId()
        ].Profile.Name;

        List<APP_ConfigurableCard__c> cards = [
            SELECT Id, Name, Title__c, Content__c, Icon__c, DefaultOrder__c, APP_Perfil__c
            FROM APP_ConfigurableCard__c
            WHERE IsActive__c = true
            ORDER BY DefaultOrder__c ASC
        ];

        List<ConfigurableCardWrapper> result = new List<ConfigurableCardWrapper>();

        for (APP_ConfigurableCard__c c : cards) {
            result.add(new ConfigurableCardWrapper(c, userProfile));
        }

        return result;
    }

    @AuraEnabled(cacheable=true)
    public static List<Id> getUserCardOrder() {
        Id userId = UserInfo.getUserId();

        List<APP_UserCardOrder__c> userOrders = [
            SELECT CardId__c 
            FROM APP_UserCardOrder__c 
            WHERE UserId__c = :userId 
            ORDER BY Order__c ASC
        ];

        List<Id> result = new List<Id>();
        for (APP_UserCardOrder__c u : userOrders) {
            result.add(u.CardId__c);
        }
        return result;
    }

    @AuraEnabled
    public static void saveUserCardOrder(List<Id> cardIds) {
        Id userId = UserInfo.getUserId();

        List<APP_UserCardOrder__c> existingRecords = [
            SELECT Id, CardId__c 
            FROM APP_UserCardOrder__c 
            WHERE UserId__c = :userId
        ];

        Map<Id, APP_UserCardOrder__c> existingMap = new Map<Id, APP_UserCardOrder__c>();
        for (APP_UserCardOrder__c record : existingRecords) {
            existingMap.put(record.CardId__c, record);
        }

        List<APP_UserCardOrder__c> toUpsert = new List<APP_UserCardOrder__c>();

        for (Integer i = 0; i < cardIds.size(); i++) {
            Id cardId = cardIds[i];
            APP_UserCardOrder__c record;

            if (existingMap.containsKey(cardId)) {
                record = existingMap.get(cardId);
                record.Order__c = i;
            } else {
                record = new APP_UserCardOrder__c(
                    UserId__c = userId,
                    CardId__c = cardId,
                    Order__c = i
                );
            }

            toUpsert.add(record);
        }
        upsert toUpsert;
    }

    // Wrapper que envia dados do card + o perfil do usuário
    public class ConfigurableCardWrapper {
        @AuraEnabled public Id id;
        @AuraEnabled public String title;
        @AuraEnabled public String content;
        @AuraEnabled public String icon;
        @AuraEnabled public String perfil;
        @AuraEnabled public String userProfile;

        public ConfigurableCardWrapper(APP_ConfigurableCard__c c, String userProfile) {
            this.id = c.Id;
            this.title = c.Title__c;
            this.content = c.Content__c;
            this.icon = c.Icon__c;
            this.perfil = c.APP_Perfil__c;
            this.userProfile = userProfile;
        }
    }
}