global with sharing class DeleteThisContact {

    public DeleteThisContact(ApexPages.StandardController controller) {}
    
    public ID contactId { get; set; }
    
    @RemoteAction
    global static void delContact(String cId) {
        TDC__c td = new TDC__c();
        td.Name = cId;       
        insert td;
    }
     
    public static testMethod void DeleteThisContactTest(){
        PageReference pageRef = Page.message;
        Test.setCurrentPageReference(pageRef);
        TDC__c td = new TDC__c(Name='Asdf');     
        insert td;   
        ApexPages.StandardController sc = new ApexPages.standardController(td);
        DeleteThisContact ddel = new  DeleteThisContact(sc); 
        delContact('test');
    }
}