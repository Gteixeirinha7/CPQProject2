public with sharing class OpenQuotePDFController {
	@AuraEnabled
	public static String getURL(String quoteId) {
		String pdfUrl = '';
		PageReference pageRef = new PageReference('/apex/PDFQuote?Id=' + quoteId);
		Blob pdf = !Test.isRunningTest() ? pageRef.getContent() : Blob.valueOf('Test');

		try {
			Quote currentQuote;
			for (Quote retrievedQuote : [SELECT Name FROM Quote WHERE Id = :quoteId LIMIT 1]) {
				currentQuote = retrievedQuote;
			}

			if (currentQuote == null) throw new CustomException('Cotação não encontrada.');

			ContentVersion contentVersion = new ContentVersion(
				Title = currentQuote.Name,
				PathOnClient = currentQuote.Name + '.pdf',
				VersionData = pdf,
				FirstPublishLocationId = quoteId
			);
			insert contentVersion;

			pdfUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/apex/PDFQuote?Id=' + quoteId;
		}
		catch (Exception ex) {
			System.debug('Generate PDF Exception => ' + ex.getMessage());
			System.debug('Stack Trace => ' + ex.getStackTraceString());
		}

		return pdfUrl;
	}

	public class CustomException extends Exception {}
}