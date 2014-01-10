public with sharing class NewLocation {
	
    public Location__c newLoc{get;set;} 
    public boolean isSuccess		{get;set;}
    public String Type		{get;set;}
    public String other		{get;set;}  
    public string testing = 'Testing';
    //Apexpages.StandardController controller;

    public newLocation(ApexPages.StandardController c) {
        // controller = c;
        this.newLoc= (Location__c)c.getRecord();
        newLoc.Account__c= ApexPages.currentPage().getParameters().get('pid');
        newLoc.Status__c = 'Active';
    	
    
    } 
    
    private boolean validate(){
        boolean isvalid = true;
        if(!isValid(newLoc.Name )){ 
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Required Field Missing: IQCP Location / Unique Identifier')); 
            isvalid = false;
        }
         if(!isValid(newLoc.Location_Type__c )){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Required Field Missing: Department')); 
            isvalid = false;
        } 
        if(!isValid(newLoc.CLIA__c )){ 
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Required Field Missing: CLIA Number')); 
            isvalid = false;
        }
         if(!isValid(newLOc.Address__c)){  
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Required Field Missing: Address Line 1')); 
            isvalid = false;
        }
        if(!isValid(newLoc.City__c)){ 
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Required Field Missing: City')); 
            isvalid = false;
        }
         if(!isValid(newLoc.Country__c)){ 
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Required Field Missing: Country')); 
            isvalid = false;
        }
        if(!isValid(newLoc.State__c)){ 
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Required Field Missing: State/Province')); 
            isvalid = false;
        }
         if(!isValid(newLoc.Zip_Code__c)){ 
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Required Field Missing: Zip/Postal Code')); 
            isvalid = false;
        }
        
         return isvalid;
    }
     private boolean isValid(string val){
        return val == null ? false : val.trim().length() == 0 ? false: true;
    }
    public void requiredFields()
   {
        if(validate()){
            
            isSuccess=true;
        }else{
            isSuccess = false;
        }
    } 
    
    
    
    public PageReference linkSave(){
    	 requiredFields(); 
      if(!isSuccess){
        return null;
      }
       save();
       PageReference ref = new PageReference('/index/index?id='+ApexPages.CurrentPage().getParameters().get('pid'));
       ref.setRedirect(true);
       return ref;
    }
    
    public void save(){
    	
    	
       insert newLoc; 
       
    }
    
    public static testMethod void newLocationTest(){
        PageReference pageRef = Page.newLocation;
        Test.setCurrentPageReference(pageRef);
        Account a =new Account(Name='Test', User_Name__c = 'tester', Email__c = 'test@example.com'); 
        insert a;
        Apexpages.currentPage().getParameters().put('pid',a.Id);
        Location__c loc = new Location__c();
        loc.Name='';
        loc.State__c='';
        loc.Zip_Code__c='';
        loc.Location_Type__c='';
        loc.Address__c = '';
        loc.City__c = '';
        loc.CLIA__c = '';
        loc.Country__c = '';
        loc.Account__c=a.id;
        loc.Status__c='Active';
       // insert loc;
        ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(loc);
        newLocation nL = new newLocation(sc);
      // nL.isSuccess= false;
       // nL.validate();
        nL.requiredFields();
       // nL.isValid(loc.City__c);
       // nL.isValid('');
        PageReference pr = nl.linkSave();    
    }
}