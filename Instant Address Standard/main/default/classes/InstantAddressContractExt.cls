public with sharing class InstantAddressContractExt {
	public  InstantAddressRenderer Renderer { get; set; }
    
    public InstantAddressContractExt(ApexPages.StandardController stdController){
        this.Renderer = new  InstantAddressRenderer(stdController, 'Contract');
    }
}