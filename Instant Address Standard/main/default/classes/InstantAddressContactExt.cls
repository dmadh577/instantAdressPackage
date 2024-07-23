public with sharing class InstantAddressContactExt {
	public InstantAddressRenderer Renderer { get; set; }
    
    public InstantAddressContactExt(ApexPages.StandardController stdController){
        this.Renderer = new InstantAddressRenderer(stdController, 'Contact');
    }
}