public with sharing class LocationsList {
    public List<Location__c>  loc {get;set;}
    
    public locationsList(){ 
        loc = [Select Id, Name, Account__c, Address__c, City__c, Detail__c, Location_Type__c, State__c,CLIA__c From Location__c where Account__c=:ApexPages.currentPage().getParameters().get('pid') AND Status__c like 'Active'];
    }
    
    public PageReference createLocation(){
        PageReference ploc= new PageReference('/apex/newLocation?pid='+ loc[0].Account__c);
        ploc.setRedirect(true);
        return ploc; 
    }
    
    static testMethod void locationListTest(){
        Account a = new Account(Name='name', User_Name__c ='contact Name', Email__c = 'test@test.com');
        insert a;
        Location__c l = new Location__c(Address__c = 'Address', City__c ='city', Status__c='Active',CLIA__c = 'a3');
        Location__c l2 = new Location__c(Address__c = 'Address231', City__c ='city2131', Status__c='Active', CLIA__c = 'a4');
        insert l;
        insert l2;
        ApexPages.currentPage().getParameters().put('pid',l.Account__c);
        LocationsList ll = new LocationsList();
        ll.createLocation();        
    }
}