public without sharing class APP_ChatUtils {
    public static String getUserType(Id userId) {
        if (userId == null) return 'Unknown';

        String prefix = String.valueOf(userId).substring(0, 3);

        if (prefix == '001') return 'Account';
        if (prefix == '003') return 'Contact';

        return 'Unknown';
    }
}