public class DoPaymentHandler{
    
    public string  name             {get;set;}
    public string  amount			{get;set;}
    public string  firstname		{get;set;}
    public string  lastname			{get;set;}
    public string  email			{get;set;}
    public string  address			{get;set;}
    public string  line2            {get;set;}
    public string  city				{get;set;}
    public string  state			{get;set;}
    public string  zip				{get;set;}
    public string  country          {get;set;}
    public string  cardholder		{get;set;}
    public string  cardnumber		{get;set;}
    public string  cardyear			{get;set;}
    public string  cardmonth		{get;set;}
    public string  cardcvv			{get;set;}
    public string  expiration		{get;set;}
    public string  selectedCardType	{get;set;}
    public string  Cart_page		{get;set;}
    public boolean isSuccess		{get;set;}
    public decimal amount1			{get;set;}
    public decimal totl;  
    public decimal discc;
    public ID id;
    public List<Contact> cont		{get;set;}
    public Assessment__c ass_id;
    public Location__c   loc_id;
	
    public DoPaymentHandler()
    {
    	address ='';
    	id=ApexPages.currentPage().getParameters().get('pid');
    	cont=[SELECT AccountId, Id, Email, FirstName, Name,  LastName, OwnerId,Type__c, User_Name__c, password__c FROM Contact where AccountId=:id and type__c='Account Administrator'];
    	Account add_info =[SELECT BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry FROM Account where Id=:id];
    	firstname=cont[0].FirstName;
    	lastname=cont[0].LastName;
    	name = cont[0].Name;
    	email=cont[0].Email;
    	
    	List<String> temp = add_info.BillingStreet.split('\n');
		if(temp.size()>1){
			for(integer i=0;i<temp.size()-1;i++ ){
				address = address + ' '+temp[i];
			}
		}else{
			address = add_info.BillingStreet;
		}
		line2   = temp.size()>1?temp[temp.size()-1]:'';
    	city    = add_info.BillingCity;
    	state   = add_info.BillingState;
    	zip     = add_info.BillingPostalCode;
    	country = add_info.BillingCountry;
    	
       	Cookie cart = ApexPages.currentPage().getCookies().get('cart_'+id);
        if(cart!=null)
        {
        	String cart_val = cart.getValue();
            List<String> arr_items;
            List<String> items = cart_val.split(';'); 
            totl=0;
            for (Integer i=0;i<items.size();i++) 
            {
            	if(items[i]==''|| items[i]==null )
                {continue;}
                arr_items = items[i].split(',');
                discc     = decimal.valueOf(arr_items[0])-((decimal.valueOf(arr_items[0])*decimal.valueOf(arr_items[2].replace('%',''))/100));
                discc     =discc.setScale(2);
                totl      = (totl+discc).setScale(2);
            }
        }
   		amount=string.valueOf(totl);
  		amount1=decimal.valueOf(amount).setScale(2);
    }
    
