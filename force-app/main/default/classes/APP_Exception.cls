public class APP_Exception extends Exception {
    public String endpoint;
    public Integer statusCode;
    public String responseBody;
    public String customMessage;
    
    public APP_Exception(String endpoint, Integer statusCode, String message, String responseBody) {
        this.customMessage = message;
        this.endpoint = endpoint;
        this.statusCode = statusCode;
        this.responseBody = responseBody;
    }
}