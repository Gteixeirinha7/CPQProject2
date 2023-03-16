public with sharing class PDFQuoteController {
	public Boolean hasError {get; set;}
	public String errorMessage {get; set;}

	public String quoteId {get; set;}
	public QuoteData quoteData {get; set;}

	public PDFQuoteController() {
		this.hasError = false;
		this.errorMessage = '';

		try {
			this.quoteId = ApexPages.currentPage().getParameters().get('Id');
			if (String.isBlank(this.quoteId)) throw new CustomException('Cotação inválida!');

			Map<Id, Product2> productIdToProductMap = new Map<Id, Product2>();
			Set<String> resourceCodeSet = new Set<String>();
			Quote currentQuote = getQuote(quoteId);
			if (currentQuote == null) throw new CustomException('Cotação não encontrada!');

			for (QuoteLineItem retrievedItem : currentQuote.QuoteLineItems) {
				if (!String.isBlank(retrievedItem.Product2.ExternalId__c)) {
					productIdToProductMap.put(retrievedItem.Product2Id, retrievedItem.Product2);
					resourceCodeSet.add(retrievedItem.Product2.ExternalId__c);
				}
			}

			Map<Id, List<TiposRecurso__c>> productIdToResourceListMap = getResources(resourceCodeSet, productIdToProductMap);
			Map<Id, ContentVersion> itemToImageMap = new Map<Id, ContentVersion>();

			if (!productIdToResourceListMap.isEmpty()) {
				itemToImageMap = getImages(productIdToResourceListMap.keySet());
			}

			this.quoteData = new QuoteData(currentQuote, productIdToResourceListMap, itemToImageMap);
		}
		catch (Exception ex) {
			System.debug('Create Quote PDF Exception => ' + ex.getMessage());
			System.debug('Stack Trace => ' + ex.getStackTraceString());
			this.hasError = true;
			this.errorMessage = ex.getMessage();
			this.quoteData = new QuoteData();
		}

		System.debug('quoteData => ' + quoteData);
	}

	public Map<Id, List<TiposRecurso__c>> getResources(Set<String> resourceCodeSet, Map<Id, Product2> productIdToProductMap) {
		Map<Id, List<TiposRecurso__c>> productIdToResourceListMap = new Map<Id, List<TiposRecurso__c>>();
		Map<String, TiposRecurso__c> resourceTypeMap = new Map<String, TiposRecurso__c>();
		Set<String> typeCodeSet = new Set<String>();

		for (String code : resourceCodeSet) {
			Integer count = 0;
			String correctCode = '';

			for (String splitCode : code.split('')) {
				correctCode += splitCode;
				count++;

				if (count == 2) {
					typeCodeSet.add(correctCode);
					correctCode = '';
					count = 0;
				}
			}
		}

		for (TiposRecurso__c retrievedType : [
			SELECT Id,
				   DescricaoRecurso__c,
				   ExternalId__c,
				   RecursoProduto__r.Name
			  FROM TiposRecurso__c
			 WHERE ExternalId__c IN :typeCodeSet
		]) {
			resourceTypeMap.put(retrievedType.ExternalId__c, retrievedType);
		}

		for (Id productId : productIdToProductMap.keySet()) {
			Product2 currentProduct = productIdToProductMap.get(productId);

			if (!productIdToResourceListMap.containsKey(productId)) {
				productIdToResourceListMap.put(productId, new List<TiposRecurso__c>());
			}

			Integer count = 0;
			String code = '';
			for (String splitCode : currentProduct.ExternalId__c.split('')) {
				code += splitCode;
				count++;

				if (count == 2) {
					if (resourceTypeMap.containsKey(code)) {
						productIdToResourceListMap.get(productId).add(resourceTypeMap.get(code));
					}

					code = '';
					count = 0;
				}
			}
		}

		return productIdToResourceListMap;
	}

	public static Map<Id, ContentVersion> getImages(Set<Id> productIdSet) {
		Map<Id, ContentVersion> itemToImageMap = new Map<Id, ContentVersion>();
		Map<Id, Id> documentIdToProductIdMap = new Map<Id, Id>();

		for (ContentDocumentLink retrievedLink : [
			SELECT ContentDocumentId,
				   LinkedEntityId
			  FROM ContentDocumentLink
			 WHERE LinkedEntityId IN :productIdSet
		]) {
			documentIdToProductIdMap.put(retrievedLink.ContentDocumentId, retrievedLink.LinkedEntityId);
		}

		for (ContentVersion retrievedContent : [
			SELECT VersionData,
				   FileExtension,
				   ContentDocumentId
			  FROM ContentVersion
			 WHERE ContentDocumentId IN :documentIdToProductIdMap.keySet()
		]) {
			itemToImageMap.put(
				documentIdToProductIdMap.get(retrievedContent.ContentDocumentId),
				retrievedContent
			);
		}

		System.debug('itemToImageMap => ' + itemToImageMap);

		return itemToImageMap;
	}

	public Quote getQuote(Id quoteId) {
		Quote currentQuote;

		for (Quote retrievedQuote : [
			SELECT Id,
				   Name,
				   Account.Name,
				   Account.ShippingStreet,
				   Account.ShippingCity,
				   Account.ShippingState,
				   Account.ShippingPostalCode,
				   Contact.Name,
				   Contact.Phone,
				   Contact.Account.Name,
				   (
					SELECT Id,
						   Quantity,
						   Product2Id,
						   Product2.Name,
						   Product2.Image_URL__c,
						   Product2.ExternalId__c,
						   ParentProduct__c
					  FROM QuoteLineItems
				   )
			  FROM Quote
			 WHERE Id = :quoteId
			 LIMIT 1
		]) {
			currentQuote = retrievedQuote;
		}

		return currentQuote;
	}

	@RemoteAction
	public static String createPDF(String contentVersionId, String quoteId, String fileName) {
		String documentId;
		for (ContentVersion retrievedDocument : [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :contentVersionId LIMIT 1]) {
			documentId = retrievedDocument.ContentDocumentId;
		}

		insert new ContentDocumentLink(
			ContentDocumentId = documentId,
			LinkedEntityId = quoteId,
			ShareType = 'V'
		);

		ContentDistribution contentDistribution = new ContentDistribution(
			Name                             = fileName,
			ContentVersionId                 = contentVersionId,
			PreferencesAllowViewInBrowser    = true,
			PreferencesLinkLatestVersion     = true,
			PreferencesNotifyOnVisit         = false,
			PreferencesPasswordRequired      = false,
			PreferencesAllowOriginalDownload = true
		);

		insert contentDistribution;

		ContentDistribution contentDistributionInserted = new ContentDistribution();
		for (ContentDistribution retreivedDistribution : [
			SELECT Id,
				   DistributionPublicUrl
			  FROM ContentDistribution
			 WHERE Id = :contentDistribution.Id
			 LIMIT 1
		]) {
			contentDistributionInserted = retreivedDistribution;
		}

		return contentDistributionInserted.DistributionPublicUrl;
	}

	@RemoteAction
	public static String getUserSessionKey() {
		System.debug(UserInfo.getSessionId());
		return UserInfo.getSessionId();
	}

	public class CustomException extends Exception {}

	public class QuoteData {
		public String name {get; set;}
		public String accountName {get; set;}
		public String contactName {get; set;}
		public String shippingStreet {get; set;}
		public String shippingCity {get; set;}
		public String shippingState {get; set;}
		public String shippingPostalCode {get; set;}
		public String contactPhone {get; set;}
		public String contactAccountName {get; set;}

		public List<QuoteItem> itemList {get; set;}

		public QuoteData() {
			this.name = '';
			this.accountName = '';
			this.shippingStreet = '';
			this.shippingCity = '';
			this.shippingState = '';
			this.shippingPostalCode = '';
			this.contactName = '';
			this.contactPhone = '';
			this.contactAccountName = '';

			this.itemList = new List<QuoteItem>();
		}
		public QuoteData(Quote currenctQuote, Map<Id, List<TiposRecurso__c>> productIdToResourceListMap, Map<Id, ContentVersion> itemToImageMap) {
			this.name = currenctQuote.Name;
			this.accountName = currenctQuote.Account.Name;
			this.shippingStreet = currenctQuote.Account.ShippingStreet;
			this.shippingCity = currenctQuote.Account.ShippingCity;
			this.shippingState = currenctQuote.Account.ShippingState;
			this.shippingPostalCode = currenctQuote.Account.ShippingPostalCode;
			this.contactName = currenctQuote.Contact.Name;
			this.contactPhone = currenctQuote.Contact.Phone;
			this.contactAccountName = currenctQuote.Contact.Account.Name;

			this.itemList = fillQuoteItemList(currenctQuote.QuoteLineItems, productIdToResourceListMap, itemToImageMap);
		}

		public List<QuoteItem> fillQuoteItemList(
			List<QuoteLineItem> itemList,
			Map<Id, List<TiposRecurso__c>> productIdToResourceListMap,
			Map<Id, ContentVersion> itemToImageMap
		) {
			List<QuoteItem> quoteItemList = new List<QuoteItem>();
			List<QuoteLineItem> quoteLineItemList = new List<QuoteLineItem>();
			Map<Id, List<QuoteLineItem>> parentProductIdToAccessoryItemListMap = new Map<Id, List<QuoteLineItem>>();

			for (QuoteLineItem retrievedItem : itemList) {
				if (!String.isBlank(retrievedItem.ParentProduct__c)) {
					if (!parentProductIdToAccessoryItemListMap.containsKey(retrievedItem.ParentProduct__c)) {
						parentProductIdToAccessoryItemListMap.put(retrievedItem.ParentProduct__c, new List<QuoteLineItem>());
					}
					parentProductIdToAccessoryItemListMap.get(retrievedItem.ParentProduct__c).add(retrievedItem);
				}
				else {
					quoteLineItemList.add(retrievedItem);
				}
			}

			for (QuoteLineItem retrievedItem : quoteLineItemList) {
				quoteItemList.add(
					new QuoteItem(
						retrievedItem,
						productIdToResourceListMap,
						itemToImageMap,
						parentProductIdToAccessoryItemListMap.get(retrievedItem.Product2Id)
					)
				);
			}

			return quoteItemList;
		}
	}

	public class QuoteItem {
		public String name {get; set;}
		public Object image {get; set;}
		public String extension {get; set;}
		public Boolean hasKit {get; set;}

		public List<OptionalItem> optionalList {get; set;}
		public List<KitData> kitDataList {get; set;}

		public QuoteItem(
			QuoteLineItem currentItem,
			Map<Id, List<TiposRecurso__c>> productIdToResourceListMap,
			Map<Id, ContentVersion> productIdToImageMap,
			List<QuoteLineItem> accessoryItemList
		) {
			this.name = currentItem.Product2.Name;
			this.hasKit = accessoryItemList != null;

			if (productIdToImageMap.containsKey(currentItem.Product2Id)) {
				Blob imageData = (Blob)productIdToImageMap.get(currentItem.Product2Id).VersionData;

				this.image = EncodingUtil.base64Encode(imageData);
				this.extension = productIdToImageMap.get(currentItem.Product2Id).FileExtension;
			}

			if (productIdToResourceListMap.containsKey(currentItem.Product2Id)) {
				this.optionalList = fillOptionals(productIdToResourceListMap.get(currentItem.Product2Id));
			}
			else this.optionalList = new List<OptionalItem>();

			if (accessoryItemList != null && !accessoryItemList.isEmpty()) {
				this.kitDataList = new List<KitData>();

				for (QuoteLineItem accessoryItem : accessoryItemList) {
					this.kitDataList.add(new KitData(accessoryItem));
				}
			}
		}

		public List<OptionalItem> fillOptionals(List<TiposRecurso__c> typeList) {
			List<OptionalItem> optionaList = new List<OptionalItem>();

			for (TiposRecurso__c retrievedType : typeList) {
				optionaList.add(new OptionalItem(retrievedType));
			}

			return optionaList;
		}
	}

	public class OptionalItem {
		public String name {get; set;}
		public String description {get; set;}

		public OptionalItem(TiposRecurso__c retrievedType) {
			this.name = retrievedType.RecursoProduto__r.Name;
			this.description = retrievedType.DescricaoRecurso__c;
		}
	}

	public class KitData {
		public String name {get; set;}
		public Decimal quantity {get; set;}

		public KitData(QuoteLineItem accessoryItem) {
			this.name = accessoryItem.Product2.Name;
			this.quantity = accessoryItem.Quantity;
		}
	}
}