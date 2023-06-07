public abstract class ProductScreenModel {
    
	public class ProductData {
		@AuraEnabled public String id {get; set;}
		@AuraEnabled public String name {get; set;}
		@AuraEnabled public Decimal quantity {get; set;}
		@AuraEnabled public Decimal quantityAccessory {get; set;}
		@AuraEnabled public Decimal changedQuantity {get; set;}
		@AuraEnabled public Decimal totalPrice {get; set;}
		@AuraEnabled public Decimal listPrice {get; set;}
		@AuraEnabled public Decimal price {get; set;}
		@AuraEnabled public Decimal discountPercent {get; set;}
		@AuraEnabled public Decimal discountCurrency {get; set;}
		@AuraEnabled public String discountType {get; set;}
		@AuraEnabled public String productCode {get; set;}
		@AuraEnabled public String internalProdCode {get; set;}
		@AuraEnabled public String image {get; set;}
		@AuraEnabled public String extension {get; set;}
		@AuraEnabled public String productId {get; set;}

        @AuraEnabled public String Product2KitAcessoriosId {get;set;}
        @AuraEnabled public String ParentProductKitAcessoriosId {get;set;}
        @AuraEnabled public String Product2Id {get;set;}
        @AuraEnabled public String ParentProduct {get;set;}

		@AuraEnabled public Boolean isSelected {get; set;}
		@AuraEnabled public Boolean showCheckout {get; set;}
		@AuraEnabled public Boolean isShowProduct {get; set;}
		@AuraEnabled public Boolean isDiscountPercent {get; set;}
		@AuraEnabled public Boolean isHasKit {get; set;}
		@AuraEnabled public Boolean isDisabledButtons {get; set;}
		@AuraEnabled public Boolean isShowNewStructure {get; set;}
		@AuraEnabled public Boolean isSingleItem {get; set;}
		@AuraEnabled public Boolean isConfigured {get; set;}
		@AuraEnabled public Boolean hasExceptionAccessory {get; set;}

		@AuraEnabled public List<GroupAccessoryData> groupAccessoryList {get; set;}
		@AuraEnabled public List<ProductData> exceptionAccessoryList {get; set;}

		public ProductData() {
			this.groupAccessoryList = new List<GroupAccessoryData>();
			this.exceptionAccessoryList = new List<ProductData>();

			this.totalPrice = 0;
			this.listPrice = 0;
			this.discountPercent = 0;
			this.discountCurrency = 0;
			this.discountType = 'currency';
			this.image = '';
			this.extension = '';
			this.isDiscountPercent = false;
			this.isConfigured = false;
			this.hasExceptionAccessory = false;
			this.isSingleItem = false;
			this.quantityAccessory = 1;
		}
		public ProductData(Product2 product) {
			this();
			this.id = product.Id;
			this.productId = product.Id;
			this.name = product.Name;
			this.image = product.Imagem_URL__c;
			this.quantity = 1;
			this.changedQuantity = 1;
			this.price = 0;
			this.productCode = product.ExternalId__c;
			this.internalProdCode = product.ProductCode;
			this.isSelected = false;
			this.isShowProduct = false;
			this.isHasKit = product.KitAcessorios__c <> null;
			this.isDisabledButtons = product.KitAcessorios__c <> null;
			this.isShowNewStructure = product.EstruturaProduto__c <> null && this.isDisabledButtons;
			this.isSingleItem = false;
		}
		public ProductData(QuoteLineItem currentQuoteLineItem) {
			this();
			this.id = currentQuoteLineItem.Product2Id;
			this.showCheckout = true;
			this.name = currentQuoteLineItem.Product2.Name;
			this.quantity = currentQuoteLineItem.Quantity;
			this.changedQuantity = currentQuoteLineItem.Quantity;
			this.image = currentQuoteLineItem.Product2.Imagem_URL__c;
			this.price = currentQuoteLineItem.UnitPrice;
			this.productCode = currentQuoteLineItem.Product2.ExternalId__c;
			this.internalProdCode = currentQuoteLineItem.Product2.ProductCode;
			this.isSelected = true;
			this.isShowProduct = true;
			this.isHasKit = currentQuoteLineItem.Product2.KitAcessorios__c != null;
			this.isDisabledButtons = currentQuoteLineItem.Product2.KitAcessorios__c != null;
			this.isShowNewStructure = false;

            this.Product2KitAcessoriosId = currentQuoteLineItem.Product2.KitAcessorios__c;
            this.ParentProductKitAcessoriosId = currentQuoteLineItem.ParentProduct__r.KitAcessorios__c;
            this.Product2Id = currentQuoteLineItem.Product2Id;
            this.ParentProduct = currentQuoteLineItem.ParentProduct__c;
			this.productId = currentQuoteLineItem.Product2Id;
			this.isSingleItem = currentQuoteLineItem.ProdutoSemEstrutura__c;

			
			this.totalPrice = 0;
			this.listPrice = currentQuoteLineItem.ListPrice;
			this.discountPercent = currentQuoteLineItem.Discount;
			this.discountCurrency = currentQuoteLineItem.ListPrice - currentQuoteLineItem.UnitPrice;
			this.discountType = 'currency';
		}
		public ProductData(OpportunityLineItem currentOpporunityLineItem) {
			this();
			this.id = currentOpporunityLineItem.Product2Id;
			this.showCheckout = true;
			this.name = currentOpporunityLineItem.Product2.Name;
			this.quantity = currentOpporunityLineItem.Quantity;
			this.changedQuantity = currentOpporunityLineItem.Quantity;
			this.image = currentOpporunityLineItem.Product2.Imagem_URL__c;
			this.price = currentOpporunityLineItem.UnitPrice;
			this.productCode = currentOpporunityLineItem.Product2.ExternalId__c;
			this.internalProdCode = currentOpporunityLineItem.Product2.ProductCode;
			this.isSelected = true;
			this.isShowProduct = true;
			this.isHasKit = currentOpporunityLineItem.Product2.KitAcessorios__c != null;
			this.isDisabledButtons = currentOpporunityLineItem.Product2.KitAcessorios__c != null;
			this.isShowNewStructure = false;

            this.Product2KitAcessoriosId = currentOpporunityLineItem.Product2.KitAcessorios__c;
            this.ParentProductKitAcessoriosId = currentOpporunityLineItem.ParentProduct__r.KitAcessorios__c;
            this.Product2Id = currentOpporunityLineItem.Product2Id;
            this.ParentProduct = currentOpporunityLineItem.ParentProduct__c;
			this.productId = currentOpporunityLineItem.Product2Id;
			this.isSingleItem = currentOpporunityLineItem.ProdutoSemEstrutura__c;
		}
		public QuoteLineItem getQuoteLineItem(PricebookEntry currentPrice, Id quoteId){
				return new QuoteLineItem(
					QuoteId = quoteId,
					UnitPrice = this.price,
					Quantity = this.quantity,
					ProdutoSemEstrutura__c = this.isSingleItem,
					// DescontoAplicado__c = currentPrice.UnitPrice - this.price,
					Discount = (1 - (this.price / currentPrice.UnitPrice)) * 100,
					Product2Id = this.productId,
					PricebookEntryId = currentPrice.Id
			);
		}
		public OpportunityLineItem getOpportunityLineItem(PricebookEntry currentPrice, Id opportunityId){
			return new OpportunityLineItem(
				OpportunityId = opportunityId,
				UnitPrice = this.price,
				Quantity = this.quantity,
				ProdutoSemEstrutura__c = this.isSingleItem,
				// DescontoAplicado__c = currentPrice.UnitPrice - this.unitPrice,
				Discount = (1 - (this.price / currentPrice.UnitPrice)) * 100,
				Product2Id = this.productId,
				PricebookEntryId = currentPrice.Id
			);
		}
	}

	public class GroupAccessoryData {
		@AuraEnabled public String id {get; set;}
		@AuraEnabled public String name {get; set;}
		@AuraEnabled public String nameCompleted {get; set;}
		@AuraEnabled public Decimal minQuantity {get; set;}
		@AuraEnabled public String value {get; set;}
		@AuraEnabled public Boolean isRequired {get; set;}
		@AuraEnabled public Boolean isNA {get; set;}
		@AuraEnabled public Boolean isIncluded {get; set;}
		@AuraEnabled public Boolean isListing {get; set;}
		@AuraEnabled public Boolean isSelected {get; set;}
		@AuraEnabled public Boolean isShowGroup {get; set;}
		@AuraEnabled public Boolean isFirstGroup {get; set;}
		@AuraEnabled public Boolean isLastGroup {get; set;}
		@AuraEnabled public Boolean isCurrentGroup {get; set;}
		@AuraEnabled public Boolean isNotCurrentGroup {get; set;}
		@AuraEnabled public String kitId {get; set;}
		@AuraEnabled public Decimal discountPercent {get; set;}
		@AuraEnabled public Decimal discountCurrency {get; set;}
		@AuraEnabled public String discountType {get; set;}

		@AuraEnabled public List<AccessoryData> accessoryList {get; set;}

		public GroupAccessoryData() {}
		public GroupAccessoryData(GrupoAcessorios__c currentGroup) {
			this.id = currentGroup.Id;
			this.name = currentGroup.Name;
			this.nameCompleted = currentGroup.Name + ' (' + currentGroup.Tipo__c + ')';
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
				if(currentAccessory.AcessorioPadrao__c){
					this.isSelected = true;
				}
			}
		}
	}

	public class AccessoryData {
		@AuraEnabled public String id {get; set;}
		@AuraEnabled public String name {get; set;}
		@AuraEnabled public String code {get; set;}
		@AuraEnabled public String prodCode {get; set;}
		@AuraEnabled public String internalProdCode {get; set;}
		@AuraEnabled public Decimal price {get; set;}
		@AuraEnabled public Decimal quantity {get; set;}
		@AuraEnabled public Decimal discount {get; set;}
		@AuraEnabled public Decimal listPrice {get; set;}
		@AuraEnabled public Boolean isDiscountPercent {get; set;}
		@AuraEnabled public Decimal changedQuantity {get; set;}
		@AuraEnabled public Decimal totalAmount {get; set;}
		@AuraEnabled public String productId {get; set;}
		@AuraEnabled public String groupId {get; set;}
		@AuraEnabled public Boolean isSelected {get; set;}
		@AuraEnabled public Boolean isDisabled {get; set;}
		@AuraEnabled public Decimal discountPercent {get; set;}
		@AuraEnabled public Decimal suggessQuantity {get; set;}
		@AuraEnabled public Decimal discountCurrency {get; set;}
		@AuraEnabled public String discountType {get; set;}
		@AuraEnabled public Boolean isShowProduct {get; set;}

		public AccessoryData() {}
		public AccessoryData(TipoAcessorios__c currentAccessory) {
			this.id = currentAccessory.Id;
			this.name = currentAccessory.Produto__r.Name;
			this.prodCode = currentAccessory.Produto__r.ProductCode != null ? currentAccessory.Produto__r.ProductCode : currentAccessory.Produto__r.ExternalId__c;
			this.internalProdCode = this.prodCode;
			this.code = currentAccessory.Name;
			this.quantity = currentAccessory.QuantidadeSugerida__c;
			this.changedQuantity = currentAccessory.QuantidadeSugerida__c;
			this.suggessQuantity = currentAccessory.QuantidadeSugerida__c;
			this.discountPercent = 0;
			this.discountType = 'currency';
			this.discountCurrency = 0;
			this.price = 0;
			this.listPrice = 0;
			this.totalAmount = 0;
			this.productId = currentAccessory.Produto__c;
			this.groupId = currentAccessory.GrupoAcessorio__c;

			this.isSelected = currentAccessory.AcessorioPadrao__c;
			this.isDisabled = false;
			this.isShowProduct = true;
		}
		public QuoteLineItem getQuoteLineItem(PricebookEntry currentPrice, Id quoteId){
			return new QuoteLineItem(
				QuoteId = quoteId,
				UnitPrice = this.price,
				Quantity = this.quantity,
				// DescontoAplicado__c = currentPrice.UnitPrice - this.unitPrice,
				Discount = (1 - (this.price / currentPrice.UnitPrice)) * 100,
				Product2Id = this.productId,
				PricebookEntryId = currentPrice.Id
			);
		}
		public OpportunityLineItem getOpportunityLineItem(PricebookEntry currentPrice, Id opportunityId){
			return new OpportunityLineItem(
				OpportunityId = opportunityId,
				UnitPrice = this.price,
				Quantity = this.quantity,
				// DescontoAplicado__c = currentPrice.UnitPrice - this.unitPrice,
				Discount = (1 - (this.price / currentPrice.UnitPrice)) * 100,
				Product2Id = this.productId,
				PricebookEntryId = currentPrice.Id
			);
		}
	}    

	public class CustomException extends Exception {}

	public class SaveResponse {
		@AuraEnabled public Boolean hasError = false;
		@AuraEnabled public String errorMessage = '';
		@AuraEnabled public String exceptionMessage = '';

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
}