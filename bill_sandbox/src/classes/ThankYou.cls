public with sharing class ThankYou {
	public  String cart_var{get;set;}
    public ID id = ApexPages.currentPage().getParameters().get('id');
    
    public ThankYou() {    
        Cookie cart = ApexPages.currentPage().getCookies().get('cart_'+id);
        if(cart!=null){
        	cart_var = String.ValueOf(cart.getValue());     
        }
        cart = new Cookie('cart_'+id,null,'/index',-1,false);
        ApexPages.currentPage().setCookies(new Cookie[]{cart}); 
    }
    
    static testMethod void thankyouTest(){
    	PageReference pageRef = Page.SandBoxCart;
        Test.setCurrentPageReference(pageRef); 
        Cookie cart = new Cookie('cart','1111,2222,3333,4444,5555,6666,7777,8888' ,null,-1,false);
        ApexPages.currentPage().setCookies(new Cookie[]{cart});
        ThankYou ty = new ThankYou();
  	}
}