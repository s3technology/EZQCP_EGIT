public with sharing class EditContact {   
    public String  Type        {get;set;}
    public String  contactName {get;set;}
    public String  FirstName   {get;set;}
    public String  LastName    {get;set;}
    public String  UserName    {get;set;}
    public String  Email       {get;set;}
    public String  Title       {get;set;}
    public String  MobilePhone {get;set;}
    public String  Phone       {get;set;}
    public String  OtherPhone  {get;set;}
    public String  HomePhone   {get;set;}  
    public String  Fax         {get;set;}  
    public String  Extension    {get;set;}  
    public Contact con         {get;set;}
    public Contact conEdit     {get;set;}
    
    public EditContact(ApexPages.StandardController controller) {
        this.con = (Contact)controller.getRecord();
        conEdit  = [Select FirstName, LastName, User_Name__c, Email, Title, Type__c, MobilePhone, Phone, OtherPhone, HomePhone,Extension__c, Fax From Contact 
                     Where id=:con.Id]; 
                     
       // FirstName    = conEdit  .FirstName; 
       // LastName     = conEdit.LastName;  
        contactName= conEdit.FirstName!=null?conEdit.FirstName:'';
        contactName = contactName + ' '+conEdit.LastName;
        UserName     = conEdit.User_Name__c; 
        HomePhone    = conEdit.HomePhone;
        MobilePhone  = conEdit.MobilePhone;
	    OtherPhone   = conEdit.OtherPhone;	  
        Email        = conEdit.Email;   
        Title        = conEdit.Title;   
        Type         = conEdit.Type__c;
        Fax          = conEdit.Fax;
        Phone        = conEdit.Phone; 
     	Extension    = conEdit.Extension__c;
    	}
    
    public PageReference editCon(){
        // con.FirstName    = FirstName; 
        // con.LastName     = LastName;
        String fx  =  Fax.replaceAll('\\D','');
        String ph	= Phone.replaceAll('\\D', '');
        String cp	= MobilePhone.replaceAll('\\D', '');
        if(fx.length()>0 && fx.length()<10)
        {
        	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Fax Number  must be 10 digits OR leave this field blank'));
        return null;
        }else  if(fx.length()==0 || fx == null || fx == ''){
        // do nothing}                          
        }
        else{
        fx=fx.substring(0,3)+'-'+fx.substring(3,6)+'-'+fx.substring(6,10);
        }
       
        if(ph.length()<10)
        {
        	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Primary Phone Number  must be 10 digits  '));
        	return null;
        }else{
        	ph=ph.substring(0,3)+'-'+ph.substring(3,6)+'-'+ph.substring(6,10);
        
        }
        if(cp.length()>0 && cp.length()<10)
        {
        	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Cell Phone Number  must be 10 digits OR leave this field blank'));
        	return null;
        }else if(cp.length()==0 || cp == null || cp == ''){
        	//Do Nothing
        }else{
        	cp=cp.substring(0,3)+'-'+cp.substring(3,6)+'-'+cp.substring(6,10);
        }
         
        List<String> name = contactName.split(' ');
        con.FirstName    = name.size()>1?name[0]:'';
        con.LastName     = name[name.size()-1];
        con.User_Name__c = UserName;
        con.Email        = Email;
        con.Title        = Title; 
        con.MobilePhone  = cp;//MobilePhone;
        con.Phone        = ph;
        con.OtherPhone   = OtherPhone;
        con.HomePhone    = HomePhone;
        con.Fax          = fx;//Fax;
        con.Type__c      = Type;
        con.Extension__c = Extension;
        try{
            update con;   
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'....'));
        }catch(DMLException e){
           // ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,'Error: ' + e));
            return null;
        }
        return new PageReference('/index/contact_detail?id='+con.id);
    }
    
    public static testMethod void editContactTest(){
        PageReference pageRef = Page.EditContact;
        Test.setCurrentPageReference(pageRef);
        Account a = new account();
        a.Name 	  = 'Test Name';
        a.Email__c = 'test@test.com';
        insert a;
        Contact con = new Contact(Email =  'test@test.com', LastName = 'Tester'); 
        con.Type__c = 'Account Administrator';
        con.accountid = a.id;
        insert con;
        ApexPages.StandardController sc = new ApexPages.standardController(con);
        EditContact ea = new EditContact(sc);
        ea.Fax='1234567890';
        ea.con.Fax=ea.Fax;
        ea.MobilePhone='1234567890';
        ea.con.MobilePhone=ea.MobilePhone;
        
        ea.Phone='1234567890';
        ea.con.Phone=ea.Phone;
        PageReference pr = ea.editCon();   
    }
}