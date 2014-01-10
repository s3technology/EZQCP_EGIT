public class DoPaymentHandlerInvoice{
    public string name{get;set;}
    public string amount{get;set;}
    public string firstname{get;set;}
    public string lastname{get;set;}
    public string email{get;set;}
    public string address{get;set;}
    public string city{get;set;}
    public string state{get;set;}
    public string zip{get;set;}
    public string pod{get;set;}
    public string country{get;set;}
    public string line2{get;set;}
    public string Cart_page{get;set;}
    public boolean isSuccess{get;set;}
    public List<Contact> cont{get;set;}
    public decimal totl;              
    public String clia;
    public  Assessment__c ass_id; 
    public  Location__c loc_id;
    public ID id; 
    //public decimal totl;
    public decimal discc;
    public DoPaymentHandlerInvoice(){
    	address ='';
        id=ApexPages.currentPage().getParameters().get('pid');
        cont=[SELECT AccountId, Id, Email, FirstName, Name,  LastName, OwnerId,Type__c, User_Name__c, password__c FROM Contact where AccountId=:id and Type__c='Account Administrator'];
        Account add_info = [SELECT BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry FROM Account where Id=:id];
        firstname=cont[0].FirstName;
        lastname=cont[0].LastName;
        email=cont[0].Email;
        name = cont[0].Name;
        system.debug(add_info);
        List<String> temp = add_info.BillingStreet.split('\n');
		if(temp.size()>1){
			for(integer i=0;i<temp.size()-1;i++ ){
				address = address + ' '+temp[i];
			}
		}else{
			address = add_info.BillingStreet;
		}
		line2 = temp.size()>1?temp[temp.size()-1]:'';
        city = add_info.BillingCity;
        state = add_info.BillingState;
        zip  = add_info.BillingPostalCode;
        country = add_info.BillingCountry;

        Cookie cart = ApexPages.currentPage().getCookies().get('cart_'+id);
        if(cart!=null)
        { 
            String cart_val=cart.getValue();
            List<String> arr_items;
            List<String> items = cart_val.split(';'); 
            totl=0;
            for (Integer i=0;i<items.size();i++) 
            {
                if(items[i]==''|| items[i]==null )
                {continue;}
                arr_items=items[i].split(',');
                discc=decimal.valueOf(arr_items[0])-((decimal.valueOf(arr_items[0])*decimal.valueOf(arr_items[2].replace('%',''))/100));
                discc=discc.setScale(2);
                totl=(totl+discc).setScale(2);
            }
        }
    
        ///////////
       amount=string.valueOf(totl);
     }
 
    public List<SelectOption> getMonths(){
       list<SelectOption> months = new list<SelectOption>();
       months.add(new selectOption('01','Jan'));
       months.add(new selectOption('02','Feb'));
       months.add(new selectOption('03','Mar'));
       months.add(new selectOption('04','Apr'));
       months.add(new selectOption('05','May'));
       months.add(new selectOption('06','Jun'));
       months.add(new selectOption('07','Jul'));
       months.add(new selectOption('08','Aug'));
       months.add(new selectOption('09','Sep'));
       months.add(new selectOption('10','Oct'));
       months.add(new selectOption('11','Nov'));
       months.add(new selectOption('12','Dec'));
       return months;
    }
    
    public List<SelectOption> getYears(){
       list<SelectOption> years = new list<SelectOption>();
       integer curMonth = system.today().year();
       for(integer i=1;i<10;i++){
           years.add(new selectOption(curMonth + '',curMonth++ + ''));
       }
       return years;
    }
    
    public List<SelectOption> getCardTypes(){
       list<SelectOption> cardtype = new list<SelectOption>();
       cardtype.add(new selectOption('Visa','Visa'));
       cardtype.add(new selectOption('Master Card','Master Card'));
       cardtype.add(new selectOption('American Express','American Express'));
       return cardtype;
    }
    public Pagereference Cancel(){
     
      return new PageReference ('/index/SandBoxCart?pid='+ApexPages.currentPage().getParameters().get('pid'));
  
    }
    
    
    
    
    //Handling payment processing submitting by VF page button
   /* public void process(){
        isSuccess = false;
      //  expiration = cardmonth + cardyear;
        
        if(!validate()){
            isSuccess = false;
            return;
        }
    /*  AuthorizeDotNet_Inv ath = new AuthorizeDotNet_Inv(true);
        ath.transaction_Inv(cardnumber,  amount, cardcvv,'','');  
        ath.setParameter('x_device_type','1');  
        ath.setParameter('x_first_name',firstname);  
        ath.setParameter('x_last_name',lastname);  
        ath.setParameter('x_address',address);  
        ath.setParameter('x_state',state);  
        ath.setParameter('x_response_format','1');  
        ath.setParameter('x_zip',zip);
        try{
            ath.process(3);
        }catch(Exception ex){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, ex.getMessage())); 
            isSuccess = false;
        }
        
        if(ath.isApproved()){
            String responsetext = ath.getResponseText();
            String transactionid = ath.getTransactionID();

           
            Cookie cart = ApexPages.currentPage().getCookies().get('cart_'+id);
            if(cart!=null)
            {
                     String cart_val=cart.getValue();
            if(cart_val=='')
            {
                return;
            }            
                     
                     List<String> arr_items;
                     List<String> items = cart_val.split(';'); 
                     
                     
        
                     
     Cart_page=' <div id="tbl" style="margin-left:300px;"><table width=\"500\" border=\"1\" bordercolor=\"#CCCCCC\" cellspacing=\"0\" cellpadding=\"2\" style=\"font-family:Arial, Helvetica, sans-serif; font-size:12px; border-radius:6px;-moz-border-radius:6px;\">';
     Cart_page=Cart_page+'<tr  style=\"background-color:#879839; \">';
     Cart_page=Cart_page+'<td style=\"height:25px;color:white\"><strong>Assessment</strong></td>';
     Cart_page=Cart_page+'<td style=\"height:25px;color:white\"><strong>IQCP Location</strong></td>';
     Cart_page=Cart_page+'<td style=\"height:25px;color:white\"><strong>Price</strong></td>';
     Cart_page=Cart_page+' <td style=\"height:25px;color:white\"><strong>Discount</strong></td>';
     Cart_page=Cart_page+' <td style=\"height:25px;color:white\"><strong>Total</strong></td>';
     Cart_page=Cart_page+'</tr> ';
                     
                     totl=0;
                     for (Integer i=0;i<items.size();i++) 
                       {
                            if(items[i]==''|| items[i]==null )
                            {continue;}
                        arr_items=items[i].split(',');
                        
                        // discc=  (decimal.valueOf(arr_items[0]))-((decimal.valueOf(arr_items[0]))*(decimal.valueOf(arr_items[2]))/100);
                         discc=decimal.valueOf(arr_items[0])-((decimal.valueOf(arr_items[0])*decimal.valueOf(arr_items[2].replace('%',''))/100));
                         totl=totl+discc;
                        
                        Cart_page=Cart_page+'<tr><td>'+arr_items[3]+'</td><td>'+arr_items[5]+'</td><td>$'+arr_items[0]+'</td><td>'+arr_items[2]+'</td><td>$'+discc+'</td></tr>';
                        LocationAssesmentRelationship__c locA= new LocationAssesmentRelationship__c();
                        Datetime myDate = datetime.newInstance(Date.today().Year(), Date.today().month(), Date.today().Day());
                        locA.Assessment__c=arr_items[7];
                        locA.ExpiryDate__c=myDate.Date().addyears(1);
                        locA.Location__c=arr_items[6];
                        locA.Status__c='Active';
                        insert locA;
                      
                       }
                       
        Cart_page=Cart_page+' <tr>';
        Cart_page=Cart_page+'<td colspan=\"4\" align=\"right\" >Total </td>';
        Cart_page=Cart_page+'<td>$'+totl+'</td>';
        Cart_page=Cart_page+'</tr>';
        Cart_page=Cart_page+'</table></div><br/><br/>';
                      cart = new Cookie('cart_'+id,null,'/index',-1,false);
                      ApexPages.currentPage().setCookies(new Cookie[]{cart});
                     // inserting assements
            //system.debug(Cart_page);          
            }
                     
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Info, responsetext + '\nTransaction Id: ' + transactionid )); 
            isSuccess = true;
            
        }
        else if(ath.isDeclined()){
            String reason = ath.getResponseText();
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, reason)); 
            isSuccess = false;
        }
        else{
            String reason = ath.getResponseText();
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, reason)); 
            isSuccess = false;
        }
   //
    }
   */
   
   //riaz 25-9
   public void requiredFields()
   {
        if(validate()){
            
            isSuccess=true;
        }else{
            isSuccess = false;
        }
    }  
    public Pagereference sendMeInvoice(){ 
      requiredFields(); 
      if(!isSuccess){
        return null;
      } //////// riaz code 
        Cookie cart = ApexPages.currentPage().getCookies().get('cart_'+id);
        if(cart!=null)
        {
            String cart_val=cart.getValue();
            if(cart_val=='')
            {
                return null;
            }            
            List<String> arr_items;
            List<String> items = cart_val.split(';'); 
            totl=0;
            for (Integer i=0;i<items.size();i++) 
            {
                if(items[i]==''|| items[i]==null )
                {continue;}
                arr_items=items[i].split(',');
                discc=decimal.valueOf(arr_items[0])-((decimal.valueOf(arr_items[0])*decimal.valueOf(arr_items[2].replace('%',''))/100));
               discc=discc.setScale(2);
                totl=(totl+discc);
                totl=totl.setScale(2);
                clia =arr_items[9];
            }
            
            Invoice__c invoice = new Invoice__c();
            invoice.Account__c = ApexPages.currentPage().getParameters().get('pid');
            invoice.Invoice_Amount__c=totl;
            invoice.Status__c='Pending';
            invoice.Purchase_Order_Number__c=pod;
            invoice.Payment_Method__c='Purchase Order Number';
            //invoice.Invoice_Detail__c='';
            //invoice.LocationAssesmentRelationship__c = locA.Id;
            insert invoice; 
            Cart_page=' <div id="tbl" style="margin-left:10px;"><table width=\"650\" border=\"1\" bordercolor=\"#CCCCCC\" cellspacing=\"0\" cellpadding=\"2\" style=\"font-family:Arial, Helvetica, sans-serif; font-size:12px; border-radius:6px;-moz-border-radius:6px;\">';
            Cart_page=Cart_page+'<tr  style=\"background-color:#879839; \">';
            Cart_page=Cart_page+'<td style=\"height:25px;color:white\"><strong>IQCP Location / Unique Identifier</strong></td>';
            Cart_page=Cart_page+'<td style=\"height:25px;color:white\"><strong>CLIA Number</strong></td>';
            Cart_page=Cart_page+'<td style=\"height:25px;color:white\"><strong>Assessment</strong></td>';
            Cart_page=Cart_page+'<td style=\"height:25px;color:white\"><strong>Price</strong></td>';
            Cart_page=Cart_page+' <td style=\"height:25px;color:white\"><strong>Discount</strong></td>';
            Cart_page=Cart_page+' <td style=\"height:25px;color:white\"><strong>Total</strong></td>';
            Cart_page=Cart_page+'</tr> ';
            
            for (Integer i=0;i<items.size();i++) 
            {
            	if(items[i]==''|| items[i]==null )
                {continue;}
                arr_items=items[i].split(',');
                //discc=  (decimal.valueOf(arr_items[0]))-((decimal.valueOf(arr_items[0]))*(decimal.valueOf(arr_items[2]))/100);
                discc=decimal.valueOf(arr_items[0])-((decimal.valueOf(arr_items[0])*decimal.valueOf(arr_items[2].replace('%',''))/100));
                discc=discc.setScale(2);
                //totl=totl+discc;
               // system.debug(arr_items[2]);
               // system.debug(decimal.valueOf(arr_items[0]).setScale(2));
               // system.debug(discc);
               // system.debug(totl);
                
                
                Cart_page=Cart_page+'<tr><td>'+arr_items[5]+'</td><td>'+clia+'</td><td>'+arr_items[3]+'</td><td>$'+decimal.valueOf(arr_items[0]).setScale(2)+'</td><td>'+(arr_items[2])+'</td><td>$'+discc.setScale(2)+'</td></tr>';
                LocationAssesmentRelationship__c locA= new LocationAssesmentRelationship__c();
                Datetime myDate = datetime.newInstance(Date.today().Year(), Date.today().month(), Date.today().Day());
                locA.Assessment__c=arr_items[7]; //7
                locA.ExpiryDate__c=myDate.Date().addyears(1);
                locA.Location__c=arr_items[6];  //6
                
                locA.Status__c='Active';
                locA.Invoice__c=invoice.Id;
                locA.Orignal_Price__c=decimal.valueOf(arr_items[0]);
                locA.Discount__c=decimal.valueOf(arr_items[2].replace('%',''));
                locA.Invoice_Price__c=decimal.valueOf(arr_items[0])-((decimal.valueOf(arr_items[0])*decimal.valueOf(arr_items[2].replace('%',''))/100));
                insert locA;
            	
            }
            Cart_page=Cart_page+'<tr>';
            Cart_page=Cart_page+'<td colspan=\"5\" align=\"right\" >Total </td>';
            Cart_page=Cart_page+'<td>$'+(totl).setScale(2)+'</td>';
            Cart_page=Cart_page+'</tr>';
            Cart_page=Cart_page+'</table></div><br/><br/>';
            Cookie un = ApexPages.currentPage().getCookies().get('username');    
            Contact cEmail =  [Select Email,FirstName,LastName From Contact Where User_Name__c =: un.getValue()];
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[] {cEmail.Email};
            mail.setToAddresses(toAddresses);
            mail.setSenderDisplayName('Support Team');
            mail.setSubject('Invoice ');
            mail.setBccSender(false);
            mail.setUseSignature(false);
            Account acc =[Select Name,Phone,billingCity,billingStreet,BillingState, BillingPostalCode,billingCountry from ACCOUNT where ID =: ApexPages.currentPage().getParameters().get('pid')];
            Invoice__c inv =[Select Name from Invoice__c where ID =: invoice.Id];
            List<Contact> ct = [Select FirstName, LastName from Contact where AccountID =:  ApexPages.currentPage().getParameters().get('pid') and type__c like 'Account Administrator'];  
            Cart_page= '<img Style="margin-left:15px;" src="https://c.na15.content.force.com/servlet/servlet.ImageServer?id=015i00000002PsJ&oid=00Di0000000JNqD&lastMod=1368776771000" alt="emaillogo"/>'+
            '<font face="Trebuchet MS">'+
            '<table width="58%" style="margin-left:15px;">'+
            '<tr>'+
                    '<td width="50%" colspan="2" align="center" Style="font-size:10px;">Invoice Number. '+ inv.Name +'</td>' +
            '</tr>'+
             '<tr>'+
                 	'<td width="50%" colspan="2" align="center" Style="font-size:10px;">Purchase Order Number. '+ pod +'</td>' +
             '</tr>'+
             '<tr>'+
            	        '<td width="50%" colspan="2" align="center" Style="font-size:10px;"> Date. ' + date.today().month()  + '-' + date.today().day() + '-'+ date.today().year()+'</td>' + 
            	     '</tr>'+
           '<tr>'+
               ' <td width="50%" Style="font-size:10px;">Company:'+ acc.Name + '</td>'+
                '<td width="50%" align="right" Style="font-size:10px;">Contact Name: '+ ct[0].FirstName + ' ' + ct[0].LastName + '</td>'+
            '</tr>'+
            '<tr>'+
                '<td width="50%" Style="font-size:10px;">Billing Address: <br/>'+ acc.BillingStreet + ',<br/>' + acc.BillingCity+ ', '+acc.BillingState +', '+acc.BillingPostalCode+', '+ acc.BillingCountry+'</td>'+
                '<td width="50%" align="right" Style="font-size:10px;">Contact Number:'+ acc.Phone + '</td>'+
            '</tr>'+
            '</table>'+'<br/><br/>'+Cart_page;
            Cart_page=Cart_page+'<b><p Style="font-size:14px;margin-left:15px"> Payment Terms</p> </b> ' +     
                 '<p Style="font-size:10px;margin-left:15px">All payments are due 30 days from the date of invoice. To be made payable to:</p>'
               + '<b><p Style="font-size:10px;margin-left:15px;">CarePoint Solutions, Inc. </b> </p>'        
               + '<p Style="font-size:10px;margin-left:15px"> PO Box 900  </p>'        
               + '<p Style="font-size:10px;margin-left:15px">Westford, MA 01886</p>';
        
           invoice.Invoice_Detail__c=Cart_page;
           update invoice;
           //+string.ValueOf(un.getValue())
           mail.setHtmlBody('Dear '+cEmail.FirstName+'  '+cEmail.LastName +'<br/><br/>'+Cart_page);
           //mail.setHtmlBody(Cart_page)+'<br/><br/> [Invoice detail goes here]');
           Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
       }
       //return null;//
       return new PageReference('/index/Thank_You?id='+ApexPages.currentPage().getParameters().get('pid'));
    }
    
    private boolean validate(){
        boolean isvalid = true;
        if(!isValid(amount)){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Required Field Missing: Amount')); 
            isvalid = false;
        }
       if(!isValid(firstname)){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Required Field Missing: First Name')); 
            isvalid = false;
        }
        if(!isValid(lastname)){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Required Field Missing: Last Name')); 
            isvalid = false;
        }
        if(!isValid(address)){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Required Field Missing: Address')); 
            isvalid = false;
        }
        if(!isValid(city)){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Required Field Missing: City')); 
            isvalid = false;
        }
        if(!isValid(state)){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Required Field Missing: State')); 
            isvalid = false;
        }
        if(!isValid(zip)){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Required Field Missing: Zip')); 
            isvalid = false;
        }
         if(!isValid(pod)){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Required Field Missing: Purchase Order #')); 
            isvalid = false;
        }
        if(!isValid(country)){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Required Field Missing: Country')); 
            isvalid = false;
        }
        return isvalid;
    }
    
    private boolean isValid(string val){
        return val == null ? false : val.trim().length() == 0 ? false: true;
    }
    static testMethod void testDoPaymentHandlerInvoice(){
        Account acc = new Account(Name = 'Account');
        acc.BillingStreet='123111\n sfsfsd \n adfasd';
        acc.BillingCity='adsf';
        acc.BillingCountry='asdf';
        acc.BillingPostalCode='143';
        
        insert acc;
        Contact con1 = new Contact(FirstName = 'fname', LastName='lname',Type__c= 'Account Administrator',AccountId = acc.Id, User_Name__c = 'TADNL1',Email = 'test@example.com');
        Contact con2 = new Contact(FirstName = 'fname', LastName='lname',Type__c= 'Account Administrator',AccountId = acc.Id, User_Name__c = 'TADNL2',Email = 'test@example.com');
        insert con1;
        insert con2;
        Location__c loc = new Location__c(Name = 'locName',Account__c = acc.Id, city__c = 'city',Address__c = 'address',CLIA__c ='a13',Country__c='pak');
        insert loc;
        Assessment__c ass = new Assessment__c();
        insert ass;
        PageReference pageRef = Page.dopayment_invoice;
        Test.setCurrentPageReference(pageRef);
        Cookie uName = new Cookie('username',con1.User_Name__c,null,-1,false);
        ApexPages.currentPage().setCookies(new Cookie[]{uName});
        Cookie cart = new Cookie('cart_'+acc.Id,'1111,2222,3333,4444,5555,666666,'+loc.Id+','+ass.Id+','+acc.Id,null,-1,false);
        ApexPages.currentPage().setCookies(new Cookie[]{cart});
        ApexPages.currentPage().getParameters().put('pid',acc.Id);
        DoPaymentHandlerInvoice inv = new  DoPaymentHandlerInvoice();
        inv.isSuccess=true;
        inv.amount ='';
        inv.firstname = '';
        inv.lastname = '';
        inv.email = '';
        inv.address = '';
        inv.city = '';
        inv.state = '';
        inv.zip = '';
        inv.pod = '';
        inv.getMonths();
        inv.getYears();
        inv.getCardTypes();
        inv.validate();
        inv.Cancel();
        
        inv.sendMeInvoice();
        inv.requiredFields();
                  
                    }
           
 static testMethod void testDoPaymentHandlerInvoice2(){
        Account acc = new Account(Name = 'Account');
        acc.BillingStreet='123111\n sfsfsd \n adfasd';
        acc.BillingCity='adsf';
        acc.BillingCountry='asdf';
        acc.BillingPostalCode='143';
        
        insert acc;
        Contact con1 = new Contact(FirstName = 'fname', LastName='lname',Type__c= 'Account Administrator',AccountId = acc.Id, User_Name__c = 'TADNL1',Email = 'test@example.com');
        Contact con2 = new Contact(FirstName = 'fname', LastName='lname',Type__c= 'Account Administrator',AccountId = acc.Id, User_Name__c = 'TADNL2',Email = 'test@example.com');
        insert con1;
        insert con2;
        Location__c loc = new Location__c(Name = 'locName',Account__c = acc.Id, city__c = 'city',Address__c = 'address',CLIA__c ='a13',Country__c='pak');
        insert loc;
        Assessment__c ass = new Assessment__c();
        insert ass;
        PageReference pageRef = Page.dopayment_invoice;
        Test.setCurrentPageReference(pageRef);
        Cookie uName = new Cookie('username',con1.User_Name__c,null,-1,false);
        ApexPages.currentPage().setCookies(new Cookie[]{uName});
        Cookie cart = new Cookie('cart_'+acc.Id,'1111,2222,3333,4444,5555,666666,'+loc.Id+','+ass.Id+','+acc.Id+','+456,null,-1,false);
        ApexPages.currentPage().setCookies(new Cookie[]{cart});
        ApexPages.currentPage().getParameters().put('pid',acc.Id);
        DoPaymentHandlerInvoice inv = new  DoPaymentHandlerInvoice();
        inv.isSuccess=true;
        inv.amount ='354';
        inv.firstname = 'dgf';
        inv.lastname = 'df';
        inv.email = 'dfg';
        inv.address = 'dfg';
        inv.city = 'dfg';
        inv.state = 'dfg';
        inv.zip = 'dfg';
        inv.pod = 'dfg';
        inv.country='SD';
        inv.name='asdf';
        inv.getMonths();
        inv.getYears();
        inv.getCardTypes();
        inv.validate();
        inv.Cancel();
        
        inv.sendMeInvoice();
        inv.requiredFields();
                  
                    }
           
           
}