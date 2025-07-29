public class AppBotComponent {
    
public static String getToken(String keyToSign){
    if(keyToSign == null){
        return null;
    }
    return EncodingUtil.base64Encode(
        Crypto.signWithCertificate(
            'RSA-SHA256',
            Blob.valueOf(keyToSign),
            'App_bot_component'
        )
    );
}
}