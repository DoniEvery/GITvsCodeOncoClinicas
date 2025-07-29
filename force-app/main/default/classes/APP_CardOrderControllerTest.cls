@isTest
private class APP_CardOrderControllerTest {

    @testSetup
    static void setupData() {
        List<APP_ConfigurableCard__c> cards = new List<APP_ConfigurableCard__c>{
            new APP_ConfigurableCard__c(Name = 'Card 1', Title__c = 'Title 1', Content__c = 'Content 1', Icon__c = 'utility:info', DefaultOrder__c = 1, IsActive__c = true),
            new APP_ConfigurableCard__c(Name = 'Card 2', Title__c = 'Title 2', Content__c = 'Content 2', Icon__c = 'utility:info', DefaultOrder__c = 2, IsActive__c = true),
            new APP_ConfigurableCard__c(Name = 'Inactive Card', Title__c = 'Title 3', Content__c = 'Content 3', Icon__c = 'utility:close', DefaultOrder__c = 3, IsActive__c = false)
        };
        insert cards;

        // Cria ordem de cartão para o usuário atual
        Id userId = UserInfo.getUserId();
        List<APP_UserCardOrder__c> orders = new List<APP_UserCardOrder__c>{
            new APP_UserCardOrder__c(UserId__c = userId, CardId__c = cards[0].Id, Order__c = 1),
            new APP_UserCardOrder__c(UserId__c = userId, CardId__c = cards[1].Id, Order__c = 0)
        };
        insert orders;
    }

    @isTest
    static void testGetAvailableCards() {
        Test.startTest();
        List<APP_CardOrderController.ConfigurableCardWrapper> result = APP_CardOrderController.getAvailableCards();
        Test.stopTest();

        System.assertEquals(2, result.size(), 'Deve retornar apenas os cartões ativos');
        System.assertNotEquals('Inactive Card', result[0].title, 'Cartão inativo não deve aparecer');
    }

    @isTest
    static void testGetUserCardOrder() {
        Test.startTest();
        List<Id> orderedIds = APP_CardOrderController.getUserCardOrder();
        Test.stopTest();

        System.assertEquals(2, orderedIds.size(), 'Deve retornar 2 registros de ordem de cartão');
    }

    @isTest
    static void testSaveUserCardOrder_UpdateAndInsert() {
        APP_ConfigurableCard__c newCard = new APP_ConfigurableCard__c(
            Name = 'Card 3',
            Title__c = 'Title 3',
            Content__c = 'Content 3',
            Icon__c = 'utility:add',
            DefaultOrder__c = 3,
            IsActive__c = true
        );
        insert newCard;

        List<APP_ConfigurableCard__c> allCards = [SELECT Id FROM APP_ConfigurableCard__c WHERE IsActive__c = true];

        // Nova ordem: [Card 3, Card 1]
        List<Id> newOrder = new List<Id>{ newCard.Id, allCards[0].Id };

        Test.startTest();
        APP_CardOrderController.saveUserCardOrder(newOrder);
        Test.stopTest();

        List<APP_UserCardOrder__c> savedOrders = [
            SELECT UserId__c, CardId__c, Order__c 
            FROM APP_UserCardOrder__c 
            WHERE UserId__c = :UserInfo.getUserId()
        ];
        System.assertEquals(true, savedOrders.size() >= 3, 'Deve conter pelo menos três registros de ordem de cartão após inserção');
    }
}