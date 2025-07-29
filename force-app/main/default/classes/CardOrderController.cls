public with sharing class CardOrderController {

    /*
    @AuraEnabled(cacheable=true)
    public static List<ConfigurableCardWrapper> getAvailableCards() {
        List<ConfigurableCard__c> cards = [
            SELECT Id, Name, Title__c, Content__c, Icon__c, DefaultOrder__c
            FROM ConfigurableCard__c
            WHERE IsActive__c = true
            ORDER BY DefaultOrder__c ASC
        ];

        List<ConfigurableCardWrapper> result = new List<ConfigurableCardWrapper>();
        for (ConfigurableCard__c c : cards) {
            result.add(new ConfigurableCardWrapper(c));
        }
        return result;
    }

    @AuraEnabled(cacheable=true)
    public static List<Id> getUserCardOrder() {
        Id userId = UserInfo.getUserId();

        List<UserCardOrder__c> userOrders = [
            SELECT CardId__c 
            FROM UserCardOrder__c 
            WHERE UserId__c = :userId 
            ORDER BY Order__c ASC
        ];

        List<Id> result = new List<Id>();
        for (UserCardOrder__c u : userOrders) {
            result.add(u.CardId__c);
        }
        return result;
    }

    @AuraEnabled
    public static void saveUserCardOrder(List<Id> cardIds) {
        Id userId = UserInfo.getUserId();

        // Consulta registros existentes do usuário
        List<UserCardOrder__c> existingRecords = [
            SELECT Id, CardId__c 
            FROM UserCardOrder__c 
            WHERE UserId__c = :userId
        ];

        // Mapeia registros existentes por CardId
        Map<Id, UserCardOrder__c> existingMap = new Map<Id, UserCardOrder__c>();
        for (UserCardOrder__c record : existingRecords) {
            existingMap.put(record.CardId__c, record);
        }

        List<UserCardOrder__c> toUpsert = new List<UserCardOrder__c>();

        for (Integer i = 0; i < cardIds.size(); i++) {
            Id cardId = cardIds[i];
            UserCardOrder__c record;

            if (existingMap.containsKey(cardId)) {
                // Atualiza registro existente
                record = existingMap.get(cardId);
                record.Order__c = i;
            } else {
                // Cria novo registro
                record = new UserCardOrder__c(
                    UserId__c = userId,
                    CardId__c = cardId,
                    Order__c = i
                );
            }

            toUpsert.add(record);
        }
        upsert toUpsert;
    }
    
    public class ConfigurableCardWrapper {
        @AuraEnabled public Id id;
        @AuraEnabled public String title;
        @AuraEnabled public String content;
        @AuraEnabled public String icon;

        public ConfigurableCardWrapper(ConfigurableCard__c c) {
            this.id = c.Id;
            this.title = c.Title__c;
            this.content = c.Content__c;
            this.icon = c.Icon__c;
        }
    }
        */
}