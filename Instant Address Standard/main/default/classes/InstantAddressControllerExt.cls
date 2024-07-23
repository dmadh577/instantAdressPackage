public with sharing class InstantAddressControllerExt {
    //public InstantAddressRenderer Renderer { get; set; }
    public ApexPages.StandardController standardController { get; set; }
	public InstantAddressControllerExt(ApexPages.StandardController stdController){
        this.standardController = stdController;
        //this.Renderer = new InstantAddressRenderer(stdController);
    }
}