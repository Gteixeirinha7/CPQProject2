public class CreateStructureResourcesController {

    public String booking {get;set;}

    public CreateStructureResourcesController() 	{}
	@RemoteAction
	public static ProductListData getCurrentRecordsSteris(List<ProductResourceData> excelDataList){
		Set<String> structureSet = new Set<String>();
		Set<String> productSet = new Set<String>();
		Set<String> internalSet = new Set<String>();

		for(ProductResourceData record: excelDataList){
			structureSet.add(record.structureName);
			productSet.add(record.productCode);
			internalSet.add(record.internalKey);
		}

        List<String> structureList = new List<String>();
        for(EstruturaProduto__c record : [SELECT Name FROM EstruturaProduto__c WHERE Ativo__c = true AND NAME IN :structureSet]){
            structureList.add(record.Name);
        }

        
        List<String> productList = new List<String>();
        for(Product2 record : [SELECT ProductCodeExternalId__c FROM Product2 WHERE isActive = true AND ProductCodeExternalId__c != null AND ProductCodeExternalId__c IN :productSet]){
            productList.add(record.ProductCodeExternalId__c);
        }

        
        List<String> internalList = new List<String>();
        for(TiposRecurso__c record : [SELECT ExternalId__c FROM TiposRecurso__c WHERE Ativo__c = true AND ExternalId__c IN :internalSet]){
            internalList.add(record.ExternalId__c.replaceAll('[^a-zA-Z0-9]', ''));
        }
		return new ProductListData(structureList, productList, internalList);
	}

	@RemoteAction
	public static String createRecords(String entryList){
		List<ProductResourceData> excelDataList = (List<ProductResourceData>)JSON.deserialize(entryList, List<ProductResourceData>.class);
		
        System.debug('excelDataList => ' + excelDataList);

		Map<String, SObject> lookups = new Map<String, SObject>();

		for (ProductResourceData oppData : excelDataList){
			lookups.put(oppData.structureName, null);
			lookups.put(oppData.productCode, null);
			lookups.put(oppData.internalKey, null);
        }

		for (EstruturaProduto__c record : [SELECT Id, Name FROM EstruturaProduto__c WHERE Ativo__c = true AND Name IN: lookups.keySet()]){
			lookups.put(record.Name, record);
		}
		for (Product2 record : [SELECT Id, ProductCodeExternalId__c FROM Product2 WHERE ProductCodeExternalId__c  IN: lookups.keySet()]){
			lookups.put(record.ProductCodeExternalId__c, record);
		}
		for (TipoRecursoProduto__c record : [SELECT Id, TipoRecurso__r.ExternalId__c, Produto__r.ProductCodeExternalId__c FROM TipoRecursoProduto__c WHERE Produto__r.ProductCodeExternalId__c  IN: lookups.keySet() AND TipoRecurso__r.ExternalId__c IN: lookups.keySet() ]){
			lookups.put(record.TipoRecurso__r.ExternalId__c +'-'+ record.Produto__r.ProductCodeExternalId__c, record);
		}

		Map<String, TipoRecursoProduto__c> productResouceMap = new Map<String, TipoRecursoProduto__c>();
		Map<String, TipoRecursoProduto__c> productResouceUpdateMap = new Map<String, TipoRecursoProduto__c>();
		Map<String, Product2> productMap = new Map<String, Product2>();
		for (ProductResourceData resourceData : excelDataList){
			TipoRecursoProduto__c resourceType = resourceData.getProductResourceData(lookups);
			String key = resourceData.internalKey +'-'+resourceData.productCode;
			System.debug(resourceType);
			if(!lookups.containsKey(key)){
            	productResouceMap.put(key, resourceType);
			}else{
				resourceType.Id = (Id)lookups.get(key).get('Id');
            	productResouceUpdateMap.put(key, resourceType);
			}
            productMap.put(resourceData.productCode, resourceData.getProduct(lookups));
		}

		System.debug('\nproductResouceMap => ' + productResouceMap);
		System.debug('\nproductMap => ' + productMap);

		String response = 'Sucesso';
		if (!productResouceMap.isEmpty()){
			Database.insert(productResouceMap.values(), false);
		}

		if (!productResouceUpdateMap.isEmpty()){
			Database.update(productResouceUpdateMap.values(), false);
		}

		if (!productMap.isEmpty()){
			Database.update(productMap.values());
		}

		return response;
	}

	public class ProductListData{
		public List<String> structureList {get; set;}
		public List<String> productList {get; set;}
		public List<String> internalList {get; set;}
		public ProductListData(List<String> structureList, List<String> productList, List<String> internalList){
			this.structureList = structureList;
			this.productList = productList;
			this.internalList = internalList;
		}
	}
	public class ProductResourceData{
		public String structureName {get; set;}
		public String productCode {get; set;}
		public String internalKey {get; set;}
		public Boolean isInvalid {get; set;}
		public Integer internalId {get; set;}
		public String errorMessage {get; set;}

		public ProductResourceData(Boolean isTest){
			if (isTest){
				this.structureName = 'CAM-0190';
				this.productCode = '100231';
				this.internalKey = '1002';
				this.isInvalid = true;
				this.internalId = 1;
				this.errorMessage = '';
			}
		}

		public Product2 getProduct(Map<String, sObject> lookups){
			return new Product2(
                Id = lookups.get(this.productCode) != null ? (Id)lookups.get(this.productCode).get('Id') : null,
                EstruturaProduto__c = lookups.get(this.structureName) != null ? (Id)lookups.get(this.structureName).get('Id') : null
			);
		}
		public TipoRecursoProduto__c getProductResourceData(Map<String, sObject> lookups){
			return new TipoRecursoProduto__c(
                Produto__r = new Product2(ProductCodeExternalId__c = this.productCode),
                TipoRecurso__r = new TiposRecurso__c(ExternalId__c = this.internalKey)
			);
		}
	}
}