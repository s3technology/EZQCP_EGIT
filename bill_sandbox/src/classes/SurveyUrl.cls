public with sharing class SurveyUrl {   
    public ID accId {get;set;}
    public String LocName {get;set;} 
    public String CLIA {get;set;} 
    public String sUrl {get;set;} 
    public String Address {get;set;} 
    public String city {get;set;}
    public String state {get;set;} 
    public List<String> deploy_uri = new List<String>();
    public List<String> Survey_id = new List<String>();
    public List<String> Survey_uri = new List<String>();
    public String Sur_Id;
    public Boolean newSurvey {get;set;}
    public LocationAssesmentRelationship__c lar {get;set;} 
        
    public SurveyUrl(ApexPages.StandardController controller){	
        Location__c l = [Select Address__c, CLIA__c, City__c, State__c, Account__c, Name  From Location__c where Id =: ApexPages.currentPage().getParameters().get('pid')];
        accId = l.Account__c;
        LocName = l.Name;
        CLIA     = l.CLIA__c;
        Address=l.Address__c;
        city=l.City__c;
        state=l.State__c;
        lar = [Select Id, Current_Url__c,Assessment__c  From LocationAssesmentRelationship__c where Id =:ApexPages.currentpage().getParameters().get('larid')];
      	Assessment__c  ASSES=[select Survey_Id__c from Assessment__c WHERE Id=:lar.Assessment__c];      
     	system.debug(lar.Current_Url__c);
   		//System.debug(ASSES.Assement__c);
     	//system.debug(ASSES.Survey_Id__c);
        Sur_Id=ASSES.Survey_Id__c;
        if(lar.Current_Url__c==null){
            newSurvey = true;
        }else{
            newSurvey = false;
        }
    }
    
    public void createSurvey(){
        lar.Current_Url__c = sUrl;
        update lar;
        newSurvey = false;
    }
    
    public String result{get;set;}
    
    public PageReference createResponse(){    
        String apiKey = '2g8HCzgKnD8ZkNBcRvrbPffC3h2qGK';
        String pwd = 'carepoint2013';
        String uri = 'https://ezqcp.fluidsurveys.com/api/v2/surveys/'+Sur_Id+'/responses/';
        //String uri = 'https://ezqcp.fluidsurveys.com/api/v2/surveys/';
        HttpRequest req = new HttpRequest();
        Http http = new Http();
        HTTPResponse res;
        try{
            req.setEndPoint(uri);
            req.setTimeout(20000);
            req.setMethod('POST');
            Blob headerValue = Blob.valueOf(apiKey + ':' + pwd);
            String authorizationHeader = 'Basic '+ EncodingUtil.base64Encode(headerValue);
            req.setHeader('Authorization', authorizationHeader);
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('Content-Length','31999'); 
            req.setBody('');
            res = http.send(req); 
            //system.debug(res);
             system.debug(res.getBody()); 
            JSONParser parser = JSON.createParser(res.getBody()); 
            system.debug(res.getBody()); 
            parser.nextToken();
            parser.nextValue();  
        	result = parser.getText();   
        //	result=result.substring(0,85);
        	system.debug(result);
        	lar.Current_Url__c = result;
       		System.debug(result);
            update lar;
            System.debug(lar);
            newSurvey = false;       
       }catch(Exception e){                                     
           return null;
       }
       system.debug('raz larid'+ApexPages.currentPage().getParameters().get('larid'));
       return new PageReference('/index/assessmentIframe?id='+ApexPages.currentPage().getParameters().get('larid')+ '&pid='+ApexPages.currentPage().getParameters().get('pid')); 
    }

    public PageReference resumeSurvey(){
       return new PageReference('/index/assessmentIframe?id='+ApexPages.currentPage().getParameters().get('larid')+ '&pid='+ApexPages.currentPage().getParameters().get('pid'));
    }
    
    static testMethod void SurveyUrlTest(){
    	Pagereference ref = Page.AssessmentDetail;
    	Test.setCurrentPageReference(ref);
        Account acc = new Account(Name='Asdf', User_Name__c = 'lkjh', Email__c = 'test@example.com');        
		insert acc;
		Location__c loc = new Location__c(Name='Peshawar', Account__c = acc.Id, Address__c = 'address', City__c = 'city', CLIA__c='a12');
		insert loc;
    	Assessment__c ass = new Assessment__c( Price__c=300);
    	insert ass;
    	LocationAssesmentRelationship__c lar = new LocationAssesmentRelationship__c(Assessment__c = ass.Id, Location__c = loc.Id); 
    	insert lar;
    	ApexPages.StandardController sc = new ApexPages.standardController(ass);	
        ApexPages.currentPage().getParameters().put('pid',loc.Id);
        ApexPages.currentPage().getParameters().put('larid',lar.Id);
        SurveyUrl su = new SurveyUrl(sc);
        su.createSurvey();
        su.createResponse();
        su.resumeSurvey();
    }
}