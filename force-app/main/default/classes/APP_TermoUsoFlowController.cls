public without sharing class APP_TermoUsoFlowController {
    
    public class TermoUsoInput {
        @InvocableVariable(required=true)
        public String termContent;
        
        @InvocableVariable(required=true)
        public Id userId;
    }

    public class TermoUsoOutput {
        @InvocableVariable
        public String hash;
    }

    @InvocableMethod(label='Gerar Hash Termo de Uso')
    public static List<TermoUsoOutput> gerarHash(List<TermoUsoInput> inputs) {
        List<TermoUsoOutput> resultados = new List<TermoUsoOutput>();

        for (TermoUsoInput input : inputs) {
            TermoUsoOutput resultado = new TermoUsoOutput();

            String conteudoParaHash = input.termContent + input.userId;
            Blob hashBlob = Crypto.generateDigest('SHA-256', Blob.valueOf(conteudoParaHash));
            resultado.hash = EncodingUtil.base64Encode(hashBlob);

            resultados.add(resultado);
        }

        return resultados;
    }
}