trigger ContactTrigger on Contact (after update, before insert) {
    for(Contact con : trigger.new){
        Account a = [Select Name From Account where Id =: con.AccountId];
        if(Trigger.isInsert){
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[] {con.Email}; 
            mail.setToAddresses(toAddresses);
            mail.setSenderDisplayName('EZ-QCP Support');
            mail.setSubject('LogIn information');
            mail.setBccSender(false);
            mail.setUseSignature(false);
            Double rnd = math.random();
            String str_rnd = String.valueOf(rnd);
            String temp_pass = str_rnd.replace('.','1');
            String pass = temp_pass.substring(1,6);
            
            mail.setHtmlBody('Dear '+ con.FirstName + ' ' + con.LastName+',<br/><br/>'+
            'Welcome to EZ-QCP! Your EZ-QCP '+ a.Name +' account has been created. To access your account for the first time please click the link provided and login with your username and the temporary password below.<br/><br/> '+
            'Username: '+ con.User_Name__c+'<br/>'+
            'Password: '+ pass +'<br/><br/>'+
            'Click to login:<br/> http://carepointsolutions.force.com/index/resetPassword?id='+con.AccountId+'<br/> <br/>'+
            'If the above link does not open the EZ-QCP login page, please cut and paste the link into your browser address bar. If you still experience problems please contact support@ez-qcp.com for assistance.');
           try{
           Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
           }catch(Exception e){system.debug(e);}             
           con.Password__c = pass;     
        }
        else if(Trigger.isUpdate ){
            List<Contact> admin = [Select Id, Type__c From Contact Where AccountId =:con.AccountId AND
             Type__c = 'Account Administrator' ];
             if(admin.size()<1){
                 con.addError('Each Account must have atleast one Contact with Admin privileges');
             }
        }
    }
}