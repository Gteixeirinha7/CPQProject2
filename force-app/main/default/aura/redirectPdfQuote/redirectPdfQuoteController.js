({
	doInit: function(component) {
		var quoteId = component.get("v.recordId");
		component.set("v.message", "");

		if (quoteId) {
			var url = '/apex/PDFQuote?Id=' + quoteId;

			component.set("v.message", "PDF Gerado!");

			window.open(url, '_blank');
		}
		else {
			component.set("v.message", "Falha ao gerar o PDF");
		}
	}
})