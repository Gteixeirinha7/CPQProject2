public with sharing class ProductScreenController extends ProductScreenModel{
	public static String context {get;set;}

	//GetCheckoutData
	public static Map<String, Set<Id>> parentProductIdToKitProductIdAccessoryMap {get;set;}
	public static Map<String, Map<Id, ProductData>> parentProductIdToKitProductMap {get;set;}
	public static Map<String, List<ProductData>> parentProductIdToExceptionProductMap {get;set;}
	public static Map<Id, Set<Id>> kitIdToProductIdSetMap {get;set;}
	public static Set<Id> kitIdSet {get;set;}


	//CreateRecordData
	public static List<QuoteLineItem> insertQuoteLineItemList {get;set;}
	public static List<QuoteLineItem> updateQuoteLineItemList {get;set;}
	public static List<OpportunityLineItem> insertOpportunityLineItemList {get;set;}
	public static List<OpportunityLineItem> updateOpportunityLineItemList {get;set;}
	public static Map<String, Id> itemKeyToLineItemMap {get;set;}
	public static Map<Id, PricebookEntry> productToPriceIdMap {get;set;}

	public static void initCheckoutStaticVariable(String objId){
		parentProductIdToKitProductIdAccessoryMap = new Map<String, Set<Id>>();
		parentProductIdToKitProductMap = new Map<String, Map<Id, ProductData>>();
		parentProductIdToExceptionProductMap = new Map<String, List<ProductData>>();
		kitIdToProductIdSetMap = new Map<Id, Set<Id>>();
		kitIdSet = new Set<Id>();

		context = isOpp(objId) ? 'Opportunity' : 'Quote';
	}
	@AuraEnabled(cacheable=false)
	public static sObject getBaseObject(String objId) {
		context = isOpp(objId) ? 'Opportunity' : 'Quote';
		for (sObject retrievedObj : Database.query('SELECT Id, Name, AccountId, Account.Name, CreatedBy.Name, Pricebook2.Name, CurrencyIsoCode FROM '+context+' WHERE Id = :objId LIMIT 1')) {
			return retrievedObj;
		}
		return null;
	}
	@AuraEnabled(cacheable=false)
	public static Map<Id, ProductData> getCheckoutData(String objId) {
		if (String.isBlank(objId)) return new Map<Id, ProductData>();

		Map<Id, ProductData> checkoutProductMap = new Map<Id, ProductData>();

		try {
			initCheckoutStaticVariable(objId);

			if(isOpp(objId)){
				for (OpportunityLineItem retrievedItem : getOppLineItemsByOpportunityId(objId)) {
					getCheckoutData(new ProductData(retrievedItem), checkoutProductMap);
				}
			}else{
				for (QuoteLineItem retrievedItem : getQuoteLineItemsByQuoteId(objId)) {
					getCheckoutData(new ProductData(retrievedItem), checkoutProductMap);
				}
			}

			if (!checkoutProductMap.isEmpty()) {
				fillProductImage(objId, checkoutProductMap);
				fillKitConfigData(kitIdSet, kitIdToProductIdSetMap, checkoutProductMap, objId);

				for (String productId : parentProductIdToExceptionProductMap.keySet()) {
					ProductData parentProductData = checkoutProductMap.get(productId);

					if (parentProductData != null) {
						parentProductData.hasExceptionAccessory = true;
						parentProductData.exceptionAccessoryList = parentProductIdToExceptionProductMap.get(productId);
					}
				}

				for (String productId : parentProductIdToKitProductMap.keySet()) {
					Map<Id, ProductData> childProductDataMap = parentProductIdToKitProductMap.get(productId);
					Set<Id> accessoryProductIdSet = parentProductIdToKitProductIdAccessoryMap.get(productId);
					ProductData parentProductData = checkoutProductMap.get(productId);

					if (parentProductData != null) {
						parentProductData.isConfigured = true;
						parentProductData.isDisabledButtons = false;

						for (GroupAccessoryData retrievedGroup : parentProductData.groupAccessoryList) {
							if (retrievedGroup.isListing) {
								for (AccessoryData retrievedAccessory : retrievedGroup.accessoryList) {
									ProductData accessoryProductData = childProductDataMap.get(retrievedAccessory.productId);

									if (accessoryProductData != null) {
										retrievedGroup.isSelected = true;
										retrievedAccessory.isSelected = true;
										retrievedAccessory.quantity = accessoryProductData.quantity;
										retrievedAccessory.price = accessoryProductData.price;
										retrievedAccessory.changedQuantity = accessoryProductData.quantity;
										retrievedAccessory.totalAmount = (retrievedAccessory.price * retrievedAccessory.quantity).setScale(2);

										accessoryProductIdSet.remove(retrievedAccessory.productId);
									}
								}
							}
						}

						for (Id exceptionProductId : accessoryProductIdSet) {
							ProductData exceptionProductData = childProductDataMap.get(exceptionProductId);

							if (exceptionProductData != null) {
								parentProductData.hasExceptionAccessory = true;
								parentProductData.exceptionAccessoryList.add(exceptionProductData);
							}
						}
					}
				}
			}
		}
		catch (Exception ex) {
			System.debug('Exception Get Checkout Data => ' + ex.getMessage());
			System.debug('Stack Trace => ' + ex.getStackTraceString());
		}

		System.debug('checkoutProductMap Done => ' + checkoutProductMap);
		return checkoutProductMap;
	}
	public static void getCheckoutData(ProductData retrievedItem, Map<Id, ProductData> checkoutProductMap) {
		if (!String.isBlank(retrievedItem.Product2KitAcessoriosId)) {
			kitIdSet.add(retrievedItem.Product2KitAcessoriosId);
			if (!kitIdToProductIdSetMap.containsKey(retrievedItem.Product2KitAcessoriosId)) {
				kitIdToProductIdSetMap.put(retrievedItem.Product2KitAcessoriosId, new Set<Id>());
			}
			kitIdToProductIdSetMap.get(retrievedItem.Product2KitAcessoriosId).add(retrievedItem.Product2Id);
		}
		if (String.isBlank(retrievedItem.ParentProduct)) {
			checkoutProductMap.put(retrievedItem.Product2Id, retrievedItem);
		} else {
			if (String.isBlank(retrievedItem.ParentProductKitAcessoriosId)) {
				if (!parentProductIdToExceptionProductMap.containsKey(retrievedItem.ParentProduct)) {
					parentProductIdToExceptionProductMap.put(
						retrievedItem.ParentProduct,
						new List<ProductData>()
					);
				}
				parentProductIdToExceptionProductMap.get(retrievedItem.ParentProduct).add(retrievedItem);
			}
			else {
				if (!parentProductIdToKitProductMap.containsKey(retrievedItem.ParentProduct)) {
					parentProductIdToKitProductMap.put(
						retrievedItem.ParentProduct,
						new Map<Id, ProductData>()
					);
				}
				parentProductIdToKitProductMap.get(retrievedItem.ParentProduct).put(retrievedItem.Product2Id, retrievedItem);
				if (!parentProductIdToKitProductIdAccessoryMap.containsKey(retrievedItem.ParentProduct)) {
					parentProductIdToKitProductIdAccessoryMap.put(
						retrievedItem.ParentProduct,
						new Set<Id>()
					);
				}
				parentProductIdToKitProductIdAccessoryMap.get(retrievedItem.ParentProduct).add(retrievedItem.Product2Id);
			}
		}
	}
    @AuraEnabled(cacheable=false)
	public static Map<Id, ProductData> getProducts(String objId, String structureId, String productCode, List<String> currentStackTraceCode, Integer quantity) {
		Map<Id, ProductData> productDataMap = new Map<Id, ProductData>();
		Map<Id, Set<Id>> kitIdToProductIdSetMap = new Map<Id, Set<Id>>();
		List<Product2> productList = new List<Product2>();
		Set<Id> kitIdSet = new Set<Id>();
		String externalId = '%' + (String.isBlank(productCode) ? '' : productCode) + '%' ;
		Map<String, String> masterValuesMap = getMasterValues(objId);

		for (Product2 retrievedProduct : getProductsByTerms(masterValuesMap.get('Pricebook2Id'), masterValuesMap.get('CurrencyIsoCode'), externalId, currentStackTraceCode, quantity, structureId)) {
			productDataMap.put(retrievedProduct.Id, new ProductData(retrievedProduct));

			if (retrievedProduct.KitAcessorios__c != null) {
				if (!kitIdToProductIdSetMap.containsKey(retrievedProduct.KitAcessorios__c)) {
					kitIdToProductIdSetMap.put(retrievedProduct.KitAcessorios__c, new Set<Id>());
				}
				kitIdToProductIdSetMap.get(retrievedProduct.KitAcessorios__c).add(retrievedProduct.Id);

				kitIdSet.add(retrievedProduct.KitAcessorios__c);
			}
		}

		if (!productDataMap.isEmpty()) {
			fillProductImage(objId, productDataMap);

			if (!kitIdToProductIdSetMap.isEmpty()) {
				fillKitConfigData(kitIdSet, kitIdToProductIdSetMap, productDataMap, objId);
			}
		}

		return productDataMap;
	}

	public static void fillProductImage(Id objId, Map<Id, ProductData> productDataMap) {
		Map<Id, ContentVersion> productIdToImageMap = getImages(productDataMap.keySet());
		Map<Id, PricebookEntry> productIdToPriceMap = getPrices(objId, productDataMap.keySet());

		for (Id productId : productDataMap.keySet()) {
			ProductData currentProduct = productDataMap.get(productId);

			// if (productIdToImageMap.containsKey(productId)) {
			// 	ContentVersion currentImage = productIdToImageMap.get(productId);
			// 	String image = EncodingUtil.base64Encode((Blob)currentImage.VersionData);
			// 	currentProduct.image = 'data:image/' + currentImage.FileExtension + ';base64,' + image;
			// }
			if (productIdToPriceMap.containsKey(productId)) {
				PricebookEntry currentPrice = productIdToPriceMap.get(productId);
				currentProduct.listPrice = currentPrice.UnitPrice;
				currentProduct.price = currentProduct.price == 0 ? currentPrice.UnitPrice : currentProduct.price;
				currentProduct.totalPrice = currentProduct.price * currentProduct.quantity;
				currentProduct.discountCurrency = (currentProduct.listPrice - currentProduct.price).setScale(2);
				currentProduct.discountPercent = ((currentProduct.discountCurrency / currentProduct.listPrice) * 100).setScale(2);
				currentProduct.isShowProduct = true;
			}
		}
	}

	public static void fillKitConfigData(Set<Id> kitIdSet, Map<Id, Set<Id>> kitIdToProductIdSetMap, Map<Id, ProductData> productDataMap, String objId) {
		Map<String, List<GroupAccessoryData>> productIdToGroupAccessories = new Map<String, List<GroupAccessoryData>>();
		Map<Id, PricebookEntry> productIdToPriceMap = new Map<Id, PricebookEntry>();
		Map<Id, TipoAcessorios__c[]> comboMap = getpAccessoriesByComboKitIdSet(kitIdSet);

		for (GrupoAcessorios__c retrievedGroup : getGroupAccessoriesByKitIdSet(kitIdSet)) {
			Set<Id> productIdSet = kitIdToProductIdSetMap.get(retrievedGroup.KitAcessorios__c);

			for (Id productId : productIdSet) {
				ProductData currentProduct = productDataMap.get(productId);

				if (currentProduct != null) {
					currentProduct.groupAccessoryList.add(new GroupAccessoryData(retrievedGroup, comboMap));
				}

				for (TipoAcessorios__c retrievedAccessory : retrievedGroup.TipoAcessorios__r) {
					productIdToPriceMap.put(retrievedAccessory.Produto__c, null);
				}
			}
		}

		productIdToPriceMap = getPrices(objId, productIdToPriceMap.keySet());

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
						retrievedAccessory.price = currentPrice.UnitPrice;
						retrievedAccessory.listPrice = currentPrice.UnitPrice;
					}
				}

				counter++;
			}
		}
	}

	@AuraEnabled(cacheable=false)
	public static List<String> checkNextTypeResources(String structureId, Integer index, List<String> currentStackTraceCode) {

		Map<String, List<String>> prodIdMap = new Map<String, List<String>>();
		for(TipoRecursoProduto__c record : [SELECT id, TipoRecurso__c, TipoRecurso__r.RecursoProduto__c, Produto__c
											FROM TipoRecursoProduto__c
											WHERE Produto__r.EstruturaProduto__c = :structureId
											AND TipoRecurso__c IN :currentStackTraceCode
											AND TipoRecurso__r.Ativo__c = true
											AND Produto__r.IsActive = true
											ORDER BY Produto__c DESC, TipoRecurso__r.Sequencial__c DESC]){
			if(!prodIdMap.containsKey(record.Produto__c))
				prodIdMap.put(record.Produto__c, new List<String>());
			prodIdMap.get(record.Produto__c).add(record.TipoRecurso__c);
		}

		Set<String> prodIdSet = new Set<String>();
		for(String prodId : prodIdMap.keySet()){
			if(prodIdMap.get(prodId).size() == currentStackTraceCode.size()){
				prodIdSet.add(prodId);
			}
		}

		List<String> typeIdSet = new List<String>();
		for(TipoRecursoProduto__c record : [SELECT id, TipoRecurso__c, TipoRecurso__r.RecursoProduto__c
											FROM TipoRecursoProduto__c
											WHERE Produto__r.EstruturaProduto__c = :structureId
											AND Produto__c IN :prodIdSet
											AND Sequencial__c = :index
											AND TipoRecurso__r.Ativo__c = true
											AND Produto__r.IsActive = true]){
			typeIdSet.add(record.TipoRecurso__c);
		}
		return typeIdSet;
	}

	// @AuraEnabled
	// public static List<String> checkNextTypeResources(String structureId, String currentExternalId, Integer index) {
	// 	Set<String> nextExternalIdSet = new Set<String>();
	// 	Integer stringIndex = index * 2;

	// 	for (Product2 retrievedProduct : getProductList(structureId, currentExternalId)) {
	// 		// String externalId = retrievedProduct.ExternalId__c;

	// 		// if ((stringIndex + 2) >= externalId.length()) {
	// 		// 	nextExternalIdSet.add(externalId.substring(stringIndex, externalId.length()));
	// 		// }
	// 		// else {
	// 		// 	nextExternalIdSet.add(externalId.substring(stringIndex, stringIndex + 2));
	// 		// }
	// 		nextExternalIdSet.add(retrievedProduct.ExternalId__c.replace(currentExternalId, ''));
	// 	}

	// 	return new List<String>(nextExternalIdSet);
	// }


	public static void initSaveLineItemsVars(String objId, List<ProductData> lineItemList){
		insertQuoteLineItemList = new List<QuoteLineItem>();
		updateQuoteLineItemList = new List<QuoteLineItem>();
		insertOpportunityLineItemList = new List<OpportunityLineItem>();
		updateOpportunityLineItemList = new List<OpportunityLineItem>();

		context = isOpp(objId) ? 'Opportunity' : 'Quote';

		getCurrentLineItems(objId);
		getPricebookEntries(objId, lineItemList);
	}


	@AuraEnabled(cacheable=false)
	public static SaveResponse saveLineItems(String objId, List<ProductData> lineItemList) {
		if (String.isBlank(objId)) return new SaveResponse('Registro inválido. Entrar em contato com Administrador do Sistema');

		Savepoint currentSavepoint = Database.setSavepoint();

		try {
			System.debug(lineItemList);
			initSaveLineItemsVars(objId, lineItemList);

			for (ProductData retrievedProductData : lineItemList) {

				for (GroupAccessoryData retrievedGroup : retrievedProductData.groupAccessoryList) {
					if (!retrievedGroup.isListing) continue;

					for (AccessoryData retrievedAccessory : retrievedGroup.accessoryList) {
						if (!retrievedAccessory.isSelected) continue;

						handleAcessoryDataDML(retrievedAccessory, retrievedProductData.productId, objId);
					}
				}

				for (ProductData retrievedAccessoryData : retrievedProductData.exceptionAccessoryList) {
					handleProductDataDML(retrievedAccessoryData, retrievedProductData.productId, objId);
				}
				handleProductDataDML(retrievedProductData, null, objId);
			}
			System.debug(insertQuoteLineItemList);
			System.debug(updateQuoteLineItemList);
			System.debug(itemKeyToLineItemMap);

			saveLineItemsDML();

		}
		catch (Exception ex) {
			System.debug('Save LineItems Exception => ' + ex.getMessage());
			System.debug('Stack Trace => ' + ex.getStackTraceString());
			Database.rollback(currentSavepoint);
			return new SaveResponse(ex);
		}

		return new SaveResponse();
	}
	public static void  saveLineItemsDML() {
		QuoteTriggerHandler.disableTrigger();
		QuoteLineItemHandler.disableTrigger();
		if (!itemKeyToLineItemMap.isEmpty()) getDeleteLineItem(itemKeyToLineItemMap.values());
		if (!insertQuoteLineItemList.isEmpty()) insert insertQuoteLineItemList;
		if (!updateQuoteLineItemList.isEmpty()) update updateQuoteLineItemList;
		if (!insertOpportunityLineItemList.isEmpty()) insert insertOpportunityLineItemList;
		if (!updateOpportunityLineItemList.isEmpty()) update updateOpportunityLineItemList;
	}

	public static void getDeleteLineItem(List<Id> deleteIdList){
		List<sObject> sobjList = new List<sObject>();
		for(Id objId : deleteIdList){
			sobjList.add(objId.getsObjectType().newsObject(objId));
		}
		delete sobjList;
	}
	public static void handleAcessoryDataDML(AccessoryData retrievedProductData, String parentId, String objId){
		PricebookEntry currentPrice = productToPriceIdMap.get(retrievedProductData.productId);
		String key = retrievedProductData.productId + '-'+String.valueOf(parentId);

		if (currentPrice == null) throw new CustomException('Produto ' + retrievedProductData.name + ' não tem preço!!');

		if(context == 'Opportunity'){
			OpportunityLineItem oppLine = retrievedProductData.getOpportunityLineItem(currentPrice, objId);
			oppLine.ParentProduct__c = parentId;
			oppLine.AcessoryGroup__c = retrievedProductData.GroupId;
			oppLine.AcessoryType__c = retrievedProductData.Id;

			System.debug(key);
			if (itemKeyToLineItemMap.containsKey(key)) {
				oppLine.Id = itemKeyToLineItemMap.get(key);

				updateOpportunityLineItemList.add(oppLine);
				itemKeyToLineItemMap.remove(key);
			} else {
				insertOpportunityLineItemList.add(oppLine);
			}
		}else{
			QuoteLineItem quoteLine = retrievedProductData.getQuoteLineItem(currentPrice, objId);
			quoteLine.ParentProduct__c = parentId;
			quoteLine.AcessoryGroup__c = retrievedProductData.GroupId;
			quoteLine.AcessoryType__c = retrievedProductData.Id;

			System.debug(key);
			if (itemKeyToLineItemMap.containsKey(key)) {
				quoteLine.Id = itemKeyToLineItemMap.get(key);

				updateQuoteLineItemList.add(quoteLine);
				itemKeyToLineItemMap.remove(key);
			} else {
				insertQuoteLineItemList.add(quoteLine);
			}
		}
	}
	public static void handleProductDataDML(ProductData retrievedProductData, String parentId, String objId){
		PricebookEntry currentPrice = productToPriceIdMap.get(retrievedProductData.productId);
		String key = retrievedProductData.productId + '-'+String.valueOf(parentId);

		if (currentPrice == null) throw new CustomException('Produto ' + retrievedProductData.name + ' não tem preço!!');

		if(context == 'Opportunity'){
			OpportunityLineItem oppLine = retrievedProductData.getOpportunityLineItem(currentPrice, objId);
			oppLine.ParentProduct__c = parentId;

			System.debug(key);
			if (itemKeyToLineItemMap.containsKey(key)) {
				oppLine.Id = itemKeyToLineItemMap.get(key);

				updateOpportunityLineItemList.add(oppLine);
				itemKeyToLineItemMap.remove(key);
			} else {
				insertOpportunityLineItemList.add(oppLine);
			}
		}else{
			QuoteLineItem quoteLine = retrievedProductData.getQuoteLineItem(currentPrice, objId);
			quoteLine.ParentProduct__c = parentId;

			System.debug(key);
			if (itemKeyToLineItemMap.containsKey(key)) {
				quoteLine.Id = itemKeyToLineItemMap.get(key);

				updateQuoteLineItemList.add(quoteLine);
				itemKeyToLineItemMap.remove(key);
			} else {
				insertQuoteLineItemList.add(quoteLine);
			}
		}
	}

	public static void getCurrentLineItems(String objId){
		itemKeyToLineItemMap = new Map<String, Id>();
		for (sObject retrievedItem : Database.query('SELECT Id, Product2Id, ParentProduct__c FROM '+context+'LineItem WHERE '+context+'Id = :objId')) {
			itemKeyToLineItemMap.put((String)retrievedItem.get('Product2Id') + '-' + (String)retrievedItem.get('ParentProduct__c'), (Id)retrievedItem.get('Id'));
		}
	}

	public static void getPricebookEntries(String objId, List<ProductData> quoteItemList) {
		Set<Id> product2IdSet = new Set<Id>();
		for (ProductData retrievedItemData : quoteItemList) {
			product2IdSet.add(retrievedItemData.productId);

			for (GroupAccessoryData retrievedGroup : retrievedItemData.groupAccessoryList) {
				if (!retrievedGroup.isListing) continue;

				for (AccessoryData retrievedAccessory : retrievedGroup.accessoryList) {
					if (!retrievedAccessory.isSelected) continue;

					product2IdSet.add(retrievedAccessory.productId);
				}
			}

			for (ProductData retrievedAccessoryData : retrievedItemData.exceptionAccessoryList) {
				product2IdSet.add(retrievedAccessoryData.productId);
			}
		}
		productToPriceIdMap = getPrices(objId, product2IdSet);
	}

	public static Map<String, String> getMasterValues(Id objId){
		context = isOpp(objId) ? 'Opportunity' : 'Quote';
		Map<String, String> masterValuesMap = new Map<String, String>();
		for (sObject retrievedObj : Database.query('SELECT Id, Pricebook2Id, CurrencyIsoCode FROM '+context+' WHERE Id = :objId LIMIT 1')) {
			masterValuesMap.put('Pricebook2Id',    (String)retrievedObj.get('Pricebook2Id'));
			masterValuesMap.put('CurrencyIsoCode', (String)retrievedObj.get('CurrencyIsoCode'));
		}
		return masterValuesMap;
	}

	public static Boolean isOpp(Id objId){
		return checkObjectContext(objId, Schema.Opportunity.getSObjectType());
	}
	public static Boolean isQuote(Id objId){
		return checkObjectContext(objId, Schema.Quote.getSObjectType());
	}
	public static Boolean checkObjectContext(Id objId, Schema.SObjectType obj){
		return objId.getSobjectType() == obj;
	}


    @AuraEnabled(cacheable=false)
    public static List<SObject> getRecords(String objectApiName, String fieldApiName, String fieldApiNames, String filter, String searchTerm, String recordId, Boolean byFocus) {
        if(recordId == null) {
            recordId = '';
        } else if (filter == null) {
            filter = '';
        }

        if((recordId != null && recordId != '') && (filter.contains('replace'))) {
            filter = filter.replace('replace', recordId);
            System.debug('filter: '+ filter);
        }

        if(byFocus) {
            String query = 'SELECT Id, ' + fieldApiNames +
                            ' FROM '    + objectApiName +
                            ' WHERE ';
                List<String> fieldList = fieldApiName.split(';');
                List<String> conditions = new List<String>();
                for (String field : fieldList) {
                    conditions.add(' ' + field + ' LIKE \'%' + searchTerm + '%\'');
                }
                query += '(' + String.join(conditions, ' OR ') + ')';
                query += filter + ' LIMIT 10';

                List<SObject> recordsList =
                Database.query(query);

                return recordsList;
        } else {
            if(String.isNotBlank(searchTerm)) {
                String query = 'SELECT Id, ' + fieldApiNames +
                                ' FROM '    + objectApiName +
                                ' WHERE ';
                List<String> fieldList = fieldApiName.split(';');
                List<String> conditions = new List<String>();
                for (String field : fieldList) {
                    conditions.add(' ' + field + ' LIKE \'%' + searchTerm + '%\'');
                }
                query += '(' + String.join(conditions, ' OR ') + ')';
                query += filter + ' LIMIT 10';

                List<SObject> recordsList =
                Database.query(query);

                return recordsList;
            }
            else {
                return NULL;
            }
        }
    }

	@AuraEnabled(cacheable=false)
	public static Map<Id, EstruturaProduto__c> getStructures() {
		return new Map<Id, EstruturaProduto__c>([
			SELECT Id,
				   Name,
				   Agrupador__c,
				   ImagemProduto__c,
				   CodigoInterno__c
			  FROM EstruturaProduto__c
			 WHERE Ativo__c = true
			 LIMIT 10000
		]);
	}

	@AuraEnabled(cacheable=false)
	public static List<RecursosProduto__c> getResources(String structureId) {
		Set<Id> typeIdSet = new Set<Id>();
		Set<Id> resourceIdSet = new Set<Id>();
		for(TipoRecursoProduto__c record : [SELECT id, TipoRecurso__c, TipoRecurso__r.RecursoProduto__c
											FROM TipoRecursoProduto__c
											WHERE Produto__r.EstruturaProduto__c = :structureId
											AND  TipoRecurso__r.Ativo__c = true
											AND Produto__r.IsActive = true]){
			typeIdSet.add(record.TipoRecurso__c);
			resourceIdSet.add(record.TipoRecurso__r.RecursoProduto__c);
		}
		return [
			SELECT Id,
				   Name,
				   EstruturaProduto__r.CodigoInterno__c,
				   (
					SELECT Id,
						   Name,
						   DescricaoRecurso__c,
						   RecursoProduto__r.Name,
						   Sequencial__c
					  FROM ComposicaoProduto__r
					 WHERE Id IN :typeIdSet
				   )
			  FROM RecursosProduto__c
			 WHERE EstruturaProduto__c = :structureId
			 AND Id IN: resourceIdSet
			 ORDER BY Sequencial__c
			 LIMIT 10000
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

	public static Map<Id, PricebookEntry> getPrices(String objId, Set<Id> product2IdSet) {
		Map<Id, PricebookEntry> productIdToPriceMap = new Map<Id, PricebookEntry>();

		Map<String, String> masterValuesMap = getMasterValues(objId);
		String currencyIsoCode = masterValuesMap.get('CurrencyIsoCode') != null ? masterValuesMap.get('CurrencyIsoCode') : 'BRL';
		String pricebook2Id = masterValuesMap.get('Pricebook2Id');

		if (String.isBlank(pricebook2Id)) return new Map<Id, PricebookEntry>();

		for (PricebookEntry retrievedPrice : [
			SELECT Id,
				   UnitPrice,
				   Product2Id
			  FROM PricebookEntry
			 WHERE Pricebook2Id = :pricebook2Id
			   AND Product2Id IN :product2IdSet
			   AND UnitPrice != 0
			   AND CurrencyIsoCode = :currencyIsoCode
		]) {
			productIdToPriceMap.put(retrievedPrice.Product2Id, retrievedPrice);
		}

		return productIdToPriceMap;
	}

	public static List<Product2> getProductsByTerms(String pricebookId, String currencyCode, String searchValue, List<String> currentStackTraceCode, Integer quantity, String structureId) {
		Set<Id> productIdSet = new Set<Id>();

		if (quantity >= 2000) quantity = 2000;

		Map<String, List<String>> prodIdMap = new Map<String, List<String>>();
		for(TipoRecursoProduto__c record : [SELECT id, TipoRecurso__c, TipoRecurso__r.RecursoProduto__c, Produto__c
											FROM TipoRecursoProduto__c
											WHERE Produto__r.EstruturaProduto__c = :structureId
											AND TipoRecurso__c IN :currentStackTraceCode
											AND TipoRecurso__r.Ativo__c = true
											AND Produto__r.IsActive = true
											ORDER BY Produto__c DESC, TipoRecurso__r.Sequencial__c DESC]){
			if(!prodIdMap.containsKey(record.Produto__c))
				prodIdMap.put(record.Produto__c, new List<String>());
			prodIdMap.get(record.Produto__c).add(record.TipoRecurso__c);
		}

		Set<String> prodIdSet = new Set<String>();
		for(String prodId : prodIdMap.keySet()){
			if(prodIdMap.get(prodId).size() == currentStackTraceCode.size()){
				prodIdSet.add(prodId);
			}
		}

		System.debug(prodIdSet);
		for (PricebookEntry retrievedEntry : [
			SELECT Product2Id
			  FROM PricebookEntry
			 WHERE Pricebook2Id = :pricebookId
			   AND IsActive = true
			   AND CurrencyIsoCode = :currencyCode
			   AND UnitPrice != 0
			   AND Product2Id IN :prodIdSet
			   AND (
					Product2.Name LIKE :searchValue
				    OR Product2.ProductCode LIKE :searchValue
				    OR Product2.ExternalId__c LIKE :searchValue
				)
			 ORDER BY ID DESC LIMIT 10000
		]) {
			productIdSet.add(retrievedEntry.Product2Id);
		}
		System.debug(productIdSet.size());
		System.debug(productIdSet);

		String q = 'SELECT Id, Name, ExternalId__c, ProductCode, Imagem_URL__c, KitAcessorios__c, EstruturaProduto__c FROM Product2 WHERE IsActive = true ';

		if(structureId == 'Pronta'){
			q += ' AND EstruturaProduto__c != null ';
		}else if(structureId == 'Excecao' || structureId == 'SingleProduct' || structureId == 'Estrutura' || structureId == 'Carrinho'){
			q += ' AND EstruturaProduto__c = null ';
		}else if(structureId != null){
			q += ' AND Id IN :productIdSet AND EstruturaProduto__c = :structureId ';
		}
		q += ' AND (Product2.Name LIKE :searchValue OR Product2.ProductCode LIKE :searchValue OR Product2.ExternalId__c LIKE :searchValue) ';
		q += ' ORDER BY Name';
		q += ' LIMIT :quantity';

		return Database.query(q);
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
						   AcessorioPadrao__c,
						   QuantidadeSugerida__c,
						   Produto__c,
						   Produto__r.Name,
						   Produto__r.ProductCode,
						   Produto__r.ExternalId__c
					  FROM TipoAcessorios__r
					 WHERE Ativo__c = true
				   ),
				   (
					SELECT Id,
						   Name,
						   GrupoAcessorio__c
					  FROM Combos__r
				   )
			  FROM GrupoAcessorios__c
			 WHERE KitAcessorios__c IN :kitIdSet
			   AND KitAcessorios__r.Ativo__c = true
			   AND Ativo__c = true
			 ORDER BY OrdemExibicao__c
		];
	}
	public static Map<Id, TipoAcessorios__c[]> getpAccessoriesByComboKitIdSet(Set<Id> kitIdSet) {
		Map<Id, TipoAcessorios__c[]> accessoryComboMap = new Map<Id, TipoAcessorios__c[]>();
		for(TipoAcessorios__c types : [SELECT Id, Name, ComboAcessorios__c,GrupoAcessorio__c, AcessorioPadrao__c, QuantidadeSugerida__c, Produto__c, Produto__r.Name, Produto__r.ProductCode, Produto__r.ExternalId__c 
										FROM TipoAcessorios__c 
										WHERE ComboAcessorios__r.GrupoAcessorio__r.KitAcessorios__c IN : kitIdSet]){
			if(!accessoryComboMap.containsKey(types.ComboAcessorios__c)){
				accessoryComboMap.put(types.ComboAcessorios__c, new List<TipoAcessorios__c>());
			}
			accessoryComboMap.get(types.ComboAcessorios__c).add(types);
		}
		return accessoryComboMap;
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

	public static List<OpportunityLineItem> getOppLineItemsByOpportunityId(String oppId) {
		return [
			SELECT Id,
				   Quantity,
				   UnitPrice,
				   ParentProduct__c,
				   ParentProduct__r.KitAcessorios__c,
				   Product2.Imagem_URL__c,
				   Product2Id,
				   Product2.Name,
				   Product2.ExternalId__c,
				   Product2.ProductCode,
				   Product2.KitAcessorios__c,
				   ProdutoSemEstrutura__c
			  FROM OpportunityLineItem
			 WHERE OpportunityId = :oppId
		];
	}

	public static List<QuoteLineItem> getQuoteLineItemsByQuoteId(String quoteId) {
		return [
			SELECT Id,
				   Quantity,
				   ListPrice,
				   Discount,
				   UnitPrice,
				   ParentProduct__c,
				   ParentProduct__r.KitAcessorios__c,
				   Product2.Imagem_URL__c,
				   Product2Id,
				   Product2.Name,
				   Product2.ExternalId__c,
				   Product2.ProductCode,
				   Product2.KitAcessorios__c,
				   ProdutoSemEstrutura__c
			  FROM QuoteLineItem
			 WHERE QuoteId = :quoteId
		];
	}
}
