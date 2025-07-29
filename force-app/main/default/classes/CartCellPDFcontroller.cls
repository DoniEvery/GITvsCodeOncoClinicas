public with sharing class CartCellPDFcontroller {

    public String jsonData {get;set;}
    public IntegracaoPdfCartController.Response data {get;set;}

    public CartCellPDFcontroller(){
        this.jsonData = ApexPages.currentPage().getParameters().get('jsonData');
        if(String.isNotBlank(this.jsonData)) this.data = (IntegracaoPdfCartController.Response) JSON.deserialize(this.jsonData, IntegracaoPdfCartController.Response.class);
    }

}