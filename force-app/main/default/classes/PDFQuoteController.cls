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

			this.quoteData = new QuoteData(currentQuote);
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

	public static Map<String, Map<String, List<TiposRecurso__c>>> getResources(Set<String> estruturaIdSet) {
		Map<String, Map<String, List<TiposRecurso__c>>> resourceTypeMap = new Map<String, Map<String, List<TiposRecurso__c>>>();
		for(TiposRecurso__c rec : [SELECT id, Sequencial__c, RecursoProduto__r.EstruturaProduto__c, RecursoProduto__r.EstruturaProduto__r.CodigoInterno__c, RecursoProduto__r.Sequencial__c, RecursoProduto__r.Name, DescricaoRecurso__c FROM TiposRecurso__c WHERE RecursoProduto__r.EstruturaProduto__c IN :estruturaIdSet order by RecursoProduto__r.Sequencial__c ASC]){
			if(!resourceTypeMap.containsKey(rec.RecursoProduto__r.EstruturaProduto__c)){
				resourceTypeMap.put(rec.RecursoProduto__r.EstruturaProduto__c, new Map<String, List<TiposRecurso__c>>());
			}	

			if(!resourceTypeMap.get(rec.RecursoProduto__r.EstruturaProduto__c).containsKey(String.valueOf(rec.RecursoProduto__r.Sequencial__c))){
				resourceTypeMap.get(rec.RecursoProduto__r.EstruturaProduto__c).put(String.valueOf(rec.RecursoProduto__r.Sequencial__c), new List<TiposRecurso__c>());
			}	

			resourceTypeMap.get(rec.RecursoProduto__r.EstruturaProduto__c).get(String.valueOf(rec.RecursoProduto__r.Sequencial__c)).add(rec);
		}
		return resourceTypeMap;
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
				   Prazo_de_Entrega__c,
					Prazo_de_Garantia__c,
					Instalacao__c,
				   Account.Name,
				   Account.ShippingStreet,
				   Account.ShippingCity,
				   Account.ShippingState,
				   Account.ShippingPostalCode,
				   Contact.Name,
				   Contact.Phone,
				   Contact.Account.Name,
				   OP_QT_Identif__c,
				   Frete__c,
					TotalPrice,
					Discount,
				   (
					SELECT Id,
						   Quantity,
						   Product2Id,
						   Product2.Name,
						   Product2.ProductCode,
						   Product2.Imagem_URL__c,
						   Product2.ExternalId__c,
						   ParentProduct__c,
						   AcessoryGroup__c,
						   AcessoryGroup__r.Tipo__c,
						   AcessoryType__c,
						   Product2.EstruturaProduto__c,
						   Product2.EstruturaProduto__r.CodigoInterno__c,
						   TotalPrice,
						   UnitPrice
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

		public String accountAddress {get;set;}
		public String prazoGarantia {get;set;}
		public String prazoEntrega {get;set;}
		public String instalacao {get;set;}
		public String frete {get;set;}
		public String addressDelivery {get;set;}
		public String createdBy {get;set;}

		public String today {get;set;}
		public String proposal {get;set;}
		public String paymentCondition {get;set;}
		public String freight {get;set;}
		public String totalPrice {get;set;}
		public String discount {get;set;}

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

			this.accountAddress = '';
			this.prazoGarantia = '';
			this.prazoEntrega = '';
			this.instalacao = '';
			this.frete = '';
			this.addressDelivery = '';
			this.createdBy = '';

			this.itemList = new List<QuoteItem>();
		}
		public QuoteData(Quote currenctQuote) {
            User us = [SELECT id, NAme, Email FROM USER WHERE ID = : UserInfo.getUserId() LIMIT 1];

			this.name = currenctQuote.Name;
			this.accountName = currenctQuote.Account.Name;
			this.shippingStreet = currenctQuote.Account.ShippingStreet;
			this.shippingCity = currenctQuote.Account.ShippingCity;
			this.shippingState = currenctQuote.Account.ShippingState;
			this.shippingPostalCode = currenctQuote.Account.ShippingPostalCode;
			this.contactName = currenctQuote.Contact.Name;
			this.contactPhone = currenctQuote.Contact.Phone;
			this.contactAccountName = currenctQuote.Contact.Account.Name;

			this.today = DateTime.now().format('dd/MM/yyyy');
			this.proposal = currenctQuote.OP_QT_Identif__c;
			this.freight = currenctQuote.Frete__c;
			this.totalPrice = convertToBRL(currenctQuote.TotalPrice);
			this.discount = convertToBRL(currenctQuote.Discount * 100);

			
			this.accountAddress = '';
            this.prazoEntrega = String.valueOf(currenctQuote.Prazo_de_Entrega__c);
            this.prazoGarantia = String.valueOf(currenctQuote.Prazo_de_Garantia__c);
            this.instalacao = currenctQuote.Instalacao__c;
            this.frete = currenctQuote.Frete__c;
			this.addressDelivery = currenctQuote.account.ShippingStreet +', '+currenctQuote.account.ShippingCity +', '+currenctQuote.account.ShippingPostalCode;
			this.createdBy = us.Name;

			this.itemList = fillQuoteItemList(currenctQuote);
		}

		public List<QuoteItem> fillQuoteItemList(Quote currenctQuote) {
			List<QuoteItem> quoteItemList = new List<QuoteItem>();
			List<QuoteLineItem> quoteLineItemList = new List<QuoteLineItem>();
			Map<Id, List<QuoteLineItem>> parentProductIdToAccessoryItemListMap = new Map<Id, List<QuoteLineItem>>();

			Set<id> productIdSet = new Set<id>();
			Set<String> estruturaIdSet = new Set<String>();
			for (QuoteLineItem retrievedItem : currenctQuote.QuoteLineItems) {
				if (!String.isBlank(retrievedItem.ParentProduct__c)) {
					if (!parentProductIdToAccessoryItemListMap.containsKey(retrievedItem.ParentProduct__c)) {
						parentProductIdToAccessoryItemListMap.put(retrievedItem.ParentProduct__c, new List<QuoteLineItem>());
					}
					parentProductIdToAccessoryItemListMap.get(retrievedItem.ParentProduct__c).add(retrievedItem);
				}
				else {
					quoteLineItemList.add(retrievedItem);
				}
				productIdSet.add(retrievedItem.Product2Id);
				estruturaIdSet.add(retrievedItem.Product2.EstruturaProduto__c);
			}

		
			Map<String, Map<String, List<TiposRecurso__c>>> productIdToResourceListMap = getResources(estruturaIdSet);
			Map<Id, ContentVersion> itemToImageMap = getImages(productIdSet);
		
			for (QuoteLineItem retrievedItem : quoteLineItemList) {
				quoteItemList.add(
					new QuoteItem(
						retrievedItem,
						productIdToResourceListMap.containsKey(retrievedItem.Product2.EstruturaProduto__c) ? productIdToResourceListMap.get(retrievedItem.Product2.EstruturaProduto__c) : new Map<String, List<TiposRecurso__c>>(),
						itemToImageMap,
						parentProductIdToAccessoryItemListMap.get(retrievedItem.Product2Id)
					)
				);
			}

			return quoteItemList;
		}
	}
    public static String convertToBRL(Decimal num){
        List<String> args = new String[]{'0','number','###.###.##0,00'};
        String numConverted =  String.format(num.setScale(2).format(), args);

        if(numConverted.indexOf(',') == -1){
            numConverted += ',00';
        }
        else if (numConverted.indexOf(',') == numConverted.length() - 2){
            numConverted += '0';
        }
        
        return numConverted;
    } 

	public class QuoteItem {
		public String name {get; set;}
		public String nameWithoutCode {get; set;}
		public String unitPrice {get; set;}
		public Object image {get; set;}
		public String extension {get; set;}
		public Boolean hasExceptionKit {get; set;}
		public Boolean hasRequiredKit {get; set;}
		public Boolean hasOptionalKit {get; set;}
		public Boolean hasStructures {get; set;}

		public List<OptionalItem> optionalList {get; set;}
		public List<KitData> kitExceptionDataList {get; set;}
		public List<KitData> kitRequiredDataList {get; set;}
		public List<KitData> kitOpcionalDataList {get; set;}

		public Decimal kitExceptionDataSubTotal {get;set;}
		public Decimal kitRequiredDataSubTotal {get;set;}
		public Decimal kitOpcionalDataSubTotal {get;set;}

		public String kitExceptionDataTotal {get;set;}
		public String kitRequiredDataTotal {get;set;}
		public String kitOpcionalDataTotal {get;set;}

		public Decimal quantity {get;set;}
		public String totalPriceEquip {get;set;}
		public String acessoryValues {get;set;}
		public String discount {get;set;}
		public String totalPrice {get;set;}

		public QuoteItem(
			QuoteLineItem currentItem,
			Map<String, List<TiposRecurso__c>> productIdToResourceListMap,
			Map<Id, ContentVersion> productIdToImageMap,
			List<QuoteLineItem> accessoryItemList
		) {
			this.name = currentItem.Product2.ProductCode +'-'+currentItem.Product2.Name;
			this.nameWithoutCode = currentItem.Product2.Name;
			this.hasStructures = currentItem.Product2.EstruturaProduto__c != null;
			this.hasExceptionKit = false;
			this.hasRequiredKit = false;
			this.hasOptionalKit = false;

			if (productIdToImageMap.containsKey(currentItem.Product2Id)) {
				Blob imageData = (Blob)productIdToImageMap.get(currentItem.Product2Id).VersionData;

				this.image = EncodingUtil.base64Encode(imageData);
				this.extension = productIdToImageMap.get(currentItem.Product2Id).FileExtension;
			}

			this.optionalList = fillOptionals(currentItem, productIdToResourceListMap);

			this.kitExceptionDataList = new List<KitData>();
			this.kitRequiredDataList = new List<KitData>();
			this.kitOpcionalDataList = new List<KitData>();

			this.kitExceptionDataSubTotal = 0;
			this.kitRequiredDataSubTotal = 0;
			this.kitOpcionalDataSubTotal = 0;


			if (accessoryItemList != null && !accessoryItemList.isEmpty()) {
				for (QuoteLineItem accessoryItem : accessoryItemList) {
					if(accessoryItem.AcessoryGroup__r.Tipo__c == null){
						this.hasExceptionKit = true;
						this.kitExceptionDataList.add(new KitData(accessoryItem));
						this.kitExceptionDataSubTotal += accessoryItem.TotalPrice;
					}else if(accessoryItem.AcessoryGroup__r.Tipo__c == 'Opcional'){
						this.hasOptionalKit = true;
						this.kitOpcionalDataList.add(new KitData(accessoryItem));
						this.kitOpcionalDataSubTotal += accessoryItem.TotalPrice;
					}else{
						this.hasRequiredKit = true;
						this.kitRequiredDataList.add(new KitData(accessoryItem));
						this.kitRequiredDataSubTotal += accessoryItem.TotalPrice;
					}
				}
			}
			this.kitExceptionDataTotal =  convertToBRL(this.kitExceptionDataSubTotal);
			this.kitRequiredDataTotal =  convertToBRL(this.kitRequiredDataSubTotal);
			this.kitOpcionalDataTotal =  convertToBRL(this.kitOpcionalDataSubTotal);

			this.quantity = currentItem.Quantity;
			this.unitPrice =  convertToBRL(currentItem.UnitPrice);
			this.totalPriceEquip =  convertToBRL(currentItem.TotalPrice);
			this.acessoryValues =   convertToBRL(this.kitExceptionDataSubTotal + this.kitRequiredDataSubTotal + this.kitOpcionalDataSubTotal);
			this.totalPrice =  convertToBRL(currentItem.TotalPrice  + this.kitExceptionDataSubTotal + this.kitRequiredDataSubTotal + this.kitOpcionalDataSubTotal);
		}

		public List<OptionalItem> fillOptionals(QuoteLineItem currentItem, Map<String, List<TiposRecurso__c>> productIdToResourceListMap) {
			
			List<OptionalItem> optionaList = new List<OptionalItem>();
			String currentExternalid = currentItem.Product2.ExternalId__c != null && currentItem.Product2.EstruturaProduto__c != null ? currentItem.Product2.ExternalId__c.replace(currentItem.Product2.EstruturaProduto__r.CodigoInterno__c, '') : '';
			for(String seqs : productIdToResourceListMap.keySet()){
				for(TiposRecurso__c recs : productIdToResourceListMap.get(seqs)){
					if(recs.Sequencial__c == null){ 
						optionaList.add(new OptionalItem(recs)); 
						break;
					}

					if(currentExternalid.startsWith(recs.Sequencial__c)){
						optionaList.add(new OptionalItem(recs));
						currentExternalid = currentExternalid.right(currentExternalid.length() - recs.Sequencial__c.length());
						break;
					}
				}
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
		public String price {get; set;}
		public String subTotal {get; set;}

		public KitData(QuoteLineItem accessoryItem) {
			this.name = accessoryItem.Product2.ProductCode +'-'+accessoryItem.Product2.Name;
			this.quantity = accessoryItem.Quantity;
			this.price = ConvertToBRL(accessoryItem.unitPrice);
			this.subTotal = ConvertToBRL(accessoryItem.TotalPrice);
		}
	}
}