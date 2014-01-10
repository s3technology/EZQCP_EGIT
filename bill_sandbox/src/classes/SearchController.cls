public with sharing class SearchController {
    
    public string  amount            {get;set;}
    public string  firstname         {get;set;}
    public string  lastname          {get;set;}
    public string  email             {get;set;}
    public string  address           {get;set;}
    public string  city              {get;set;}
    public string  state             {get;set;}
    public string  zip               {get;set;}
    public string  cardholder        {get;set;}
    public string  cardnumber        {get;set;}
    public string  cardyear          {get;set;}
    public string  cardmonth         {get;set;}
    public string  cardcvv           {get;set;}
    public string  expiration        {get;set;}
    public string  selectedCardType  {get;set;}
    public boolean isSuccess         {get;set;}
    public Boolean showL             {get;set;}
    public String  msg               {get;set;}
    public List<Assessment__c> cart_var {get;set;}
    public List<Location__c> cart_loc   {get;set;}
    public List<LocationAssesmentRelationship__c> orders {get;set;}
    public string Cart_page{get;set;}
    public decimal totl;
    public decimal discc;
    public decimal acc_disc;
    LocationAssesmentRelationship__c lar = new LocationAssesmentRelationship__c();
    public LocationAssesmentRelationship__c getLar(){
        return lar;
    }
    public ID locationId = ApexPages.currentPage().getParameters().get('lid');
    public List<LocationAssesmentRelationship__c> larList  {get;set;}
    public List<LocationAssesmentRelationship__c> larList2 {get;set;}
    public Assessment__c fieldsData;
    public String soql {get;set;}
    public SearchController(ApexPages.StandardController controller) {
        fieldsData = (Assessment__c)controller.getRecord();
        msg = ApexPages.currentPage().getParameters().get('msg');
    }
    public List<Assessment__c> selectedAssessments {get;set;}             
    public List<sAssessment> assessmentList {get;set;}                           // Wrapper class which stores assessment data and a boolean flag.
    public Boolean selectAllCheckbox {get;set;}                                  // Stores checkbox data.
    public boolean errormsg=false;                                               // Error msg. When no assessment has been selected.
    public List<Assessment__c> results = new List<Assessment__c>();              // assessment search results.
    
    /* Method to Search the assessment database to fetch the query results */
    public List<Assessment__c> assessmentSearch(){
        errormsg=false;
        assessmentList = new List<sAssessment>();
        soql = 'select Id, Name, Price__c, Test_Name__c, Analyte__c , Manufacturer__c, Device__c, URL__c From Assessment__c where Status__c != \'Disable\' AND '; 
        soql = soql+ 'Id NOT IN (Select Assessment__c From LocationAssesmentRelationship__c where Location__c = \''+ locationId +'\' and Status__c like \'Active\' and ExpiryDate__c > TODAY)';
        if (fieldsData.Manufacturer__c!=null)
            soql += ' and Manufacturer__c LIKE \''+ fieldsData.Manufacturer__c +'%\'';
        if (fieldsData.Device__c!=null)
            soql += ' and Device__c LIKE \''+fieldsData.Device__c+'%\'';
        if (fieldsData.Analyte__c!=null)
            soql += ' and Analyte__c  INCLUDES(\''+fieldsData.Analyte__c+'\')';
        if (fieldsData.Test_Name__c!=null)
            soql += ' and Test_Name__c includes (\''+fieldsData.Test_Name__c+'\')';
          
        for(Assessment__c a :Database.query(soql)){
            assessmentList.add(new sAssessment(a));
        }                                                       
        return null;
    }

    public List<sAssessment> getresults(){
        return assessmentList;
    }

    /* Wrapper class to contain assessment record and a boolean flag */
    public class sAssessment{
        public Assessment__c ass {get; set;}
        public Boolean selected {get; set;}
           
        /*This is the constructor method. When we create a new sAssessment object we pass a
        assessment that is set to the ass property. We also set the selected value to false*/
        
        public sAssessment(Assessment__c a){
            ass = a;
            selected = false;
        }
    }
    
    /* Method to process the selected records*/
    public PageReference redirect(String url){
     	return new Pagereference (url);
    }

    public void process2(ID id2)
    {
    	String acid=    ApexPages.currentPage().getParameters().get('pid');                 
        Account curr_acc = [Select Discount__c From Account Where Id =:acid];
        try{
        	acc_disc = curr_acc.Discount__c==null?0:curr_acc.Discount__c;
        }catch(Exception e){
        	//TODO: Do nothing
        }
        
    	lar.Location__c = ApexPages.currentPage().getParameters().get('lid');
        lar.Assessment__c =id2;
        lar.Status__c = 'Active';
        Datetime myDate = datetime.newInstance(Date.today().Year(), Date.today().month(), Date.today().Day());
        lar.ExpiryDate__c = myDate.Date().addyears(1);
        cart_var=  [Select  a.Price__c,  a.Manufacturer__c,  a.Id, a.Discount__c, a.Device__c,  a.Analyte__c From Assessment__c a where a.Id=:lar.Assessment__c];
        decimal ass_price = cart_var[0].Price__c;
        decimal disc_price = ass_price-(ass_price*acc_disc/100);
        String sale_price = cart_var[0].Price__c.format();
        String price = disc_price.format();
        String manf=cart_var[0].Manufacturer__c;
        ID ass_id=id2;
        String disc='0%';//cart_var[0].Discount__c.format();
        String devic=cart_var[0].Device__c;
        String analyt=cart_var[0].Analyte__c;
        cart_loc=[Select  l.Status__c, l.Name, l.Id, l.City__c, l.Address__c, l.Account__c ,CLIA__c From Location__c l where l.id=:lar.Location__c];
        String name=cart_loc[0].Name;
        String id=lar.Location__c;  
        String loc_clia = cart_loc[0].CLIA__c;

        // going to set the cookie
        Cookie cart = ApexPages.currentPage().getCookies().get('cart_'+acid);
        system.debug(cart+'***********');
        if(cart!=null)
        {
        	String cartDisc=cart.getValue();
        	List<String> cartDisc_items = cartDisc.split(';');
            for (Integer i=0;i<cartDisc_items.size();i++) 
            {
                if(cartDisc_items[i]==''|| cartDisc_items[i]==null )
                {continue;}
                if(cartDisc_items[i].indexOf(ass_id)>0 && cartDisc_items[i].indexOf(loc_clia)>0)
            		disc='75%';
            }
            
            String ass1='temp ';
            orders= [Select Assessment__c  from LocationAssesmentRelationship__c where location__c IN (Select Id From Location__c where Account__c =:acid  AND CLIA__c =: loc_clia) AND Status__c = 'Active'];
                  
            for(LocationAssesmentRelationship__c order1: orders)
            { 
            	system.debug(order1.Assessment__c +'-----'+ass_id);
            	if(order1.Assessment__c == ass_id){
            		disc='75%';	
	            	system.debug(disc);
            	}
            	//ass1=ass1+order1.Assessment__c+',';
            }
            
            //if(ass1.indexOf(ass_id)>=0)
            //	disc='75%';
         }
         if (cart == null ) {
         	orders= [Select Assessment__c  from LocationAssesmentRelationship__c where location__c IN (Select Id From Location__c where Account__c =:acid  AND CLIA__c =: loc_clia) AND Status__c = 'Active'];
                  
            for(LocationAssesmentRelationship__c order1: orders)
            { 
            	system.debug(order1.Assessment__c +'-----'+ass_id);
            	if(order1.Assessment__c == ass_id){
            		disc='75%';	
	            	system.debug(disc);
            	}
            	//ass1=ass1+order1.Assessment__c+',';
            }
         	cart = new Cookie('cart_'+acid, price+','+manf+','+disc+','+devic+','+analyt+','+name+','+id+','+ass_id+','+acid+','+loc_clia+','+sale_price+','+acc_disc,'/index',172800,false);
			system.debug('1************');
         } else {
         	String pcart = cart.getValue();
            // now check if assment already in the cart                                
            if(pcart.indexOf(id+','+ass_id)>=0) 
            {
            	return;  
            	msg='1';
            	redirect('/index/searchAssessment?lid='+ApexPages.currentPage().getParameters().get('lid')+'&name='+ApexPages.currentPage().getParameters().get('name')+'&pid='+ApexPages.currentPage().getParameters().get('pid')+'&msg='+msg);
            }
            else
            {
            	cart = new Cookie('cart_'+acid, pcart+';'+price+','+manf+','+disc+','+devic+','+analyt+','+name+','+id+','+ass_id+','+acid+','+loc_clia+','+sale_price+','+acc_disc,'/index',172800,false);
            	system.debug('2************');
            }
            //cart = new Cookie('cart','',null,-1,false);
         }
         ApexPages.currentPage().setCookies(new Cookie[]{cart});
    }
    public PageReference processSelected(){
    	if(larList==null){larList = new List<LocationAssesmentRelationship__c>();}
        selectedAssessments = new List<Assessment__c>();
        if (assessmentList!= null){ 
            for(sAssessment sAss : assessmentList){ //getresult()
                if(sAss.selected == true){
                   selectedAssessments.add(sAss.ass);
                   process2(sAss.ass.Id);
                }
            }
            return new Pagereference ('/index/SandBoxCart?pid='+ApexPages.currentPage().getParameters().get('pid'));
         }        
        /* return error message if no assessment is selected */
        if(selectedAssessments.size()==0){
             errormsg=true;
             return null;
        } 
        else{
            errormsg=false;
            String id=System.currentpagereference().getparameters().get('id');
            Pagereference p=new Pagereference ('/index/locationdetail?id='+locationId);
            //return p;
            return null;
        }
    }
   
    /* return error message if no assessment is selected */
    public boolean geterrormsg(){
        return errormsg;
    }
    
    /* Method to cancel the entire process */
    public Pagereference Cancel(){
        Pagereference p =new Pagereference('/index/locationdetail?id='+locationId);
    	return p;
    }
   /* 
    public Pagereference sendMeInvoice(){ 
    	Cookie cart = ApexPages.currentPage().getCookies().get('cart');
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
                totl=totl+discc;
            }
            Invoice__c invoice = new Invoice__c();
            invoice.Account__c = ApexPages.currentPage().getParameters().get('pid');
            invoice.Invoice_Amount__c=totl;
            //invoice.LocationAssesmentRelationship__c = locA.Id;
            insert invoice; 
            Cart_page=' <div id="tbl" style="margin-left:300px;"><table width=\"500\" border=\"1\" bordercolor=\"#CCCCCC\" cellspacing=\"0\" cellpadding=\"2\" style=\"font-family:Arial, Helvetica, sans-serif; font-size:12px; border-radius:6px;-moz-border-radius:6px;\">';
     		Cart_page=Cart_page+'<tr  style=\"background-color:#879839; \">';
     		Cart_page=Cart_page+'<td style=\"height:25px;color:white\"><strong>Assesment</strong></td>';
     		Cart_page=Cart_page+'<td style=\"height:25px;color:white\"><strong>IQCP Location</strong></td>';
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
                //discc=decimal.valueOf(arr_items[0])-((decimal.valueOf(arr_items[0])*decimal.valueOf(arr_items[2].replace('%',''))/100));
                //totl=totl+discc;
                Cart_page=Cart_page+'<tr><td>'+arr_items[3]+'</td><td>'+arr_items[5]+'</td><td>$'+arr_items[0]+'</td><td>'+arr_items[2]+'</td><td>$'+discc+'</td></tr>';
                LocationAssesmentRelationship__c locA= new LocationAssesmentRelationship__c();
                Datetime myDate = datetime.newInstance(Date.today().Year(), Date.today().month(), Date.today().Day());
                locA.Assessment__c=arr_items[7];
                locA.ExpiryDate__c=myDate.Date().addyears(1);
                locA.Location__c=arr_items[6];
                locA.Status__c='Active';
                locA.Invoice__c=invoice.Id;
                locA.Orignal_Price__c=decimal.valueOf(arr_items[0]);
                locA.Discount__c=decimal.valueOf(arr_items[2].replace('%',''));
                locA.Invoice_Price__c=decimal.valueOf(arr_items[0])-((decimal.valueOf(arr_items[0])*decimal.valueOf(arr_items[2].replace('%',''))/100));
                insert locA;
			}
			Cart_page=Cart_page+' <tr>';
        	Cart_page=Cart_page+'<td colspan=\"4\" align=\"right\" >Total </td>';
        	Cart_page=Cart_page+'<td>'+totl+'</td>';
        	Cart_page=Cart_page+'</tr>';
        	Cart_page=Cart_page+'</table></div><br/><br/>';
         	Cookie un = ApexPages.currentPage().getCookies().get('username');    
         	Contact cEmail =  [Select Email From Contact Where User_Name__c =: un.getValue()];
         	Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
         	String[] toAddresses = new String[] {cEmail.Email};
         	mail.setToAddresses(toAddresses);
         	mail.setSenderDisplayName('Support Team');
         	mail.setSubject('Invoice ');  
         	mail.setBccSender(false);
         	mail.setUseSignature(false);
      		Account acc =[Select Name,Phone,billingCity,billingStreet,billingCountry from ACCOUNT where ID =: ApexPages.currentPage().getParameters().get('pid')];
      		Invoice__c inv =[Select Name from Invoice__c where ID =: invoice.Id];
      		List<Contact> ct = [Select FirstName, LastName from Contact where AccountID =:  ApexPages.currentPage().getParameters().get('pid') and type__c like 'Account Administrator'];  
      		Cart_page= '<img Style="margin-left:15px;" src="https://c.na15.content.force.com/servlet/servlet.ImageServer?id=015i00000002PsJ&oid=00Di0000000JNqD&lastMod=1368776771000" alt="emaillogo"/>'+
            '<font face="Trebuchet MS">'+
            '<p Style="margin-left:400px;font-size:10px;">Invoice Number. '+ inv.Name +'</p>' +
            '<p Style="margin-left:450px;font-size:10px;"> Date. ' + date.today().month()  + '-' + date.today().day() + '-'+ date.today().year()+'</p>' + 
            '<table width="100%" style="margin-left:15px;">'+
           	'<tr>'+
               	'<td width="50%" Style="font-size:10px;">Company:'+ acc.Name + '</td>'+
                '<td width="50%" Style="font-size:10px;">Contact Name: '+ ct[0].FirstName + ' ' + ct[0].LastName + '</td>'+
            '</tr>'+
            '<tr>'+
                '<td width="50%" Style="font-size:10px;">Billing Address:'+ acc.BillingStreet + ',' + acc.BillingCity+ ','+ acc.BillingCountry+'</td>'+
                '<td width="50%" Style="font-size:10px;">Contact Number:'+ acc.Phone + '</td>'+
            ' </tr>'+
            '</table>'+Cart_page;
            Cart_page=Cart_page+'<b><p Style="font-size:14px;margin-left:15px"> Payment Terms</p> </b> ' +     
            '<p Style="font-size:10px;margin-left:15px">All payments are due 30 days from the date of invoice. To be made payable to:</p>'+
            '<b><p Style="font-size:10px;margin-left:15px;">CarePoint Solutions, Inc. </b> </p>'+
            '<p Style="font-size:10px;margin-left:15px"> PO Box 900</p>'+
            '<p Style="font-size:10px;margin-left:15px">Westford, MA 01886</p>';
         	mail.setHtmlBody('Dear '+string.ValueOf(un.getValue())+'<br/><br/>'+Cart_page);
         	//mail.setHtmlBody(Cart_page)+'<br/><br/> [Invoice detail goes here]');
         	Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
         }   
         //return null;// 
         return new PageReference('/index/index?id='+ApexPages.currentPage().getParameters().get('pid'));
    }
    */
    public Pagereference payNow(){
       // return Page.DoPayment?pid={!$CurrentPage.parameters.pid};    
       Pagereference p =new Pagereference('/index/dopayment?pid='+ApexPages.currentPage().getParameters().get('pid'));
       return p;//null;
    }
    
    public Pagereference SendInvoice(){ 
       Pagereference p =new Pagereference('/index/dopayment_invoice?pid='+ApexPages.currentPage().getParameters().get('pid'));
       return p;//null;
    }
    ///////////////////////
/*  public List<SelectOption> getMonths(){
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
    
    //Handling payment processing submitting by VF page button
    public PageReference process(){
        isSuccess = false;
        expiration = cardmonth + cardyear;
        if(!validate()){
            isSuccess = false;
            return null;
        }
        AuthorizeDotNet ath = new AuthorizeDotNet(true);
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
        if(ath.isApproved()){
            String responsetext = ath.getResponseText();
            String transactionid = ath.getTransactionID();
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Info, responsetext + '\nTransaction Id: ' + transactionid )); 
            isSuccess = true;
          	//insert lar;
            return new PageReference('/index/assessmentDetail?id='+lar.Assessment__c+'&pid='+lar.Location__c+'&larid='+lar.id); 
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
        return null;
    }
    
    private boolean validate(){
        boolean isvalid = true;
        if(!isValid(amount)){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Required Field Missing: Amount')); 
            isvalid = false;
        }
        if(!isValid(cardnumber)){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Required Field Missing: Card Number')); 
            isvalid = false;
        }
        if(!isValid(expiration)){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Required Field Missing: Expiration Date')); 
            isvalid = false;
        }
        if(!isValid(cardcvv)){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Required Field Missing: CVV Number')); 
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
        if(!isValid(state)){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Required Field Missing: State')); 
            isvalid = false;
        }
        if(!isValid(zip)){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Required Field Missing: Zip')); 
            isvalid = false;
        }
        return isvalid;
    }
    
    private boolean isValid(string val){
        return val == null ? false : val.trim().length() == 0 ? false: true;
    }
*/
    static testMethod void searchControllerTest(){
        PageReference pageRef = Page.searchAssessment;
        //processSelected();
        
        Test.setCurrentPageReference(pageRef);
        Account a =new Account(Name='Test', User_Name__c = 'tester', Email__c = 'test@example.com'); 
        insert a;
       
        Contact con = new Contact(Email =  'test@test.com', LastName = 'Tester'); 
        con.User_Name__c = 'tester';
        con.Type__c = 'Account Administrator';
        con.accountid = a.id;
        insert con;
                
        Cookie usName = new Cookie('username', con.User_Name__c,null,-1,false);
        
        ApexPages.currentPage().setCookies(new Cookie[]{usName});
        Location__c loc = new Location__c();
        loc.Address__c = '123';
        loc.City__c = 'Peshawar';
        loc.Account__c = a.id;
        loc.Name ='peswaer';
        loc.CLIA__c = '232';
        insert loc;
        Apexpages.currentPage().getParameters().put('lid',loc.Id);
        Apexpages.currentPage().getParameters().put('pid',a.Id);
		
        Assessment__c asmt = new Assessment__c();
        asmt.Analyte__c = 'testAn';
        asmt.Device__c = 'testDev';
        asmt.Manufacturer__c= 'testMan';
        asmt.Test_Name__c = '';
        asmt.Discount__c = 5;
        asmt.Price__c=123;
       
     	//Cookie cartt =new Cookie( asmt.Price__c, asmt.Manufacturer__c ,asmt.Discount__c, asmt.Device__c,asmt.Analyte__c,null,-1,false);
   		//Cookie cart =new Cookie('cart',';'+price+','+manf+','+disc+','+devic+','+analyt+','+name+','+id+','+ass_id+','+acid,'/index',-1,false);                               
        //cart = new Cookie('cart','',null,-1,false);
    	//ApexPages.currentPage().setCookies(new Cookie[]{cartt});
        insert asmt;
        ApexPages.currentPage().getParameters().put('msg','msg1');
        ApexPages.StandardController sc = new ApexPages.standardController(asmt);    
        SearchController  SearchCon = new SearchController(sc);  
        sAssessment sAssmt = new sAssessment(asmt);
        sAssmt.selected=true;
        //for(sAssessment ss: SearchCon.getresults() )
        //if(ss.selected == true)
        //SearchCon.selectedAssessments.add(asmt.Id);
        //SearchCon.lar.Location__c = loc.id;
        //SearchCon.lar.Assessment__c =asmt.id;
        //SearchCon.lar.Status__c = 'Active';
        SearchCon.lar.ExpiryDate__c=system.today();
        //system.assertEquals(asmt.Analyte__c, 'asd');  
        SearchCon.assessmentSearch(); 
        SearchCon.getresults(); 
        SearchCon.processSelected();
        SearchCon.geterrormsg(); 
        SearchCon.Cancel();
        SearchCon.process2(asmt.Id);
    	//SearchCon.getMonths();
    	//SearchCon.getYears();
    	//searchCon.getCardTypes();
    	//SearchCon.validate();
    	//SearchCon.payNow();
    	//SearchCon.process();
        SearchCon.getLar();
    	//SearchCon.sendMeInvoice();
        SearchCon.sendInvoice();       
   }
}