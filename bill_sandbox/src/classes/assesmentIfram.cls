public with sharing class assesmentIfram {
    
    public ID     accId   {get;set;}
    public String LocName {get;set;}  
    public String Address {get;set;} 
    public String city    {get;set;}
    public String state   {get;set;}   
    public String CLIA    {get;set;} 
    public String CLIA2    {get;set;} 
  	//public String sUrl  {get;set;} 
  	//public List<String> deploy_uri = new List<String>();
   	//public List<String> Survey_id = new List<String>();
    //public List<String> Survey_uri = new List<String>();
  	//public String Sur_Id;
   	//public Boolean newSurvey {get;set;}
   	//public LocationAssesmentRelationship__c lar {get;set;} 
    
    public assesmentIfram(ApexPages.StandardController controller) {
        
        Location__c l = [SELECT  Address__c, CLIA__c, City__c, Name, State__c  FROM Location__c where Id =: ApexPages.currentPage().getParameters().get('pid')];
       	//accId = l.Account__c;
        LocName = l.Name;
        CLIA    = l.CLIA__c;
        Address = l.Address__c;
        city=l.City__c;
        state=l.State__c;
       	//system.debug('testttttt');
        //system.debug(LocName);
       	//system.debug(CLIA);
        //system.debug(Address);
        //system.debug(city);
        //system.debug(state);
       }
    
    static testMethod void Test(){
    	Pagereference ref = Page.assessmentIframe;
    	Test.setCurrentPageReference(ref);
        Account acc = new Account(Name='Asdf', User_Name__c = 'lkjh', Email__c = 'test@example.com');        
		insert acc;
		Location__c loc = new Location__c(Name='Peshawar', Account__c = acc.Id,CLIA__c='233', Address__c = 'address', City__c = 'city');
		insert loc;
    	Assessment__c ass = new Assessment__c( Price__c=300);
    	insert ass;
    	LocationAssesmentRelationship__c lar = new LocationAssesmentRelationship__c(Assessment__c = ass.Id, Location__c = loc.Id); 
    	insert lar;
    	ApexPages.StandardController sc = new ApexPages.standardController(lar);	
        ApexPages.currentPage().getParameters().put('pid',loc.Id);
        ApexPages.currentPage().getParameters().put('larid',lar.Id);
        assesmentIfram su = new assesmentIfram(sc);
       	//su.createSurvey();
      	//su.createResponse();
       	//su.resumeSurvey();
    }
}