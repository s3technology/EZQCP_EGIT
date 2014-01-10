public with sharing class EditLocation {
    public Location__c editLoc{get;set;}
    
    public editLocation(ApexPages.StandardController controller) {
        this.editLoc = (Location__c)controller.getRecord();    
            
    }
    
    public PageReference savelocation(){
    	
       	if(editLoc.Location_Type__c!='Other')
       { 
        editLoc.Other__c=null;
      	save(); 
       	}   
        else {
         save();
       	     		}
       //return new PageReference('/index/index?id='+editLoc.Account__c);
       return new PageReference('/index/locationDetail?id='+editLoc.Id+'&pid='+editLoc.Account__c);
    }
    
    public void save(){
        update editLoc;
    }
     
    static testMethod void editLocationTest(){
        PageReference pageRef = Page.editLocation;
        Test.setCurrentPageReference(pageRef);
        Location__c edLoc = new Location__c ();
        edLoc.Name='pak';
        edLoc.CLIA__c = 'a10';
        edLoc.Address__c='isb';
        edLoc.City__c='isb2';
        edLoc.Location_Type__c='Hospital';
        insert edLoc;
        ApexPages.StandardController sc = new ApexPages.standardController(edLoc);
        editLocation el = new editLocation(sc);        
        el.savelocation();
        el.save();
   }
}