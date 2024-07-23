public with sharing class InstantAddressRendererAltAdd {
    
    // SObject API name
    public string sobjectname { get; set; }
    
    // SObject Label
    public string sobjectlabel { get; set; }
    
    // SObject Title (Changes between New and Edit)
    public string sobjecttitle { get; set; }
    
    public string sobjectaccounttitle { get; set; }
    
    // jQuery reference
    public string jqueryurl { get {
        return 'https://instantaddresspublic.blob.core.windows.net/core/v6.5.1/jquery-1.7.2.min.js';
    } private set;}
    
    // Instant Address Initialize Script - Salesforce AJAX Toolkit logic
    public string initializerurl { get {
        return 'https://instantaddresspublic.blob.core.windows.net/salesforce/InitiumInstantAddressInitializer.js';
    } private set;}
    
    // Lightning CSS
    public string lightningcss { get {
        return 'https://instantaddresspublic.blob.core.windows.net/salesforce/InstantAddressLightning.css';
    } private set;}
    
    // Salesforce Ajax Toolkit URL 
    public string forceconnectionurl { get {
        return '../../soap/ajax/38.0/connection.js';
    } private set;}
    
    // Instant Address URL (Dynamic per Organization ID)
    public string instantaddressurl { get {
     
        //return 'https://instantaddressstaging.blob.core.windows.net/product/salesforce/bootstrap-min-sig='+ UserInfo.getOrganizationId() +'.js';
    
        
        return 'https://cdn.initiumsoftware.com/product/salesforce/bootstrap-min-sig='+ UserInfo.getOrganizationId() +'.js';
    } private set;}
    
    // Processed Layout
    public transient Component.Apex.PageBlock bodyhtml { get; set; }
    
    // Controller Extension reference
    ApexPages.StandardController stdcontroller { get; set; }
    
    // SObject available fields
    private Map<String, Schema.SObjectField> globalfields { get; set; }
    
    // Is Create or Is Edit flag
    @testVisible private Boolean isCreate {get; set;}
    
    // Layout sections from the Json layout
    private List<InstantAddressSection> layoutSections { get; set; }
    
    // Record Type in case there is
    private string recordtypeid { get; set; }
    
    // Record Id in case of Edit
    private string recordid { get; set; }
    private string layoutstring { get; set; }
    private List<InstantAddressObjectSection> iasections {get;set;}
    
    // In case it is a Person Account
    @testVisible private boolean isPersonAccount { get; set; }
    public string personSalutation { get; set; }
    public string personFirstName { get; set; }
    public string personLastName { get; set; }
    public string personMiddleName { get; set; }
    public string personSuffixName { get; set; }
    public string errorMessageOnSubmit { get; set; }
    
    public InstantAddressRendererAltAdd (){}
    
    public InstantAddressRendererAltAdd (ApexPages.StandardController stdcontroller, string sobjectname, string jsonLayout){
        // Assign API Name for further queries
        this.sobjectname = sobjectname;
        
        // Store the controller reference
        this.stdcontroller = stdcontroller;
        
        List<string> layoutfields = new List<string>();
        if(jsonLayout != ''){
            System.debug(jsonLayout);
            this.layoutSections = new List<InstantAddressSection>();
            JSONParser parser = JSON.createParser(jsonLayout);
            while (parser.nextToken() != null) {
                if (parser.getCurrentToken() == JSONToken.START_ARRAY) {
                    while (parser.nextToken() != null) {
                        if (parser.getCurrentToken() == JSONToken.START_OBJECT) {
                            this.layoutSections.add((InstantAddressSection)parser.readValueAs(InstantAddressSection.class));
                        }
                    }
                }
            }
                
            for(integer i = 0; i < this.layoutSections.size(); i++){
                // Rows
                List<InstantAddressRow> rows = layoutSections[i].layoutRows;
                for(integer f = 0; f < rows.size(); f++){
                    // Items
                    List<InstantAddressItem> items = rows[f].layoutItems;
                    for(integer c = 0; c < items.size(); c++) {
                        InstantAddressItem item = items[c];
                        
                        try{
                            for(integer comp = 0; comp < (item.layoutComponents).size(); comp++){
                                InstantAddressComponent component = item.layoutComponents[comp];
                                try{
                                    List<InstantAddressInnerComponent> components = component.components;
                                    for(InstantAddressInnerComponent k : components){
                                        if(k.type == 'Field')
                                        	layoutfields.add(k.value);
                                        //system.debug(k.value);
                                    }
                                } catch(Exception e){}
                                try{
                                    if(component.type == 'Field')
                                    	layoutfields.add(component.value);
                                    //system.debug(component.value);
                                } catch(Exception e){}
                            }
                        } catch(Exception e){}
                    }
                }
            }
            
            if(sobjectname == 'Account'){
                layoutfields.add('RecordTypeId');
            }

            GetApexAvailableFields();

            if(!Test.isRunningTest()){
                this.stdcontroller.addFields(layoutfields);
            }
        }

        // We can try getting the id in case of an Edit
        Id recordId = stdcontroller.getId();
        SObject dynamicSObj = stdController.getRecord();
      
        this.recordid = recordId;

        try{
            if(recordId == null){
                this.isCreate = true;
                
                // In some default SObject, we need to assign the current user
                // as the Owner of the SObject that is going to be created
                dynamicSObj.put('Ownerid', UserInfo.getUserId());
            } else {
                this.isCreate = false;
                this.sobjecttitle = (String)dynamicSObj.get('Name');
                this.recordtypeid = (String)dynamicSObj.get('RecordTypeId');
            }
        } catch(Exception err){ }
        
        // Now for Person Account
        try {
            if((String)dynamicSObj.get('RecordTypeId') != NULL && (String)dynamicSObj.get('RecordTypeId') != ''){
                this.recordtypeid = (String)dynamicSObj.get('RecordTypeId');
                recordType recType = Database.query('select ispersontype from recordType where id = \''+ recordtypeid +'\' and sobjectType=\'account\' limit 1');
                
               
                if(recType != null){
                    this.isPersonAccount = (Boolean)recType.get('IsPersonType');
                }
                if(this.isPersonAccount) {
                    this.sobjectaccounttitle = 'Person Account Edit';
                } else {
                    this.sobjectaccounttitle = 'Account Edit';
                }
            }
            if(this.isPersonAccount && !isCreate){
                this.personFirstName = (String)dynamicSObj.get('FirstName');
                this.personLastName =  (String)dynamicSObj.get('LastName');
                this.personMiddleName = (String)dynamicSObj.get('MiddleName');
                this.personSuffixName = (String)dynamicSObj.get('Suffix');
                this.personSalutation = (String)dynamicSObj.get('Salutation');
            }
        } catch(Exception err){}
        
      
    }
    
    @testVisible private List<SelectOption> GetSalutationPickList(){
        List<SelectOption> salutationList = new List<SelectOption>();
        Map<String, Schema.SObjectType> gdMap = Schema.getGlobalDescribe();
        Schema.Describesobjectresult dsr = gdMap.get('Account').getDescribe();
        Map<String, Schema.SObjectField> a_fields = dsr.fields.getMap();

        for(String fld : a_fields.keySet()){
            string flabel = a_fields.get(fld).getDescribe().getLabel();
            Schema.DisplayType fieldtype = a_fields.get(fld).getDescribe().getType();
            if( fieldtype == Schema.DisplayType.MULTIPICKLIST || fieldtype == Schema.DisplayType.PICKLIST){
                if(flabel =='Salutation'){
                    DescribeFieldResult describe = a_fields.get(fld).getDescribe();
                    List<Schema.PicklistEntry> ple = describe.getPicklistValues();
                    for(Schema.PicklistEntry p : ple){
                        salutationList.add(new SelectOption(p.getValue(), p.getLabel()));
                    }

                }
            }
        }
        return salutationList;
    }
    
    private List<String> GetApexAvailableFields(){       
        Map<String, Schema.SObjectType> gdMap = Schema.getGlobalDescribe();
        Schema.Describesobjectresult dsr = gdMap.get(this.sobjectname).getDescribe();
        this.sobjectlabel = dsr.getLabel();
        this.sobjecttitle = 'New ' + this.sobjectlabel;
        this.globalfields = dsr.fields.getMap();

        Set<String> afields = new Set<String>();
        for (String s : this.globalfields.keySet()) {
            afields.add(s);
        }
        return new List<String>(afields);
    }
    
    @testVisible private Schema.DescribeFieldResult DescribeField(string fieldname){
        Map<String, Schema.SObjectType> gdMap = Schema.getGlobalDescribe();
        Schema.Describesobjectresult dsr = gdMap.get(this.sobjectname).getDescribe();
        this.globalfields = dsr.fields.getMap();
        Set<String> keyset = this.globalfields.keySet();
        for (String s : keyset) {
            if(s == fieldname){
                Schema.SObjectField field = this.globalfields.get(s);
                return field.getDescribe();
            }
        }
        return null;
    }
    
    public List<String> TestGetApexAvailableFields(){
        if(Test.isRunningTest()){
            return GetApexAvailableFields();
        }
        return new List<String>();
    }
    
    public PageReference CustomSave(){
        if(this.isPersonAccount){ 
            //Commented this code since we are not using person accounts in our org as per US-151487
            /*if(this.personLastName == null || this.personLastName == ''){
                this.errorMessageOnSubmit = 'Error: You must enter a Last Name to continue.';
                return null;
            }         
            // personLastName
            SObject dynamicSObj = stdController.getRecord();
            dynamicSObj.put('LastName', this.personLastName);
            dynamicSObj.put('FirstName', this.personFirstName);
            dynamicSObj.put('MiddleName', this.personMiddleName);
            dynamicSObj.put('Suffix', this.personSuffixName);
            dynamicSObj.put('Salutation', this.personSalutation);*/
        }
        return stdcontroller.save();
    }
    
    public PageReference SaveAndNew(){
        if(this.isPersonAccount){
            //Commented this code since we are not using person accounts in our org as per US-151487
            /*if(this.personLastName == null || this.personLastName == ''){
                this.errorMessageOnSubmit = 'Error: You must enter a Last Name to continue.';
                return null;
            }         
            // personLastName
            SObject dynamicSObj = stdController.getRecord();
            dynamicSObj.put('LastName', this.personLastName);
            dynamicSObj.put('FirstName', this.personFirstName);
            dynamicSObj.put('MiddleName', this.personMiddleName);
            dynamicSObj.put('Suffix', this.personSuffixName);
            dynamicSObj.put('Salutation', this.personSalutation);*/
        }      
        stdcontroller.save();
        Schema.DescribeSObjectResult describeResult = this.stdcontroller.getRecord().getSObjectType().getDescribe();
        string url ='/' + describeResult.getKeyPrefix() + '/e';
         
        if(recordtypeid != null){   
            url= url+ '?RecordType=' +recordtypeid + '&ent=Account';          
        }
        
        PageReference pr = new PageReference(url);
        pr.setRedirect(true); 
          
        return pr; 
    }
    
    public List<ApexPages.Component> getBodyComponents(){
        return this.bodyhtml.childComponents;
    }
    
    // Before calling the ActionFunction we are rendering some HTML
    // we need.
    public Component.Apex.OutputPanel getRenderInitialHTML(){
        
        // Main block were we are adding all the HTML
        Component.Apex.OutputPanel panel = new Component.Apex.OutputPanel();
        panel.id = 'InstantAddressBlock';
        panel.layout = 'block';
        
        // Add jQuery to the page
        Component.Apex.IncludeScript jqueryjs = new Component.Apex.Includescript();
        jqueryjs.value = this.jqueryurl;
        panel.childComponents.add(jqueryjs);
        
        
       
        
        // Add support for Rich Text textareas
        Component.Apex.IncludeScript ckeditor = new Component.Apex.Includescript();
        ckeditor.value = 'https://instantaddresspublic.blob.core.windows.net/core/v6.5.1/ckeditor.js';
        panel.childComponents.add(ckeditor);
        
        // Add Initiums Initialize script (Gets layout from AJAX Toolkit)
        
        
        // Get Record Type Id from the Request URL if there is one.
        string recordId = ApexPages.currentPage().getParameters().get('RecordType');
        if(recordId == null){
            recordId = this.recordtypeid;
        }
        
        // Add support for lightning UI
        if(UserInfo.getUiThemeDisplayed() == 'Theme4d' || UserInfo.getUiThemeDisplayed() == 'Theme4t'){
            Component.Apex.slds lightning = new Component.Apex.slds();
            panel.childComponents.add(lightning);
            
            // lightningcss
            Component.Apex.Stylesheet lightningcssscript = new Component.Apex.Stylesheet();
            lightningcssscript.value = lightningcss;
            panel.childComponents.add(lightningcssscript);
        }
        
        // Add Javascript code to trigger the initializeInstantAddress function on the 
        // $(document).ready function. We take the current user session id. 
     
 
        return panel;
    }
    
    public void RenderLayoutSections(){
        List<InstantAddressObjectSection> iasections = new List<InstantAddressObjectSection>();
        try{
            for(integer i = 0; i < this.layoutSections.size(); i++){
                // Section
                 InstantAddressObjectSection iasection = new  InstantAddressObjectSection();
                iasection.columns = Integer.valueOf(layoutSections[i].columns);
                iasection.title = layoutSections[i].heading;
                iasection.collapsible = Boolean.valueOf(layoutSections[i].collapsed);
                iasection.showheader = Boolean.valueOf(layoutSections[i].useHeading);
                
                // Rows
                List< InstantAddressRow> rows = layoutSections[i].layoutRows;
                for(integer f = 0; f < rows.size(); f++){
                    // Items
                    List< InstantAddressItem> items = rows[f].layoutItems;
                    for(integer c = 0; c < items.size(); c++) {
                         InstantAddressItem item = items[c];
                        
                        // Blank
                        if(item.placeholder == 'true'){
                             InstantAddressObject iaobj = new  InstantAddressObject();
                            iaobj.type = 'blank';
                            iasection.objcolumns[c].add(iaobj);                        
                        } else {
                            
                            // Components
                            for(integer comp = 0; comp < (item.layoutComponents).size(); comp++){
                                 InstantAddressComponent component = item.layoutComponents[comp];
                                
                                // Inner Components
                                try {
                                    List< InstantAddressInnerComponent> components = component.components;
                                    
                                    // Special case: Salutation and name
                                    if(component.value == 'Name' && components[0].value == 'Salutation'){
                                        
                                        // temp
                                        if(this.isPersonAccount){
                                            //inputText
                                            //Commented this code since we are not using person accounts in our org as per US-151487
                                            /*for( InstantAddressInnerComponent k : components){
                                                 InstantAddressObject iaobj = new  InstantAddressObject();
                                                iaobj.order = integer.valueOf(k.tabOrder);
                                                if(k.value == 'LastName'){
                                                    iaobj.type = 'requiredInputText';
                                                    iaobj.value = 'personLastName';
                                                } else {
                                                    iaobj.type = 'inputText';
                                                    if(k.value == 'FirstName'){
                                                        iaobj.value = 'personFirstName';
                                                    } else if(k.value == 'Suffix'){
                                                        iaobj.value = 'personSuffixName';
                                                    } else if(k.value == 'Salutation'){
                                                        iaobj.value = 'personSalutation';
                                                        iaobj.type = 'picklist';
                                                    } else if(k.value == 'MiddleName'){
                                                        iaobj.value = 'personMiddleName';
                                                    }
                                                }
                                                iasection.objcolumns[c].add(iaobj);
                                            }*/
                                        } else {
                                        
                                            for( InstantAddressInnerComponent k : components){
                                                if(k.value == 'Salutation'){
                                                     InstantAddressObject iaobj = new  InstantAddressObject();
                                                    iaobj.type = 'salutation';
                                                    iaobj.expression = '{!'+ sobjectname +'.' + components[0].value + '};{!'+ sobjectname +'.' + components[1].value + '}';
                                                    iaobj.value = components[0].value + ';' + components[1].value;
                                                    iaobj.order = integer.valueOf(components[0].tabOrder);
                                                    iasection.objcolumns[c].add(iaobj);
                                                } else if(k.value != 'FirstName'){
                                                     InstantAddressObject iaobj = new  InstantAddressObject();
                                                    iaobj.type = 'input';
                                                    iaobj.expression = '{!'+ sobjectname +'.' + k.value + '}';
                                                    iaobj.value = k.value;
                                                    iaobj.order = integer.valueOf(k.tabOrder);
                                                    if(k.value == 'LastName'){
                                                        iaobj.required = boolean.valueOf(item.required);   
                                                    }
                                                    iasection.objcolumns[c].add(iaobj);
                                                }
                                            }
                                        }
                                    } else {
                                        // Print normal components
                                        for(integer z = 0; z < components.size(); z++) {
                                             InstantAddressInnerComponent innercomponent = components[z];
                                            if(innercomponent.type == 'Field'){
                                                 InstantAddressObject iaobj = new  InstantAddressObject();
                                                iaobj.type = 'input';
                                                iaobj.expression = '{!'+ sobjectname +'.' + innercomponent.value + '}';
                                                iaobj.value = innercomponent.value;
                                                iaobj.order = integer.valueOf(innercomponent.tabOrder);
                                                iaobj.required = boolean.valueOf(item.required);
                                                iasection.objcolumns[c].add(iaobj);
                                            }
                                        }
                                    }
                                } 
                                // No Inner
                                catch(Exception ex){
                                    if(component.type == 'Field'){
                                        // InputField
                                        if(boolean.valueOf(item.editableForUpdate)){
                                             InstantAddressObject iaobj = new  InstantAddressObject();
                                            iaobj.type = 'input';
                                            iaobj.expression = '{!'+ sobjectname +'.' + component.value + '}';
                                            iaobj.value = component.value;
                                            iaobj.order = integer.valueOf(component.tabOrder);
                                            iaobj.required = boolean.valueOf(item.required);
                                            
                                            // For Rich TextArea
                                            Schema.SObjectField schemobj = this.globalfields.get(component.value);
                                            Schema.DisplayType schemobjtype = schemobj.getDescribe().getType();
                                            
                                            if(schemobjtype == Schema.DisplayType.TEXTAREA) {
                                                if(!schemobj.getDescribe().isHtmlFormatted()){
                                                    //iaobj.style = 'height: ' + (22.5 * integer.valueOf(component.displayLines)) + 'px;';
                                                } else {
                                                    iaobj.type = 'textarea';
                                                }
                                            }
                                            iasection.objcolumns[c].add(iaobj);
                                        } 
                                        // Output
                                        else {
                                             InstantAddressObject iaobj = new  InstantAddressObject();
                                            iaobj.type = 'output';
                                            iaobj.expression = '{!'+ sobjectname + '.' + component.value + '}';
                                            iaobj.value = component.value;
                                            iaobj.order = integer.valueOf(component.tabOrder);
                                            iasection.objcolumns[c].add(iaobj);
                                        }
                                    }
                                    // Blank
                                    else if(component.type == 'EmptySpace') {
                                         InstantAddressObject iaobj = new  InstantAddressObject();
                                        iaobj.type = 'blank';
                                        iasection.objcolumns[c].add(iaobj);
                                    }
                                }  
                            }
                        }
                    }
                }
                iasections.add(iasection);
            }
        }
        catch(Exception e){
            this.SendErrorReport(e.getMessage(), 'RenderLayoutSections');
        }
        this.iasections = iasections;
        PrintSectionsLayout(iasections);
    }
    
    @testVisible private void PrintSectionsLayout(List< InstantAddressObjectSection> iasections){
        try{
            // Iterate through all sections
            for(integer counter = 0; counter < iasections.size(); counter++){
                
                // Build the section HTML
                 InstantAddressObjectSection section = iasections[counter];
                Component.Apex.PageBlockSection bsection = new Component.Apex.PageBlockSection();
                bsection.columns = section.columns;
                bsection.title = section.title;
                bsection.collapsible = section.collapsible;
                bsection.showHeader = section.showheader;
                
                integer maxcolumns = GetPrintCountForSection(section.objcolumns);
                
                // Iterate through all Rows and Items
                for(integer counter1 = 0; counter1 < maxcolumns; counter1++){
                    for(integer counter2 = 0; counter2 < section.columns; counter2++){
                        try {
                             InstantAddressObject iaobj = section.objcolumns[counter2][counter1];
                            if(iaobj.type == 'picklist'){
                                Component.Apex.PageBlockSectionItem sectionitem = new Component.Apex.PageBlockSectionItem();
                                
                                Component.Apex.OutputLabel llabel = new Component.Apex.OutputLabel();
                                llabel.value = 'Salutation';
                                
                                Component.Apex.SelectList slist = new Component.Apex.SelectList();
                                slist.id = iaobj.value;
                                 
                                system.debug('personSalutation: ' +this.personSalutation);
                                 
                               
                                //Component.Apex.selectOptions sopts = new Component.Apex.SelectOptions();
                                List<SelectOption> opts = this.GetSalutationPickList();
                                slist.Size = 1;
                                slist.multiselect = false;                                
                                for(SelectOption opt:opts){
                                    if(opt.getValue() == this.personSalutation){
                                     Component.Apex.selectOption sopt = new Component.Apex.selectOption();
                                     sopt.itemValue = opt.getValue();
                                     sopt.itemLabel = opt.getLabel();                                     
                                     slist.childComponents.add(sopt); 
                                    }                                    
                                }
                                 for(SelectOption opt:opts){
                                    if(opt.getValue() != this.personSalutation){
                                     Component.Apex.selectOption sopt = new Component.Apex.selectOption();
                                     sopt.itemValue = opt.getValue();
                                     sopt.itemLabel = opt.getLabel();                                     
                                     slist.childComponents.add(sopt); 
                                    }                                    
                                }
                                sectionitem.childComponents.add(llabel);
                                sectionitem.childComponents.add(slist);
                                bsection.childComponents.add(sectionitem);
                            } else if(iaobj.type == 'requiredInputText'){
                                Component.Apex.PageBlockSectionItem sectionitem = new Component.Apex.PageBlockSectionItem();
                                
                                Component.Apex.OutputLabel llabel = new Component.Apex.OutputLabel();
                                llabel.value = 'Last Name';
                                
                                Component.Apex.PanelGroup ppanel = new Component.Apex.PanelGroup();
                                ppanel.styleClass = 'col02 requiredInput';
                                ppanel.layout = 'block';
                                
                                Component.Apex.PanelGroup ppanel2 = new Component.Apex.PanelGroup();
                                ppanel2.styleClass = 'requiredBlock';
                                ppanel2.layout = 'block';
                                
                                Component.Apex.InputText input = new Component.Apex.InputText();
                                input.value = this.personLastName;
                                input.id = iaobj.value;
                                if(UserInfo.getUiThemeDisplayed() == 'Theme4d' || UserInfo.getUiThemeDisplayed() == 'Theme4t'){
                                    input.styleClass = 'slds-input';
                                }
                                
                                ppanel.childComponents.add(ppanel2);
                                ppanel.childComponents.add(input);
                                
                                sectionitem.childComponents.add(llabel);
                                sectionitem.childComponents.add(ppanel);
                                bsection.childComponents.add(sectionitem);
                            } else if(iaobj.type == 'inputText'){
                                Component.Apex.InputText input = new Component.Apex.InputText();
                                input.value = this.personLastName;
                                input.label = iaobj.value;
                                input.id = iaobj.value;
                                
                                if(iaobj.value =='personFirstName'){
                                    input.value = this.personFirstName;
                                    input.label='First Name';
                                }
                                                               
                                else if(iaobj.value =='personSuffixName'){
                                   input.value = this.personSuffixName;
                                   input.label='Suffix'; 
                                }                                 
                                else if(iaobj.value =='personSalutation'){
                                    input.value = this.personSalutation;
                                    input.label='Salutation';
                                }                                 
                                else if(iaobj.value =='personMiddleName'){
                                  input.value = this.personMiddleName;
                                  input.label='Middle Name';    
                                }    
                                if(UserInfo.getUiThemeDisplayed() == 'Theme4d' || UserInfo.getUiThemeDisplayed() == 'Theme4t'){
                                    input.styleClass = 'slds-input';
                                }
                                bsection.childComponents.add(input);
                            } else if(iaobj.type == 'input'){ // Print an input
                                Component.Apex.InputField input = new Component.Apex.InputField();
                                input.expressions.value = iaobj.expression;
                                input.id = iaobj.value;                                
                                input.taborderhint = iaobj.order;
                                input.style = iaobj.style;
                                input.required = iaobj.required;
                                input.rendered = true;
                                 
                                if(UserInfo.getUiThemeDisplayed() == 'Theme4d' || UserInfo.getUiThemeDisplayed() == 'Theme4t'){
                                    input.styleClass = 'slds-input';
                                }
                                bsection.childComponents.add(input);
                            } else if(iaobj.type == 'blank'){ // Print a blank space
                                Component.Apex.PageBlockSectionItem blank = new Component.Apex.PageBlockSectionItem();
                                bsection.childComponents.add(blank);
                                
                            } else if(iaobj.type == 'output'){ // Print an output label
                                if(iaobj.value != 'RecordTypeId' || !isCreate){
                                    Component.Apex.OutputField output = new Component.Apex.OutputField();
                                    output.expressions.value = iaobj.expression;
                                    output.id = iaobj.value;
                                    bsection.childComponents.add(output);
                                } else {
                                    
                                 Component.Apex.PageBlockSectionItem sectionitem = new Component.Apex.PageBlockSectionItem();
                                
                                Component.Apex.OutputLabel llabel = new Component.Apex.OutputLabel();
                                llabel.value = 'Record Type Id';
                                
                                Component.Apex.PanelGroup ppanel = new Component.Apex.PanelGroup();
                                ppanel.styleClass = 'col02 ';
                                ppanel.layout = 'block';
                                
                                Component.Apex.PanelGroup ppanel2 = new Component.Apex.PanelGroup();                                
                                ppanel2.layout = 'block';                                
                              
                                
                                ppanel.childComponents.add(ppanel2);
                                 
                                sectionitem.childComponents.add(llabel);
                                sectionitem.childComponents.add(ppanel);
                                bsection.childComponents.add(sectionitem);
                               
                                }
                            
                            } else if(iaobj.type == 'textarea'){ // Print a textarea
                                Component.Apex.InputTextarea richtxt = new Component.Apex.InputTextarea();
                                richtxt.expressions.value = iaobj.expression;
                                richtxt.id = iaobj.value;
                                richtxt.richText = false;
                                richtxt.tabindex = string.valueOf(iaobj.order);
                                richtxt.styleClass = 'ckeditor';
                                bsection.childComponents.add(richtxt);
                            } else if(iaobj.type == 'salutation'){ // Special case, salutation
                                Component.Apex.PageBlockSectionItem sectionitem = new Component.Apex.PageBlockSectionItem();
                                
                                Component.Apex.OutputLabel namelabel = new Component.Apex.OutputLabel();
                                namelabel.value = 'First Name';
                                sectionitem.childComponents.add(namelabel);
                                
                                Component.Apex.OutputPanel namepanel = new Component.Apex.OutputPanel(); 
                                
                                Component.Apex.InputField input = new Component.Apex.InputField();
                                input.expressions.value = iaobj.expression.split('\\;')[0];
                                input.id = iaobj.value.split('\\;')[0];
                                input.taborderhint = iaobj.order;
                                input.style = iaobj.style;
                                if(UserInfo.getUiThemeDisplayed() == 'Theme4d' || UserInfo.getUiThemeDisplayed() == 'Theme4t'){
                                    input.styleClass = 'slds-input';
                                }
                                input.required = iaobj.required;
                                namepanel.childComponents.add(input);
                                
                                Component.Apex.InputField input2 = new Component.Apex.InputField();
                                input2.expressions.value = iaobj.expression.split('\\;')[1];
                                input2.id = iaobj.value.split('\\;')[1];
                                input2.taborderhint = iaobj.order + 1;
                                input2.style = 'width: 100px;';
                                if(UserInfo.getUiThemeDisplayed() == 'Theme4d' || UserInfo.getUiThemeDisplayed() == 'Theme4t'){
                                    input2.styleClass = 'slds-input';
                                }
                                input2.required = iaobj.required;
                                namepanel.childComponents.add(input2);
                                
                                sectionitem.childComponents.add(namepanel);
                                bsection.childComponents.add(sectionitem);
                            }
                        } catch(Exception ex){
                            Component.Apex.PageBlockSectionItem blank = new Component.Apex.PageBlockSectionItem();
                            bsection.childComponents.add(blank);
                        }
                    }
                }
                this.bodyhtml.childComponents.add(bsection);
            }
        }
        catch(Exception e){
            this.SendErrorReport(e.getMessage(), 'PrintSectionsLayout');
        }
    }
              
    public PageReference RenderSObjectLayoutGlobal(string layout){
        this.layoutstring = layout;
        return RenderSObjectLayout();
    }
    
    public PageReference RenderSObjectLayout() {
        try{
            string jsonLayout = '';
            if(this.layoutstring == null || this.layoutstring == ''){
                jsonLayout = Apexpages.currentPage().getParameters().get('jsonLayout');
                
            } else {
                jsonLayout = this.layoutstring;
            }
            if(jsonLayout == 'error'){
                this.SendErrorReport('Javascript issue in InitiumInstantAddressInitializer.js', 'initializeInstantAddress');
                return ReturnUserToStandardLayout();
            } else { 

                //Main block
                Component.Apex.PageBlock block = new Component.Apex.PageBlock();
                //sobjectaccounttitle
                block.mode = 'edit';
                if(this.isPersonAccount){
                    block.title = this.sobjectaccounttitle;
                } else {
                    block.title = this.sobjectlabel + ' Edit';
                }
                
                Component.Apex.IncludeScript iascript = new Component.Apex.IncludeScript();
                iascript.value = this.instantaddressurl;
                block.childComponents.add(iascript);
                
                Component.Apex.PageBlockButtons buttonWrap = new Component.Apex.PageBlockButtons();
                // Save button
                Component.Apex.CommandButton saveButtonTop = new Component.Apex.CommandButton();
                saveButtonTop.styleClass = 'IATriggerValidation';
                saveButtonTop.value = 'Save';
                saveButtonTop.expressions.action = '{!Renderer.CustomSave}';
                buttonWrap.childComponents.add(saveButtonTop);
                
                // Save & New
                Component.Apex.CommandButton saveandnew = new Component.Apex.CommandButton();
                saveandnew.value = 'Save & New';
                saveandnew.styleClass = 'IATriggerValidation saveandnewclick';
                saveandnew.expressions.action = '{!Renderer.SaveAndNew}';
                buttonWrap.childComponents.add(saveandnew);
                
                // Cancel
                Component.Apex.CommandButton cancelbutton = new Component.Apex.CommandButton();
                cancelbutton.value = 'Cancel';
                cancelbutton.expressions.action = '{!Cancel}';
                buttonWrap.childComponents.add(cancelbutton);
                
                block.childComponents.add(buttonWrap);
                
                if(this.errorMessageOnSubmit != null && this.errorMessageOnSubmit != ''){
                    Component.Apex.pageMessage errormessage = new Component.Apex.pageMessage();
                    errormessage.summary = this.errorMessageOnSubmit;
                    errormessage.severity = 'error';
                    errormessage.strength = 2;
                    block.childComponents.add(errormessage);
                }
                
                 InstantAddressInnerComponent pendingInputField = new  InstantAddressInnerComponent();
                pendingInputField.value = '';
                 InstantAddressInnerComponent pendingAfterInputField = new  InstantAddressInnerComponent();
                pendingAfterInputField.value = '';
                integer pendingInputFieldWait = 0;
                integer ltabindex = -1;
                
                bodyhtml = block;
            }
        }
        catch(Exception e){
            try{
                this.SendErrorReport(e.getMessage(), 'RenderSObjectLayout');
            } catch(Exception e2){}
            
            return ReturnUserToStandardLayout();
        }
        
        // Sections
        RenderLayoutSections();

        return null;
    }
    
    private integer GetPrintCountForSection(List<List<InstantAddressObject>> printlist){
        integer size = 0;
        try{
            for(integer c = 0; c < printlist.size(); c++){
                integer z = printlist[c].size();
                if(size < z){
                    size = z;
                }
            }
        }
        catch(Exception e){
            this.SendErrorReport(e.getMessage(), 'GetPrintCountForSection');
        }
        return size;
    }
    
    public PageReference ReturnUserToStandardLayout(){
        Schema.DescribeSObjectResult describeResult = this.stdcontroller.getRecord().getSObjectType().getDescribe();
        string url = '/' + describeResult.getKeyPrefix() + '/e?nooverride=1';
        if(recordid != null){
            url = url + '&id=' + this.recordid;
        }
        PageReference pr = new PageReference(url);
        pr.setRedirect(true); 
        return pr;
    }
    
    private void SendErrorReport(string error, string functionname){
        Messaging.reserveSingleEmailCapacity(1);
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new String[] {'instantaddressoperations@initiumsoftware.com'});
        mail.setSenderDisplayName('Salesforce Support');
        mail.setSubject('Salesforce Support');
        mail.setBccSender(false);
        mail.setUseSignature(false);
        mail.setHtmlBody('<h3>Instant Address Salesforce Error</h3><p><b>Client: </b>'+ UserInfo.getOrganizationName() +' ('+ UserInfo.getOrganizationId() +')</p><p><b>User: </b>'+ UserInfo.getName() +'</p><p><b>User email: </b>'+ UserInfo.getUserEmail() +'</p><p><b>Integration URL: </b>'+ this.instantaddressurl +'</p><p><b>Error function: </b>'+ functionname +'</p><p><b>Error:</b></p><p>'+ error +'</p>');
        Messaging.sendEmail(new Messaging.Email[] { mail });
    } 
}