    public List<SelectOption> getMonths()
    {
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

    public List<SelectOption> getYears()
    {
    	list<SelectOption> years = new list<SelectOption>();
       	integer curMonth = system.today().year();
       	for(integer i=1;i<10;i++){
       		years.add(new selectOption(curMonth + '',curMonth++ + ''));
       	}
       	return years;
    }
  
    public List<SelectOption> getCardTypes()
    {
		list<SelectOption> cardtype = new list<SelectOption>();
       	cardtype.add(new selectOption('Visa','Visa'));
       	cardtype.add(new selectOption('Master Card','Master Card'));
       	cardtype.add(new selectOption('American Express','American Express'));
       	return cardtype;
    }
    
    //Handling payment processing submitting by VF page button
    public Pagereference redirect()
    {
      return new PageReference ('/index/Thank_You?id='+ApexPages.currentPage().getParameters().get('pid'));
    }
  
    public Pagereference Cancel()
    { 
    	return new PageReference ('/index/SandBoxCart?pid='+ApexPages.currentPage().getParameters().get('pid'));
  	}
  
    public void process()
    {
    	isSuccess = false;
        expiration = cardmonth + cardyear;    
        if(!validate())
        {
        	isSuccess = false;
            return;
        }
        
        AuthorizeDotNet ath = new AuthorizeDotNet(false);
        ath.transaction(cardnumber, expiration, amount, cardcvv,'','');  
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
        
        if(ath.isApproved())
        {
        	String responsetext  = ath.getResponseText();
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
    	    	Invoice__c invoice = new Invoice__c();
                invoice.Account__c = ApexPages.currentPage().getParameters().get('pid');
                //invoice.Invoice_Amount__c=totl;
                invoice.Status__c='Paid';
                invoice.Payment_Method__c='Authorize.net';
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
 				totl=0;
 				
 				for (Integer i=0;i<items.size();i++) 
                {
                	if(items[i]==''|| items[i]==null )
                    {continue;}
                    
                    arr_items=items[i].split(',');
                   	//discc=  (decimal.valueOf(arr_items[0]))-((decimal.valueOf(arr_items[0]))*(decimal.valueOf(arr_items[2]))/100);
                    discc=decimal.valueOf(arr_items[0])-((decimal.valueOf(arr_items[0])*decimal.valueOf(arr_items[2].replace('%',''))/100));
                    discc=discc.setScale(2);
                    totl=(totl+discc).setScale(2);
                    Cart_page = Cart_page+'<tr><td>'+arr_items[5]+'</td><td>'+arr_items[9]+'</td><td>'+arr_items[3]+'</td><td>$'+decimal.valueOf(arr_items[0]).setScale(2)+'</td><td>'+arr_items[2]+'</td><td>$'+discc+'</td></tr>';
                    
                    LocationAssesmentRelationship__c locA= new LocationAssesmentRelationship__c();
    				Datetime myDate    = datetime.newInstance(Date.today().Year(), Date.today().month(), Date.today().Day());
            		locA.Assessment__c = arr_items[7]; 
           	 		locA.ExpiryDate__c = myDate.Date().addyears(1);
            		locA.Location__c   = arr_items[6]; 
            		locA.Status__c     = 'Active';
            		locA.Invoice__c    = invoice.Id;
            		insert locA;
                } 
        		Cart_page = Cart_page+' <tr>';
        		Cart_page = Cart_page+'<td colspan=\"5\" align=\"right\" >Total </td>';
        		Cart_page = Cart_page+'<td>$'+totl+'</td>';
        		Cart_page = Cart_page+'</tr>';
        		Cart_page = Cart_page+'</table></div><br/><br/>';
        		invoice.Invoice_Amount__c = totl;
         		invoice.Invoice_Detail__c = Cart_page;
         		update invoice;
    			//cart = new Cookie('cart',null,'/index',-1,false);
    			//ApexPages.currentPage().setCookies(new Cookie[]{cart});
    			// inserting assements
    			//system.debug(Cart_page);   		
				//riaz 25-9\\
				//	if(cart!=null)
        		{
             	cart_val=cart.getValue();
          		//if(cart_val=='')
           		//{
            	//return ;
           		//}            
           		//arr_items;
            	items = cart_val.split(';'); 
            	totl=0;
            	
            	for (Integer i=0;i<items.size();i++) 
            	{
                	if(items[i]==''|| items[i]==null )
                	{continue;}
                	
                	arr_items = items[i].split(',');
                	discc=decimal.valueOf(arr_items[0])-((decimal.valueOf(arr_items[0])*decimal.valueOf(arr_items[2].replace('%',''))/100));
                	discc=discc.setScale(2);
                	totl=(totl+discc).setScale(2);
            	}
            	Cart_page = ' <div id="tbl" style="margin-left:10px;"><table width=\"650\" border=\"1\" bordercolor=\"#CCCCCC\" cellspacing=\"0\" cellpadding=\"2\" style=\"font-family:Arial, Helvetica, sans-serif; font-size:12px; border-radius:6px;-moz-border-radius:6px;\">';
            	Cart_page = Cart_page+'<tr style=\"background-color:#879839; \">';
            	Cart_page = Cart_page+'<td style=\"height:25px;color:white\"><strong>IQCP Location / Unique Identifier</strong></td>';
            	Cart_page = Cart_page+'<td style=\"height:25px;color:white\"><strong>CLIA Number</strong></td>';
            	Cart_page = Cart_page+'<td style=\"height:25px;color:white\"><strong>Assessment</strong></td>';
            	Cart_page = Cart_page+'<td style=\"height:25px;color:white\"><strong>Price</strong></td>';
            	Cart_page = Cart_page+' <td style=\"height:25px;color:white\"><strong>Discount</strong></td>';
            	Cart_page = Cart_page+' <td style=\"height:25px;color:white\"><strong>Total</strong></td>';
            	Cart_page = Cart_page+'</tr> ';
            	for (Integer i=0;i<items.size();i++) 
            	{
                	if(items[i]==''|| items[i]==null )
                	{continue;}
                	
                	arr_items = items[i].split(',');
                	//discc   = (decimal.valueOf(arr_items[0]))-((decimal.valueOf(arr_items[0]))*(decimal.valueOf(arr_items[2]))/100);
                	discc     = decimal.valueOf(arr_items[0])-(( decimal.valueOf(arr_items[0])*  decimal.valueOf(arr_items[2].replace('%',''))/100));
                	discc    = discc.setScale(2);
                	//totl=totl+discc;
                	system.debug((arr_items[2]));
                	Cart_page = Cart_page+'<tr><td>'+arr_items[5]+'</td><td>'+arr_items[9]+'</td><td>'+arr_items[3]+'</td><td>$'+decimal.valueOf(arr_items[0]).setScale(2)+'</td><td>'+(arr_items[2])+'</td><td>$'+discc+'</td></tr>';
            	}
            	Cart_page=Cart_page+'<tr>';
            	Cart_page=Cart_page+'<td colspan=\"5\" align=\"right\" >Total </td>';
            	Cart_page=Cart_page+'<td>$'+totl+'</td>';
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
            	
            	Account acc =[Select Name,Phone,billingCity,billingStreet,billingCountry,BillingState,BillingPostalCode from ACCOUNT where ID =: ApexPages.currentPage().getParameters().get('pid')];
            	Invoice__c inv =[Select Name from Invoice__c where ID =: invoice.Id];
            	List<Contact> ct = [Select FirstName, LastName from Contact where AccountID =:  ApexPages.currentPage().getParameters().get('pid') and type__c like 'Account Administrator'];  
            	
            	Cart_page= '<img Style="margin-left:15px;" src="https://c.na15.content.force.com/servlet/servlet.ImageServer?id=015i00000002PsJ&oid=00Di0000000JNqD&lastMod=1368776771000" alt="emaillogo"/>'+
            	'<font face="Trebuchet MS">'+
            	'<table width="58%" style="margin-left:15px;">'+
            	     '<tr>'+
            	        '<td width="50%" colspan="2" align="center" Style="font-size:10px;">Invoice Number. '+ inv.Name +'</td>' +
            	     '</tr>'+
            	     '<tr>'+
            	        '<td width="50%" colspan="2" align="center" Style="font-size:10px;"> Date. ' + date.today().month()  + '-' + date.today().day() + '-'+ date.today().year()+'</td>' + 
            	     '</tr>'+
            		'<tr>'+
               			'<td width="50%" Style="font-size:10px;">Company: '+ acc.Name + '</td>'+
                		'<td width="50%" align="right" Style="font-size:10px;">Contact Name: '+ ct[0].FirstName + ' ' + ct[0].LastName + '</td>'+
            		'</tr>'+
            		'<tr>'+
                		'<td width="50%" Style="font-size:10px;">Billing Address:<br/>'+ acc.BillingStreet + ',<br/>' + acc.BillingCity+ ', '+acc.BillingState+', '+acc.BillingPostalCode+ ', ' + acc.BillingCountry+'</td>'+
                		'<td width="50%" align="right" Style="font-size:10px;">Contact Number:'+ acc.Phone + '</td>'+
            		'</tr>'+
            	'</table>'+'<br/><br/>'+Cart_page;
            
			   	Datetime dt = Datetime.NOW();
			    String year  =  string.valueOf(dt.year());
			    String day   =  string.valueOf(dt.day());
			    String month =  string.valueOf(dt.month());
			    String hour  =  string.valueOf(dt.hour());
			    String minute=  string.valueOf(dt.minute());
			    String second=  string.valueOf(dt.second());
			    
			    Cart_page=Cart_page+'<b><p Style="font-size:14px;margin-left:15px"> Payment Terms</p> </b> '
			    +'<p Style="font-size:10px;margin-left:15px"> Invoice Paid through Credit card on ' + system.now() +'</p>'          
               	+'<b><p Style="font-size:10px;margin-left:15px;">CarePoint Solutions, Inc. </b> </p>'        
               	+'<p Style="font-size:10px;margin-left:15px"> PO Box 900  </p>'        
               	+'<p Style="font-size:10px;margin-left:15px">Westford, MA 01886</p>';
               	mail.setHtmlBody('Dear '+cEmail.FirstName+' '+cEmail.LastName+'<br/><br/>'+Cart_page);
           		//mail.setHtmlBody(Cart_page)+'<br/><br/> [Invoice detail goes here]');
           		Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail }); 
       			}
				//Invoice Paid through Credit card on {Date & Time}
    		}
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Info, responsetext + '\nTransaction Id: ' + transactionid )); 
            isSuccess = true;        
      		//riaz 25-9\\
       	}
        else if(ath.isDeclined())
        {
        	String reason = ath.getResponseText();
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, reason)); 
            isSuccess = false;
        }
        else
        {
            String reason = ath.getResponseText();
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, reason)); 
            isSuccess = false;
        }
    }
    
    private boolean validate()
    {
    	boolean isvalid = true;
        
        if(!isValid(amount))
        {
        	ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Required Field Missing: Amount')); 
            isvalid = false;
        }
        if(!isValid(cardnumber))
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Required Field Missing: Card Number')); 
            isvalid = false;
        }
        if(!isValid(expiration))
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Required Field Missing: Expiration Date')); 
            isvalid = false;
        }
        if(!isValid(cardcvv))
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Required Field Missing: CVV Number')); 
            isvalid = false;
        }
        if(!isValid(firstname))
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Required Field Missing: First Name')); 
            isvalid = false;
        }
        if(!isValid(lastname))
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Required Field Missing: Last Name')); 
            isvalid = false;
        }
        if(!isValid(address))
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Required Field Missing: Address')); 
            isvalid = false;
        }
        if(!isValid(state))
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Required Field Missing: State')); 
            isvalid = false;
        }
        if(!isValid(zip))
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Required Field Missing: Zip')); 
            isvalid = false;
        }
        if(!isValid(city))
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Required Field Missing: city')); 
            isvalid = false;
        }
        if(!isValid(cardholder))
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Required Field Missing: cardholder Name')); 
            isvalid = false;
        }
        return isvalid;
    }
    
    private boolean isValid(string val)
    {
    	return val == null ? false : val.trim().length() == 0 ? false: true;
    }
    
    static testMethod void testDoPaymentHandler()
    {
   		PageReference pageRef = Page.DoPayment;
    	Test.setCurrentPageReference(pageRef);
    	
    	Account acc = new Account(Name = 'Account');
    	acc.BillingCity='ads';
    	acc.BillingCountry='adsf';
    	acc.BillingPostalCode='asdf';
    	acc.BillingState='dsadsf';
    	acc.BillingStreet='dSF';
   		insert acc;
   		
   		 system.debug('testttt'+acc.Id); 
   		 
   		Contact con1 = new Contact(FirstName = 'fname', LastName='lname',Type__c= 'Account Administrator',AccountId = acc.Id, User_Name__c = 'TADNL1',Email = 'test@example.com');
   		Contact con2 = new Contact(FirstName = 'fname', LastName='lname',Type__c= 'Account Administrator',AccountId = acc.Id, User_Name__c = 'TADNL2',Email = 'test@example.com');
   		insert con1;
   		insert con2;
   		
   		Location__c loc = new Location__c(Name = 'locName',Account__c = acc.Id, city__c = 'city',Address__c = 'address', CLIA__c='131');
   		insert loc;
   		
   		Assessment__c ass = new Assessment__c(); 
   		insert ass;
   		Invoice__c inv= new Invoice__c();
   		inv.Account__c=acc.Id;
   		inv.Payment_Method__c='asd';
   		inv.Status__c='paid';
   		insert inv;
   		
   		 LocationAssesmentRelationship__c locA= new LocationAssesmentRelationship__c();
    				Datetime myDate    = datetime.newInstance(Date.today().Year(), Date.today().month(), Date.today().Day());
            		locA.Assessment__c = ass.id; 
           	 		locA.ExpiryDate__c = myDate.Date().addyears(1);
            		locA.Location__c   = loc.Id; 
            		locA.Status__c     = 'Active';
            		locA.Invoice__c    = inv.Id;
            		insert locA;
   		
   		
        Cookie username = new Cookie('username',con1.User_Name__c,'/index',-1,false);
        ApexPages.currentPage().setCookies(new Cookie[]{username});
        ApexPages.currentPage().getParameters().put('pid',acc.Id); 
        Cookie cart = new Cookie('cart_'+acc.Id,'0000,1111,5555,345,8766,453,'+loc.Id+','+ass.Id+','+acc.Id+','+66666,null,-1,false);
     	ApexPages.currentPage().setCookies(new Cookie[]{cart}); 
     	
   		 system.debug('testttt'+acc.Id); 
   		
        DoPaymentHandler doPayment = new DoPaymentHandler();        
        doPayment.cardnumber = '12345678890';
        doPayment.cardcvv = '12345';
        doPayment.totl = 123.12;
        doPayment.amount1=123.23;
        doPayment.amount='1223.344';
        doPayment.process();
        doPayment.getMonths();
        doPayment.getYears();
        doPayment.getCardTypes();
        doPayment.Cancel();
        doPayment.redirect();
        doPayment.firstname='test';
        doPayment.isValid(doPayment.firstname);
        doPayment.lastname='test';
        doPayment.email='test@test.com';
        doPayment.address='test';
        doPayment.city='test';
        doPayment.state='test';
        doPayment.zip='123456';
        doPayment.cardholder='test';
        doPayment.cardnumber='test';
        doPayment.cardyear='test'; 
        doPayment.cardmonth='test';
        doPayment.cardcvv='test';
        doPayment.expiration='test';
        doPayment.selectedCardType='test';
       doPayment.process();
        
        
        AuthorizeDotNet auth = new AuthorizeDotNet(true);
        auth.transaction(doPayment.cardnumber, doPayment.expiration, doPayment.amount, doPayment.cardcvv,'','');  
        auth.setParameter('x_device_type','1');  
        auth.setParameter('x_first_name','fname');  
        auth.setParameter('x_last_name','lname');  
        auth.setParameter('x_address','adddedf');  
        auth.setParameter('x_state','state');  
        auth.setParameter('x_response_format','1');  
        auth.setParameter('x_zip','1234');
        auth.setTransactionType('test');
        auth.process(3);
        auth.getResultResponse();
        auth.isDeclined();
    }
}