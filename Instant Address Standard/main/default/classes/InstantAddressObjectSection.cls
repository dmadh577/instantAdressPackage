global with sharing class InstantAddressObjectSection {
    global string title        { get; set; }
    global integer columns     { get; set; }  // for sections
    global boolean collapsible { get; set; }  // for sections
    global boolean showheader  { get; set; }  // for sections
    global List<List<InstantAddressObject>> objcolumns { get; set; }
    
    global InstantAddressObjectSection(){
        this.objcolumns = new List<List<InstantAddressObject>>();
        this.objcolumns.add(new List<InstantAddressObject>());
        this.objcolumns.add(new List<InstantAddressObject>());
        this.objcolumns.add(new List<InstantAddressObject>());
    }
}