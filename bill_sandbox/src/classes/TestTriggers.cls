@isTest
private class TestTriggers{
    
    public static testMethod void testToDeleteContact(){
        List<TDC__c> tdc = new List<TDC__c>();    
        for(Integer i=0; i<10; i++){
            TDC__c con = new TDC__c(Name = 'test' + i);
            tdc.add(con); 
        }   
        Test.startTest();
        insert tdc;
        Test.stopTest();
    }
     
    Private Static testmethod void TestdetectClone(){
        Account a=new account();
        a.Name = 'Test Name';
        a.Email__c = 'test@example.com';
        insert a;
        
        Contact c =new Contact();
        c.Type__c = 'Account Administrator';
        c.lastname='Account Administrator';
        c.Email = 'test@test.com';
        c.accountid=a.id;
        insert c;
        
        c.Email = 'test@test.com';
        update c;
    }
    
    public static testMethod void invoiceTriggerTest(){
        Account	acc = new Account(Name='Test_name', Email__c= 'email@test.com', Phone='0519874563');
        insert acc;
        Contact	con = new Contact(LastName = 'TEst_lname', User_Name__c='user', Password__c='pass',Type__c='Account Administrator', AccountId= acc.Id, Email = acc.Email__c);
        insert con;
        Location__c   loc = new Location__c(Name='Test_name', Account__c = acc.Id, Address__c='address',City__c='city', CLIA__c = 'a11');
        insert loc;
        Assessment__c ass = new Assessment__c(Price__c=80, Discount__c=10, Manufacturer__c='SDK', Test_Name__c='Blood Glocuse');
        insert ass;
        LocationAssesmentRelationship__c lar =  new LocationAssesmentRelationship__c(Assessment__c = ass.id, Location__c = loc.id);      
        insert lar; 
        Invoice__c nvc = new Invoice__c(LocationAssesmentRelationship__c = lar.id, Account__c = acc.Id);  
        insert nvc;  
        nvc.Status__c = 'Paid';
        update nvc;
    }
}