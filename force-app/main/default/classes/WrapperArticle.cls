public class WrapperArticle {

    @AuraEnabled public string id;
    @AuraEnabled public string title;
    @AuraEnabled public string numero;
    @AuraEnabled public string summary;    
    @AuraEnabled public string name;    
    @AuraEnabled public string question;
    @AuraEnabled public string answer;
    @AuraEnabled public boolean isvisibleCsp;
    @AuraEnabled public string assuntoUnidade;
    @AuraEnabled public string motivoAssuntoUnidade;
    @AuraEnabled public string status;

   public WrapperArticle(Knowledge__kav ar)
   {
       this.id = ar.Id;
       this.title = ar.Title;
       this.numero = ar.ArticleNumber;
       this.name = '/'+ar.Id;
       this.question = ar.Question__c;
       this.answer = ar.Answer__c;
       this.summary = ar.Summary;
       this.isvisibleCsp = ar.IsVisibleInCsp;
       this.assuntoUnidade = ar.AssuntoUnidade__c;
       this.motivoAssuntoUnidade = ar.AssuntoUnidade__r.MotivoCaso__c;
       this.status = ar.PublishStatus;

   }
}