public with sharing class LocationDetail {
    public Boolean show {get;set;}  
    public ID DeviceId  {get;set;} 
    public ID larId     {get;set;}  
    //public List<Assessment__c> la {get;set;}
    public List<LocationAssesmentRelationship__c > la2 {get;set;}
    public Location__c myLoc {get;set;}
    
    public LocationDetail(ApexPages.StandardController controller) {
        this.myLoc = (Location__c)controller.getRecord();
        //la = [select Id, Device__c, Manufacturer__c, Test_Name__c, Analyte__c, URL__c From Assessment__c where Id IN (Select Assessment__c 
        //From LocationAssesmentRelationship__c Where Location__c =:ApexPages.CurrentPage().getParameters().get('id')  AND Status__c = 'Active')];
        la2 = [Select Id, Assessment__c, Assessment__r.Name, Assessment__r.Device__c, Assessment__r.Manufacturer__c, Assessment__r.Test_Name__c, Assessment__r.Analyte__c, Location__c, Location__r.CLIA__c, Location__r.Location_Type__c,Location__r.Name,
        Assessment__r.URL__c from LocationAssesmentRelationship__c where location__c =:ApexPages.CurrentPage().getParameters().get('id') AND Status__c = 'Active' AND ExpiryDate__c > Today];
        Cookie username = ApexPages.currentPage().getCookies().get('username');
        if(username == null) {
            show = false;
        }else{
            Cookie customertype = ApexPages.currentPage().getCookies().get('customertype');
            if(customertype.getValue()=='User'){
               show = false;             
            }else{
               show = true;          
            }
        }
    }
    
    public PageReference deleteLocation(){
        PageReference ref = new PageReference('/index/index?id='+myLoc.Account__c);   
        system.debug(ref);
        del();
        return ref;
    }
    
    public void del(){
        delete myLoc;
    }
    
    //public void deleteLDR(){
    //  List<LocationDeviceRelationship__c> toDelete;
    //  try{
    //    toDelete = [select Id from LocationDeviceRelationship__c where Device__c = :DeviceId and Location__c 
    //    =:ApexPages.currentPage().getParameters().get('id') ]; 
    //    delete toDelete[0];
    //    }catch(exception e){
    //        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, string.valueOf(e))); 
    //    }
    //  showA = att.size()>0?true:false;      
    //}
    
    public void deleteLAR(){
        LocationAssesmentRelationship__c deactivate;
        try{
            deactivate = [select Id, Status__c from LocationAssesmentRelationship__c where Id =:larId];
            deactivate.Status__c = 'Inactive';
            update deactivate;
        }catch(exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, string.valueOf(e))); 
        }
        //la = [select Id, Device__c, Manufacturer__c, Test_Name__c, Analyte__c, URL__c From Assessment__c where Id IN (Select Assessment__c  From LocationAssesmentRelationship__c Where Location__c =:ApexPages.CurrentPage().getParameters().get('id')  
        //AND Status__c = 'Active')];
        la2 = [Select Id, Assessment__c, Assessment__r.Name, Assessment__r.Device__c, Assessment__r.Manufacturer__c, Assessment__r.Test_Name__c, Assessment__r.Analyte__c, Location__c, Location__r.CLIA__c, Location__r.Location_Type__c,Location__r.Name,
        Assessment__r.URL__c from LocationAssesmentRelationship__c where location__c =:ApexPages.CurrentPage().getParameters().get('id') AND Status__c = 'Active'];
        //showA = att.size()>0?true:false;      
    }
    
    static testMethod void LocationDetailTest(){
        Cookie username = new Cookie('username','user','/index',-1,false);
        Cookie customertype = new Cookie('customertype','Account Administrator','/index',-1,false);
        ApexPages.currentPage().setCookies(new Cookie[]{username});
        ApexPages.currentPage().setCookies(new Cookie[]{customertype});  
        PageReference pageRef = Page.LocationDetail;
        Test.setCurrentPageReference(pageRef);
        Location__c edLoc = new Location__c ();
        edLoc.Name='pak';
        edLoc.CLIA__c = 'a5';
        edLoc.Address__c='isb';
        edLoc.City__c='isb2';
        edLoc.Location_Type__c='Hospital';
        insert edLoc;
        ApexPages.StandardController sc = new ApexPages.standardController(edLoc);
        LocationDetail locD = new LocationDetail(sc);
        locD.deleteLocation();
        locD.deleteLAR();
    }
}