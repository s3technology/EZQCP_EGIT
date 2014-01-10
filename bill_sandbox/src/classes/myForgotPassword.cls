public with sharing class myForgotPassword {
    public String username {get;set;}
    
    public PageReference resetPassword(){
        List<Contact> con = [Select Password__c, Email, Name From Contact where User_Name__c =:username];
        if(con.size()>0){    
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[] {con[0].Email}; 
            mail.setToAddresses(toAddresses);
            mail.setSenderDisplayName('Support Team');
            mail.setSubject('Forgot Password');
            mail.setBccSender(false);
            mail.setUseSignature(false);            
            mail.setHtmlBody('Dear '+con[0].Name+',<br/>'+
            'Your EZ-QCP password is : '+ con[0].Password__c +'<br/><br/>'+
            'Go to this link to login: http://carepointsolutions.force.com/index'+'<br/> If the above link does not open the EZ-QCP login page, please cut and paste the link text into your browser address bar.');
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});    
            return  new PageReference('/index/message?r=1');
        }
        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'User Name you provided does not EXISTS'));          
        return null;
    }
    
    static testMethod void myForgotPasswordTest(){
        Account a = new Account(Name='name', User_Name__c='user name',Email__c='Email@example.com');
        insert a;
        Contact con = new Contact(Email =  'test@test.com', LastName = 'Tester'); 
        con.Type__c = 'Account Administrator';
        con.AccountId = a.id;
        insert con;
        myForgotPassword mfp = new myForgotPassword();
        mfp.resetPassword();
    } 
}