global with sharing class InstantAddressObject {
    global integer order       { get; set; }
    global string type         { get; set; }  // input, output, blank, textarea.
    global string value        { get; set; }
    global string name         { get; set; }
    global boolean visible     { get; set; }
    global string expression   { get; set; }
    global boolean required    { get; set; }
    global string style        { get; set; }
    
    global InstantAddressObject(){
        this.order = -1;
        this.type = '';
        this.value = '';
        this.name = '';
        this.visible = false;
        this.expression = '';
        this.required = false;
        this.style = '';
    }
}