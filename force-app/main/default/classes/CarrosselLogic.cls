public class CarrosselLogic {
    //Testes Ok
    public static List<Emails_do_Contato__c> getEmailsFromContact(string idContact) 
    {
        List<Emails_do_Contato__c> emailsContact = 
            [SELECT
             	Contato__c, 
             	CreatedById,
             	Data__c,
             	E_mail__c,
             	Name,
             	Invalido__c,
             	Nao_engajado__c,
             	OwnerId,
             	LastModifiedById
             		FROM Emails_do_Contato__c
            			WHERE Contato__c = :idContact];
        
        return emailsContact;
    }
    
    //Testes Ok
    public static boolean iSEmailNotEngajed(Emails_do_Contato__c objectEmail)
    {
       	if (objectEmail.Nao_engajado__c)
            return true;
        
        return false; 
    }
    
    //Testes Ok
    public static boolean iSEmailInvalid(Emails_do_Contato__c objectEmail)
    {
		if (objectEmail.Invalido__c)
        	return true;
        
        return false;
    }
    
	//Testes Ok
    public static void updateMainEmail(Contact contato, List<Emails_do_Contato__c> emailsContactList)
    {
        for (Emails_do_Contato__c email : emailsContactList)
        {
            if(iSEmailInvalid(email) == false && iSEmailNotEngajed(email) == false)
            {
				contato.Email = email.E_mail__c;
                break;
            }
        }
        
        if(!isAnyEmailAvailableAndEngajed(contato, emailsContactList))
        {
            contato.Contato_sem_Email_engajado__c = true;
        }
    }
    
    //Teste Ok 
    public static boolean isAnyEmailAvailableAndEngajed(Contact contato, List<Emails_do_Contato__c> emailsContactList)
    {
        for (Emails_do_Contato__c email : emailsContactList)
        {
            if(iSEmailInvalid(email) == false && iSEmailNotEngajed(email) == false)
				return true;
        }
        return false;
    }
    
    //Testes Ok
    public static boolean isEmailInList(List<Emails_do_Contato__c> emails, string emailContact)
    {
        for (Emails_do_Contato__c emailAux : emails)
        {
            if (emailContact == emailAux.E_mail__c)
                return true;
        }
        return false;
    }
    
    //Testes OK
    public static void createEmailContact(Contact contato)
    {
        
       	List<Emails_do_Contato__c> auxListEmailsContact = new List<Emails_do_Contato__c>(); 
        
        if(contato.Engajamento__c == 'Inválido')
        {
            auxListEmailsContact.add(new Emails_do_Contato__c(E_mail__c = contato.Email, 
                                                              Contato__c = contato.Id,
                                                              Invalido__c = true,
                                                              Data__c = date.today()));
        }     
        else if(contato.Engajamento__c == 'Não engajado')
        {
            auxListEmailsContact.add(new Emails_do_Contato__c(E_mail__c = contato.Email, 
                                                              Contato__c = contato.Id,
                                                              Nao_engajado__c = true,
                                                              Data__c = date.today()));
        }
        
        insert auxListEmailsContact;   
    }
    
    //Testes OK
    public static void updateEmailsContact(Contact contato, List<Emails_do_Contato__c> emailsContact)
    {
        List<Emails_do_Contato__c> auxListEmailsContact = new List<Emails_do_Contato__c>();
 
        for (Emails_do_Contato__c email : emailsContact)
        { 
            if(contato.Email == email.E_mail__c)
            {
                if(contato.Engajamento__c == 'Inválido')
                {
                    email.Invalido__c = true;
                    email.Data__c = date.today();
                }     
                else if(contato.Engajamento__c == 'Não engajado')
                {
                    email.Nao_engajado__c = true;
                    email.Data__c = date.today();
                }
                update email;
            }                  
        }              
    }
    
    //Ok
    public static void mainFunction(Contact contato)
    {
        
        List<Emails_do_Contato__c> emailsContactList = getEmailsFromContact(contato.Id);
        
        //Criar um contato quando a lista vier vazia - Ok
        if(emailsContactList.isEmpty() || emailsContactList == null)
        {
            createEmailContact(contato);
            updateMainEmail(contato, emailsContactList);
            return;
        }
        else
        {
            // Quando a lista não vier vazia e o email existir na lista, fazer update. -OK
            if(isEmailInList(emailsContactList, contato.Email))
            {
                updateEmailsContact(contato, emailsContactList);
                updateMainEmail(contato, emailsContactList);
                return;
            }
                   
            
            // Quando a lista não vier vazia e o email não existir na lista, criar email
            if(!isEmailInList(emailsContactList, contato.Email))
            {
                createEmailContact(contato);
                updateMainEmail(contato, emailsContactList);
                return;
            }  
        }      
    }
}