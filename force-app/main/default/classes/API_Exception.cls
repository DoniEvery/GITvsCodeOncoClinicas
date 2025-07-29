public class API_Exception extends Exception {
    public String endpoint;
    public Integer statusCode;
    public String responseBody;
    public String customMessage;

    public API_Exception(String message, String endpoint, Integer statusCode, String responseBody) {
        this.customMessage = message;
        this.endpoint = endpoint;
        this.statusCode = statusCode;
        this.responseBody = responseBody;
    }
}