public with sharing class newAssessment {
    public LocationAssesmentRelationship__c lar {get;set;}
    
    public Assessment__c newAsse{get;set;} 
    //ApexPages.StandardController controller;
    
    public newAssessment(ApexPages.StandardController c) {
       // controller =c;
        this.newAsse= (Assessment__c )c.getRecord();
        lar = new LocationAssesmentRelationship__c(); //  ApexPages.currentPage().getParameters().get('pid');
        lar .Location__c = ApexPages.currentPage().getParameters().get('lid');
    }
    
    public PageReference linkSave(){
       save();
       lar .Assessment__c = newAsse.Id;
       insert lar ;
       return new PageReference('/index/locationDetail?id='+ApexPages.currentPage().getParameters().get('lid'));
    }
    
    public void save(){
       //newDev = controller.save();   
       insert newAsse;
    }
    
    static testMethod void newAssessmentTest(){
        PageReference pageRef = Page.newAssessment;
        Test.setCurrentPageReference(pageRef);           
        Location__c loc = new Location__c();
        loc.Address__c = '123';
        loc.City__c = 'Peshawar';
        loc.CLIA__c = 'a1';
        insert loc;
        Apexpages.currentPage().getParameters().put('lid',loc.Id);
        Assessment__c asmt = new Assessment__c();
        asmt.Analyte__c = '';
        asmt.Device__c = '';
        asmt.Discount__c = 5;
        ApexPages.StandardController sc = new ApexPages.standardController(asmt);
        newAssessment nA = new newAssessment(sc);
        nA.linkSave();
    }
}