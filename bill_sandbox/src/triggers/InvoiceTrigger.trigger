trigger InvoiceTrigger on Invoice__c (before update) {
	for(Invoice__c invoice : Trigger.New){      
    	try{
	    	Invoice__c old = System.Trigger.oldMap.get(invoice.Id);  
	    	String oldVal = '';
	    	String newVal = '';
	    	oldVal = old.Status__c==null?oldVal:old.Status__c;
	     	newVal = invoice.Status__c==null?newVal:invoice.Status__c;
			if(newVal.equals('Paid') && oldVal != 'Paid') {
	        	Account acc = 	[Select Email__c From Account where Id =: invoice.Account__c];   
	         	Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
	         	String[] toAddresses = new String[] {acc.Email__c}; 
	         	mail.setToAddresses(toAddresses);
	         	mail.setSenderDisplayName('EZ-QCP Support');
	         	mail.setSubject('EZ-QCP Payment Confirmation');
	         	mail.setBccSender(false); 
	         	mail.setUseSignature(false);
	          	mail.setHtmlBody('Your payment of $'+invoice.Invoice_Amount__c+' for Order Number '+invoice.Purchase_Order_Number__c+' has been received.  If you have any questions please contact support@ez-qcp.com.<br/><br/> We appreciate your business and having you as a valued customer.<br/> <br/>The EZ-QCP Team'); 
	          		          	
	          	/*
	         	'<img Style="margin-left:15px;" src="https://c.na15.content.force.com/servlet/servlet.ImageServer?id=015i00000002PsJ&oid=00Di0000000JNqD&lastMod=1368776771000" alt="emaillogo"/>'+
	         	'<font face="Trebuchet MS">' +
	 			'<p Style="margin-left:400px;font-size:10px;">Invoice Number. '+ invoice.Name +'</p>' +
	 			'<p Style="margin-left:450px;font-size:10px;"> Date. ' + date.today().month()  + '-' + date.today().day() + '-'+ date.today().year()+'</p>' + 
	 			'<table width="100%" style="margin-left:15px;">'+
		        	'<tr>'+
		        		'<td width="50%" Style="font-size:10px;">Company:'+ acc.Name + '</td>'+
		         		'<td width="50%" Style="font-size:10px;">Contact Name: '+ ct[0].FirstName + ' ' + ct[0].LastName + '</td>'+
		        	'</tr>'+
		        	' <tr>'+
		            	'<td width="50%" Style="font-size:10px;">Billing Address:'+ acc.BillingStreet + ',' + acc.BillingCity+ ','+ acc.BillingCountry+'</td>'+
		            	'<td width="50%" Style="font-size:10px;">Contact Number:'+ acc.Phone + '</td>'+
		        	'</tr>'+
		  		'</table>'+
		  		'<table width = "72%" style="margin-left:15px;border:1px solid black;">'+ 
		        	'<tr bgcolor="gray" style="border:1px solid black;">'+
		            	'<th width="80%"> Item </th>'+
		            	'<th width="20%"> Price </th>'+
		        	'</tr>'+
		        	'<tr>'+
		            	'<td>'+ info.Assessment__r.Test_Name__c + '</td>'+
		            	'<td style="text-align:center;border-left:1px solid black;">$'+  invoice.Price__c+'</td>'+
		        	'</tr>'+ 
		        	'<tr>'+
		            	'<td style="text-align:left">Discount on Assessment (' + info.Assessment__r.Discount__c  +'%)</td>'+
		            	'<td style="text-align:center;border-left:1px solid black;">-$'+ cutPrice.setScale(2) +'</td  >'+
		        	'</tr>'+ 
		        	'<tr>'+
		            	'<td>&nbsp;</td>'+
		            	'<td style="text-align:center;border-left:1px solid black;">&nbsp;</td>'+
		        	'</tr>'+ 
		        	'<tr bgcolor="gray" style="border:1px solid black;">'+
		            	'<th> Grand Total </th>'+
		            	'<th style="text-align:center;border-left:1px solid black;">$'+ finalPrice.setScale(2) +'</th>'+
		        	'</tr>'+
		        	'</table> <br/>' +
	 				'<b><p Style="font-size:14px;margin-left:15px"> Payment Terms</p> </b> ' +     
	       			'<p Style="font-size:10px;margin-left:15px">All payments are due 30 days from the date of invoice. To be made payable to:</p>'
			      	+'<b><p Style="font-size:10px;margin-left:15px;">CarePoint Solutions, Inc. </b> </p>'        
			       	+'<p Style="font-size:10px;margin-left:15px"> PO Box 900  </p>'        
			       	+'<p Style="font-size:10px;margin-left:15px">Westford, MA 01886</p> ' 
	         		);*/
	         	Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });             
	    	}
		}catch(Exception e){ }
	}
}