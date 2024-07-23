public class InstantAddressAddressExt {
	public InstantAddressRenderer Renderer { get; set; }
    
    public InstantAddressAddressExt(ApexPages.StandardController stdController){
		this.Renderer = new InstantAddressRenderer(stdController, 'Address__c');
    }
}