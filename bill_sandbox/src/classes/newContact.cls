public with sharing class newContact {
    public Contact con {get;set;}
    public String contactName  {get;set;}
    public boolean isSuccess   {get;set;}
    //public String Type         {get;set;}
    //public String Phone        {get;set;}
    //public String cellPhone    {get;set;}
    //public String extension    {get;set;}
    //ApexPages.StandardController controller;
    
    public newContact(ApexPages.StandardController c) {
        //controller = c;
        con = (Contact)c.getRecord();
        
        con.AccountId = ApexPages.currentPage().getParameters().get('pid');
        //List<String> name = contactName.split(' ');
        //con.FirstName    = name.size()>1?name[0]:'';
        //con.LastName     = name[name.size()-1];
        //con.Type__c='User';   
    }
    
    private boolean validate(){
        boolean isvalid = true;
        if(!isValid(contactName)){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Required Field Missing: contactName')); 
            isvalid = false;
        }
        
       if(!isValid(con.Phone) || con.Phone.length()<10){ 
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Required Field Missing OR Incorrect format: Primary Phone')); 
            isvalid = false;
        }else{
            String ph = con.Phone.replaceAll('\\D', '');              
            ph=ph.substring(0,3)+'-'+ph.substring(3,6)+'-'+ph.substring(6,10);              
            con.Phone = ph;
       }
       
       
       if( isValid(con.Fax) && con.Fax.length()<10){ 
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Fax Number  must be 10 digits OR leave this field blank')); 
            isvalid = false;
        }else if(!isValid(con.Fax) ){
       //do nothing
       }
       else{
            String fx = con.Fax.replaceAll('\\D', '');              
            fx=fx.substring(0,3)+'-'+fx.substring(3,6)+'-'+fx.substring(6,10);              
            con.Fax = fx;
       }
       
       
       
       
       
       if(isValid(con.MobilePhone) && con.MobilePhone.length()<10){ 
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Incorrect Field format: Cell Phone')); 
            isvalid = false;
        } else if(!isValid(con.MobilePhone)){
            //DO Nothing..
        }else{
            String cp  = con.MobilePhone.replaceAll('\\D', '');
            cp=cp.substring(0,3)+'-'+cp.substring(3,6)+'-'+cp.substring(6,10);  
            con.MobilePhone= cp;
       }
        
        if(!isValid(con.Title)){ 
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Required Field Missing: Title')); 
            isvalid = false;
        }
        
        if(!isValid(con.Type__c)){  
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Required Field Missing: Type of User')); 
            isvalid = false;
        }
        if(!isValid(con.Email)){ 
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Required Field Missing: Email')); 
            isvalid = false;
        }
        if(!isValid(con.User_Name__c)){ 
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Required Field Missing: Username')); 
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

    public PageReference save(){
    requiredFields(); 
      if(!isSuccess){
        return null;
      }
      
    List<String> name = contactName.split(' ');
        con.FirstName    = name.size()>1?name[0]:'';
        con.LastName     = name[name.size()-1];
        insert con;
        return new PageReference('/index/index?id='+con.AccountId);
    }
    
    public static testMethod void newContactTest(){
        Account acc = new Account(name='Test', email__c='test@test.com');
        insert acc;
        PageReference pageRef = Page.newContact;
        Test.setCurrentPageReference(pageRef);   
        ApexPages.currentPage().getParameters().put('pid', acc.Id);
        Contact con = new Contact(Email =  'test@test.com', LastName = 'Tester'); 
      
        ApexPages.StandardController sc = new ApexPages.standardController(con);
        newContact nC = new newContact(sc);
      
      nC.con.Phone='';
      nC.isValid( nC.con.Phone);
       con.Phone='1234';
      nC.isValid( con.Phone);
       nC.con.Phone='1234567890';
      nC.isValid( nC.con.Phone);
       nC.con.Fax='';
      nC.isValid( nC.con.Fax);
       nC.con.Fax='123';
      nC.isValid( nC.con.Fax);
       nC.con.Fax='1234567890';
      nC.isValid( nC.con.Fax);
      
       nC.con.MobilePhone  ='';
      nC.isValid( nC.con.MobilePhone );
       nC.con.MobilePhone='1234567890';
      nC.isValid( nC.con.MobilePhone );
 
        PageReference pr = nC.save();
       
        
    }
}