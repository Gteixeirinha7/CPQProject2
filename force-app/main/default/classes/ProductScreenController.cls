public with sharing class ProductScreenController {
	@AuraEnabled
	public static Map<Id, ProductData> getProducts(String quoteId, String structureId, String productCode) {
		Map<Id, ProductData> productDataMap = new Map<Id, ProductData>();
		Map<Id, Id> kitIdToProductIdMap = new Map<Id, Id>();
		String externalId = '%' + productCode + '%';

		if (String.isBlank(structureId)) {
			for (Product2 retrievedProduct : getProductListWithoutStructure(externalId)) {
				productDataMap.put(retrievedProduct.Id, new ProductData(retrievedProduct));

				if (retrievedProduct.KitAcessorios__c != null) {
					kitIdToProductIdMap.put(retrievedProduct.KitAcessorios__c, retrievedProduct.Id);
				}
			}
		}
		else {
			for (Product2 retrievedProduct : getProductListWithStructure(structureId, externalId)) {
				productDataMap.put(retrievedProduct.Id, new ProductData(retrievedProduct));

				if (retrievedProduct.KitAcessorios__c != null) {
					kitIdToProductIdMap.put(retrievedProduct.KitAcessorios__c, retrievedProduct.Id);
				}
			}
		}

		if (!productDataMap.isEmpty()) {
			fillProductImage(quoteId, productDataMap);

			if (!kitIdToProductIdMap.isEmpty()) {
				fillKitConfigData(kitIdToProductIdMap, productDataMap, quoteId);
			}
		}

		return productDataMap;
	}

	public static void fillProductImage(Id quoteId, Map<Id, ProductData> productDataMap) {
		Map<Id, ContentVersion> productIdToImageMap = getImages(productDataMap.keySet());
		Map<Id, PricebookEntry> productIdToPriceMap = getPrices(quoteId, productDataMap.keySet());

		for (Id productId : productDataMap.keySet()) {
			ProductData currentProduct = productDataMap.get(productId);

			if (productIdToImageMap.containsKey(productId)) {
				ContentVersion currentImage = productIdToImageMap.get(productId);
				String image = EncodingUtil.base64Encode((Blob)currentImage.VersionData);
				currentProduct.image = 'data:image/' + currentImage.FileExtension + ';base64,' + image;
			}
			if (productIdToPriceMap.containsKey(productId)) {
				PricebookEntry currentPrice = productIdToPriceMap.get(productId);
				currentProduct.listPrice = currentPrice.UnitPrice;
				currentProduct.price = currentPrice.UnitPrice;
				currentProduct.totalPrice = currentPrice.UnitPrice;
				currentProduct.isShowProduct = true;
			}
		}
	}

	public static void fillKitConfigData(Map<Id, Id> kitIdToProductIdMap, Map<Id, ProductData> productDataMap, String quoteId) {
		Map<String, List<GroupAccessoryData>> productIdToGroupAccessories = new Map<String, List<GroupAccessoryData>>();
		Map<Id, PricebookEntry> productIdToPriceMap = new Map<Id, PricebookEntry>();

		for (GrupoAcessorios__c retrievedGroup : getGroupAccessoriesByKitIdSet(kitIdToProductIdMap.keySet())) {
			String productId = kitIdToProductIdMap.get(retrievedGroup.KitAcessorios__c);

			if (!String.isBlank(productId)) {
				ProductData currentProduct = productDataMap.get(productId);

				if (currentProduct != null) {
					currentProduct.groupAccessoryList.add(new GroupAccessoryData(retrievedGroup));
				}
			}

			for (TipoAcessorios__c retrievedAccessory : retrievedGroup.TipoAcessorios__r) {
				productIdToPriceMap.put(retrievedAccessory.Produto__c, null);
			}
		}

		productIdToPriceMap = getPrices(quoteId, productIdToPriceMap.keySet());

		for (Id productId : productDataMap.keySet()) {
			ProductData currentProduct = productDataMap.get(productId);
			Integer counter = 1;

			for (GroupAccessoryData retrievedGroup : currentProduct.groupAccessoryList) {
				if (counter == 1) {
					retrievedGroup.isCurrentGroup = true;
					retrievedGroup.isShowGroup = true;
					retrievedGroup.isFirstGroup = true;
				}
				if (counter == currentProduct.groupAccessoryList.size()) {
					retrievedGroup.isLastGroup = true;
				}

				for (AccessoryData retrievedAccessory : retrievedGroup.accessoryList) {
					PricebookEntry currentPrice = productIdToPriceMap.get(retrievedAccessory.productId);

					if (currentPrice != null) {
						retrievedAccessory.unitPrice = currentPrice.UnitPrice;
					}
				}

				counter++;
			}
		}
	}

	public static List<Product2> getProductListWithoutStructure(String externalId) {
		return [
			SELECT Id,
				   Name,
				   ExternalId__c,
				   Image_URL__c,
				   KitAcessorios__c
			  FROM Product2
			 WHERE IsActive = true
			   AND ExternalId__c LIKE :externalId
			 LIMIT 10000
		];
	}

	public static List<Product2> getProductListWithStructure(String structureId, String externalId) {
		return [
			SELECT Id,
				   Name,
				   ExternalId__c,
				   Image_URL__c,
				   KitAcessorios__c
			  FROM Product2
			 WHERE IsActive = true
			   AND ExternalId__c LIKE :externalId
			   AND EstruturaProduto__c = :structureId
			 LIMIT 10000
		];
	}

	public static List<GrupoAcessorios__c> getGroupAccessoriesByKitIdSet(Set<Id> kitIdSet) {
		return [
			SELECT Id,
				   Name,
				   Tipo__c,
				   AcaoGrupo__c,
				   NumeroMinimoAcessorios__c,
				   KitAcessorios__c,
				   (
					SELECT Id,
						   Name,
						   GrupoAcessorio__c,
						   Produto__c,
						   Produto__r.Name
					  FROM TipoAcessorios__r
					 WHERE Ativo__c = true
				   )
			  FROM GrupoAcessorios__c
			 WHERE KitAcessorios__c IN :kitIdSet
			   AND KitAcessorios__r.Ativo__c = true
			   AND Ativo__c = true
			 ORDER BY OrdemExibicao__c
		];
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

		return itemToImageMap;
	}

	public static Map<Id, PricebookEntry> getPrices(String quoteId, Set<Id> product2IdSet) {
		Id pricebook2Id;
		Map<Id, PricebookEntry> productIdToPriceMap = new Map<Id, PricebookEntry>();

		for (Quote retrievedQuote : [SELECT Pricebook2Id FROM Quote WHERE Id = :quoteId]) {
			pricebook2Id = retrievedQuote.Pricebook2Id;
		}

		if (String.isBlank(pricebook2Id)) return new Map<Id, PricebookEntry>();

		for (PricebookEntry retrievedPrice : [
			SELECT Id,
				   UnitPrice,
				   Product2Id
			  FROM PricebookEntry
			 WHERE Pricebook2Id = :pricebook2Id
			   AND Product2Id IN :product2IdSet
		]) {
			productIdToPriceMap.put(retrievedPrice.Product2Id, retrievedPrice);
		}

		return productIdToPriceMap;
	}

	@AuraEnabled
	public static Map<Id, EstruturaProduto__c> getStructures() {
		return new Map<Id, EstruturaProduto__c>([
			SELECT Id,
				   Name,
				   Agrupador__c,
				   ImagemProduto__c
			  FROM EstruturaProduto__c
			 WHERE Ativo__c = true
			 LIMIT 10000
		]);
	}

	@AuraEnabled
	public static List<RecursosProduto__c> getResources(String structureId) {
		return [
			SELECT Id,
				   Name,
				   (
					SELECT Id,
						   Name,
						   DescricaoRecurso__c,
						   ExternalId__c
					  FROM ComposicaoProduto__r
					 WHERE Ativo__c = true
					 ORDER BY Sequencial__c
				   )
			  FROM RecursosProduto__c
			 WHERE EstruturaProduto__c = :structureId
			 ORDER BY Sequencial__c
			 LIMIT 10000
		];
	}

	@AuraEnabled
	public static List<String> checkNextTypeResources(String structureId, String currentExternalId, Integer index) {
		Set<String> nextExternalIdSet = new Set<String>();
		Integer stringIndex = index * 2;

		for (Product2 retrievedProduct : getProductList(structureId, currentExternalId)) {
			String externalId = retrievedProduct.ExternalId__c;

			if ((stringIndex + 2) >= externalId.length()) {
				nextExternalIdSet.add(externalId.substring(stringIndex, externalId.length()));
			}
			else {
				nextExternalIdSet.add(externalId.substring(stringIndex, stringIndex + 2));
			}
		}

		return new List<String>(nextExternalIdSet);
	}

	public static List<Product2> getProductList(String structureId, String currentExternalId) {
		String externalId = currentExternalId + '%';

		return [
			SELECT ExternalId__c
			  FROM Product2
			 WHERE EstruturaProduto__c = :structureId
			   AND ExternalId__c LIKE :externalId
		];
	}

	@AuraEnabled
	public static SaveResponse saveQuoteLineItems(String quoteId, List<ProductData> quoteItemList) {
		if (String.isBlank(quoteId)) return new SaveResponse('Cotação inválida');

		Savepoint currentSavepoint = Database.setSavepoint();

		try {
			List<QuoteLineItem> insertQuoteLineItemList = new List<QuoteLineItem>();
			List<QuoteLineItem> updateQuoteLineItemList = new List<QuoteLineItem>();
			Map<Id, QuoteLineItem> quoteLineItemMap = new Map<Id, QuoteLineItem>();
			Map<Id, PricebookEntry> productToPriceIdMap = getPricebookEntries(quoteId, quoteItemList);

			for (QuoteLineItem retrievedItem : [SELECT Id, Product2Id FROM QuoteLineItem WHERE QuoteId = :quoteId]) {
				quoteLineItemMap.put(retrievedItem.Product2Id, retrievedItem);
			}

			for (ProductData retrievedProductData : quoteItemList) {

				for (GroupAccessoryData retrievedGroup : retrievedProductData.groupAccessoryList) {

					if (retrievedGroup.isListing) {
						for (AccessoryData retrievedAccessory : retrievedGroup.accessoryList) {
							if (retrievedAccessory.isSelected) {

								PricebookEntry currentPrice = productToPriceIdMap.get(retrievedAccessory.productId);

								if (currentPrice == null) throw new CustomException('Acessorio ' + retrievedProductData.name + ' não tem preço!');

								if (quoteLineItemMap.containsKey(retrievedAccessory.productId)) {
									updateQuoteLineItemList.add(new QuoteLineItem(
										Id = quoteLineItemMap.get(retrievedAccessory.productId).Id,
										UnitPrice = retrievedAccessory.unitPrice,
										Quantity = retrievedAccessory.quantity,
										// DescontoAplicado__c = currentPrice.UnitPrice - retrievedAccessory.unitPrice,
										Discount = (1 - (retrievedAccessory.unitPrice / currentPrice.UnitPrice)) * 100,
										Product2Id = retrievedAccessory.productId,
										PricebookEntryId = currentPrice.Id,
										ParentProduct__c = retrievedProductData.id
									));

									quoteLineItemMap.remove(retrievedAccessory.productId);
								}
								else {
									insertQuoteLineItemList.add(new QuoteLineItem(
										QuoteId = quoteId,
										UnitPrice = retrievedAccessory.unitPrice,
										Quantity = retrievedAccessory.quantity,
										// DescontoAplicado__c = currentPrice.UnitPrice - retrievedAccessory.unitPrice,
										Discount = (1 - (retrievedAccessory.unitPrice / currentPrice.UnitPrice)) * 100,
										Product2Id = retrievedAccessory.productId,
										PricebookEntryId = currentPrice.Id,
										ParentProduct__c = retrievedProductData.id
									));
								}
							}
						}
					}
				}

				PricebookEntry currentPrice = productToPriceIdMap.get(retrievedProductData.id);

				if (currentPrice == null) throw new CustomException('Produto ' + retrievedProductData.name + ' não tem preço!!');

				if (quoteLineItemMap.containsKey(retrievedProductData.id)) {
					updateQuoteLineItemList.add(new QuoteLineItem(
						Id = quoteLineItemMap.get(retrievedProductData.id).Id,
						UnitPrice = retrievedProductData.price,
						Quantity = retrievedProductData.quantity,
						// DescontoAplicado__c = currentPrice.UnitPrice - retrievedProductData.price,
						Discount = (1 - (retrievedProductData.price / currentPrice.UnitPrice)) * 100,
						Product2Id = retrievedProductData.id,
						PricebookEntryId = currentPrice.Id
					));

					quoteLineItemMap.remove(retrievedProductData.id);
				}
				else {
					insertQuoteLineItemList.add(new QuoteLineItem(
						QuoteId = quoteId,
						UnitPrice = retrievedProductData.price,
						Quantity = retrievedProductData.quantity,
						// DescontoAplicado__c = currentPrice.UnitPrice - retrievedProductData.price,
						Discount = (1 - (retrievedProductData.price / currentPrice.UnitPrice)) * 100,
						Product2Id = retrievedProductData.id,
						PricebookEntryId = currentPrice.Id
					));
				}
			}

			// if (!quoteLineItemMap.isEmpty()) delete (quoteLineItemMap.values());
			if (!insertQuoteLineItemList.isEmpty()) insert insertQuoteLineItemList;
			if (!updateQuoteLineItemList.isEmpty()) update updateQuoteLineItemList;
		}
		catch (Exception ex) {
			System.debug('Save QuoteLineItems Exception => ' + ex.getMessage());
			System.debug('Stack Trace => ' + ex.getStackTraceString());
			Database.rollback(currentSavepoint);
			return new SaveResponse(ex);
		}

		return new SaveResponse();
	}

	public static Map<Id, PricebookEntry> getPricebookEntries(String quoteId, List<ProductData> quoteItemList) {
		Map<Id, PricebookEntry> productToPriceIdMap = new Map<Id, PricebookEntry>();
		Set<Id> product2IdSet = new Set<Id>();
		Id pricebook2Id;

		for (Quote retrievedQuote : [SELECT Id, Pricebook2Id FROM Quote WHERE Id = :quoteId LIMIT 1]) {
			pricebook2Id = retrievedQuote.Pricebook2Id;
		}

		for (ProductData retrievedItemData : quoteItemList) {
			product2IdSet.add(retrievedItemData.id);

			for (GroupAccessoryData retrievedGroup : retrievedItemData.groupAccessoryList) {
				if (retrievedGroup.isListing) {
					for (AccessoryData retrievedAccessory : retrievedGroup.accessoryList) {
						if (retrievedAccessory.isSelected) {
							product2IdSet.add(retrievedAccessory.productId);
						}
					}
				}
			}
		}

		for (PricebookEntry retrievedPrice : [
			SELECT Id,
				   UnitPrice,
				   Product2Id
			  FROM PricebookEntry
			 WHERE Product2Id IN :product2IdSet
			   AND Pricebook2Id = :pricebook2Id
		]) {
			productToPriceIdMap.put(retrievedPrice.Product2Id, retrievedPrice);
		}

		return productToPriceIdMap;
	}

	public class CustomException extends Exception {}

	public class SaveResponse {
		@AuraEnabled
		public Boolean hasError = false;
		@AuraEnabled
		public String errorMessage = '';
		@AuraEnabled
		public String exceptionMessage = '';

		public SaveResponse() {}
		public SaveResponse(String errorMessage) {
			this.hasError = true;
			this.errorMessage = errorMessage;
		}
		public SaveResponse(Exception ex) {
			this.hasError = true;
			this.errorMessage = ex.getMessage();
		}
	}

	public class ProductData {
		@AuraEnabled
		public String id {get; set;}
		@AuraEnabled
		public String name {get; set;}
		@AuraEnabled
		public Decimal quantity {get; set;}
		@AuraEnabled
		public Decimal totalPrice {get; set;}
		@AuraEnabled
		public Decimal listPrice {get; set;}
		@AuraEnabled
		public Decimal price {get; set;}
		@AuraEnabled
		public Decimal discountPercent {get; set;}
		@AuraEnabled
		public Decimal discountCurrency {get; set;}
		@AuraEnabled
		public String discountType {get; set;}
		@AuraEnabled
		public String productCode {get; set;}
		@AuraEnabled
		public String image {get; set;}
		@AuraEnabled
		public String extension {get; set;}

		@AuraEnabled
		public Boolean isSelected {get; set;}
		@AuraEnabled
		public Boolean isShowProduct {get; set;}
		@AuraEnabled
		public Boolean isDiscountPercent {get; set;}
		@AuraEnabled
		public Boolean isHasKit {get; set;}
		@AuraEnabled
		public Boolean isDisabledButtons {get; set;}
		@AuraEnabled
		public Boolean isConfigured {get; set;}

		@AuraEnabled
		public List<GroupAccessoryData> groupAccessoryList {get; set;}

		public ProductData() {}
		public ProductData(Product2 product) {
			this.id = product.Id;
			this.name = product.Name;
			this.quantity = 1;
			this.totalPrice = 0;
			this.listPrice = 0;
			this.price = 0;
			this.discountPercent = 0;
			this.discountCurrency = 0;
			this.discountType = 'currency';
			this.productCode = product.ExternalId__c;
			this.image = '';
			this.extension = '';

			this.isSelected = false;
			this.isShowProduct = false;
			this.isDiscountPercent = false;
			this.isHasKit = product.KitAcessorios__c <> null;
			this.isDisabledButtons = product.KitAcessorios__c <> null;
			this.isConfigured = false;

			this.groupAccessoryList = new List<GroupAccessoryData>();
		}
	}

	public class GroupAccessoryData {
		@AuraEnabled
		public String id {get; set;}
		@AuraEnabled
		public String name {get; set;}
		@AuraEnabled
		public Decimal minQuantity {get; set;}
		@AuraEnabled
		public String value {get; set;}
		@AuraEnabled
		public Boolean isRequired {get; set;}
		@AuraEnabled
		public Boolean isNA {get; set;}
		@AuraEnabled
		public Boolean isIncluded {get; set;}
		@AuraEnabled
		public Boolean isListing {get; set;}
		@AuraEnabled
		public Boolean isSelected {get; set;}
		@AuraEnabled
		public Boolean isShowGroup {get; set;}
		@AuraEnabled
		public Boolean isFirstGroup {get; set;}
		@AuraEnabled
		public Boolean isLastGroup {get; set;}
		@AuraEnabled
		public Boolean isCurrentGroup {get; set;}
		@AuraEnabled
		public Boolean isNotCurrentGroup {get; set;}
		@AuraEnabled
		public String kitId {get; set;}

		@AuraEnabled
		public List<AccessoryData> accessoryList {get; set;}

		public GroupAccessoryData() {}
		public GroupAccessoryData(GrupoAcessorios__c currentGroup) {
			this.id = currentGroup.Id;
			this.name = currentGroup.Name + ' (' + currentGroup.Tipo__c + ')';
			this.minQuantity = currentGroup.NumeroMinimoAcessorios__c > 1 ? currentGroup.NumeroMinimoAcessorios__c : 1;
			this.isRequired = currentGroup.Tipo__c == 'Obrigatório';
			this.isNA = currentGroup.AcaoGrupo__c == 'N/A';
			this.isIncluded = currentGroup.AcaoGrupo__c == 'Incluido';
			this.isListing = currentGroup.AcaoGrupo__c == 'Listar';
			this.isSelected = false;
			this.kitId = currentGroup.KitAcessorios__c;
			this.isShowGroup = false;
			this.isFirstGroup = false;
			this.isCurrentGroup = false;
			this.isNotCurrentGroup = false;
			this.isLastGroup = false;

			this.value = (
				this.isNA ? 'N/A' : (
					this.isIncluded ? 'Incluido' : ''
				)
			);

			this.accessoryList = new List<AccessoryData>();

			for (TipoAcessorios__c currentAccessory : currentGroup.TipoAcessorios__r) {
				this.accessoryList.add(new AccessoryData(currentAccessory));
			}
		}
	}

	public class AccessoryData {
		@AuraEnabled
		public String id {get; set;}
		@AuraEnabled
		public String name {get; set;}
		@AuraEnabled
		public String code {get; set;}
		@AuraEnabled
		public Decimal unitPrice {get; set;}
		@AuraEnabled
		public Decimal quantity {get; set;}
		@AuraEnabled
		public Decimal totalAmount {get; set;}
		@AuraEnabled
		public String productId {get; set;}
		@AuraEnabled
		public String groupId {get; set;}
		@AuraEnabled
		public Boolean isSelected {get; set;}
		@AuraEnabled
		public Boolean isDisabled {get; set;}

		public AccessoryData() {}
		public AccessoryData(TipoAcessorios__c currentAccessory) {
			this.id = currentAccessory.Id;
			this.name = currentAccessory.Produto__r.Name;
			this.code = currentAccessory.Name;
			this.quantity = 1;
			this.unitPrice = 0;
			this.totalAmount = 0;
			this.productId = currentAccessory.Produto__c;
			this.groupId = currentAccessory.GrupoAcessorio__c;

			this.isSelected = false;
			this.isDisabled = false;
		}
	}
}