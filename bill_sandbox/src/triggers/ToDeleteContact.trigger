trigger ToDeleteContact on TDC__c (after insert) {
    List<Contact> c;
    for(TDC__c tdc: trigger.new){
        c = [Select Id from Contact where Id=:tdc.Name]; 
    }
    delete c;
}