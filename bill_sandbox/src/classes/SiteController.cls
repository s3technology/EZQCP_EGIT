public with sharing class SiteController {
	public Boolean bbr        {get;set;}
	public Boolean sbr        {get;set;}
    public String  bline1     {get;set;}
    public String  bline2     {get;set;}
    public String  sline1     {get;set;}
    public String  sline2     {get;set;}    
    public Boolean showAction {get;set;}
    public Boolean showC	  {get;set;}
    public Boolean showL	  {get;set;}
    public Boolean showDep	  {get;set;}
    
    public ID LocationId 	  {get;set;} 
    public ID contactId		  {get;set;}
    public ID orderId         {get;set;}
    public ID accId = ApexPages.CurrentPage().getParameters().get('id');
    public Boolean showUser        {get;set;}
    //public ID AttachmentId {get;set;}
    //public ID NoteId {get;set;}  
    //public Boolean showA{get;set;}
    //public Boolean showN{get;set;}
    public Account redirect		{get;set;}         
    //public list<Account> acc_street{get;set;}
    public List<Contact> cont	{get;set;}
    public List<Contact> un	{get;set;}        //contacts object
    public List<Location__c> loc{get;set;}
    public List<LocationAssesmentRelationship__c> order{get;set;}
    
    //public List<Note> n_att{get;set;}        //notes objec
    //public List<Attachment> att{get;set;}    // attachment object
    
    public SiteController(ApexPages.StandardController controller) {
    	 Account acc_street = [Select BillingStreet,ShippingStreet From Account where Id =: accId];
    	 //acc_street = [Select BillingStreet, ShippingStreet From Account where Id =: accId];
    	 //system.debug(acc_street);
    	 showUser = false;
    	
    	 if(acc_street.BillingStreet !=null){    	
    	 List<String> btemp = acc_street.BillingStreet.split('\n');
    	 bline1 = btemp[0];
    	 bline2 = btemp.size()>1?btemp[1]:'';
    	 bbr = btemp.size()>1?true:false;
    	 }
    	
    	 if(acc_street.ShippingStreet!=null){
    	 List<String> stemp = acc_street.ShippingStreet.split('\n');
    	 sline1 = stemp[0];
    	 sline2 = stemp.size()>1?stemp[1]:'';
    	 sbr = stemp.size()>1?true:false;
    	 }
         cont  = [Select Id, Name, Title, FirstName, LastName, Email, Type__c From Contact Where accountId=:accId];
         loc   = [SELECT id, Address__c, Name, City__c, Order_Count__c, CLIA__c,Location_Type__c,Other__c FROM Location__c where Account__c = :accId AND Status__c='Active'];  
         order = [Select Id, Assessment__c, Location__r.Name,Location__r.Location_Type__c, Location__c, Assessment__r.Name, Assessment__r.Device__c, Assessment__r.Manufacturer__c, Assessment__r.Test_Name__c, Assessment__r.Analyte__c 
                from LocationAssesmentRelationship__c where location__c IN (Select Id From Location__c where Account__c = :accId AND Status__c like 'Active') and ExpiryDate__c > Today and Status__c like 'Active'];
		 List<LocationAssesmentRelationship__c> order1=[Select Id, Assessment__c, ExpiryDate__c, Location__r.Name, Location__c, Assessment__r.Name, Assessment__r.Device__c, Assessment__r.Manufacturer__c, Assessment__r.Test_Name__c, Assessment__r.Analyte__c 
                from LocationAssesmentRelationship__c where location__c IN (Select Id From Location__c where Account__c = :accId AND Status__c like 'Active') ];
		 //n_att = [SELECT Id,Title,Body FROM Note WHERE ParentId=:ApexPages.CurrentPage().getParameters().get('id')];
         //att= [SELECT Name, BodyLength, ContentType, Description  FROM Attachment WHERE ParentId=:ApexPages.CurrentPage().getParameters().get('id')];
         showL = loc.size()>0?true:false; 
        // showDep= loc.Other__c.length==0?true:false;
         showC = cont.size()>0?true:false; 
         //showN = n_att.size()>0?true:false; 
         //showA = att.size()>0?true:false; 
         Cookie username = ApexPages.currentPage().getCookies().get('username');
    	 
        if(username == null) {
            showAction = false;
        }else{
             Cookie customertype = ApexPages.currentPage().getCookies().get('customertype');
             if(customertype.getValue()=='User'){
                showAction = false;             
             	un = [Select Name, Type__c, Email From Contact Where User_Name__c =: username.getValue()];
             }else{
                showAction = true;          
             }
        }
    }
   
    public PageReference createAccount(){
        PageReference ca = new PageReference('/apex/newAccount?pid='+ApexPages.CurrentPage().getParameters().get('id'));
        ca.setRedirect(true);
        return ca; 
    }
   
    public PageReference resetPassword(){
        PageReference rp= new PageReference('/apex/resetPassword?pid='+ApexPages.CurrentPage().getParameters().get('id'));
        rp.setRedirect(true);
        return rp; 
    }
   
    public PageReference createLocation(){
        PageReference loc= new PageReference('/apex/newLocation?pid='+ApexPages.CurrentPage().getParameters().get('id'));
        loc.setRedirect(true);
        return loc; 
    }
   
    public PageReference goToContact() {
        PageReference cc = new PageReference('/newContact?pid='+ApexPages.CurrentPage().getParameters().get('id'));
        cc.setRedirect(true);
        return cc; 
    }

   // public PageReference goToNote() {
   //     PageReference note = new PageReference('/newNote?pid='+ApexPages.CurrentPage().getParameters().get('id'));
   //     note.setRedirect(true);
   //     return note; 
   // }
    
   // public PageReference goToAttachment() {
   //     PageReference attachment = new PageReference('/newAttachment?pid='+ApexPages.CurrentPage().getParameters().get('id'));
   //     attachment.setRedirect(true);
   //     return attachment; 
   // }

    
  //  public void deleteNote(){
  //      Note toDelete;
  //      try{
  //      toDelete = [select Id from Note where id= :NoteId]; 
  //      delete toDelete ;
  //      }catch(exception e){
  //          ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, NoteId +' '+string.valueOf(e)));
  //         
  //    }
  //       n_att = [SELECT Id,Title,Body FROM Note WHERE ParentId=:ApexPages.CurrentPage().getParameters().get('id')]; 
  //       showN = n_att.size()>0?true:false; 
  //  }
    
    
    public void deleteLocation(){
        Location__c toDelete3;
        try{
        toDelete3 = [select id, Status__c,CLIA__c from Location__c where id=:LocationId]; 
  		toDelete3.Status__c='Inactive';
        //delete toDelete3 ;
        update toDelete3;
        LocationAssesmentRelationship__c lr = [Select Assessment__c,Status__c from LocationAssesmentRelationShip__c where Location__c =: toDelete3.Id];
        if (lr != null){	
        	lr.Status__c = 'Inactive';
        	update lr;
        }
        }catch(exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, LocationId +' '+string.valueOf(e)));
           system.debug(e);
        }
       loc =[SELECT id, Address__c, Name, City__c,CLIA__c,  Order_Count__c,Location_Type__c,Other__c FROM Location__c where Account__c =:accId AND Status__c='Active'];//[ SELECT id,Address__c,City__c Name FROM Location__c where Account__c = :ApexPages.CurrentPage().getParameters().get('id')];
       system.debug(loc);
       showL = loc.size()>0?true:false; 
    }
 //   public void deleteAttachment(){
 //       Attachment toDelete2;
 //       try{
 //       toDelete2 = [select Id from Attachment where id= :AttachmentId]; 
 //       delete toDelete2 ;
 //       }catch(exception e){
 //           ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, string.valueOf(e))); 
 //       }
 //       att= [SELECT Name, BodyLength, ContentType, Description  FROM Attachment WHERE ParentId=:ApexPages.CurrentPage().getParameters().get('id')]; 
 //       showA = att.size()>0?true:false;      
 //   }
    
    public void deleteContact(){
        TDC__c td = new TDC__c();
        td.Name = contactId;       
        insert td;
    }
    
    public void deactivateOrder(){
        LocationAssesmentRelationship__c deactivate;
        try{
        deactivate = [select Id, Status__c from LocationAssesmentRelationship__c where Id =:orderId];
        system.debug(deactivate);
        deactivate.Status__c = 'Inactive';
        update deactivate;
        }catch(exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, string.valueOf(e))); 
        }
        order= [Select Id, Assessment__c, Location__r.Name,Location__r.Location_Type__c, Location__c, Assessment__r.Name, Assessment__r.Device__c, Assessment__r.Manufacturer__c, Assessment__r.Test_Name__c, Assessment__r.Analyte__c 
                from LocationAssesmentRelationship__c where location__c IN (Select Id From Location__c where Account__c =:accId) AND Status__c = 'Active'];
    }
    
    static testMethod void myPage_Test(){
        PageReference pageRef = Page.login;
      Test.setCurrentPageReference(pageRef);
        
      Account ac = new Account(Name='Asdf', User_Name__c = 'lkjh', Email__c = 'test@example.com');  
      ac.BillingStreet = 'mailing \n gsds \n sgfsf \n';
      ac.ShippingStreet='shipping\n gsds \n sgfsf \n';  
      insert ac;
      ApexPages.CurrentPage().getParameters().put('id',ac.id);    
      ApexPages.StandardController sc = new ApexPages.standardController(ac);
      SiteController cust = new SiteController(sc);
     cust.bline1= 'asim';
     cust.bline2 ='rafiq'; 
     cust.createAccount();
     cust.resetPassword();
     cust.createLocation();
     cust.goToContact();
     cust.deleteLocation();
     cust.deleteContact();
     cust.deactivateOrder();
    }
}