public with sharing class EditAccount {
    public String name            {get;set;}
    public String contactName     {get;set;} 
    
    public String email           {get;set;}
    public String phone           {get;set;}
    public String extension       {get;set;}
    public String cell_phone      {get;set;}
    public String fax             {get;set;}
     public String Title             {get;set;}
    
    public String billingStreet     {get;set;}
    public String billingline2      {get;set;}    
    public String billingCity       {get;set;}
    public String BillingState      {get;set;}
    public String BillingPostalCode {get;set;}
    public String billingCountry    {get;set;}

    public String shippingStreet     {get;set;}
    public String shippingline2     {get;set;}    
    public String shippingCity       {get;set;}
    public String shippingState      {get;set;}
    public String shippingPostalCode {get;set;}
    public String shippingCountry    {get;set;}
    
    public Account acc;
    public Account accEdit; 
    public EditAccount(ApexPages.StandardController controller) {
        this.acc = (Account)controller.getRecord();
        accEdit = [Select Name,Title__c,Contact_Name__c, Email__c, Phone, Cell_Phone__c, Extension__c, Fax, BillingStreet, BillingCity, BillingState, BillingPostalCode, Billingcountry, ShippingStreet, ShippingCity,  
            ShippingState, ShippingPostalCode, ShippingCountry From Account Where id=:acc.Id];
        try{
        	name  		  = accEdit.Name;
        	email   	  = accEdit.Email__c;           
        	phone         = accEdit.Phone;
        	cell_phone    = accEdit.Cell_Phone__c;
        	extension     = accEdit.Extension__c;
        	fax           = accEdit.Fax; 
            Title		  =accEdit.Title__c;
            contactName	  =accEdit.Contact_Name__c;	 
        	List<String> btemp = accEdit.BillingStreet.split('\n');
        	billingStreet     = btemp[0];
        	billingline2      = btemp.size()>1?btemp[1]:'';
        	billingCity       = accEdit.BillingCity;
        	BillingState      = accEdit.BillingState;
        	BillingPostalCode = accEdit.BillingPostalCode;
        	billingCountry    = accEdit.BillingCountry;

	        List<String> stemp = accEdit.ShippingStreet.split('\n');
    	    shippingStreet     = stemp[0];
        	shippingline2      = stemp.size()>1?stemp[1]:'';    
        	shippingCity       = accEdit.ShippingCity;
			shippingState      = accEdit.BillingState;
        	shippingPostalCode = accEdit.BillingPostalCode;
        	shippingCountry    = accEdit.ShippingCountry;        
    	}catch(Exception e){}
    }
    
    public PageReference saveAcc(){
    	String ph='';
    	if( phone!= null && phone!= '' && phone.length()>=10){
    		ph = phone.replaceAll('\\D', '');
	        if(ph.length()<10){
				ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'invalid Formate: Primary Phone must have 10 digits'));
    			return null;		        
	        }
	        ph = ph.substring(0,3)+'-'+ph.substring(3,6)+'-'+ph.substring(6,10);
    	}else{
    		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'invalid Formate: Primary Phone must have 10 digits'));
    		return null;
    	}
    	String fx='';
    	if( fax!= null && fax!= '' && fax.length()>=10){
    		fx = fax.replaceAll('\\D', '');
	        if(fx.length()<10){
				ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'invalid Formate: Fax must have 10 digits OR leave this field empty'));
    			return null;		        
	        }
	        else
	        fx = fx.substring(0,3)+'-'+fx.substring(3,6)+'-'+fx.substring(6,10);
    	}else if(fax == null || fax =='' || fax.length()==0){
    		//DO nothing
    	}else{
    		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'invalid Formate: Fax must have 10 digits OR leave this field empty'));
    		return null;
    	}
    	
    	
    	String cp='';
    	if( cell_phone != null && cell_phone!= '' && cell_phone.length()>=10){
    		cp = cell_phone.replaceAll('\\D', '');
    		if(cp.length()<10){
    			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Invalid Formate: Cell Phone must have 10 digits OR leave this field empty'));
    			return null;
    		}
	        cp = cp.substring(0,3)+'-'+cp.substring(3,6)+'-'+cp.substring(6,10);
    	}else if(cell_phone == null || cell_phone =='' || cell_phone.length()==0){
    		//DO nothing
    	}else{
    		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Invalid Formate: Cell Phone must have 10 digits OR leave this field empty'));
    		return null;
    	}
        //String cp	 = cell_phone!=null && cell_phone!='' && cell_phone.length()>=10?cell_phone.replaceAll('\\D', ''):'';
        //String ext = extension!=null && extension!=''?extension.replaceAll('\\D', ''):'';

        //cp = cp!=null && cp!=''?cp.substring(0,3)+'-'+cp.substring(3,6)+'-'+cp.substring(6,10):'';
        //ext=ext!=null && ext!='' ?ext.substring(0,3)+'-'+ext.substring(3,6)+'-'+ext.substring(6,10):'';
        
        acc.Name     = name;
        acc.Contact_Name__c= contactName;
        acc.Email__c = email;           
        acc.Phone    = ph;// phone;
        acc.Fax      = fx; //fax
        acc.Cell_Phone__c = cp;// cell_phone;
		acc.Extension__c  = extension;//extension;         
        acc.Title__c	  = Title;
        acc.BillingStreet     = billingStreet+'\n'+billingline2; 
        acc.BillingCity       = billingCity;
        acc.BillingState      = BillingState;        
        acc.BillingPostalCode = BillingPostalCode;
        acc.BillingCountry    = billingCountry;

        acc.ShippingStreet    = shippingStreet+'\n'+shippingline2;
        acc.ShippingCity      = shippingCity;
        acc.ShippingState     = shippingState;
        acc.ShippingPostalCode = shippingPostalCode;
        acc.ShippingCountry    = shippingCountry;
        update acc;
        return new PageReference('/index/index?id='+acc.id);    
    }
    
    public static testMethod void editAccountTest(){
        PageReference pageRef = Page.EditContact;
        Test.setCurrentPageReference(pageRef);
        Account ac = new Account(Name='Test', User_Name__c = 'tester', Email__c = 'test@example.com'); 
        
        
        insert ac;          
        
                         
        ApexPages.StandardController sc = new ApexPages.standardController(ac);
        
        EditAccount ea = new EditAccount(sc);
        
         
        ea.phone='12345678900';
		ea.acc.Phone=ea.phone;
	
		
		ea.cell_phone='121234567899';		
		ea.acc.Cell_Phone__c=ea.cell_phone;
		
		ea.fax='1234567890';
		ea.acc.Fax=ea.fax;
		
        PageReference pr = ea.saveAcc();  
    }
    public static testMethod void editAccountTest2(){
   //     PageReference pageRef = Page.EditContact;
   //     Test.setCurrentPageReference(pageRef);
        Account ac = new Account(Name='Test', User_Name__c = 'tester', Email__c = 'test@example.com'); 
        ac.BillingStreet='adsf \n dsfa \n  eswf\n';
        ac.ShippingStreet='adsf \n dsfa \n  eswf\n';
        insert ac;          
        
                         
        ApexPages.StandardController sc = new ApexPages.standardController(ac);
        
        EditAccount ea = new EditAccount(sc);
        ea.phone='';
		ea.acc.Phone=ea.phone;
	
		
		ea.cell_phone='';		
		ea.acc.Cell_Phone__c=ea.cell_phone;
		
		ea.fax='';
		ea.acc.Fax=ea.fax;
		
        PageReference pr = ea.saveAcc();  
    }
     public static testMethod void editAccountTest3(){
   //     PageReference pageRef = Page.EditContact;
   //     Test.setCurrentPageReference(pageRef);
        Account ac = new Account(Name='Test', User_Name__c = 'tester', Email__c = 'test@example.com'); 
        insert ac;          
        
                         
        ApexPages.StandardController sc = new ApexPages.standardController(ac);
        
        EditAccount ea = new EditAccount(sc);
        ea.phone='111-111-111';
		ea.acc.Phone=ea.phone;
	
		
		ea.cell_phone='111-111-11';		
		ea.acc.Cell_Phone__c=ea.cell_phone;
		
		ea.fax='111-111-111';
		ea.acc.Fax=ea.fax;
		
        PageReference pr = ea.saveAcc();  
    }
       
    
    
    
}