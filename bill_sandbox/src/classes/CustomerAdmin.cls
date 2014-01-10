public with sharing class CustomerAdmin {
    
    public  Account acc          {get;set;}    
    public  String  facility_name {get;set;}
    public  String  pr_phone      {get;set;}
    public  String  contactName   {get;set;}
    public  String  title         {get;set;}
    public  String  email         {get;set;}
    public  String  extention     {get;set;}
    public  String  cell_phone    {get;set;}
    public  String  fax           {get;set;}
    public  String  FirstName     {get;set;}
    public  String  LastName      {get;set;}
    
    public  String  ba_line1      {get;set;}
    public  String  ba_line2      {get;set;}
    public  String  ba_city       {get;set;}
    public  String  ba_state      {get;set;}
    public  String  ba_zip        {get;set;}
    public  String  ba_country    {get;set;}
    
    public  String  ma_line1      {get;set;}
    public  String  ma_line2      {get;set;}
    public  String  ma_city       {get;set;}
    public  String  ma_state      {get;set;}
    public  String  ma_zip        {get;set;}
    public  String  ma_country    {get;set;}
    
    public  String  result        {get;set;}
    public  List<Contact> cust    {get;set;}
    public  String type           {get;set;}
    public  String adminId        {get;set;}
    private String user_name      {get;set;}
    private String password       {get;set;} 
    public  String custId         {get;set;}
    public boolean isSuccess      {get;set;}
    List<String> cust_fields;
    
    public Boolean dupChk = false;

    public ID accId = ApexPages.CurrentPage().getParameters().get('id');
    
    public String tab {get;set;}
    
    public CustomerAdmin(ApexPages.StandardController c) {
        //this.acc = (Account)c.getRecord();
        tab = Apexpages.currentPage().getParameters().get('tab');      
        if(tab == null){
            tab = 'login';
        }
    }
    
    public void setUser_Name(String s){
        user_name = s;
    	system.debug(s);
    }
    
    public String getUser_Name(){
    	
        return user_name;
    }

    public void setPassword(String s){
        password = s;
    }
    
    public String getPassword(){
        return password;
    }
    
    //terms condition
    public void requiredFields()
   {
        if(validate()){
            
            isSuccess=true;
        }else{
            isSuccess = false;
        }
    } 
    
    
    
    public Pagereference next(){
   		requiredFields(); 
      	if(!isSuccess){
        	return null;
      	}
  /*      list<Contact> u=[select id from Contact where User_Name__c=:user_name];
        if(u.size()>0)
         {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'This username already exists. Please enter a different username.'));
            return null;
        }
    */    
    /*    if(pr_phone.length()<10){
        	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Primary Phone must be 10 digits  '));
        	return null;
        }
        if(cell_phone.length()<10){
        	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Cell Phone must be 10 digits  '));
        	return null;
        }
        if(extention.length()<10){
        	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Extension must be 10 digits  '));
        	return null;
        }
      */    
        Cookie cust_admin = new Cookie('cust_admin',facility_name+','+contactName+','+title+','+user_name+','+pr_phone+','+extention+','+cell_phone+','+fax+','+email+','+ba_line1+','+ba_line2+','+ba_city+','+ba_state+','+ba_zip+','+ba_country+','+ma_line1+','+ma_line2+','+ma_city+','+ma_state+','+ma_zip+','+ma_country,null,-1,false);
        ApexPages.currentPage().setCookies(new Cookie[]{cust_admin});
        Pagereference ref = new Pagereference('/index/termsCondition');
        return ref;
    }
    
    private boolean validate(){
    	//system.debug(user_name);
        boolean isvalid = true;
       
         
        if(!isValid(facility_name)){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Required Field Missing: Facility Name')); 
            isvalid = false;
        }
       /* if(!isValid(fax) || fax.length()<10){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Required Field Missing OR Incorrect format: Fax')); 
            isvalid = false;
        }else{
   	        String fx = fax.replaceAll('\\D', '');
            fax = fx.substring(0,3)+'-'+fx.substring(3,6)+'-'+fx.substring(6,10);				
        }
        */
        
      String fx='';
    	if( fax != null && fax!= '' && fax.length()>=10){
    		fx = fax.replaceAll('\\D', '');
    	system.debug(fx);
    		if(fx.length()<10){
    			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Invalid Formate: Fax must have 10 digits OR leave this field empty'));
    			isvalid = false;
    			//return null;
    		}
    		else
	        fax = fx.substring(0,3)+'-'+fx.substring(3,6)+'-'+fx.substring(6,10);
    	system.debug(fax);
    	}else if(fax == null || fax =='' || fax.length()==0){
    		//DO nothing
    	}else{
    		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Invalid Formate: Fax must have 10 digits OR leave this field empty'));
    		isvalid = false;
    		//return null;
    	}
      
        
        
       if(!isValid(pr_phone) || pr_phone.length()<10){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Required Field Missing OR Incorrect format: Primary Phone')); 
            isvalid = false;
        }else{
   	        String ph = pr_phone.replaceAll('\\D', '');
            pr_phone = ph.substring(0,3)+'-'+ph.substring(3,6)+'-'+ph.substring(6,10);				
        }
        if(isValid(cell_phone) && cell_phone.length()<10){
        	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,'Incorrect Format: Cell Phone must have 10 digits OR leave this field empty'));
        	isvalid=false;
        }else if(!isvalid(cell_phone)){
        	//Do nothing
        }else{
            String cp  = cell_phone.replaceAll('\\D', '');
            cell_phone = cp.substring(0,3)+'-'+cp.substring(3,6)+'-'+cp.substring(6,10);
        }
        if(!isValid(contactName)){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Required Field Missing: Contact Name')); 
            isvalid = false;
        }
        if(!isValid(title)){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Required Field Missing: Title')); 
            isvalid = false;
        }
        if(!isValid(email)){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Required Field Missing: Email')); 
            isvalid = false;
        }
        
         if(user_name==null || user_name=='')
     		{   
        		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Required Field Missing: User Name'));
            	isvalid = false;
    		}
        else 
        {
	        list<Contact> u=[select id from Contact where User_Name__c=:user_name];
	        if(u.size()>0)
		         {
		         	ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'This username already exists. Please enter a different username.'));
		            isvalid = false;
		         }
        } 
        
    /*    if(!isValid(user_name)){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Required Field Missing: User Name')); 
            isvalid = false;
        } */
        if(!isValid(ba_line1)){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Required Field Missing: Billing Address Line 1')); 
            isvalid = false;
        }
        if(!isValid(ba_city)){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Required Field Missing: Billing Address City')); 
            isvalid = false;
        }
        if(!isValid(ba_state)){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Required Field Missing: Billing Address State/Province')); 
            isvalid = false;
        }
        if(!isValid(ba_zip)){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Required Field Missing: Billing Address Zip/Postal Code')); 
            isvalid = false;
        }
        if(!isValid(ba_country)){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Required Field Missing: Billing Address Country')); 
            isvalid = false;
        }
        if(!isValid(ma_line1)){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Required Field Missing: Mailing Address Line 1')); 
            isvalid = false;
        }
        if(!isValid(ma_city)){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Required Field Missing: Mailing Address City')); 
            isvalid = false;
        }
        if(!isValid(ma_state)){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Required Field Missing: Mailing Address State/Province')); 
            isvalid = false;
        }
        if(!isValid(ma_zip)){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Required Field Missing: Mailing Addres Zip/Postal Code')); 
            isvalid = false;  
        }
        if(!isValid(ma_country)){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Required Field Missing: Mailing Address Country')); 
            isvalid = false;
        }
		if(!isValid(ma_city)){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Required Field Missing: Mailing Address City')); 
            isvalid = false;
        }
        return isvalid;
    }
     private boolean isValid(string val){
        return val == null ? false : val.trim().length() == 0 ? false: true;
    }
    
    public PageReference login(){
        String user = getUser_Name();
      //  system.debug(user);
        String pass = getPassword();
        PageReference ref;
        cust =  [Select Id, AccountId, Type__c from contact where User_Name__c  =: user and Password__c =: pass];
        if(cust.size()>0){
            //try{
            result = 'Correct';
            type = cust[0].Type__c;
            custId = cust[0].Id;
            adminId = cust[0].AccountId;
            Cookie username = new Cookie('username',user,'/index',-1,false);
            system.debug(user);
            Cookie customertype = new Cookie('customertype',type,'/index',-1,false);
            ApexPages.currentPage().setCookies(new Cookie[]{username});
          system.debug(username.getValue());
            ApexPages.currentPage().setCookies(new Cookie[]{customertype});
            //ref = new PageReference('/index/session?t='+type+'&u='+user+'&id='+cust[0].Accountid);
            ref = new PageReference('/index/index?id='+cust[0].Accountid); 
            }
            //catch(Exception e){
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'ID not exit'));
            //  return page.ErrorPage;
            //}
        else{
            result = 'Incorrect Userame or Password. Please try again...';
            ref = null;
        }
        return ref;
    }

    public PageReference signUp(){
    	save();
        if(dupChk==false){
           PageReference msg = Page.message;
           msg.setRedirect(true);
           return msg;
        }
        else 
            return null;
    }
    
    public void save(){      
        try{
            dupChk=false;
            Cookie cust_cks = Apexpages.currentPage().getCookies().get('cust_admin');
            if(cust_cks != null){
                String cust_data =  cust_cks.getValue();
                if(cust_data != ''){
                    cust_fields =  cust_data.split(',');
                }
            }
/*          String ph			   = cust_fields[4].replaceAll('\\D', '');
            String cp			   = cust_fields[6].replaceAll('\\D', '');
            String ext			   = cust_fields[5].replaceAll('\\D', '');
            ph=ph.substring(0,3)+'-'+ph.substring(3,6)+'-'+ph.substring(6,10);				
            cp=cp.substring(0,3)+'-'+cp.substring(3,6)+'-'+cp.substring(6,10);				
            ext=ext.substring(0,3)+'-'+ext.substring(3,6)+'-'+ext.substring(6,10);				
  */         
            Account account = new Account();
            account.Name           = cust_fields[0]; 
            account.Contact_Name__c= cust_fields[1];
            account.Title__c	   = cust_fields[2];	
            account.User_Name__c   = cust_fields[3];
            account.Phone          = cust_fields[4];
            account.Extension__c   = cust_fields[5];
            account.Cell_Phone__c  = cust_fields[6];
            account.Fax            = cust_fields[7];
            account.Email__c       = cust_fields[8];
            
            account.BillingStreet     = cust_fields[9]+'\n'+cust_fields[10];
            account.BillingCity       = cust_fields[11];
            account.BillingState      = cust_fields[12];
            account.BillingPostalCode = cust_fields[13];
            account.BillingCountry    = cust_fields[14];
            
            account.ShippingStreet     = cust_fields[15]+'\n'+cust_fields[16];
            account.ShippingCity       = cust_fields[17];
            account.ShippingState      = cust_fields[18];
            account.ShippingPostalCode = cust_fields[19];
            account.ShippingCountry    = cust_fields[20];
            
            insert account;
            
            List<String> name = cust_fields[1].split(' ');
            Contact ca = new Contact();
            ca.FirstName    = name.size()>1?name[0]:'';
            ca.LastName     = name[name.size()-1];
            ca.Title   		= cust_fields[2];
            ca.User_Name__c = account.User_Name__c;
            ca.AccountId    = account.Id;
            ca.Email        = account.Email__c;
            ca.Type__c      = 'Account Administrator';
            ca.Fax          = account.Fax;
            ca.Phone        = account.Phone;
            ca.MobilePhone  = account.Cell_Phone__c;
            ca.Extension__c = account.Extension__c;
            
            ca.MailingStreet     = cust_fields[15]+'\n'+cust_fields[16];
            ca.MailingCity       = cust_fields[17];
            ca.MailingState      = cust_fields[18];
            ca.MailingPostalCode = cust_fields[19];
            ca.MailingCountry    = cust_fields[20];
           
            insert ca;
            
       }catch(Exception e){
            dupChk=true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'This username already exists. Please enter a different username.'));
       }
    }
    
    /*Test Method*/
    public static testMethod void customerAdminTest(){
        PageReference pageRef = Page.login;
        Test.setCurrentPageReference(pageRef);
        Account ac = new Account(Name='Asdf', User_Name__c = 'lkjh', Email__c = 'test@example.com', Phone = '03444567890');        
      //  Account acc = new Account(Name='test');
        ApexPages.StandardController sc = new ApexPages.standardController(ac);
        CustomerAdmin custAd = new CustomerAdmin(sc);
        
        custAd.FirstName = 'Test Name';
        custAd.LastName = 'Test Name';
        Cookie cust_admin = new Cookie('cust_admin',ac.Name+','+ac.Contact_Name__c+','+ac.Title__c+','+ac.User_Name__c+','+ac.Phone+','+ac.Extension__c+','+ac.Cell_Phone__c+','+ac.Fax+','+ac.Email__c+','+ ac.BillingCity+','+ ac.BillingCity+','+ ac.BillingCity+','+ac.BillingState+','+ac.BillingCountry+','+ac.BillingCountry+','+ac.BillingCountry+','+ac.BillingCountry+','+ac.BillingCountry+','+ac.BillingState+','+ac.BillingCountry+','+ac.BillingCountry,null,-1,false);
        ApexPages.currentPage().setCookies(new Cookie[]{cust_admin});
       
       //  custAd.requiredFields();
        custAd.next();
        custAd.signUp();
        custAd.password = 'pass';
        custAd.user_name = 'user';
        custAd.setUser_Name('user');
        custAd.setPassword('pass');
       
        
        custAd.login();
        
   }
}