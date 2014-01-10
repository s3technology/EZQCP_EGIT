public with sharing class contactDetail {
	
	public Boolean showAction{get;set;}
    public String accID{get;set;}
    public Contact con{get;set;}
    
    public contactDetail(ApexPages.StandardController c){
    	con = (Contact)c.getRecord();
        Account acc;
        acc = [Select Name from Account where Id =: con.AccountId];
        accID = String.valueOf(acc.name);
        Cookie username = ApexPages.currentPage().getCookies().get('username'); 
        if(username == null) {
            showAction = false;
        }else{
            Cookie customertype = ApexPages.currentPage().getCookies().get('customertype');
            if(customertype.getValue()=='User'){
           		showAction = false;             
            	//cont = [Select Id, Name, Email, Type__c From Contact Where accountId=:accId AND Type__c != 'Account Administrator'];
             }else{
                showAction = true;          
             }
        }
	}
    
    public static testMethod void testContactDetail(){
 		PageReference pageRef = Page.contact_detail;
        Test.setCurrentPageReference(pageRef);
        Account a=new account();
        a.Name = 'Test Name';
        a.Email__c = 'test@test.com';
        insert a;
        Contact con = new Contact(Email =  'test@test.com', LastName = 'Tester'); 
        con.Type__c = 'Account Administrator';
        con.accountid = a.id;
        insert con;
        Cookie usName = new Cookie('username', con.User_Name__c,null,-1,false);
        ApexPages.currentPage().setCookies(new Cookie[]{usName});
        Cookie cuType = new Cookie('customertype', 'User',null,-1,false);
        ApexPages.currentPage().setCookies(new Cookie[]{cuType});
        ApexPages.StandardController sc = new ApexPages.standardController(con);
        contactDetail cD = new contactDetail(sc);
	}
}