public with sharing class Cart {
	public  String cart_var{get;set;}
	public  String pcart{get;set;}
	public  String del{get;set;}
	public  List<string> arr_items;
    public  String ass_id;
    public  String loc_clia;
    public  string str2;
    public  string acid = ApexPages.currentPage().getParameters().get('pid');
    public  string username {get;set;}

    public void check_item(String item1){
    	if(item1.indexOf(del)<0){
        	arr_items=item1.split(',');
            ass_id=arr_items[7];
            loc_clia = arr_items[9];            
            Boolean found = false; 
            List<String> str2_items = str2.split(';');
            
            for (Integer i=0;i<str2_items.size();i++) 
            {
                if(str2_items[i]==''|| str2_items[i]==null )
                {continue;}
				if(str2_items[i].indexOf(ass_id)>=0 && str2_items[i].indexOf(loc_clia)>=0){
            		found = true;
				}
            }
           	if(found){
	       		item1=item1.replace('0%','75%');
          	}else{
          		
          		String ass1='temp ';
            	system.debug(ass1);
            	List<LocationAssesmentRelationship__c> orders= [Select Assessment__c  from LocationAssesmentRelationship__c where location__c IN (Select Id From Location__c where Account__c =:acid  AND CLIA__c =: loc_clia) AND Status__c = 'Active'];
                for(LocationAssesmentRelationship__c order1: orders)
            	{ 
            		ass1=ass1+order1.Assessment__c+',';
            	}
            	if(ass1.indexOf(ass_id)<0)
            		item1=item1.replace('75%','0%');
            	
               	
           	}
            str2=str2+item1+';';
            
         }
    }
    public Cart(ApexPages.StandardController controller) {
    	Cookie usercookie = ApexPages.currentPage().getCookies().get('username');
        username = usercookie.getValue();
        
    	Cookie cart = ApexPages.currentPage().getCookies().get('cart_'+acid);
        pcart='';
        if(cart!=null){
        	pcart = cart.getValue();
        }
        if(pcart!=''){
        	del = ApexPages.currentPage().getParameters().get('del');
            str2='';
        	if(del!=null){      
           		//List<string> arr_del=del.split(',');
           		//List<string> arr_items;
           		//String ass_id;
           		//Integer counter=0;
           		List<String> items = pcart.split(';'); 
        		for (Integer i=0;i<items.size();i++) {
           			if(items[i]==''|| items[i]==null ){
           				continue;
           			}
                	check_item(items[i]);
            	}
            	cart = new Cookie('cart_'+acid,str2,'/index',172800,false);
            	ApexPages.currentPage().setCookies(new Cookie[]{cart});
            	//return new Pagereference ('/index/SandBoxCart?pid='+ApexPages.currentPage().getParameters().get('pid'));
        	}
        	cart_var=String.ValueOf(cart.getValue());
      	}
    }
    public Pagereference Checkout(){
    	Pagereference p =new Pagereference('/index/payInvoice');
       	return p;
    }
 	// public Pagereference Cancel(){
 	//      Pagereference p =new Pagereference('/index/locationdetail?id='+ApexPages.currentPage().getParameters().get('locid'));
    //   return p;
   	// }
   
    static testMethod void cartTest(){
    	PageReference pageRef = Page.SandBoxCart;
       	// processSelected();
        Test.setCurrentPageReference(pageRef);  
        //ApexPages.currentPage().getParameters().put('del','yes');
        Assessment__c asmt = new Assessment__c();
        asmt.Analyte__c = 'testAn';
        asmt.Device__c = 'testDev';
        insert asmt; 
        Account ac= new account(Name='ADS');
        insert ac;        
        String acid=ApexPages.currentPage().getParameters().put('pid',ac.Id);
        Cookie cart = new Cookie('cart_'+acid,'1111,2222,3333,4444,5555,6666,7777,8888,9999,1234,56,67, ' ,null,-1,false);
        ApexPages.currentPage().setCookies(new Cookie[]{cart});
        ApexPages.currentPage().getParameters().put('del',asmt.id+','+'1erasd');
        //pcart='11111';
        Cookie usercookie = new Cookie('username','asd' ,null,-1,false);
         ApexPages.currentPage().setCookies(new Cookie[]{usercookie});
         ApexPages.currentPage().getParameters().put('username','1erasd');
        ApexPages.StandardController sc = new ApexPages.standardController(asmt);    
        Cart  obj = new cart(sc);
       	ApexPages.currentPage().getParameters().put('del','11111');
        obj.pcart='11111';
      //	obj.del='2222';
      	//obj.payNow();
        obj.Checkout();
        obj.loc_clia='3333';
        obj.str2='1111';
        obj.ass_id='1111';
        obj.del='jjjjjjjjjjjj';
        obj.check_item('1111,2222,3333,4444,5555,6666,7777,8888,9999,1234,56,67');
        obj.ass_id='2222';
        obj.check_item('1111,2222,3333,4444,5555,6666,7777,8888,9999;1234,56,67');
       	//obj.process1(asmt.id+','+'1erasd');
  }
  
}