public virtual class ContactRepository {


    public List<Contact> findByIds (Set<String> contactIds) {
        return [SELECT Id, Name, Tipo_de_Medico__c, Atribuido_a__c FROM Contact WHERE Id IN :contactIds];
    }
}