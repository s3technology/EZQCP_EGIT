public with sharing class ResetPassword {
    ApexPages.StandardController controller;
    private String password      {get;set;} 
    private String newPassword   {get;set;} 
    private String renewPassword {get;set;}
    public  String user_name     {get;set;}    
    public  String result        {get;set;}
    public  String test;
    
    public resetPassword(ApexPages.StandardController c){
    	controller = c;
    	Cookie user = ApexPages.currentPage().getCookies().get('username');
    	if(user!=null){
    		user_name =user.getValue();
    	}
    }
                
    public void   setpassword(String p)     {   password = p;     }
    public String getpassword()             {  return password;   }
    public void   setnewPassword(String n)  {  newPassword = n;   }
    public String getnewPassword()          { return newPassword; }
    public void   setrenewPassword(String r){ renewpassword = r;  }
    public String getrenewPassword()        {return renewpassword;}
     
    public PageReference resetPassword(){
        String pass           = getPassword();
        String newpass        = getnewPassword();
        String renew_pass     = getrenewPassword();
        List<Contact> c_users = [Select Password__c, User_Name__c from Contact where AccountId=:ApexPages.CurrentPage().getParameters().get('id') AND
                                 Password__c = :pass AND User_Name__c =: user_name];
        if(c_users.size()>0){
            c_users[0].Password__c = newpass;
            update c_users[0];   
        }
        else{
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Invalid Current Password'));
            return null;
        }
        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'Password Changed Successfully... click on link to login with the new'+
        ' password <a href="http://carepointsolutions.force.com/index">http://carepointsolutions.force.com/index</a>'));
        return null;       
    }
        
    public static testMethod void resetPasswordTest(){
        PageReference pageRef = Page.resetPassword;
        Test.setCurrentPageReference(pageRef);
        Account acc = new Account();
        acc.Name='test';
        acc.User_Name__c =  'Tester';
        //acc.Password__c='testPassword';
        acc.Email__c = 'test@test.com';
        ApexPages.StandardController sc = new ApexPages.standardController(acc);
        resetPassword rP = new resetPassword(sc);
        rp.setpassword('test');
        rp.setnewPassword('testt');
        String str1 = rp.getpassword();
        String str2 = rp.getnewPassword();
        rp.setrenewPassword('testtt');
        String str3 = rp.getrenewPassword();
        PageReference pr = rp.resetPassword();   
    }
}