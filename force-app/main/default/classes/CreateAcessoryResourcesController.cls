public class CreateAcessoryResourcesController {
    public CreateAcessoryResourcesController() 	{}
	@RemoteAction
	public static ProductListData getCurrentRecordsSteris(AllAcessoryData excelDataList){
		Set<String> productSet = new Set<String>();

		for(AcessoryData record: excelDataList.acessoryDatas){
			productSet.add(record.productCode);
		}

        List<String> productList = new List<String>();
        for(Product2 record : [SELECT ProductCodeExternalId__c FROM Product2 WHERE isActive = true AND ProductCodeExternalId__c != null AND ProductCodeExternalId__c IN :productSet]){
            productList.add(record.ProductCodeExternalId__c);
        }

		return new ProductListData(productList);
	}

	@RemoteAction
	public static String createRecords(String entryList){
		AllAcessoryData excelDataList = (AllAcessoryData)JSON.deserialize(entryList, AllAcessoryData.class);

        insertKit(excelDataList);
        insertGroup(excelDataList);
        insertAcessory(excelDataList);
        updateProduct2(excelDataList);
		return 'Sucesso';
	}
    public static void insertKit(AllAcessoryData excelDataList){
		Map<String, KitAcessorios__c> kitMap = new Map<String, KitAcessorios__c>();
		for (KitData oppData : excelDataList.kitDatas){
            kitMap.put( oppData.names, oppData.getRecord());
		}

		if (!kitMap.isEmpty()){
			Database.upsert(kitMap.values(), KitAcessorios__c.CodigoInterno__c, false);
		}
    }
    public static void insertGroup(AllAcessoryData excelDataList){
		Map<String, GrupoAcessorios__c> kitMap = new Map<String, GrupoAcessorios__c>();
		for (GroupData oppData : excelDataList.groupDatas){
			String key = oppData.kitName +' - '+ oppData.names;
            kitMap.put(key,  oppData.getRecord());
		}
        
		if (!kitMap.isEmpty()){
			Database.upsert(kitMap.values(), GrupoAcessorios__c.CodigoInterno__c, false);
		}
    }
    public static void insertAcessory(AllAcessoryData excelDataList){
		Map<String, TipoAcessorios__c> kitMap = new Map<String, TipoAcessorios__c>();
		for (AcessoryData oppData : excelDataList.acessoryDatas){
			String key = oppData.structureName +' - '+ oppData.groupName +' - '+ oppData.productCode;
            kitMap.put(key,  oppData.getRecord());
		}
        
		if (!kitMap.isEmpty()){
			Database.upsert(kitMap.values(), TipoAcessorios__c.CodigoInterno__c, false);
		}

    }
    public static void updateProduct2(AllAcessoryData excelDataList){
		Map<String, Product2> kitUpdateMap = new Map<String, Product2>();
		for (ProductData oppData : excelDataList.productDatas){
            kitUpdateMap.put(oppData.productCode,  oppData.getRecord());
		}
		if (!kitUpdateMap.isEmpty()){
			Database.upsert(kitUpdateMap.values(), Product2.ProductCodeExternalId__c, false);
		}

    }

	public class ProductListData{
		public List<String> productList {get; set;}
		public ProductListData(List<String> productList){
			this.productList = productList;
		}
	}
	public class AllAcessoryData{
		public AcessoryData[] acessoryDatas {get; set;}
		public GroupData[] groupDatas {get; set;}
		public KitData[] kitDatas {get; set;}
		public ProductData[] productDatas {get; set;}
	}
	public class AcessoryData{
		public String productCode {get; set;}
		public Decimal quantity {get; set;}
		public String standards {get; set;}
		public String groupName {get; set;}
		public String structureName {get; set;}
		public String internalKey {get; set;}
		public Boolean isInvalid {get; set;}
		public Integer internalId {get; set;}
		public String errorMessage {get; set;}
        public TipoAcessorios__c getRecord(){
            TipoAcessorios__c types =  new TipoAcessorios__c(
                CodigoInterno__C = this.structureName +' - '+this.groupName+' - '+this.productCode,
                Produto__r =  new Product2(ProductCodeExternalId__c = this.productCode), 
                QuantidadeSugerida__c = this.quantity, 
				Ativo__c = true, 
                AcessorioPadrao__c = (this.standards == 'true'),
                GrupoAcessorio__r = new GrupoAcessorios__c(CodigoInterno__c = this.structureName +' - '+this.groupName));
            System.debug(types);
            System.debug(this.structureName +' - '+this.groupName);
            return types;
        }
	}
	public class GroupData{
		public String names {get; set;}
		public String types {get; set;}
		public Decimal orderShow {get; set;}
		public Decimal minimumQuantity {get; set;}
		public String actions {get; set;}
		public String kitName {get; set;}
		public String internalKey {get; set;}
		public Boolean isInvalid {get; set;}
		public Integer internalId {get; set;}
		public String errorMessage {get; set;}
        public GrupoAcessorios__c getRecord(){
            return new GrupoAcessorios__c(CodigoInterno__c = this.kitName+' - '+this.names, Name = this.names, Ativo__c = true, Tipo__c = this.types, OrdemExibicao__c = this.orderShow, NumeroMinimoAcessorios__c = this.minimumQuantity, 
                AcaoGrupo__c = this.actions, KitAcessorios__r = new KitAcessorios__c(CodigoInterno__c = this.kitName));
        }
	}
	public class KitData{
		public String names {get; set;}
		public String internalKey {get; set;}
		public Boolean isInvalid {get; set;}
		public Integer internalId {get; set;}
		public String errorMessage {get; set;}
        public KitAcessorios__c getRecord(){
            return new KitAcessorios__c(CodigoInterno__c = this.names, Name = this.names, Ativo__c = true);
        }
	}
	public class ProductData{
		public String productCode {get; set;}
		public String kitName {get; set;}
		public String internalKey {get; set;}
		public Boolean isInvalid {get; set;}
		public Integer internalId {get; set;}
		public String errorMessage {get; set;}
        public Product2 getRecord(){
            return new Product2(ProductCodeExternalId__c = this.productCode, KitAcessorios__r = new KitAcessorios__c(CodigoInterno__c = this.kitName));
        }
	}
}