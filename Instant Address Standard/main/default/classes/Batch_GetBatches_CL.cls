public class Batch_GetBatches_CL {
    public Source pageSource{get;set;}
    public Boolean displayPopup {get;set;}
    Public Boolean showColumn2{get; set;}
    Public Boolean showColumn3{get; set;}
    Public Boolean showColumn4{get; set;}
    Public Boolean showColumn5{get; set;}
    Public String colorsSet {get; set;}
    Public List<ResponseFlagData> chartData{get;set;}
    public List<SelectOption> flagsList{
        get {
            String[] data = new List<String>() ;
            if(chartData != null){
                List<SelectOption> dlist = new List<SelectOption>();
                for(ResponseFlagData rf : chartData){
                    if(rf.flagvalue != 'O'){
                        dlist.add(new SelectOption(rf.flagvalue, rf.flagname));
                        data.add(rf.flagvalue); 
                    }
                                       
                }          
                return dlist;
            } else {
                return new List<SelectOption>();
            }
        }
        set;
    }
    public String[] selectedFlagsList{get; set;}
     //Contructor
    public Batch_GetBatches_CL(){       
     try{       
            pageSource = new Source();
            pageSource.SelectedFlag ='2f6c8eb2-1546-4852-8053-f09c76c09558';
            pageSource.FilterFlagTxt='';
            pageSource.ShowE1 = true;
             
            string tran = ApexPages.currentPage().getParameters().get('TransactionId'); 
            if(string.isNotEmpty(tran)){
               pageSource.TransactionId = tran; 
                LoadS2Data();           
            }       
             
            if(chartData == null){         
                processResponseFlagData();
            }
            // init
          page = 0;
          pageMax = 0;
          noOfRecords =0;
          GetSelected();         
        }
        catch(exception e){ ExceptionHelper.LogError(e,'Batch_GetBatches_CL');} 
    }
     // pagination
    static final Integer size = 25;   
    Public Integer page{get;set;} 
    Public Integer pageMax{get;set;}        
    Public Integer noOfRecords{get; set;} 
    
    public String MappingItemId { public get; public set;  } 
    public String MappingItemRowId {   get;   set;  } 
    
    public void FlagsMappingChange(){
        pageSource.FilterFlagTxt ='';
        return ;
    }
    public  List<Flag__c> getFlagsData(){
        
        string filter = '%'+ pageSource.FilterFlagTxt+ '%';
        List<Flag__c> toReturn  = [SELECT  Value__c,Name, Description__c FROM Flag__c WHERE FlagLevel__c =:pageSource.SelectedFlag  AND (Description__c LIKE  :filter Or Name LIKE  :filter ) ORDER BY Value__c];
        
        
        /*
        SelectedFlag  {get;set;} 
                public string FilterFlagTxt
        */
        return toReturn;
    }
    public Boolean hasPaginationPreviews{get{return page >= 1 ;}}
    public Boolean hasPaginationNext{get{return page < pageMax && pageMax > 1 ;}}    
    public string totalAddresses{get; set;}
    public string filtersString{get;set;}
    Public String  soqlQuery {get;set;} 
    Public String  GridLeyend {get{
        string text;
        if(noOfRecords >0){
            if(((page+1) * size)>noOfRecords){
                text = ((((page+1) * size)+1) - size) + ' - ' +  noOfRecords  +' of '+ noOfRecords;
            }
            else{
                 text = ((((page+1) * size)+1) - size) + ' - ' +  ((page+1) * size)  +' of ' + noOfRecords ;
            }    
             if(noOfRecords>2000)
             text =text + '      '+ 'The tool only allow  to navigate up to 2000 objects';
        }
        else{
            text ='   no data';
        }
         
        return text ;
    }} 
    // event handler 
     public void tmp(){
         
      //List<Sobject> t = [select TransactionId__c,Data__c   FROM  Service_Maste_Transaction__c where TransactionId__c = 'a818464c-32b7-2a52-f227-a939461275d7'];
      //system.debug(t);
    }
    // pagination
    public void PaginationFirst(){
     try{
         page =0;    
        }
        catch(exception e){ ExceptionHelper.LogError(e,'PaginationFirst');} 
      }
    public void PaginationPreview(){
     try{
         page--;     
        }
        catch(exception e){ ExceptionHelper.LogError(e,'PaginationPreview');} 
    }
    public void PaginationNext(){
       try{
        page++;     
        }
        catch(exception e){ ExceptionHelper.LogError(e,'PaginationNext');}          
    }
    public void PaginationLast(){
      try{
        page = pageMax - 1;  
        }
        catch(exception e){ ExceptionHelper.LogError(e,'PaginationLast');} 
    }    
    public void GetSelected(){
     try{            
        List<string> filts = new List<string>() ;
        
        filts.add(' ResponseFlag__c = \' null \' ');
         
        if(selectedFlagsList != null){
         for(string s : selectedFlagsList){
            filts.add(' ResponseFlag__c = \'' + s + '\' ');   
          } 
        }    

         String formatedFilter = String.join(filts, ' OR '); 
        filtersString = formatedFilter;
        }
        catch(exception e){ ExceptionHelper.LogError(e,'GetSelected');} 
    }
    public PageReference Cancel(){
        try {
          string transactionid = pageSource.TransactionId;
          pageSource = new Source();
          pageSource.ShowE1 = true;
            
          BatchUpdateDataBatchable b = new BatchUpdateDataBatchable();
          b.TransactionId = transactionid;
          b.TransactionCleanUp();
        } catch(Exception e){
            ExceptionHelper.LogError(e,'GetSelected');            
        }
        PageReference cancelPg = new pagereference('/apex/Batch_NewSession_UI');
        cancelPg.setRedirect(true);
       return   cancelPg;
    }
    public void LoadStep2(){
     try{
          pageSource.ShowE1 = false;
          pageSource.ShowE2 = true;
          pageSource.ShowE3 = false;
    
          LoadObjectFields();
         // LoadMapping();
          pageSource.FieldMappingOptions = Batch_MappingOptions.ddlListOutput;
        }
        catch(exception e){ ExceptionHelper.LogError(e,'');} 
    }
    public PageReference LoadStep3(){
     try{
          pageSource.ShowE1 = false;
          pageSource.ShowE2 = false;
          pageSource.ShowE3 = true;
            
          SaveMapping();
          UpdateData();
           
            pagereference summaryredirect = new pagereference('/apex/FinishingBatch');
            summaryredirect.getParameters().put('TransactionId', pageSource.TransactionId ); 
            summaryredirect.setRedirect(true);
            return summaryredirect;
        }
        catch(exception e){ ExceptionHelper.LogError(e,'');} 
        return null;
    } 
    public void AddSubMappingItem(){
     try{
          Batch_NewSession_CL.MappingItem mItem  =GetMappingItem(MappingItemId); 
          mItem.MappingsList.add(new Batch_NewSession_CL.MappingField('OUTPUT',pageSource.baSendata.SelectedObject)); 
        }
        catch(exception e){ ExceptionHelper.LogError(e,'');}
    }       
    public void RemoveMappingField(){    
       try{
        Batch_NewSession_CL.MappingItem mItem  =GetMappingItem(MappingItemId);
        //MappingsList     
        Integer j = 0;
            while (j < mItem.MappingsList.size())
            {
              if(mItem.MappingsList.get(j).Id == MappingItemRowId)
              {
                mItem.MappingsList.remove(j);
              }else
              {
                j++;
              }
            }
        }
        catch(exception e){ ExceptionHelper.LogError(e,'RemoveMappingField');} 
     
    }
    @RemoteAction
    @readOnly
    public static integer getServiceOutputCount(string filter){
        try{
          if(string.isNotEmpty(filter)){
            return database.countQuery('SELECT COUNT() FROM ServiceOutput__c WHERE ' + filter);
        }
        return database.countQuery('SELECT COUNT() FROM ServiceOutput__c');
        }
        catch(exception e){ ExceptionHelper.LogError(e,'getServiceOutputCount');}
       return 0;
    }
    // private
    private void UpdateData(){ 
       
        BatchUpdateDataBatchable baUpdateData= new BatchUpdateDataBatchable();
        baUpdateData.Soql = QueryBuilderToProcess(filtersString);    
        baUpdateData.SourceMapping =  pageSource.mappingList; 
        baUpdateData.MappingId =  pageSource.baSendata.MappingId; 
        baUpdateData.SelectedObject =  pageSource.baSendata.SelectedObject; 
        baUpdateData.SelectedObjectName =  pageSource.baSendata.SelectedObjectName; 
        baUpdateData.TransactionId = pageSource.TransactionId;

        Database.executeBatch(baUpdateData,25);  
       Service_Maste_Transaction__c  tran = [SELECT Id,Name, TransactionId__c, Total_Addresses__c FROM Service_Maste_Transaction__c WHERE TransactionId__c =:pageSource.TransactionId LIMIT 1]; 
        
        tran.Status__c  = 'Submitting';                 
 
       update tran;        
           
    }
    private Batch_NewSession_CL.MappingItem GetMappingFromData(string data, string id ){
    Batch_NewSession_CL.MappingItem toReturn = new Batch_NewSession_CL.MappingItem();
     toReturn.MappingsList = new List<Batch_NewSession_CL.MappingField>();       
     toReturn.Id = id;
      
     Mappings tt =   (Mappings)JSON.deserialize(data, Mappings.class);
     
        for(Mapping Iitem : tt.Mappings){
        
            Batch_NewSession_CL.MappingField item = new Batch_NewSession_CL.MappingField(Iitem.Name, Iitem.Map_Object, Iitem.Index,Iitem.type, pageSource.baSendata.SelectedObject); 
            //item.Id = Iitem.Mapping_ID();
            toReturn.MappingsList.add(item);
            
        }
        
      
        return toReturn;
    }
    private void LoadMapping(){         
             string mId=  pageSource.baSendata.MappingId ;
             Mapping__c tmap = [select Id__c, ObjectId__c, Name from Mapping__c  where Id__c = :mId  LIMIT 1] ;           
                             
                  List<Mapping_Detail__c> tmapDetList = [select Id__c,MappingId__c, Data__c from Mapping_Detail__c  where MappingId__c = :tmap.Id__c] ;
                  
                  system.debug(tmapDetList);
        
                  pageSource.mappingList = new List<Batch_NewSession_CL.MappingItem>();
                  for(Mapping_Detail__c Iitem : tmapDetList){  
                    pageSource.mappingList.Add(GetMappingFromData(Iitem.Data__c,Iitem.Id__c ));
                  }           
                  
                 pageSource.isSavedMapping = true;
        }
    private string GetmappingData(Batch_NewSession_CL.MappingItem Imap ){
        Mappings vmap = new  Mappings();
           integer i =0;
            for(Batch_NewSession_CL.MappingField Iitem : Imap.MappingsList){                
              Mapping item = new Mapping(Iitem.Label,Iitem.Field,Iitem.MapField,i,Iitem.type );
               vmap.Mappings.add(item);               
               i++; 
            }           
            return  JSON.serialize(vmap);
    }
    private void SaveMapping(){
      List<Mapping_Detail__c> details =  new List<Mapping_Detail__c>();
        for( Batch_NewSession_CL.MappingItem Imap: pageSource.mappingList){
            Mapping_Detail__c mapDetail = [SELECT Id__c, MappingId__c ,Data__c FROM Mapping_Detail__c WHERE Id__c = :Imap.Id LIMIT 1];             
            String data = GetmappingData(Imap);            
            mapDetail.Data__c =data;
            details.add(mapDetail);            
         } 
         UPDATE details; 
    }
    private Schema.sObjectType GetByName( string val){
        //system.debug(val);
      list<schema.sObjectType> allObjects = Schema.getGlobalDescribe().Values();
        for(schema.sObjectType c : allObjects){
            if(c.getDescribe().getKeyPrefix() +'_'+c.getDescribe().getLabel() == val ){
                  //system.debug(c);
                return c;
            }
        }
        return null;
      }
     @TestVisible
    private void LoadObjectFields(){
        //system.debug('LoadObjectFields');
      pageSource.PreferObjectFieldOptions = new SelectOption[]{};  
      schema.sObjectType tmp = GetByName(pageSource.baSendata.selectedObject);
         //system.debug(pageSource.baSendata.selectedObject );
          //system.debug(tmp);
        
           Schema.DescribeSObjectResult a_desc = tmp.getDescribe(); 
        //for the Account object, you can replace that with any object you have, standard or custom
        //
        //system.debug(a_desc);
        Map<String, Schema.SObjectField> a_fields = a_desc.fields.getMap();
        
        for(String  fld:a_fields.keySet()){ 
            //DescribeFieldResult describe = fld.getDescribe();
            // String label = describe.getLabel();
            // String tkey = fld.keySet();
            string flabel = a_fields.get(fld).getDescribe().getLabel();
            Schema.DisplayType fieldtype = a_fields.get(fld).getDescribe().getType();
            if(fld != 'Id' && fieldtype != Schema.DisplayType.ADDRESS && fieldtype != Schema.DisplayType.SOBJECT
              && fieldtype != Schema.DisplayType.BASE64 && fieldtype != Schema.DisplayType.BOOLEAN
              && fieldtype != Schema.DisplayType.CURRENCY && fieldtype != Schema.DisplayType.DATACATEGORYGROUPREFERENCE
              && fieldtype != Schema.DisplayType.MULTIPICKLIST && fieldtype != Schema.DisplayType.REFERENCE
              && fieldtype != Schema.DisplayType.URL && fieldtype != Schema.DisplayType.PHONE
             /* && fieldtype != Schema.DisplayType.PICKLIST*/){
              pageSource.PreferObjectFieldOptions.add(new SelectOption(fld , flabel));   
            }            
          }
        
        pageSource.PreferObjectFieldOptions = Batch_NewSession_CL.SortSelectOptionList(pageSource.PreferObjectFieldOptions);
        pageSource.PreferObjectFieldOptions.add(0, new SelectOption('' ,'select...'));
    }
    private Batch_NewSession_CL.MappingItem GetMappingItem( string val){
        for(Batch_NewSession_CL.MappingItem obj : pageSource.mappingList){
            if(obj.Id ==val ){
                return obj;
            }   
        }
        return null; 
    }
    
     @TestVisible
    private void LoadS2Data(){  
        
        integer Trancount = database.countQuery('SELECT  COUNT()  FROM Service_Maste_Transaction__c WHERE TransactionId__c = \''+pageSource.TransactionId +'\' ');
     
        if(Trancount > 0){            
          Service_Maste_Transaction__c  tran = [SELECT TransactionId__c,Data__c FROM Service_Maste_Transaction__c WHERE TransactionId__c =:pageSource.TransactionId LIMIT 1]; 
           
            pageSource.baSendata  = (Batch_SentDataBatchable)System.JSON.deserialize(tran.Data__c, Batch_SentDataBatchable.class);
        }
     
    }
   @TestVisible
    private static List<ServiceOutput__c> parseList(List<Response> responselist){
        List<ServiceOutput__c> outputlist = new List<ServiceOutput__c>();
        for(Response response : responselist){
            try{ 
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
        	catch(exception e){ ExceptionHelper.LogError(e,'parseList');}
            
        }
        return outputlist;
    }
    public List<ServiceOutput__c> getDataSet() {
        showColumn2 = false;
        showColumn3 = false;
        showColumn4 = false;
        showColumn5 = false;
        
        List<ServiceOutput__c> listSO = new List<ServiceOutput__c>();
        //system.debug(QueryBuilder(filtersString));
        
        Map <String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get('ServiceOutput__c').getDescribe().fields.getMap();
        //Map <String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(ServiceOutput__c).getDescribe().fields.getMap();
        string selectitems = '';
        for(Schema.SObjectField sfield : fieldMap.Values()){
            schema.describefieldresult dfield = sfield.getDescribe();
            selectitems += dfield.getName() + ',';
        }
        selectitems = selectitems.substring(0, selectitems.length() - 1);
        system.debug(QueryBuilder(filtersString));
        listSO = Database.query(QueryBuilder(filtersString));  
      
        noOfRecords =   GetDataCount ; 
        
        //PAGINATION
        Decimal toround ;
        if(noOfRecords > 2000){
            //toround = (2000 / size);
            toround = ((decimal)(2000)).divide((decimal)(size), 2);
        }
        else{
          //toround =  (noOfRecords / size);
          toround = ((decimal)(noOfRecords)).divide((decimal)(size), 2);
        }
        // Decimal toround = (noOfRecords / size);
         pageMax = (integer)(toRound.setScale(0, RoundingMode.CEILING));

        return listSO;
    }  
    private integer  GetDataCount {get{ 
        string sq = QueryBuilder(filtersString );
        
        if(soqlQuery ==sq){
            return noOfRecords;
        }       
         
        //regen query with new page;       
        integer count;
        try{
           count = database.countQuery( QueryToCount( ));   
        }
        catch(exception e){
            //system.debug('GetDataCount');
            //system.debug(e.getMessage());
                //system.debug(QueryToCount( ));
            // break over 50000;
            count =2000;
        }
       
        return count;
    }}    
    private void processResponseFlagData(){
        List<ResponseFlagData> rdata = new List<ResponseFlagData>();
        try{
            colorsSet = '';
            boolean iscreated = false;
            Service_Maste_Transaction__c masterTransaction = (Service_Maste_Transaction__c)Database.query('select Total_Addresses__c, Response_Flag_Metrics__c FROM  Service_Maste_Transaction__c where TransactionId__c =\''+ pageSource.TransactionId +'\'');
            
            //system.debug('masterTransaction.Response_Flag_Metrics__c');
            //system.debug(masterTransaction.Response_Flag_Metrics__c);
            Map<string, integer> metrics = (Map<string, integer>)JSON.deserialize(masterTransaction.Response_Flag_Metrics__c, Map<string, integer>.class);
            
            //integer totalcount = (integer)masterTransaction.Total_Addresses__c;
            integer totalcount = 0;
            for (string responseflag : metrics.keySet()) {
                totalcount += metrics.get(responseflag);
            }
            metrics = Batch_Helpers.sortMap(metrics);
            totalAddresses = 'Total: ' + totalcount + ' Addresses';
            if( selectedFlagsList ==null) {
                selectedFlagsList = new String[]{};
                iscreated = true;
            }
            
            for (string responseflag : metrics.keySet()) {
                integer metriccount = metrics.get(responseflag);
                string perc = String.valueOf(((decimal)(metriccount * 100)).divide(totalcount, 2)) + '%';
                rdata.add(new ResponseFlagData(responseflag, getFlagNameById(responseflag), metriccount, perc));
                if(iscreated){                    
                  selectedFlagsList.add(responseflag);
                }
            }
           
            BuildResponseFlagData(rdata);
        } catch(Exception e){
            totalAddresses = '0 Addresses';
        }   
    }    
    private void BuildResponseFlagData(List<ResponseFlagData> rdata){
     
    List<String> flags = new  List<String>();
       flags.add('E');
       flags.add('T');
       flags.add('M');
       flags.add('S');
       flags.add('U');
       flags.add('O');
       flags.add('N');       
       
        this.chartData = new List<ResponseFlagData> ();            
            
       for(string s : flags ){
           ResponseFlagData d = null;
           for(ResponseFlagData c : rdata) {
              if(c.flagvalue == s)
                    d= c; 
           }
             
           if(d == null){
               d= new ResponseFlagData(s, getFlagNameById(s), 0, '0%')  ;         
           }
           this.chartData.add(d); 
           ColorSetByFlag(s);
       }
       
     colorsSet = colorsSet.substring(0, colorsSet.length() - 1);
    }
    private void ColorSetByFlag(string flagid){
        
        if(flagid.toUpperCase() == 'E'){
            colorsSet += '#008000,';            
        } else if (flagid.toUpperCase() == 'T'){
            colorsSet += '#6495ED,';           
        } else if (flagid.toUpperCase() == 'P'){
            colorsSet += '#e0d728,';            
        } else if (flagid.toUpperCase() == 'S'){
            colorsSet += '#800080,';            
        } else if (flagid.toUpperCase() == 'U'){
            colorsSet += '#FF0000,';           
        } else if (flagid.toUpperCase() == 'N'){
            colorsSet += '#8f8f8f,';           
        } else if (flagid.toUpperCase() == 'M'){
            colorsSet += '#FF4500,';
          
        } else if (flagid.toUpperCase() == 'O'){
            colorsSet += '#C2C2C2,';
           
        }       
    }
     @TestVisible
    private string getFlagNameById(string flagid){
        if(flagid.toUpperCase() == 'E'){
            //colorsSet += '#008000,';
            return 'Exact';
        } else if (flagid.toUpperCase() == 'T'){
            //colorsSet += '#6495ED,';
            return 'Tentative';
        } else if (flagid.toUpperCase() == 'P'){
            //colorsSet += '#e0d728,';
            return 'Primary';
        } else if (flagid.toUpperCase() == 'S'){
            //colorsSet += '#800080,';
            return 'Secondary';
        } else if (flagid.toUpperCase() == 'U'){
            //colorsSet += '#FF0000,';
            return 'Unmatched';
        } else if (flagid.toUpperCase() == 'N'){
            //colorsSet += '#8f8f8f,';
            return 'Not Processed';
        } else if (flagid.toUpperCase() == 'M'){
            //colorsSet += '#FF4500,';
            return 'Multiple';
        } else if (flagid.toUpperCase() == 'O'){            
            return 'Overridden*';
        }
        return flagid;
    }
     @TestVisible
    private string QueryBuilder(){
        return QueryBuilder(null);
    }
    private string QueryBuilder(string filters){
      string base ='SELECT {0} FROM {1}'; 
      
      String oName = 'ServiceOutput__c' ;
        
      List<string> columnsList = new List<String>();
        
       Map <String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(oName).getDescribe().fields.getMap();
        
        string selectitems = '';
        for(Schema.SObjectField sfield : fieldMap.Values()){
            schema.describefieldresult dfield = sfield.getDescribe();
            columnsList.add(dfield.getName());            
        }
        
        String columnsString = String.join(columnsList, ','); 
        List<String> fillers = new String[]{columnsString,oName};     
        String formatted = String.format(base, fillers); 
             // 
             //
        formatted = formatted+' WHERE (TransactionId__c = \''+pageSource.TransactionId +'\')';
            
        if(string.isNotEmpty(filters) ){          
           formatted = formatted+' AND (' + filters + ')';
           //formatted = formatted+' where ' + filters;
        }        
         formatted = formatted+' ORDER BY ID  LIMIT ' + size + ' OFFSET ' + (size * (page));
       
       return formatted;
    }   
     @TestVisible
    private string QueryBuilderToProcess(string filters){
      string base ='SELECT {0} FROM {1}'; 
      
      String oName = 'ServiceOutput__c' ;
        
      List<string> columnsList = new List<String>();
        
       Map <String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(oName).getDescribe().fields.getMap();
        
        string selectitems = '';
        for(Schema.SObjectField sfield : fieldMap.Values()){
            schema.describefieldresult dfield = sfield.getDescribe();
            columnsList.add(dfield.getName());            
        }
        
        String columnsString = String.join(columnsList, ','); 
        List<String> fillers = new String[]{columnsString,oName};     
        String formatted = String.format(base, fillers); 
        
        formatted = formatted+' WHERE (TransactionId__c = \'' + pageSource.TransactionId + '\')';
        
        if(string.isNotEmpty(filters) ){          
           formatted = formatted+' AND (' + filters + ')';
        }
         formatted = formatted+' ORDER BY ID';
        
        
        
         //system.debug('formatted  SOQL: ');
        
       //system.debug(formatted);
       return formatted;
    }   
     @TestVisible
    private string QueryToCount(){  
    
        string baseQuery ='SELECT  COUNT()  FROM  ServiceOutput__c '; 
          
        string formatted;
        formatted = baseQuery;
        if(string.isNotEmpty(filtersString) ){          
           formatted = formatted+' WHERE ' + filtersString;
        }        
         formatted = formatted+'  LIMIT 2000 ' ;
        
         
        return formatted;
    } 
    // Pop Up
    public void showPopup() {
        displayPopup = true;
    }    
    public void closePopup() {
        displayPopup = false;
    }   
    //Class  
    public class Source{
        private Batch_SentDataBatchable ba_data; 
        // Flags Filter
        public string SelectedFlag  {get;set;} 
        public string FilterFlagTxt  {get;set;} 
        // Flags Filter   

        
        public string TransactionId  {get;set;}  
        public Batch_SentDataBatchable baSendata{
                set {
                   ba_data = value;
                   isSavedMapping = string.isNotEmpty(ba_data.MappingId);
                    SavedMapping = ba_data.MappingId;
                    MappingName = ba_data.MappingName;
                     mappingList = ba_data.SourceMapping;
                    SelectedObjectName = ba_data.SelectedObjectName;
                        } 
                 get{ return ba_data;}} 
            
        public boolean ShowE1 {get;set;}
        public boolean ShowE2 {get;set;}
        public boolean ShowE3 {get;set;}
         
        public boolean isSavedMapping {get;set;}
        public string  SavedMapping  {get;set;} 
        public string  MappingName  {get;set;}
    public string  SelectedObjectName  {get;set;}
                        
        public List<Batch_NewSession_CL.MappingItem> mappingList {get;set;} 
        public SelectOption[] FieldMappingOptions {get;set;}
        public SelectOption[] SavedMappingsOptions {get;set;} 
        public SelectOption[] preferObjectsOptions {get;set;}  
        public SelectOption[] PreferObjectFieldOptions {get;set;} 
        
    }
    public class ResponseFlagData  {
        public string flagname {get; set;}
        public string flagvalue {get; set;}
        public integer data {get; set;}
        public string percentage {get; set;}
        public string color {get; set;}
        
        public ResponseFlagData(string flagvalue, string name, integer data, string p){
            this.flagvalue = flagvalue;
            this.flagname = name;
            this.data = data;
            this.percentage = p;
        }
           //Implement
 
    }
}