public class APP_ApiIdentificacaoClienteRespostaDTO {
    
    public Integer id_person;
    public String ds_person;
    public String ds_docnumber2;
    public String dt_born;
    public String ds_emailprincipal;
    public String ds_emailalternativo;
    public String ds_ddicel;
    public String ds_dddcel;
    public String ds_numcel;  
    public String message = '';
    
    public APP_ApiIdentificacaoClienteRespostaDTO() {
        this.id_person = 000000;
         this.ds_person = '';
         this.ds_docnumber2 = '';
         this.dt_born = '';
         this.ds_emailprincipal = '';
         this.ds_ddicel = '';
         this.ds_dddcel = '';
         this.ds_numcel = '';
    }
    
}