public class InstantAddressBatchProcessResponse {
	public string batchid { get; set; }
    public string completed { get; set; }
    public List<string> errors { get; set; }
    public string totalreceived { get; set; }
    public string totalsent { get; set; }
    public string message { get; set; }
}