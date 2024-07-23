public class instantAddressBatchData  {    
    Public Boolean showColumn2{get; set;}
    Public Boolean showColumn3{get; set;}
    Public Boolean showColumn4{get; set;}
    Public Boolean showColumn5{get; set;}
    Public Integer size{get;set;} 
    Public Integer noOfRecords{get; set;} 
    public List<SelectOption> paginationSizeOptions{get;set;}
    
    public string batchformatid { get {
        return '52B31CCB-761E-4A6B-AE2B-05822DFD4ADB';
    } set; }
    public string batchusername { get {
        return 'BB356F2F-570F-';
    } private set; }
    public string batchpassword { get {
        return '61d51d35-e';
    } private set; }
    public InstantAddressBatchProcessResponse batchresponse {get; set;}
    public string responsebody {get; set;}
         
    public instantAddressBatchData(){
        size=10;
        paginationSizeOptions = new List<SelectOption>();
        paginationSizeOptions.add(new SelectOption('5','5'));
        paginationSizeOptions.add(new SelectOption('10','10'));
        paginationSizeOptions.add(new SelectOption('20','20'));
        paginationSizeOptions.add(new SelectOption('50','50'));
        paginationSizeOptions.add(new SelectOption('100','100'));
    }
     
    public ApexPages.StandardSetController setCon {
        get {
            if(setCon == null) {                
                setCon = new ApexPages.StandardSetController(Database.getQueryLocator(
                      [SELECT Name,MailingCountry,  MailingState,MailingCity,MailingPostalCode,MailingStreet FROM Contact WHERE MailingPostalCode <> '' AND MailingCountry = 'USA' ]));
                setCon.setPageSize(size);  
                noOfRecords = setCon.getResultSize();
            }            
            return setCon;
        }
        set;
    }
     
    //Changes the size of pagination
    public PageReference refreshPageSize() {
         setCon.setPageSize(size);
         return null;
    }
 
    // Initialize setCon and return a list of record    
     
    public List<Contact> getContacts() {
         return (List<Contact>) setCon.getRecords();
    }
    
    public PageReference testWSCommunication(){
        batchresponse = new InstantAddressBatchProcessResponse();
        List<InputAddress> listtoreview = new List<InputAddress>();
        List<Contact> contacts = getContacts();
        
        for(Contact c : contacts) {
            InputAddress i = new InputAddress();
            i.reference1 = c.Id;
            i.street1 = c.MailingStreet;
            i.zipcode = c.MailingPostalCode;
            i.country = c.MailingCountry;
            i.city = c.MailingCity;
            listtoreview.add(i);
        }
        String jsonBody = json.serialize(listtoreview);
        
        Blob headerValue = Blob.valueOf(batchusername + ':' + batchpassword);
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://stagingbatchservices.initiumsoftware.com/api/service/StartBatchSession?name=KennethSeLaCome&description=DeVerdad&country=USA');
        req.setMethod('POST');
        req.setCompressed(false);
        req.setHeader('Encoding','utf-8');
        req.setHeader('Authorization', authorizationHeader);
        req.setHeader('Content-Type', 'application/json');
        req.setBody(jsonBody);
        req.setHeader('Content-length',string.valueOf(jsonBody.length()));
        HttpResponse res = new http().send(req);
        
        JSONParser parser = JSON.createParser(res.getBody());
        while (parser.nextToken() != null) {
            if (parser.getCurrentToken() == JSONToken.START_OBJECT) {
                this.batchresponse = (InstantAddressBatchProcessResponse)parser.readValueAs(InstantAddressBatchProcessResponse.class);
            }
        }
        return null;
    }
    
    public PageReference testBatchState(){
        if(batchresponse.batchid != '' && batchresponse.batchid != null){
            Blob headerValue = Blob.valueOf(batchusername + ':' + batchpassword);
            String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
            
            HttpRequest req = new HttpRequest();
            req.setEndpoint('https://stagingbatchservices.initiumsoftware.com/api/service/GetBatchSessionState?batchid=' + batchresponse.batchid);
            req.setMethod('GET');
            req.setCompressed(false);
            req.setHeader('Encoding','utf-8');
            req.setHeader('Authorization', authorizationHeader);
            
            HttpResponse res = new http().send(req);
            JSONParser parser = JSON.createParser(res.getBody());
            while (parser.nextToken() != null) {
                if (parser.getCurrentToken() == JSONToken.START_OBJECT) {
                    this.batchresponse = (InstantAddressBatchProcessResponse)parser.readValueAs(InstantAddressBatchProcessResponse.class);
                }
            }
        }
    	return null;
    }

	public static PageReference testGetRecords(){
        Blob headerValue = Blob.valueOf('cbf96cb0-66ce-4:fbccc429-4');
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://stagingbatchservices.initiumsoftware.com/api/service/SessionResults?batchid=299915E4-C4DA-466C-AEAD-89B1225298DD&formatid=52B31CCB-761E-4A6B-AE2B-05822DFD4ADB&onlyformatted=false');
        req.setMethod('GET');
        req.setCompressed(false);
        req.setHeader('Encoding','utf-8');
        req.setHeader('Authorization', authorizationHeader);
        
        List<Response> responselist = new List<Response>();
        
        HttpResponse res = new http().send(req);
        string responsebody2 = res.getBody();
        responsebody2 = responsebody2.replaceAll('"Zip code":', '"Zipcode":').replaceAll('"Address 1":', '"Address1":').replaceAll('"Address 2":', '"Address2":').replaceAll('"Address 3":', '"Address3":').replaceAll('"Address 4":', '"Address4":').replaceAll('"Address 5":', '"Address5":');
        JSONParser parser = JSON.createParser(responsebody2);
        
        //responselist.add((List<Response>)parser.readValueAs(List<Response>.class));
        
        while (parser.nextToken() != null) {
            if (parser.getCurrentToken() == JSONToken.START_ARRAY) {
                while (parser.nextToken() != null) {
                    if (parser.getCurrentToken() == JSONToken.START_OBJECT) {
                        responselist.add((Response)parser.readValueAs(Response.class));
                    }
                }
            }
        }
       	
        List<ServiceOutput__c> toInsert = parseList(responselist);
        if(toInsert != null && toInsert.size() > 0){
            try {
            	insert toInsert;
            } catch(Exception e){
                System.debug(e);
            }
        }
        
        return null;
    }
    
    private static List<ServiceOutput__c> parseList(List<Response> responselist){
        List<ServiceOutput__c> outputlist = new List<ServiceOutput__c>();
        for(Response response : responselist){
            ServiceOutput__c output = new ServiceOutput__c();
            output.recordkey__c = response.details[0].recordkey;
            output.recordtype__c = response.details[0].recordtype;
            output.carrierrouteid__c = response.details[0].carrierrouteid;
            output.streetpredirectionalabbrev__c = response.details[0].streetpredirectionalabbrev;
            output.streetpredirectionalname__c = response.details[0].streetpredirectionalname;
            output.streetprefixabbrev__c = response.details[0].streetprefixabbrev;
            output.streetprefixname__c = response.details[0].streetprefixname;
            output.street__c = response.details[0].street;
            output.privatemailbox__c = response.details[0].privatemailbox;
            output.privatemailboxnumber__c = response.details[0].privatemailboxnumber;
            output.pobox__c = response.details[0].pobox;
            output.poboxnumber__c = response.details[0].poboxnumber;
            output.streetsuffixabbrev__c = response.details[0].streetsuffixabbrev;
            output.streetsuffixname__c = response.details[0].streetsuffixname;
            output.streetpostfixabbrev__c = response.details[0].streetpostfixabbrev;
            output.streetpostfixname__c = response.details[0].streetpostfixname;
            output.zipcode__c = response.details[0].zipcode;
            output.zip4__c = response.details[0].zip4;
            output.zip4low__c = response.details[0].zip4low;
            output.zip4high__c = response.details[0].zip4high;
            output.housenumberlow__c = response.details[0].housenumberlow;
            output.housenumberhigh__c = response.details[0].housenumberhigh;
            output.housenumberparity__c = response.details[0].housenumberparity;
            output.building__c = response.details[0].building;
            output.secondaryunitabbrev__c = response.details[0].secondaryunitabbrev;
            output.secondaryunitname__c = response.details[0].secondaryunitname;
            output.secondaryunitlow__c = response.details[0].secondaryunitlow;
            output.secondaryunithigh__c = response.details[0].secondaryunithigh;
            output.secondaryunitparity__c = response.details[0].secondaryunitparity;
            output.stateabbrev__c = response.details[0].stateabbrev;
            output.statename__c = response.details[0].statename;
            output.stateid__c = response.details[0].stateid;
            output.congressionaldistrictid__c = response.details[0].congressionaldistrictid;
            output.municipalitykey__c = response.details[0].municipalitykey;
            output.urbanizationkey__c = response.details[0].urbanizationkey;
            output.basealternamecodeflag__c = response.details[0].basealternamecodeflag;
            output.lacsflag__c = response.details[0].lacsflag;
            output.governmentflag__c = response.details[0].governmentflag;
            output.housenumber__c = response.details[0].housenumber;
            output.secondaryunit__c = response.details[0].secondaryunit;
            output.citystatekey__c = response.details[0].citystatekey;
            output.cityname__c = response.details[0].cityname;
            output.preferredcityname__c = response.details[0].preferredcityname;
            output.citydeliveryflag__c = response.details[0].citydeliveryflag;
            output.carrierrouteflag__c = response.details[0].carrierrouteflag;
            output.financialnumber__c = response.details[0].financialnumber;
            output.countyid__c = response.details[0].countyid;
            output.countyname__c = response.details[0].countyname;
            output.dpv__c = response.details[0].dpv;
            output.dpc__c = response.details[0].dpc;
            output.dpcd__c = response.details[0].dpcd;
            output.dpvf__c = response.details[0].dpvf;
            //output.mailstopcode__c = response.details[0].mailstopcode;
            output.dataretentionelement1__c = response.details[0].dataretentionelement1;
            output.dataretentionelement2__c = response.details[0].dataretentionelement2;
            output.datapostretentionelement__c = response.details[0].datapostretentionelement;
            output.countryname__c = response.details[0].countryname;
            output.countryid__c = response.details[0].countryid;
            output.latitude__c = response.details[0].latitude;
            output.longitude__c = response.details[0].longitude;
            output.cmra__c = response.details[0].cmra;
            output.rdi__c = response.details[0].rdi;
            output.elotcode__c = response.details[0].elotcode;
            output.elotnumber__c = response.details[0].elotnumber;
            //output.verifiedOn__c = response.details[0].verifiedOn;
            output.fips__c = response.details[0].fips;
            //output.geoflag__c = response.details[0].geoflag;
            output.augmentedBuilding__c = response.details[0].augmentedBuilding;
            output.urbanization__c = response.details[0].urbanization;
            output.timestamp__c = response.timestamp;
            output.verificationFlag__c = response.verificationflag;
            output.responseflag__c = response.responseflag;
            output.addresschangeflags__c = response.addresschangeflags;
            output.ErrorData__c = response.errordata;
            output.FR_Country__c =  response.formattedaddress.Country;
            output.FR_Address1__c = response.formattedaddress.Address1;
            output.FR_Address2__c = response.formattedaddress.Address2;
            output.FR_Address3__c = response.formattedaddress.Address3;
            output.FR_Address4__c = response.formattedaddress.Address4;
            output.FR_Address5__c = response.formattedaddress.Address5;
            output.FR_City__c =     response.formattedaddress.City;
            output.FR_State__c =    response.formattedaddress.State;
            output.FR_Zipcode__c =  response.formattedaddress.Zipcode;
            output.IA_Address1__c = response.inputaddress.street1;
            output.IA_Address2__c = response.inputaddress.street2;
            output.IA_Address3__c = response.inputaddress.street3;
            output.IA_Address4__c = response.inputaddress.street4;
            output.IA_Address5__c = response.inputaddress.street5;
            output.IA_City__c = response.inputaddress.city;
            output.IA_State__c = response.inputaddress.state;
            output.IA_Zipcode__c = response.inputaddress.zipcode;
            output.IA_Zip4__c = response.inputaddress.zip4;
            output.IA_Reference1__c = response.inputaddress.Reference1;
            output.IA_Reference2__c = response.inputaddress.Reference2;
            output.IA_Reference3__c = response.inputaddress.Reference3;
            output.IA_Reference4__c = response.inputaddress.Reference4;
            output.IA_Reference5__c = response.inputaddress.Reference5;
            outputlist.add(output);
        }
        return outputlist;
    }
     
    public List<ServiceOutput__c> getDataSet() {
        showColumn2 = false;
        showColumn3 = false;
        showColumn4 = false;
        showColumn5 = false;
        
        List<ServiceOutput__c> listSO = new List<ServiceOutput__c>();

        Map <String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get('ServiceOutput__c').getDescribe().fields.getMap();
        string selectitems = '';
        for(Schema.SObjectField sfield : fieldMap.Values()){
            schema.describefieldresult dfield = sfield.getDescribe();
            selectitems += dfield.getName() + ',';
        }
        selectitems = selectitems.substring(0, selectitems.length() - 1);
        listSO = Database.query('SELECT '+ selectitems +' FROM ServiceOutput__c');  
        /*
        List<sObject> tData =   GetData;      
        noOfRecords =   GetDataCount ; 
        
        //PAGINATION
        Decimal toround ;
        if(noOfRecords > 2000){
            toround = (2000 / size);
        }
        else{
            toround =  (noOfRecords / size);
        }
        // Decimal toround = (noOfRecords / size);
        pageMax = (integer)toRound.setScale(0, RoundingMode.CEILING);
        
        List<DisplayDataItem> toReturnData =  new  List<DisplayDataItem>();    
        
        for(sObject tRow : tData){
            integer mapIndex = 0;
            for(MappingItem tfield : source.mappingList){
                DisplayDataItem d = new DisplayDataItem();
                d.Country  = GetFieldValue('Country',tRow, tfield);
                d.Zip   = GetFieldValue('Zipcode',tRow, tfield);
                d.State = GetFieldValue('State',tRow, tfield);
                d.City  = GetFieldValue('City',tRow, tfield);
                d.Address1  = GetFieldValue('Address',tRow, tfield,1);
                d.Address2  = GetFieldValue('Address',tRow, tfield,2);
                d.Address3  = GetFieldValue('Address',tRow, tfield,3);
                d.Address4  = GetFieldValue('Address',tRow, tfield,4 );
                d.Address5  = GetFieldValue('Address',tRow, tfield,5); 
                
                d.SourceType = GetFieldLabel('Address', tfield);
                
                d.mappingIndex = mapIndex;
                
                if(mappings != null){
                    d.MappingId = mappings[mapIndex].Mapping_Id__c; 
                    d.Id = GetId(tRow);
                }
                
                if(String.isNotEmpty(d.Country) || String.isNotEmpty(d.Zip) || String.isNotEmpty(d.State)  || String.isNotEmpty(d.City)|| String.isNotEmpty(d.Address1) ){
                    if(string.isNotEmpty(d.Address2))  
                        showColumn2 = true;
                    if(string.isNotEmpty(d.Address3))  
                        showColumn3 = true; 
                    if(string.isNotEmpty(d.Address4))  
                        showColumn4 = true;
                    if(string.isNotEmpty(d.Address5))  
                        showColumn5 = true;
                    
                    toReturnData.add(d); 
                }
                mapIndex ++;
            }    
        }   
        
        //noOfBatchRecords =toReturnData.size();
        return toReturnData;*/
        return listSO;
    }
 	
    public List<ResponseFlagData> getResponseFlagData(){
        List<ResponseFlagData> rdata = new List<ResponseFlagData>();
        List<SObject> r = Database.query('SELECT ResponseFlag__c flag, count(Id) data FROM ServiceOutput__c GROUP BY ResponseFlag__c ORDER BY ResponseFlag__c');
        integer totalcount = database.countQuery('select count() from ServiceOutput__c');
        for(SObject o : r){
            string flagvalue = String.valueOf(o.get('flag'));
            integer flagcount = Integer.valueOf(o.get('data'));
            string perc = String.valueOf(flagcount * 100 / totalcount) + '%';
            rdata.add(new ResponseFlagData(getFlagNameById(flagvalue), flagcount, perc));
        }
        return rdata;
    }
    
    private string getFlagNameById(string flagid){
        if(flagid.toUpperCase() == 'E'){
            return 'Exact';
        } else if (flagid.toUpperCase() == 'T'){
            return 'Tentative';
        } else if (flagid.toUpperCase() == 'P'){
            return 'Primary';
        } else if (flagid.toUpperCase() == 'S'){
            return 'Secondary';
        } else if (flagid.toUpperCase() == 'U'){
            return 'Unmatched';
        } else if (flagid.toUpperCase() == 'N'){
            return 'Not Processed';
        } else if (flagid.toUpperCase() == 'M'){
            return 'Multiple';
        }
        return flagid;
    }
    
     private string getColorById(string flagid){
        if(flagid.toUpperCase() == 'E'){
            return '#008000';
        } else if (flagid.toUpperCase() == 'T'){
            return '#6495ED';
        } else if (flagid.toUpperCase() == 'P'){
            return '#795548';
        } else if (flagid.toUpperCase() == 'S'){
            return '#800080';
        } else if (flagid.toUpperCase() == 'U'){
            return '#FF0000';
        } else if (flagid.toUpperCase() == 'N'){
            return '#000000';
        } else if (flagid.toUpperCase() == 'M'){
            return '#FF4500';
        }
        return flagid;
    }
    
    public class ResponseFlagData{
        public string flagname {get; set;}
        public integer data {get; set;}
        public string percentage {get; set;}
        public string color {get; set;}
        
        public ResponseFlagData(string name, integer data, string p){
            this.flagname = name;
            this.data = data;
            this.percentage = p;
        }
    }
}