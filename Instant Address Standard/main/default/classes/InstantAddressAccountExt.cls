public  class InstantAddressAccountExt {
    
    public InstantAddressRenderer Renderer { get; set; }
    
    public InstantAddressAccountExt(ApexPages.StandardController stdController){         
        this.Renderer = new InstantAddressRenderer(stdController, 'Account');      
    }
}