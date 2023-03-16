({
	doInit: function(component) {
		var quoteId = component.get("v.recordId");

		var url = '/lightning/n/StructureProductScreen?';

		if (quoteId) {
			url += `c__quoteId=${quoteId}`;
		}

		var urlEvent = $A.get("e.force:navigateToURL");
		urlEvent.setParams({ "url": url });
		urlEvent.fire();

		$A.get("e.force:closeQuickAction").fire();
    }
})