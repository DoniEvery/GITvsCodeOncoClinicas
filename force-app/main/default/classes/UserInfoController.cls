public with sharing class UserInfoController {
    @AuraEnabled(cacheable=true)
    public static String getCurrentUserId() {
        return UserInfo.getUserId();
    }
}