public with sharing class PDFQuoteController {
	public String quoteId {get; set;}
	public QuoteData quoteData {get; set;}
	public String contentDocs {get; set;}

	public PDFQuoteController() {
		this.quoteId = ApexPages.currentPage().getParameters().get('Id');
		Quote currentQuote = getQuote(quoteId);
		this.quoteData = new QuoteData(currentQuote);
		// this.contentDocs = this.quoteData.currencyIsos == 'USD' ? this.getTermsUSD() : this.getTermsBRL(); 
		this.contentDocs = '<tr ><td class="fontSizes">TERMOS E CONDIÇÕES DE VENDA</td></tr>';
	}
	public String getTermsUSD(){
		String returnVal = '';
		returnVal += '<tr ><td class="fontSizes">TERMOS E CONDIÇÕES DE VENDA E INSTALAÇÃO DA STERIS CORPORATION';
		returnVal += '</td></tr><tr ><td class="fontSizes">I. Oferta e Aceitação';
		returnVal += '</td></tr><tr ><td class="fontSizes">A. O Cliente concorda que este orçamento constitui uma oferta da STERIS Corporation (“Vendedor”) para a venda (a “Oferta”) de produtos (os';
		returnVal += '</td></tr><tr ><td class="fontSizes">“Produtos”) ou serviços (os “Serviços”). Salvo estipulação em contrário nesta Oferta ou em algum outro documento assinado pelo Vendedor,';
		returnVal += '</td></tr><tr ><td class="fontSizes">os termos e condições de venda estabelecidos neste documento (“Termos do Vendedor”) se aplicam a todos os Produtos e Serviços vendidos';
		returnVal += '</td></tr><tr ><td class="fontSizes">ou fornecidos pelo Vendedor.';
		returnVal += '</td></tr><tr ><td class="fontSizes">B. O Cliente reconhece que qualquer pedido de compra ou outra forma de aceitação emitida pelo Cliente resultará em um contrato de compra';
		returnVal += '</td></tr><tr ><td class="fontSizes">dos Produtos ou Serviços pelo preço indicado na Oferta. Considera-se que o Cliente aceitou qualquer um dos Termos do Vendedor aos quais';
		returnVal += '</td></tr><tr ><td class="fontSizes">o Cliente não se opôs especificamente. A emissão pelo Cliente de um pedido de compra que pretende rejeitar alguns ou todos os Termos do';
		returnVal += '</td></tr><tr ><td class="fontSizes">Vendedor do formulário padrão não será objeção suficiente. O Cliente deverá estabelecer cada objeção aos Termos do Vendedor por escrito,';
		returnVal += '</td></tr><tr ><td class="fontSizes">assinado e datado pelo Cliente e entregue ao Vendedor antes ou simultaneamente do pedido de compra do Cliente ou outra forma de';
		returnVal += '</td></tr><tr ><td class="fontSizes">aceitação. A falha do Vendedor em se opor às disposições de qualquer pedido de compra ou outra comunicação do Cliente (incluindo, mas';
		returnVal += '</td></tr><tr ><td class="fontSizes">não se limitando a cláusulas de penalidade de qualquer tipo), não constituirá uma renúncia aos Termos do Vendedor nem uma aceitação pelo';
		returnVal += '</td></tr><tr ><td class="fontSizes">Vendedor de tais disposições. Quaisquer termos do pedido de compra do Cliente ou qualquer documento de aceitação que seja diferente ou';
		returnVal += '</td></tr><tr ><td class="fontSizes">adicional aos Termos do Vendedor são, desde já, rejeitados, a menos que sejam especificamente aceitos pelo Vendedor em documento';
		returnVal += '</td></tr><tr ><td class="fontSizes">separado assinado pelo Cliente e pelo Vendedor, ainda que aqueles termos alterassem materialmente os termos deste documento. Nenhum';
		returnVal += '</td></tr><tr ><td class="fontSizes">curso de negociação, costume ou uso que seja contrário aos Termos do Vendedor será aplicável.';
		returnVal += '</td></tr><tr ><td class="fontSizes">C. O Vendedor se reserva o direito de corrigir qualquer erro tipográfico ou formal nos preços, especificações, orçamentos ou recibos.';
		returnVal += '</td></tr><tr ><td class="fontSizes">II. Produtos ou Serviços Sujeitos a Venda';
		returnVal += '</td></tr><tr ><td class="fontSizes">Os Produtos (incluindo equipamentos, suprimentos e peças) ou Serviços sujeitos a esta venda serão limitados aos descritos na Oferta. A';
		returnVal += '</td></tr><tr ><td class="fontSizes">menos que explicitamente incluído na Oferta, esse orçamento não inclui, e o Cliente assume a responsabilidade por: (A) todas as';
		returnVal += '</td></tr><tr ><td class="fontSizes">interligações a serviços públicos, alvarás e outros requisitos regulatórios, conforme aplicável; e (B) remoções, configuração, instalação e';
		returnVal += '</td></tr><tr ><td class="fontSizes">ativação.';
		returnVal += '</td></tr><tr ><td class="fontSizes">III. Condição Financeira';
		returnVal += '</td></tr><tr ><td class="fontSizes">A pedido do Vendedor, o Cliente fornecerá informações suficientes para permitir que o Vendedor avalie a capacidade creditícia do Cliente,';
		returnVal += '</td></tr><tr ><td class="fontSizes">incluindo a preparação do pedido de crédito do Vendedor. O Vendedor pode, a seu critério, exigir cartas de crédito, pagamento total ou parcial';
		returnVal += '</td></tr><tr ><td class="fontSizes">antecipado ou outras formas de garantia.';
		returnVal += '</td></tr><tr ><td class="fontSizes">IV. Preços, Remessa e Entrega';
		returnVal += '</td></tr><tr ><td class="fontSizes">A. Os preços são baseados em dólares americanos e serão EX-WORKS (EXW, INCOTERMS, 2020) a menos que de outra forma esteja';
		returnVal += '</td></tr><tr ><td class="fontSizes">expressamente previsto na Oferta. Os preços não incluem frete ou taxas de entrega ou impostos (vendas, consumo, uso, ad valorem, etc.) ou';
		returnVal += '</td></tr><tr ><td class="fontSizes">quaisquer encargos de exportação ou importação. Essas cobranças podem ser pagas antecipadamente pelo Vendedor e o Cliente concorda';
		returnVal += '</td></tr><tr ><td class="fontSizes">em reembolsar tais cobranças que forem adicionadas à fatura do Cliente.';
		returnVal += '</td></tr><tr ><td class="fontSizes">B. O Vendedor selecionará o método e a transportadora para a entrega de todos os Produtos. A propriedade e o risco de perda ou dano aos';
		returnVal += '</td></tr><tr ><td class="fontSizes">Produtos serão transmitidos do Vendedor ao Cliente por ocasião de sua entrega a uma transportadora no ponto de embarque.';
		returnVal += '</td></tr><tr ><td class="fontSizes">C. Qualquer data de remessa, entrega ou desempenho declarada na Oferta ou em outro documento do contrato é apenas aproximada e não';
		returnVal += '</td></tr><tr ><td class="fontSizes">constitui qualquer garantia de remessa, entrega ou desempenho em qualquer data específica.';
		returnVal += '</td></tr><tr ><td class="fontSizes">D. O tempo não será condição essencial deste contrato.';
		returnVal += '</td></tr><tr ><td class="fontSizes">V. Pagamentos, Propriedade, e Garantia';
		returnVal += '</td></tr><tr ><td class="fontSizes">A. Todos os pagamentos serão feitos na moeda dos Estados Unidos da América. Todos os pagamentos serão efetuados sem dedução de';
		returnVal += '</td></tr><tr ><td class="fontSizes">cobranças adicionais, outras contas entre o Vendedor e o Cliente e similares, as quais serão liquidadas independentemente do pagamento da';
		returnVal += '</td></tr><tr ><td class="fontSizes">fatura. O pagamento não prejudicará as reivindicações por conta de omissões ou falhas na remessa, mas tais reivindicações não serão';
		returnVal += '</td></tr><tr ><td class="fontSizes">permitidas a menos que sejam feitas dentro de 96 (noventa e seis) horas após o recebimento pelo Cliente da remessa aplicável.';
		returnVal += '</td></tr><tr ><td class="fontSizes">B. O pagamento será devido dentro de 30 (trinta) dias a partir da data da fatura do Vendedor.';
		returnVal += '</td></tr><tr ><td class="fontSizes">C. Na hipótese de o Cliente atrasar o pagamento após a data de vencimento, poderá ser cobrado, mensalmente, juros na taxa de 1,5% (um e';
		returnVal += '</td></tr><tr ><td class="fontSizes">meio por cento) ou à taxa máxima permitida por lei sobre o saldo do valor não pago, o que for menor.';
		returnVal += '</td></tr><tr ><td class="fontSizes">D. Não obstante a propriedade e o risco de perda serem transmitidos ao Cliente por ocasião do embarque, o Cliente concede, por meio deste,';
		returnVal += '</td></tr><tr ><td class="fontSizes">uma garantia correspondente aos Produtos para assegurar integralmente o seu o pagamento. O Cliente autoriza o Vendedor a qualquer';
		returnVal += '</td></tr><tr ><td class="fontSizes">momento e periodicamente a (1) arquivar em qualquer escritório de arquivamento em qualquer jurisdição do Código Comercial Unificado';
		returnVal += '</td></tr><tr ><td class="fontSizes">(Uniform Commercial Code) demonstrações financeiras e aditivos indicando o Cliente como devedor and descrevendo os Produtos como';
		returnVal += '</td></tr><tr ><td class="fontSizes">garantia, e (2) enviar as notificações necessárias para aperfeiçoar tal garantia ou estabelecer sua prioridade.';
		returnVal += '</td></tr><tr ><td class="fontSizes">VI. Atrasos e Alterações';
		returnVal += '</td></tr><tr ><td class="fontSizes">A. O Vendedor não será responsável por perdas, danos ou descumprimentos resultantes de atrasos no recebimento de especificações ou';
		returnVal += '</td></tr><tr ><td class="fontSizes">instruções finais do Cliente, alterações nas especificações, força maior, incluindo mas não se limitando a greves, distúrbio trabalhistas,';
		returnVal += '</td></tr><tr ><td class="fontSizes">escassez de materiais, condições adversas para fabricação, atrasos ou falhas de transportadoras ou de comunicação, epidemias,';
		returnVal += '</td></tr><tr ><td class="fontSizes">inundações, tempestades, acidentes, distúrbios civis, atos de terrorismo, guerra e invasão, requisição ou prioridades governamentais, atos de';
		returnVal += '</td></tr><tr ><td class="fontSizes">Deus ou outras causas fora do controle razoável do Vendedor.';
		returnVal += '</td></tr><tr ><td class="fontSizes">B. Nesses casos, a data de entrega será prorrogada por um período igual ao tempo perdido ocasionado pelo respectivo motivo, ou o';
		returnVal += '</td></tr><tr ><td class="fontSizes">Vendedor, a seu critério, poderá cancelar a entrega e reembolsar quaisquer valores pagos pelo Cliente, como único e exclusivo remédio ao';
		returnVal += '</td></tr><tr ><td class="fontSizes">Cliente. O Vendedor se comprometerá a notificar imediatamente o Cliente sobre qualquer atraso significativo e especificará a data de entrega';
		returnVal += '</td></tr><tr ><td class="fontSizes">revisada assim que possível. EM NENHUM CASO O VENDEDOR SERÁ RESPONSÁVEL POR DANOS ESPECIAIS, INCIDENTAIS OU';
		returnVal += '</td></tr><tr ><td class="fontSizes">CONSEQUENCIAIS, RESULTANTES DE ATRASO, CANCELAMENTO OU FALHA DE ENTREGA OU FABRICAÇÃO.';
		returnVal += '</td></tr><tr ><td class="fontSizes">C. Se a remessa for atrasada ou estendida pelo Cliente, este providenciará e notificará o Vendedor sobre o local ou locais para os quais o';
		returnVal += '</td></tr><tr ><td class="fontSizes">Vendedor enviará os Produtos, a serem cobertos pela contratação de armazenamento ou depósito às custas do Cliente e todo o risco de';
		returnVal += '</td></tr><tr ><td class="fontSizes">perda ou dano aos Produtos ou Serviços serão suportados pelo Cliente. Se o Cliente não estiver disposto ou não puder providenciar';
		returnVal += '</td></tr><tr ><td class="fontSizes">prontamente instalações de armazenamento ou depósito, o Vendedor poderá fazê-lo à custa do Cliente. O Cliente, neste ato, concorda em';
		returnVal += '</td></tr><tr ><td class="fontSizes">reembolsar todos e quaisquer encargos de armazenamento ou depósito incorridos pelo Vendedor, conforme refletidos na fatura do Vendedor.';
		returnVal += '</td></tr><tr ><td class="fontSizes">D. Além dos direitos e obrigações estabelecidos no Capítulo, item C, as alterações dos pedidos com valor superior a USD 15.000,00 (quinze';
		returnVal += '</td></tr><tr ><td class="fontSizes">mil dólares americanos) também podem estar sujeitas a uma taxa de alteração do pedido. O Vendedor poderá cobrar uma taxa de alteração';
		returnVal += '</td></tr><tr ><td class="fontSizes">de 1% (um por cento) ou USD 2.500,00 (dois mil e quinhentos dólares americanos), o que for maior, quando o Cliente solicitar uma alteração';
		returnVal += '</td></tr><tr ><td class="fontSizes">nas configurações do Produto, quantidade do pedido ou data de entrega e tal pedido se der dentro de 30 (trinta) dias de antecedência da data';
		returnVal += '</td></tr><tr ><td class="fontSizes">de entrega original. Todos os pedidos de alteração devem ser aceitos e aprovados pelo Vendedor. Os pedidos de alteração serão';
		returnVal += '</td></tr><tr ><td class="fontSizes">processados mediante envio de pedido de compra revisado. Pedidos de alteração podem acarretar atrasos no envio e/ou instalação.';
		returnVal += '</td></tr><tr ><td class="fontSizes">VII. Cancelamento';
		returnVal += '</td></tr><tr ><td class="fontSizes">O cancelamento ou suspensão do pedido pelo Cliente, após a aceitação do Vendedor, poderá ser feito apenas em termos que compensem o';
		returnVal += '</td></tr><tr ><td class="fontSizes">Vendedor pela perda resultante de seu cancelamento ou suspensão. Antes da remessa, o Cliente poderá cancelar o seu pedido mediante';
		returnVal += '</td></tr><tr ><td class="fontSizes">uma notificação escrita de cancelamento endereçada ao Vendedor. Após a remessa, o Cliente poderá cancelar apenas se os Produtos forem';
		returnVal += '</td></tr><tr ><td class="fontSizes">revendíveis e o Cliente arcar com os custos de reposição, remessa e manuseio, conforme razoavelmente determinados pelo Vendedor.';
		returnVal += '</td></tr><tr ><td class="fontSizes">VIII. Garantias e Isenções';
		returnVal += '</td></tr><tr ><td class="fontSizes">A. Sujeito ao item (C) abaixo, o Vendedor garante que todos os Produtos classificados como equipamento de capital, de acordo com os';
		returnVal += '</td></tr><tr ><td class="fontSizes">princípios contábeis geralmente aceitos nos Estados Unidos da América, são livres de defeitos de material e mão-de-obra em condições';
		returnVal += '</td></tr><tr ><td class="fontSizes">normais de uso e operação por um período de um ano após a data de remessa ao Cliente e a única garantia do Vendedor em relação a todos';
		returnVal += '</td></tr><tr ><td class="fontSizes">os outros Produtos é que os mesmos cumprem as especificações do Vendedor por um período de 1 (um) ano após a instalação ou 18';
		returnVal += '</td></tr><tr ><td class="fontSizes">(dezoito) meses após a transferência da posse para o Cliente (o que se encerrar primeiro), salvo se de outra forma estiver expressamente';
		returnVal += '</td></tr><tr ><td class="fontSizes">previsto na Oferta. Se o Produto estiver sujeito a uma data de validade, neste caso a data de validade será aplicada. As garantias do';
		returnVal += '</td></tr><tr ><td class="fontSizes">Vendedor não se aplicam a danos resultantes de instalações não autorizadas, acidentes, casualidades, alterações, uso indevido ou falha em';
		returnVal += '</td></tr><tr ><td class="fontSizes">seguir as instruções do Vendedor. Nenhuma outra garantia expressa é feita em relação aos Produtos. Se qualquer modelo ou amostra foi';
		returnVal += '</td></tr><tr ><td class="fontSizes">exibido para o Cliente, estes foram usados somente para ilustrar o tipo e a qualidade dos Produtos e não para representar que os Produtos,';
		returnVal += '</td></tr><tr ><td class="fontSizes">necessariamente, obedeceriam ao modelo exibido. GARANTIA COMPLETA: O VENDEDOR NÃO OFERECE OUTRA GARANTIA,';
		returnVal += '</td></tr><tr ><td class="fontSizes">EXPRESSA OU IMPLÍCITA, E O VENDEDOR EXPRESSAMENTE DISPENSA QUALQUER GARANTIA DE COMERCIALIZAÇÃO OU';
		returnVal += '</td></tr><tr ><td class="fontSizes">ADEQUAÇÃO A QUALQUER FINALIDADE ESPECÍFICA, E TODAS AS OUTRAS GARANTIAS SÃO EXPRESSAMENTE EXCLUÍDAS. O';
		returnVal += '</td></tr><tr ><td class="fontSizes">VENDEDOR NÃO TERÁ QUALQUER OUTRA RESPONSABILIDADE, DIRETA OU INDIRETA, DE QUALQUER TIPO, INCLUINDO A';
		returnVal += '</td></tr><tr ><td class="fontSizes">RESPONSABILIDADE, POR DANOS ESPECIAIS, INCIDENTAIS OU CONSEQUENCIAIS.';
		returnVal += '</td></tr><tr ><td class="fontSizes">B. O Cliente concorda que sua única e exclusiva compensação pela violação das garantias anteriores será o reparo ou substituição e';
		returnVal += '</td></tr><tr ><td class="fontSizes">reinstalação de peças defeituosas (com exceção de itens normalmente considerados dispensáveis, como filtros, fusíveis, juntas, lâmpadas,';
		returnVal += '</td></tr><tr ><td class="fontSizes">papel e cartucho para impressora, tinta, lubrificantes, planilhas, etc.), ou, a critério do Vendedor, reembolsar o preço de compra; desde que (1)';
		returnVal += '</td></tr><tr ><td class="fontSizes">o produto não tenha sido alterado ou modificado por outro a não ser o Vendedor, (2) o Produto tenha sido adequadamente armazenado,';
		returnVal += '</td></tr><tr ><td class="fontSizes">instalado, mantido e operado dentro dos limites especificados pelo Vendedor, e (3) o Cliente envie imediatamente ao Vendedor uma';
		returnVal += '</td></tr><tr ><td class="fontSizes">notificação de defeito acompanhada de prova satisfatória do defeito e permita ao Vendedor a oportunidade de inspecionar os Produtos, e no';
		returnVal += '</td></tr><tr ><td class="fontSizes">caso de reparo ou substituição, envie o Produto ao Vendedor, com o frete pré-pago. As peças defeituosas substituídas pelo Vendedor';
		returnVal += '</td></tr><tr ><td class="fontSizes">tornar-se-ão propriedade do Vendedor. As peças reparadas ou de reposição serão entregues ao Cliente na modalidade “Ex-Works” (EXW,';
		returnVal += '</td></tr><tr ><td class="fontSizes">INCOTERMS, 2020). O Produto que for devolvido ao Vendedor, mas que está em conformidade com as garantias estabelecidas pelo mesmo,';
		returnVal += '</td></tr><tr ><td class="fontSizes">será devolvido à custa do Cliente e permanecerá sujeito às disposições destes Termos do Vendedor, incluindo o Capítulo acima.';
		returnVal += '</td></tr><tr ><td class="fontSizes">C. Se o Produto vendido não for fabricado pelo Vendedor, este poderá estender ao Cliente a garantia que';
		returnVal += '</td></tr><tr ><td class="fontSizes">Installation Terms and Conditions Rev 14-feb-2020';
		returnVal += '</td></tr><tr ><td class="fontSizes">recebeu do fabricante original para não exceder o período especificado no Capítulo, item (A) dos Termos do Vendedor.';
		returnVal += '</td></tr><tr ><td class="fontSizes">D. O Vendedor não se responsabiliza por nenhum trabalho de garantia, conserto, substituição ou outro trabalho ou encargo relacionado aos';
		returnVal += '</td></tr><tr ><td class="fontSizes">mesmos, que não tenha sido autorizado por escrito pelo Vendedor.';
		returnVal += '</td></tr><tr ><td class="fontSizes">E. Quando aplicável e adquirido separadamente, o Vendedor atrasará a data de início da garantia por até 12 (doze) meses a partir da data da';
		returnVal += '</td></tr><tr ><td class="fontSizes">remessa, desde que o Vendedor confirme por inspeção que, a partir da data de início diferida, os Produtos atendem às especificações';
		returnVal += '</td></tr><tr ><td class="fontSizes">originais de fábrica do Vendedor e não diferem materialmente de sua condição de fábrica.';
		returnVal += '</td></tr><tr ><td class="fontSizes">F. O Vendedor é um empregador de oportunidades iguais e um contratado ou subcontratado federal. Consequentemente, o Vendedor e o';
		returnVal += '</td></tr><tr ><td class="fontSizes">Cliente concordam que, conforme aplicável, cumprirão os requisitos de 41 CFR 60-1.4 (a), 41 CFR 60-300.5 (a) e 41 CFR 60-741.5 (a) e que';
		returnVal += '</td></tr><tr ><td class="fontSizes">essas leis sejam incorporadas aqui por referência. Esses regulamentos proíbem a discriminação contra indivíduos qualificados com base em';
		returnVal += '</td></tr><tr ><td class="fontSizes">seu status de veteranos protegidos ou indivíduos com deficiência e proíbem a discriminação contra todos os indivíduos com base em raça,';
		returnVal += '</td></tr><tr ><td class="fontSizes">cor, religião, sexo ou nacionalidade. Esses regulamentos exigem que os principais contratados e subcontratados cobertos tomem medidas';
		returnVal += '</td></tr><tr ><td class="fontSizes">afirmativas para empregar e avançar no emprego de indivíduos, independentemente de raça, cor, religião, sexo, origem nacional, status de';
		returnVal += '</td></tr><tr ><td class="fontSizes">veterano protegido ou deficiência. O Cliente e o Vendedor também concordam que, conforme aplicável, eles cumprirão os requisitos da';
		returnVal += '</td></tr><tr ><td class="fontSizes">Ordem Executiva 13496 (29 CFR Parte 471, Apêndice A da Subparte A), relacionados ao aviso de direitos dos funcionários de acordo com as';
		returnVal += '</td></tr><tr ><td class="fontSizes">leis trabalhistas federais.';
		returnVal += '</td></tr><tr ><td class="fontSizes">IX. Patentes, Marcas, Direitos Autorais e Software';
		returnVal += '</td></tr><tr ><td class="fontSizes">A. O Vendedor garante que os Produtos fabricados de acordo com seu design serão entregues livres de qualquer reivindicação legítima por';
		returnVal += '</td></tr><tr ><td class="fontSizes">violação de qualquer patente, marca comercial ou direito autoral dos Estados Unidos.';
		returnVal += '</td></tr><tr ><td class="fontSizes">B. Se o Vendedor for notificado imediatamente por escrito sobre qualquer reivindicação de violação, este se defenderá ou poderá';
		returnVal += '</td></tr><tr ><td class="fontSizes">transacionar, às suas custas, qualquer reivindicação, desde que o Cliente coopere com o Vendedor na defesa de qualquer reclamação. O';
		returnVal += '</td></tr><tr ><td class="fontSizes">Vendedor, às suas custas e discrição, (1) buscará ao Cliente o direito de continuar utilizando qualquer Produto infrator, (2) substituirá ou';
		returnVal += '</td></tr><tr ><td class="fontSizes">modificará os Produtos para que não mais infrinjam, ou (3) removerá os Produtos e reembolsará o preço de compra (menos a depreciação';
		returnVal += '</td></tr><tr ><td class="fontSizes">razoável por qualquer período de uso). O disposto acima reflete a responsabilidade total do Vendedor por qualquer patente, marca comercial,';
		returnVal += '</td></tr><tr ><td class="fontSizes">direito autoral ou outra violação de propriedade intelectual dos Produtos ou de qualquer parte deles.';
		returnVal += '</td></tr><tr ><td class="fontSizes">C. As disposições anteriores não se aplicarão a nenhum Produto ou peça especificada pelo Cliente ou fabricada conforme o design pedido';
		returnVal += '</td></tr><tr ><td class="fontSizes">pelo Cliente, nem ao uso de qualquer Produto fornecido à luz destes termos em conjunto com qualquer outro item em uma combinação não';
		returnVal += '</td></tr><tr ><td class="fontSizes">fornecida pelo Vendedor como parte desta transação. Em relação a qualquer item, peça ou uso em tal combinação, o Vendedor não se';
		returnVal += '</td></tr><tr ><td class="fontSizes">responsabilizará por violação de patente, marca comercial ou direito autoral e o Cliente indenizará o Vendedor e o manterá indene de';
		returnVal += '</td></tr><tr ><td class="fontSizes">qualquer reivindicação, responsabilidade, dano ou despesa, incluindo honorários advocatícios razoáveis, como resultado de reivindicações';
		returnVal += '</td></tr><tr ><td class="fontSizes">por infração decorrentes.';
		returnVal += '</td></tr><tr ><td class="fontSizes">X. Limitação de Ações';
		returnVal += '</td></tr><tr ><td class="fontSizes">A. Qualquer ação por quebra de contrato relacionada a Produtos ou Serviços fornecidos pela STERIS deve ser iniciada dentro de 1 (um) ano';
		returnVal += '</td></tr><tr ><td class="fontSizes">após a ocorrência da causa da ação.';
		returnVal += '</td></tr><tr ><td class="fontSizes">B. O VENDEDOR NÃO SERÁ RESPONSÁVEL POR DANOS ESPECIAIS OU CONSEQUENCIAIS OU POR DANOS POR PERDA DE USO';
		returnVal += '</td></tr><tr ><td class="fontSizes">DECORRENTE DIRETA OU INDIRETAMENTE DE QUALQUER QUEBRA DE CONTRATO, MATERIAL OU NÃO, OU DE QUAISQUER';
		returnVal += '</td></tr><tr ><td class="fontSizes">ATOS CULPOSOS OU OMISSÕES DE SEUS EMPREGADOS OU AGENTES, E EM NENHUM EVENTO A RESPONSABILIDADE DO';
		returnVal += '</td></tr><tr ><td class="fontSizes">VENDEDOR EXCEDE O PREÇO DE QUALQUER PRODUTO DEFEITUOSO OU PRODUTO SUJEITO A ENTREGA TARDIA. Se o';
		returnVal += '</td></tr><tr ><td class="fontSizes">Vendedor, sem a correspondente remuneração, fornecer ao Cliente conselhos ou outra assistência com relação a qualquer Produto fornecido';
		returnVal += '</td></tr><tr ><td class="fontSizes">à luz deste documento ou a qualquer sistema ou equipamento no qual esse Produto possa ser instalado e que não seja exigido neste';
		returnVal += '</td></tr><tr ><td class="fontSizes">documento, o fornecimento de tais conselhos ou assistência não sujeitará o Vendedor a qualquer responsabilidade, seja contratual, legal ou';
		returnVal += '</td></tr><tr ><td class="fontSizes">qualquer outra.';
		returnVal += '</td></tr><tr ><td class="fontSizes">C. Se o Cliente deixar de cumprir os termos de pagamento de qualquer fatura ou se a condição ou responsabilidade financeira ou comercial';
		returnVal += '</td></tr><tr ><td class="fontSizes">do Cliente se tornar prejudicada ou insatisfatória para o Vendedor, este poderá, sem ônus perante o Cliente ou prejuízo a qualquer outro';
		returnVal += '</td></tr><tr ><td class="fontSizes">remédio legal ou equitativo, suspender o cumprimento até que sejam efetuados pagamentos em atraso e recebida comprovação satisfatória';
		returnVal += '</td></tr><tr ><td class="fontSizes">de pagamento.';
		returnVal += '</td></tr><tr ><td class="fontSizes">D. A concessão de qualquer crédito pelo Vendedor ao Cliente está condicionada à satisfação ininterrupta do Vendedor quanto a capacidade';
		returnVal += '</td></tr><tr ><td class="fontSizes">creditícia do Cliente e não estabelecerá nenhum direito de crédito contra o Vendedor. O Vendedor reserva o direito de suspender o crédito e';
		returnVal += '</td></tr><tr ><td class="fontSizes">exigir pagamento em espécie de forma antecipada ou na entrega, por todo ou parte do preço, ou alterar as condições de pagamento com';
		returnVal += '</td></tr><tr ><td class="fontSizes">base em sua avaliação da capacidade creditícia do Cliente a qualquer momento, e a falha do Cliente em satisfazer tais condições de crédito';
		returnVal += '</td></tr><tr ><td class="fontSizes">ou pagamento alteradas constituirão motivos de insegurança para o Vendedor.';
		returnVal += '</td></tr><tr ><td class="fontSizes">XI. Instruções de Operação';
		returnVal += '</td></tr><tr ><td class="fontSizes">A. O Cliente cumprirá e exigirá que seus agentes e funcionários cumpram todas as instruções, avisos de segurança, alertas e outras';
		returnVal += '</td></tr><tr ><td class="fontSizes">instruções fornecidas pelo Vendedor, bem como usará e exigirá que seus agentes e funcionários utilizem cuidados razoáveis no uso dos';
		returnVal += '</td></tr><tr ><td class="fontSizes">Produtos.';
		returnVal += '</td></tr><tr ><td class="fontSizes">B. O VENDEDOR NÃO TERÁ OBRIGAÇÃO OU RESPONSABILIDADE POR QUALQUER FALHA DO CLIENTE, DE SEUS FUNCIONÁRIOS';
		returnVal += '</td></tr><tr ><td class="fontSizes">OU AGENTES, OU QUALQUER TERCEIRO AO OBSERVAR AS DISPOSIÇÕES DESTE CAPÍTULO, OU POR QUALQUER LESÃO OU';
		returnVal += '</td></tr><tr ><td class="fontSizes">DANO CAUSADO, EM TODO OU EM PARTE, PELA FALHA DO CLIENTE EM CUMPRIR OS REQUISITOS DE SEGURANÇA FEDERAIS,';
		returnVal += '</td></tr><tr ><td class="fontSizes">ESTADUAIS OU LOCAIS APLICÁVEIS, E O CLIENTE DEVERÁ INDENIZAR E MANTER O VENDEDOR INDENE DE QUALQUER';
		returnVal += '</td></tr><tr ><td class="fontSizes">RECLAMAÇÃO, RESPONSABILIDADES OU PERDAS DECORRENTES OU CONECTADAS COM QUALQUER LESÃO OU DANO OU';
		returnVal += '</td></tr><tr ><td class="fontSizes">RECLAMAÇÃO.';
		returnVal += '</td></tr><tr ><td class="fontSizes">XII. Termos Adicionais para Pedidos Personalizados de Soluções Cirúrgicas';
		returnVal += '</td></tr><tr ><td class="fontSizes">Os pedidos personalizados para salas de operações integradas, luzes e estativas, e outros equipamentos personalizados para cuidados';
		returnVal += '</td></tr><tr ><td class="fontSizes">cirúrgicos e críticos estarão sujeitos aos Termos e Condições de Venda e Instalação padrão do Vendedor, bem como aos seguintes termos e';
		returnVal += '</td></tr><tr ><td class="fontSizes">condições adicionais:';
		returnVal += '</td></tr><tr ><td class="fontSizes">A. Pagamento. A menos que previsto expressamente de outra forma na Oferta, o pagamento será realizado por meio de depósito não';
		returnVal += '</td></tr><tr ><td class="fontSizes">reembolsável de 30% (trinta por cento) do preço total da compra de qualquer pedido que inclua equipamentos personalizados em favor do';
		returnVal += '</td></tr><tr ><td class="fontSizes">Vendedor dentro do prazo de 10 (dez) dias a contar da data em que o Vendedor receber o pedido de compra do Cliente. O pagamento do';
		returnVal += '</td></tr><tr ><td class="fontSizes">restante do preço de compra deve ser feito dentro do prazo de 30 (trinta) dias a contar da data da fatura do Vendedor.';
		returnVal += '</td></tr><tr ><td class="fontSizes">B. Modificação e Cancelamento. Em caso de modificação do pedido, serão aplicáveis as disposições da cláusula VI.(D) Se o Cliente optar por';
		returnVal += '</td></tr><tr ><td class="fontSizes">cancelar um pedido de compra personalizado, o depósito do Cliente será perdido.';
		returnVal += '</td></tr><tr ><td class="fontSizes">C. Preparação das Instalações. Será aplicada uma taxa de alteração do pedido no valor de USD 2.500,00 (dois mil e quinhentos dólares';
		returnVal += '</td></tr><tr ><td class="fontSizes">americanos) se a equipe de instalação do Vendedor chegar ao estabelecimento do Cliente para uma instalação agendada, mas não puder';
		returnVal += '</td></tr><tr ><td class="fontSizes">concluir o serviço previsto devido à falha do Cliente em preparar o local de acordo com as especificações previamente acordadas.';
		returnVal += '</td></tr><tr ><td class="fontSizes">D. Devolução de Mercadorias. O Cliente não terá direito a qualquer reembolso ou crédito por peças personalizadas, peças usadas ou peças';
		returnVal += '</td></tr><tr ><td class="fontSizes">desprovidas de etiquetas ou embalagens. As mercadorias não podem ser devolvidas sem a aprovação prévia do Vendedor. O Cliente é';
		returnVal += '</td></tr><tr ><td class="fontSizes">responsável por todos os custos de frete associados à devolução de mercadorias após o envio e pode ser obrigado a pagar uma taxa de';
		returnVal += '</td></tr><tr ><td class="fontSizes">reabastecimento.';
		returnVal += '</td></tr><tr ><td class="fontSizes">XIII. Disposições Gerais';
		returnVal += '</td></tr><tr ><td class="fontSizes">A. Nenhum direito do Cliente resultante do relacionamento fabricante/comprador entre o Vendedor e o Cliente, nem qualquer dever do';
		returnVal += '</td></tr><tr ><td class="fontSizes">Vendedor resultante desse relacionamento, serão cedidos sem o consentimento prévio por escrito do Vendedor.';
		returnVal += '</td></tr><tr ><td class="fontSizes">B. A nulidade de qualquer disposição dos Termos do Vendedor não afetará a validade de qualquer outra disposição deste documento e';
		returnVal += '</td></tr><tr ><td class="fontSizes">qualquer disposição inválida será, na medida do possível, modificada para atingir os mesmos objetivos de maneira válida, sem afetar as';
		returnVal += '</td></tr><tr ><td class="fontSizes">demais disposições.';
		returnVal += '</td></tr><tr ><td class="fontSizes">C. Nenhuma falha do Vendedor em exercer qualquer direito resultante do relacionamento fabricante/comprador ou sob qualquer contrato de';
		returnVal += '</td></tr><tr ><td class="fontSizes">vendas firmado com o Cliente representará uma renúncia ou impedirá o exercício do mesmo ou de qualquer outro direito ou privilégio do';
		returnVal += '</td></tr><tr ><td class="fontSizes">Vendedor.';
		returnVal += '</td></tr><tr ><td class="fontSizes">D. Qualquer notificação exigida ou contemplada nos termos deste documento deve ser feita por escrito e entregue pessoalmente ou enviada';
		returnVal += '</td></tr><tr ><td class="fontSizes">por fax ou por correio registrado pré-pago.';
		returnVal += '</td></tr><tr ><td class="fontSizes">E. Não existem outros termos e condições aplicáveis à compra e venda de Produtos do Vendedor além dos contidos na Oferta (incluindo';
		returnVal += '</td></tr><tr ><td class="fontSizes">quaisquer especificações ou outros documentos que o Vendedor incorporou por referência na Oferta ou na fatura). Nenhuma modificação,';
		returnVal += '</td></tr><tr ><td class="fontSizes">aditamento, renúncia ou outra mudança em qualquer disposição dos Termos do Vendedor será vinculante para o Vendedor sem o';
		returnVal += '</td></tr><tr ><td class="fontSizes">consentimento por escrito do mesmo.';
		returnVal += '</td></tr><tr ><td class="fontSizes">F. Os direitos e obrigações do Cliente e do Vendedor, e a interpretação e os efeitos de qualquer contrato firmado entre eles serão regidos';
		returnVal += '</td></tr><tr ><td class="fontSizes">pelas leis do Estado de Ohio.';
		returnVal += '</td></tr><tr ><td class="fontSizes">G. Nenhuma indicação em uma remessa de pagamento ou similar de que um pagamento em valor inferior ao total de uma ou mais faturas ou';
		returnVal += '</td></tr><tr ><td class="fontSizes">outras obrigações constituiria seu pagamento integral será efetivo e nenhum acordo e satisfação, crédito ou transação serão efetivos, a';
		returnVal += '</td></tr><tr ><td class="fontSizes">menos que o Vendedor concorde expressamente com isso por escrito.';
		returnVal += '</td></tr><tr ><td class="fontSizes">TERMOS E CONDIÇÕES DE INSTALAÇÃO DA STERIS CORPORATION';
		returnVal += '</td></tr><tr ><td class="fontSizes">(quando a instalação é adquirida pelo Vendedor)';
		returnVal += '</td></tr><tr ><td class="fontSizes">I. Definições Gerais e Escopo de Responsabilidades';
		returnVal += '</td></tr><tr ><td class="fontSizes">1. Os Termos do Vendedor anexados a este documento são incorporados por referência aqui.';
		returnVal += '</td></tr><tr ><td class="fontSizes">2. O Vendedor não será responsável por outros serviços que não sejam prestados por fontes contratadas pelo Vendedor ou pelo Vendedor, a';
		returnVal += '</td></tr><tr ><td class="fontSizes">menos que autorizado por escrito pelo Vendedor.';
		returnVal += '</td></tr><tr ><td class="fontSizes">3. Todo o trabalho será realizado durante o horário normal de trabalho: das 9:00 às 18:00, de segunda a sexta-feira. Feriados e horas extras';
		returnVal += '</td></tr><tr ><td class="fontSizes">exigirão custos adicionais.';
		returnVal += '</td></tr><tr ><td class="fontSizes">4. Trabalho não sindicalizado será usado.';
		returnVal += '</td></tr><tr ><td class="fontSizes">5. O Vendedor não será responsável pela limpeza de todos os materiais de embalagem, caixas, engradados e/ou outros detritos de';
		returnVal += '</td></tr><tr ><td class="fontSizes">transporte/instalação do equipamento.';
		returnVal += '</td></tr><tr ><td class="fontSizes">6. Peças e mão-de-obra necessárias para reparar danos causados por acidente, abuso, desastre natural, incêndio ou furto, uso indevido do';
		returnVal += '</td></tr><tr ><td class="fontSizes">equipamento operacional para funções/processos não originalmente projetados ou recomendados, ou alteração/modificação do equipamento';
		returnVal += '</td></tr><tr ><td class="fontSizes">ou acessórios após a montagem e teste finais do Vendedor, devem ser fornecidos pelo Cliente e não serão custeados pelo Vendedor.';
		returnVal += '</td></tr><tr ><td class="fontSizes">7. A menos que incluído especificamente no escopo do contrato, a STERIS não será responsável por medidas de controle de infecção.';
		returnVal += '</td></tr><tr ><td class="fontSizes">8. Onde permitido, o Vendedor realizará a conexão às instalações fornecidas pelo Cliente a menos de um metro do ponto final de conexão. As';
		returnVal += '</td></tr><tr ><td class="fontSizes">instalações não devem ser separados do ponto de conexão do equipamento por barreiras físicas, como paredes, tetos ou outros';
		returnVal += '</td></tr><tr ><td class="fontSizes">impedimentos.';
		returnVal += '</td></tr><tr ><td class="fontSizes">II. Responsabilidade do Cliente - PREPARAÇÃO DO LOCAL';
		returnVal += '</td></tr><tr ><td class="fontSizes">1. Barreiras de controle de infecção, tal como considerados necessários pela avaliação de controle de risco de infecção das instalações, a';
		returnVal += '</td></tr><tr ><td class="fontSizes">serem projetadas, instaladas e monitoradas pelo Cliente.';
		returnVal += '</td></tr><tr ><td class="fontSizes">2. Remoção de todo o amianto e/ou outros materiais perigosos das dependências do equipamento e áreas limítrofes, além do descarte seguro';
		returnVal += '</td></tr><tr ><td class="fontSizes">destes materiais, de acordo com os códigos locais/estaduais/federais, antes da instalação e/ou remoção do equipamento.';
		returnVal += '</td></tr><tr ><td class="fontSizes">3. Obter ou incorrer em despesas para a obtenção de quaisquer/todas as permissões, aprovações, licenças, certificação, taxas e testes de';
		returnVal += '</td></tr><tr ><td class="fontSizes">fonte, locais ou não, que possam ser necessários para a instalação ou operação do equipamento que está sendo instalado.';
		returnVal += '</td></tr><tr ><td class="fontSizes">4. Preparação do local para permitir a instalação do equipamento, de acordo com os desenhos do equipamento/documentação técnica do';
		returnVal += '</td></tr><tr ><td class="fontSizes">Vendedor, para incluir paredes, pisos, ralos, tetos, conexões de instalações prediais, incluindo drip-legs e reguladores de pressão, e';
		returnVal += '</td></tr><tr ><td class="fontSizes">quaisquer/todas as modificações estruturais necessárias no edifício, incluindo superestrutura acima do teto e/ou do suporte de parede e';
		returnVal += '</td></tr><tr ><td class="fontSizes">reforço do piso.';
		returnVal += '</td></tr><tr ><td class="fontSizes">5. Fornecimento de laje, parede, piso, localização de ancoragem e/ou estrutura adequada para aceitar dispositivos de amarração sísmica,';
		returnVal += '</td></tr><tr ><td class="fontSizes">conforme especificado nos desenhos/documentação técnica dos equipamentos do Vendedor. Se for necessário parafuso passante ou raio-x';
		returnVal += '</td></tr><tr ><td class="fontSizes">devido a limitações estruturais, o Cliente deverá fornecer.';
		returnVal += '</td></tr><tr ><td class="fontSizes">6. Instalação de qualquer um dos respiradouros de exaustão do edifício, além do ponto de terminação do respiradouro do fabricante,';
		returnVal += '</td></tr><tr ><td class="fontSizes">conforme designado nos desenhos do equipamento/documentação técnica do Vendedor, e garantia de que todo o sistema HVAC é adequado';
		returnVal += '</td></tr><tr ><td class="fontSizes">para lidar com a(s) carga(s) esperada(s) com o novo equipamento.';
		returnVal += '</td></tr><tr ><td class="fontSizes">7. Assegurar-se de que todas as aberturas de portas, corredores e áreas a caminho da área de recebimento até o local da instalação estejam';
		returnVal += '</td></tr><tr ><td class="fontSizes">desobstruídas e permitam o transporte do equipamento sem necessidade de desmontagem ou de remover/modificar quaisquer esquadrias de';
		returnVal += '</td></tr><tr ><td class="fontSizes">portas, tetos, armários ou outras estruturas da instalação. Fornecer proteção de piso.';
		returnVal += '</td></tr><tr ><td class="fontSizes">8. Forneça todas as instalações (vapor, água, ar comprimido, retorno de condensado, drenagem de resíduos, elétrica, exaustão,';
		returnVal += '</td></tr><tr ><td class="fontSizes">telecomunicações, dados) de acordo com os códigos locais/estaduais/federais e os desenhos e documentação técnica dos equipamentos do';
		returnVal += '</td></tr><tr ><td class="fontSizes">Vendedor.';
		returnVal += '</td></tr><tr ><td class="fontSizes">9. Fornecimento e instalação de todas as desconexões elétricas e terminação final nos equipamentos do Vendedor, conforme especificado';
		returnVal += '</td></tr><tr ><td class="fontSizes">nos desenhos dos equipamentos do Vendedor e de acordo com os códigos locais/estaduais/federais.';
		returnVal += '</td></tr><tr ><td class="fontSizes">	';
		returnVal += '</td></tr><tr ><td class="fontSizes">10. Fornecimento e instalação de válvulas de desligamento abaixo do teto, de fácil alcance e à vista para paradas de emergência ou de';
		returnVal += '</td></tr><tr ><td class="fontSizes">serviço, conforme especificado nos desenhos de equipamentos do Vendedor e de acordo com os códigos locais/estaduais/federais.';
		returnVal += '</td></tr><tr ><td class="fontSizes">11. Fornecimento de iluminação adequada nas áreas de serviço do equipamento.';
		returnVal += '</td></tr><tr ><td class="fontSizes">12. Fornecimento de área de serviço adequada ao redor do equipamento, conforme especificado nos desenhos de equipamentos do';
		returnVal += '</td></tr><tr ><td class="fontSizes">Vendedor e de acordo com os códigos locais/estaduais/federais.';
		returnVal += '</td></tr><tr ><td class="fontSizes">III. Responsabilidades do Cliente - RECEBIMENTO';
		returnVal += '</td></tr><tr ><td class="fontSizes">1. Fornecimento de doca de carregamento com capacidade para entregas com porta traseira manual.';
		returnVal += '</td></tr><tr ><td class="fontSizes">2. Se o transporte vertical for necessário devido ao acesso limitado a pisos superiores ou inferiores através de escadas, limitações de';
		returnVal += '</td></tr><tr ><td class="fontSizes">elevadores, etc., o Cliente será responsável por todos/quaisquer encargos adicionais.';
		returnVal += '</td></tr><tr ><td class="fontSizes">3. Recebimento e inspeção dos novos equipamentos quanto a danos no transporte e armazenamento em uma área';
		returnVal += '</td></tr><tr ><td class="fontSizes">segura e protegida contra as intempéries, dentro do edifício designado para inspeção final ou providência de transporte e armazenamento';
		returnVal += '</td></tr><tr ><td class="fontSizes">externo, agendando a remessa a tempo da inspeção final.';
		returnVal += '</td></tr><tr ><td class="fontSizes">4. O Vendedor precisará de 2 (duas) semanas de aviso prévio antes de iniciar o trabalho de instalação, com acesso livre ao(s) local(is) do';
		returnVal += '</td></tr><tr ><td class="fontSizes">equipamento final.';
		returnVal += '</td></tr><tr ><td class="fontSizes">5. Se o equipamento removido se tornar propriedade do Vendedor, ele será mantido no local no local designado para retirada pelo transporte';
		returnVal += '</td></tr><tr ><td class="fontSizes">contratado pelo Vendedor dentro de um prazo razoável.';
		returnVal += '</td></tr><tr ><td class="fontSizes">IV. Responsabilidades do Cliente - INSTALAÇÕES';
		returnVal += '</td></tr><tr ><td class="fontSizes">A. VAPOR:';
		returnVal += '</td></tr><tr ><td class="fontSizes">1. Pressão - a pressão dinâmica deve atender às especificações dos desenhos e documentação técnica do equipamento do Vendedor; deve';
		returnVal += '</td></tr><tr ><td class="fontSizes">fornecer reguladores de pressão de vapor e válvulas de fechamento onde/quando especificado.';
		returnVal += '</td></tr><tr ><td class="fontSizes">2. Qualidade - fornecimento de purgadores de vapor, isolamento e roteamento de tubos necessários para fornecer 97% (noventa e sete por';
		returnVal += '</td></tr><tr ><td class="fontSizes">cento) de vapor.';
		returnVal += '</td></tr><tr ><td class="fontSizes">B. AR:';
		returnVal += '</td></tr><tr ><td class="fontSizes">1. Pressão - a pressão dinâmica deve atender às especificações dos desenhos e documentação técnica do equipamento do Vendedor;';
		returnVal += '</td></tr><tr ><td class="fontSizes">reguladores de ar devem ser fornecidos onde especificado.';
		returnVal += '</td></tr><tr ><td class="fontSizes">2. Qualidade - fornecimento de filtros/secadores necessários para fornecer qualidade do ar conforme especificada nos desenhos e';
		returnVal += '</td></tr><tr ><td class="fontSizes">documentação técnica do equipamento do Vendedor.';
		returnVal += '</td></tr><tr ><td class="fontSizes">C. ÁGUA:';
		returnVal += '</td></tr><tr ><td class="fontSizes">1. Pressão - a pressão dinâmica deve atender às especificações dos desenhos e documentação técnica do equipamento do Vendedor;';
		returnVal += '</td></tr><tr ><td class="fontSizes">reguladores de pressão da água devem ser fornecidos onde especificado.';
		returnVal += '</td></tr><tr ><td class="fontSizes">2. Vazões - a tubulação deve ser dimensionada adequadamente para evitar golpe de aríete; fornecimento de tubos e supressores de golpe de';
		returnVal += '</td></tr><tr ><td class="fontSizes">aríete de tamanho correto, a fim de suportar as taxas e pressões do fluxo de água, conforme especificado nos desenhos e documentação';
		returnVal += '</td></tr><tr ><td class="fontSizes">técnica do equipamento do Vendedor e de acordo com os códigos locais/estaduais/federais para prevenção de retorno de fluxo.';
		returnVal += '</td></tr><tr ><td class="fontSizes">3. Qualidade - a água fornecida pode ser tratada conforme necessário, mas deve atender às especificações de qualidade nos desenhos e';
		returnVal += '</td></tr><tr ><td class="fontSizes">documentação técnica do equipamento do Vendedor.';
		returnVal += '</td></tr><tr ><td class="fontSizes">D. EXAUSTÃO:';
		returnVal += '</td></tr><tr ><td class="fontSizes">1. Fornecimento de fluxo de exaustão de ar (SCFM) conforme especificado nos desenhos e documentação técnica do equipamento do';
		returnVal += '</td></tr><tr ><td class="fontSizes">Vendedor.';
		returnVal += '</td></tr><tr ><td class="fontSizes">E. RESÍDUOS:';
		returnVal += '</td></tr><tr ><td class="fontSizes">1. Fornecimento de dreno(s) adequado(s), dimensionado(s) para lidar com as taxas de fluxo de água/vapor, conforme especificado nos';
		returnVal += '</td></tr><tr ><td class="fontSizes">desenhos e documentação técnica do equipamento do Vendedor e armadilhas, conforme exigido pelos códigos locais/estaduais/federais.';
		returnVal += '</td></tr><tr ><td class="fontSizes">F. ELÉTRICA:';
		returnVal += '</td></tr><tr ><td class="fontSizes">1. Fornecimento de alimentação elétrica conforme especificado nos desenhos e documentação técnica do equipamento do Vendedor, com';
		returnVal += '</td></tr><tr ><td class="fontSizes">chaves seccionadoras de bloqueio, conforme exigido pelos códigos locais/estaduais/federais.';
		returnVal += '</td></tr><tr ><td class="fontSizes">G. EXAUSTÃO ATMOSFÉRICA:';
		returnVal += '</td></tr><tr ><td class="fontSizes">1. Fornecimento de tubulação de exaustão atmosférica para válvulas de alívio de pressão, conforme exigido pelos códigos';
		returnVal += '</td></tr><tr ><td class="fontSizes">locais/estaduais/federais. Fornecer exaustão.';
		returnVal += '</td></tr><tr ><td class="fontSizes">H. TELECOMUNICAÇÕES:';
		returnVal += '</td></tr><tr ><td class="fontSizes">1. Receber orientações do suporte técnico da STERIS antes do envio de um técnico.';
		returnVal += '</td></tr><tr ><td class="fontSizes">2. Permitir que a STERIS monitore todos os equipamentos conectados no ProConnect® Response Center';
		returnVal += '</td></tr><tr ><td class="fontSizes">3. Requisitos do Computador:';
		returnVal += '</td></tr><tr ><td class="fontSizes">a) Desktop, servidor ou computador virtual que atenda aos seguintes requisitos mínimos de hardware/software para executar o software de';
		returnVal += '</td></tr><tr ><td class="fontSizes">monitoramento, de agente de serviço e de suporte do ProConnect Remote Monitoring.';
		returnVal += '</td></tr><tr ><td class="fontSizes">b) Windows Server 2008 R2 / 2012/2016, Windows 7 de 64 bits ou Windows 10 com os service packs mais recentes. As notificações do UAC';
		returnVal += '</td></tr><tr ><td class="fontSizes">devem estar desativadas';
		returnVal += '</td></tr><tr ><td class="fontSizes">c) Processador Multi-core de 2.5 GHz';
		returnVal += '</td></tr><tr ><td class="fontSizes">d) 6 GB ram';
		returnVal += '</td></tr><tr ><td class="fontSizes">e) 50 GB de espaço livre no disco rígido';
		returnVal += '</td></tr><tr ><td class="fontSizes">f) Microsoft.Net Framework 4.5 ou superior';
		returnVal += '</td></tr><tr ><td class="fontSizes">g) Conta de administrador local da STERIS atribuída';
		returnVal += '</td></tr><tr ><td class="fontSizes">h) Conectado na rede da instalação';
		returnVal += '</td></tr><tr ><td class="fontSizes">i) Acesso contínuo à Internet pela porta 443';
		returnVal += '</td></tr><tr ><td class="fontSizes">4. Requisitos de rede no equipamento';
		returnVal += '</td></tr><tr ><td class="fontSizes">a) Uma rede TCP/IP 10/100 BaseT Ethernet ativa com um conector RJ45 a 10\' de cada unidade';
		returnVal += '</td></tr><tr ><td class="fontSizes">b) É necessário um endereço IP reservado estático ou DHCP para cada unidade';
		returnVal += '</td></tr><tr ><td class="fontSizes">c) Cabos Ethernet para conectar cada unidade ao conector RJ45 fornecido';
		returnVal += '</td></tr><tr ><td class="fontSizes">d) Se o acesso físico ao computador executando o software ProConnect não for factível, algum método de acesso remoto, como a Área de';
		returnVal += '</td></tr><tr ><td class="fontSizes">Trabalho Remota, deve ser ativado';
		returnVal += '</td></tr><tr ><td class="fontSizes">e) Alguns equipamentos requerem energia de 120 VCA para um roteador externo';
		returnVal += '</td></tr><tr ><td class="fontSizes">V. Questões Ambientais e de Segurança';
		returnVal += '</td></tr><tr ><td class="fontSizes">1. HAZARD COMMUNICATION - Customer agrees to provide Seller with information as to all hazards or hazardous materials which Seller\'s';
		returnVal += '</td></tr><tr ><td class="fontSizes">personnel may encounter when performing services for Customer and to familiarize Seller, its employees and contractors with Customer\'s';
		returnVal += '</td></tr><tr ><td class="fontSizes">Hazard Communication Program. If Customer\'s facility has an asbestos maintenance plan, the applicability of the plan to Seller\'s services must';
		returnVal += '</td></tr><tr ><td class="fontSizes">be specifically pointed out to Seller, and a copy of the plan must be provided to Seller prior to Seller\'s commencement of work. Customer shall';
		returnVal += '</td></tr><tr ><td class="fontSizes">ensure the safety of the work area and of Seller\'s employees and agrees to defend, indemnify and hold Seller, its employees and contractors,';
		returnVal += '</td></tr><tr ><td class="fontSizes">and their insurers (the \'Indemnified Parties\') harmless from any and all claims, demands, losses, liabilities, fines, penalties (including but not';
		returnVal += '</td></tr><tr ><td class="fontSizes">limited to OSHA penalties), costs (including but not limited to attorney\'s fees) or other liability suffered or incurred by the Indemnified Parties as';
		returnVal += '</td></tr><tr ><td class="fontSizes">a result of Customers failure to do so.';
		returnVal += '</td></tr><tr ><td class="fontSizes">2. UNEXPECTED OR HAZARDOUS CONDITIONS - If unforeseen conditions are discovered (such as the discovery of hazardous substances';
		returnVal += '</td></tr><tr ><td class="fontSizes">or conditions) which may increase the time or expense of performance, Seller shall be entitled to additional compensation for the effects of';
		returnVal += '</td></tr><tr ><td class="fontSizes">such unexpected conditions. If Seller and Customer cannot agree on such additional compensation, Seller may stop work without liability and';
		returnVal += '</td></tr><tr ><td class="fontSizes">Customer shall pay Seller for any services already performed, at Seller\'s hourly rates. If Seller encounters materials which it believes may be';
		returnVal += '</td></tr><tr ><td class="fontSizes">hazardous, Seller may suspend its services until adequate testing and analysis have been conducted to confirm whether such materials are';
		returnVal += '</td></tr><tr ><td class="fontSizes">hazardous or not. In no event shall Seller or its contractors be responsible for the removal, abatement or disposal of any hazardous materials';
		returnVal += '</td></tr><tr ><td class="fontSizes">(including but not limited to asbestos, asbestos containing materials, hazardous waste, or infectious waste).</td></tr>';

		return returnVal;
	}
	public String getTermsBRL(){
		String returnVal = '';
		returnVal += '<tr ><td class="fontSizes">I. Oferta e Aceitação		';
		returnVal += '</td></tr><tr ><td class="fontSizes">A. O Cliente concorda que este orçamento constitui uma oferta da STERIS Brasil (“Vendedor”) para a venda (a “Oferta”) de produtos (os';
		returnVal += '“Produtos”) ou serviços (os “Serviços”). Salvo estipulação em contrário nesta Oferta ou em algum outro documento assinado pelo Vendedor,';
		returnVal += 'os termos e condições de venda estabelecidos neste documento (“Termos do Vendedor”) se aplicam a todos os Produtos e Serviços vendidos';
		returnVal += 'ou fornecidos pelo Vendedor.		';
		returnVal += '</td></tr><tr ><td class="fontSizes">B. O Cliente reconhece que qualquer pedido de compra ou outra forma de aceitação emitida pelo Cliente resultará em um contrato de';
		returnVal += 'compra dos Produtos ou Serviços pelo preço indicado na Oferta. Considera-se que o Cliente aceitou qualquer um dos Termos do Vendedor';
		returnVal += 'aos quais o Cliente não se opôs especificamente. A emissão pelo Cliente de um pedido de compra que pretende rejeitar alguns ou todos os';
		returnVal += 'Termos do Vendedor do formulário padrão não será objeção suficiente.		';
		returnVal += '</td></tr><tr ><td class="fontSizes">C. O Cliente deverá estabelecer cada objeção aos Termos do Vendedor por escrito, assinado e datado pelo Cliente e entregue ao Vendedor';
		returnVal += 'antes ou simultaneamente do pedido de compra do Cliente ou outra forma de aceitação. A falha do Vendedor em se opor às disposições de';
		returnVal += 'qualquer pedido de compra ou outra comunicação do Cliente (incluindo, mas não se limitando a cláusulas de penalidade de qualquer tipo),';
		returnVal += 'não constituirá uma renúncia aos Termos do Vendedor nem uma aceitação pelo Vendedor de tais disposições.		';
		returnVal += '</td></tr><tr ><td class="fontSizes">D. Quaisquer termos do pedido de compra do Cliente ou qualquer documento de aceitação que seja diferente ou adicional aos Termos do';
		returnVal += 'Vendedor são, desde já, rejeitados, a menos que sejam especificamente aceitos pelo Vendedor em documento separado assinado pelo';
		returnVal += 'Cliente e pelo Vendedor, ainda que aqueles termos alterassem materialmente os termos deste documento.		';
		returnVal += '</td></tr><tr ><td class="fontSizes">E. Nenhum curso de negociação, costume ou uso que seja contrário aos Termos do Vendedor será aplicável.		';
		returnVal += '</td></tr><tr ><td class="fontSizes">F. O Vendedor se reserva o direito de corrigir qualquer erro tipográfico ou formal nos preços, especificações, orçamentos ou recibos.		';
		returnVal += '</td></tr><tr ><td class="fontSizes">II. Produtos ou Serviços Sujeitos a Venda';
		returnVal += 'Os Produtos (incluindo equipamentos, suprimentos e peças) ou Serviços sujeitos a esta venda serão limitados aos descritos na Oferta. A';
		returnVal += 'menos que explicitamente incluído na Oferta, esse orçamento não inclui, e o Cliente assume a responsabilidade por:		';
		returnVal += '</td></tr><tr ><td class="fontSizes">A. Todas as interligações a serviços públicos, alvarás e outros requisitos regulatórios, conforme aplicável;		';
		returnVal += '</td></tr><tr ><td class="fontSizes">B. Remoções, configuração, instalação e ativação.		';
		returnVal += '</td></tr><tr ><td class="fontSizes">III. Condição Financeira		';
		returnVal += '</td></tr><tr ><td class="fontSizes">A pedido do Vendedor, o Cliente fornecerá informações suficientes para permitir que o Vendedor avalie a capacidade de crédito do Cliente. O';
		returnVal += 'Vendedor pode, a seu critério, exigir cartas de crédito, pagamento total ou parcial antecipado ou outras formas de garantia.		';
		returnVal += '</td></tr> <tr class="html2pdf__page-break"><td>';
		returnVal += '</td></tr><tr ><td class="fontSizes">IV. Preços, Remessa e Entrega		';
		returnVal += '</td></tr><tr ><td class="fontSizes">A. Os preços são baseados reais (Brasileiro) a menos que de outra forma esteja expressamente previsto na Oferta.		';
		returnVal += '</td></tr><tr ><td class="fontSizes">B. Qualquer data de remessa, entrega ou desempenho declarada na Oferta ou em outro documento do contrato é apenas aproximada e não';
		returnVal += 'constitui qualquer garantia de remessa, entrega ou desempenho em qualquer data específica.		';
		returnVal += '</td></tr><tr ><td class="fontSizes">C. O Vendedor poderá, conforme negociado nos termos e condições comerciais de sua proposta, entregar, sem custos ao Cliente, os		';
		returnVal += '</td></tr><tr ><td class="fontSizes"> D. O içamento e o deslocamento interno do(s) equipamento(s) do almoxarifado ou estoque até seu local de instalação são de';
		returnVal += 'responsabilidade do Cliente. Caso seja necessária a contratação de serviços de içamento e/ou de deslocamento interno, o Vendedor poderá';
		returnVal += 'auxiliar no processo, no entanto, estes custos serão negociados de modo apartado, sendo o Cliente responsável por seu pagamento.		';
		returnVal += '</td></tr><tr ><td class="fontSizes">E. Em casos onde o frete negociado com o cliente seja a modalidade Cliente Retira, o Vendedor poderá, a seu exclusivo critério, cobrar';
		returnVal += 'taxas de armazenamento, caso o Cliente não retire o equipamento em até 5 (cinco) dias úteis contados a partir da data de comunicação de';
		returnVal += 'liberação para sua retirada.';
		returnVal += '</td></tr><tr ><td class="fontSizes">F. O tempo não será condição essencial deste contrato.';
		returnVal += '</td></tr><tr ><td class="fontSizes">V. Pagamentos';
		returnVal += '</td></tr><tr ><td class="fontSizes">A. Todos os pagamentos serão feitos na moeda real. Todos os pagamentos serão efetuados sem dedução de cobranças adicionais, outras';
		returnVal += 'contas entre o Vendedor e o Cliente e similares, as quais serão liquidadas independentemente do pagamento da fatura. O pagamento não';
		returnVal += 'prejudicará as reivindicações por conta de omissões ou falhas na remessa, mas tais reivindicações não serão permitidas a menos que sejam';
		returnVal += 'feitas dentro de 96 (noventa e seis) horas após o recebimento pelo Cliente da remessa aplicável.';
		returnVal += '</td></tr><tr ><td class="fontSizes">B. O pagamento será devido conforme condições de pagamento pré acordadas.';
		returnVal += '</td></tr><tr ><td class="fontSizes">C. Na hipótese de o Cliente atrasar o pagamento após a data de vencimento, poderá ser cobrado, mensalmente, juros na taxa de 1,5% (um';
		returnVal += 'e meio por cento) ou à taxa máxima permitida por lei sobre o saldo do valor não pago, o que for menor.';
		returnVal += '</td></tr><tr ><td class="fontSizes">D. A produção do(s) equipamento(s) e/ou seu embarque, somente será(ão) iniciada(o) quando houver a aprovação da linha de crédito do';
		returnVal += 'cliente, comprovada através de documentação de suporte, tais como contrato, entre outros. A entrega do(s) equipamento(s) e/ou sua retirada,';
		returnVal += 'somente será liberada quando o montante devido tiver sido depositado na conta corrente do Vendedor.';
		
		returnVal += '</td></tr> <tr class="html2pdf__page-break"><td>';
		returnVal += '</td></tr><tr ><td class="fontSizes">VI. Garantia e Instalação:';
		returnVal += '</td></tr><tr ><td class="fontSizes">A. O Vendedor concede garantia ao(s) equipamentos de toda sua linha IPT (Infection Prevention Tecnologies), e SS (Surgical Solutions)';
		returnVal += 'pelo período legal de 90 (noventa) dias contra defeitos de fabricação na conformidade da Lei 8.078 de 11/09/1990, adicionados ao período';
		returnVal += 'complementar de 270 (duzentos e setenta) dias, concedidos por liberalidade pela boa conduta de manutenções preventivas e corretivas em';
		returnVal += 'conformidade e observância ao Manual e Instruções de Uso, Operações e Manutenções, perfazendo no total 360 (trezentos e sessenta) dias.';
		returnVal += '</td></tr><tr ><td class="fontSizes">B. O período de garantia legal e a garantia complementar iniciar-se-ão a partir da data de instalação do equipamento ou 180 (cento e';
		returnVal += 'oitenta) dias após a entrega no local definido pelo cliente na compra (o que acontecer primeiro). Para sua validade e mantimento, se faz';
		returnVal += 'necessária a realização de todas as manutenções preventivas e corretivas em conformidade e observância ao Manual e Instruções de Uso,';
		returnVal += 'Operações e Manutenções.';
		returnVal += '</td></tr><tr ><td class="fontSizes">C. O Vendedor disponibiliza assistência técnica em todo o território nacional rede(s) de assistência(s) técnica(s), rede de autorizada(s), rede';
		returnVal += 'de credenciada(s) e, também, sua equipe de assistência técnica direta.';
		returnVal += '</td></tr><tr ><td class="fontSizes">D. A instalação dos itens constantes nesta proposta, se contratada, será composta pelas etapas a seguir:';
		returnVal += '</td></tr><tr ><td class="fontSizes">1.1 - Interligações elétricas, hidráulicas e pneumáticas (se aplicável) a rede, com base no lay-out de instalação e assentamento previamente';
		returnVal += 'fornecidos pelo Vendedor.';
		returnVal += '</td></tr><tr ><td class="fontSizes">1.2 - Start-up, instalações e ajustes que se façam necessários.';
		returnVal += '</td></tr><tr ><td class="fontSizes">1.3 - Testes operacionais em vazio e com carga.';
		returnVal += '</td></tr><tr ><td class="fontSizes">1.4 - A execução dos serviços contratados, devem ser programados pelo Cliente e agendado com a departamento de SAC do Vendedor.';
		returnVal += '</td></tr><tr ><td class="fontSizes">1.5 - A impossibilidade da realização dos serviços contratados, por força de ausência das utilidades, área disponível ou qualquer outro fator';
		returnVal += 'de responsabilidade do Cliente não a isenta de liquidar os eventos financeiros acordados e constantes da proposta comercial.';
		returnVal += '</td></tr><tr ><td class="fontSizes">1.6 - Todas as utilidades para a realização dos serviços ora contratados, tais como qualidade da água, energia elétrica, água, ar comprimido,';
		returnVal += 'mão-de-obra interna, endotoxinas, teste bowie dick e indicadores químicos e/ou biológicos próprios ou de terceiros e estudos microbiológicos';
		returnVal += 'são de responsabilidade do Cliente';
		returnVal += '</td></tr><tr ><td class="fontSizes">1.7 - Caso a instalação seja contratada, o Vendedor fornecerá mão-de-obra especializada, todas as ferramentas e padrões necessários para';
		returnVal += 'a execução dos serviços.';
		returnVal += '</td></tr><tr ><td class="fontSizes">1.8 - O assentamento do equipamento no local de instalação é de responsabilidade do Cliente, e deverá basear-se no lay-out de instalação e';
		returnVal += 'assentamento fornecidos pelo vendedor.';
		returnVal += '</td></tr><tr ><td class="fontSizes">1.9 - As qualificações de instalação, de operação e de performance, que compõem a validação do processo, são de responsabilidade do';
		returnVal += 'Cliente, salvo se contratado e expresso em pedido ou contrato.';
		returnVal += '</td></tr> <tr class="html2pdf__page-break"><td>';
		returnVal += '</td></tr><tr ><td class="fontSizes">1.10 - O local, sua eventual adequação, as instalações elétricas, hidráulicas e pneumáticas (se aplicável) e qualidade de água em';
		returnVal += 'conformidade com as normativas vigentes e deverão ser fornecidas pelo Cliente.';
		returnVal += '</td></tr><tr ><td class="fontSizes">1.11 - As especificações de fornecimento de água aos equipamentos de termodesinfecção (lavadoras) e esterilização de alta temperatura,';
		returnVal += 'devem respeitar as normativas vigentes.';
		returnVal += '</td></tr><tr ><td class="fontSizes">1.12 - Caso a instalação seja contratada, o(s) preço(s) ofertado(s) nesta proposta inclui(em) o(s) Kit(s) instalação(ões) em conformidade com';
		returnVal += 'lay-out e/ou projeto de instalação elaborado pelo Vendedor e entregue ao Cliente';
		returnVal += '</td></tr><tr ><td class="fontSizes">1.13 - Caso a instalação seja contratada, o(s) preço(s) ofertado(s) nesta proposta não inclui(em) o(s) valor(es) referente(s) a viagem (traslado,';
		returnVal += 'passagem e estadia) e devem(rão) ser contratados e/ou pago(s) pelo Cliente.';
		returnVal += '</td></tr><tr ><td class="fontSizes">1.14. O assentamento do(s) equipamento(s) constantes nesta proposta no local de instalação e funcionamento são de responsabilidade do';
		returnVal += 'Cliente, que deverá basear-se no lay-out de instalação e assentamento previamente fornecido pelo Vendedor, salvo informações contrárias';
		returnVal += 'inclusas na proposta comercial.';
		returnVal += '</td></tr><tr ><td class="fontSizes">1.15 - Todas as obras civis (remoção, cortes e construção de paredes, montagens de portas, batentes, cortes de lajes, entre outros), se';
		returnVal += 'necessário for para assentamento do(s) produto(s) ofertado(s) nesta proposta, são de responsabilidade do Cliente.';
		returnVal += '</td></tr><tr ><td class="fontSizes">1.16- O Vendedor poderá realizar, caso contratado, treinamento técnico local (no Brasil) realizado por seu pessoal e/ou através de parceiro';
		returnVal += 'comercial / técnico local. Este treinamento, será efetuado para 1 (hum) engenheiro do cliente que vier a operar ou prestar atendimentos';
		returnVal += 'técnicos aos equipamentos. Este treinamento tem como objetivo apoiar usuários e membros da engenharia clínica do cliente a identificar e';
		returnVal += 'realizar o primeiro atendimento caso este se faça necessário.';
		returnVal += '</td></tr><tr ><td class="fontSizes">1.17- O Vendedor realizará treinamento operacional de cada tecnologia adquirida, conforme datas e horários a serem acordados entre as';
		returnVal += 'partes. Caso contratado, O Vendedor poderá disponibilizar treinamento técnico operacional em sua(s) fábrica(s), sob forma de estágio e com';
		returnVal += 'prévio agendamento.';
		returnVal += '</td></tr><tr ><td class="fontSizes">1.18- O Vendedor, em acordo com o cliente, poderá realizar treinamento para reciclagem dos conceitos básicos de esterilização e utilização';
		returnVal += 'de equipamentos cirúrgicos e, também, de sua aplicabilidade nas tecnologias adquiridas;';
		
		returnVal += '</td></tr> <tr class="html2pdf__page-break"><td>';
		returnVal += '</td></tr><tr ><td class="fontSizes">VII. Questões Ambientais e de Segurança';
		returnVal += '</td></tr><tr ><td class="fontSizes">A. COMUNICAÇÃO DE RISCO.';
		returnVal += '</td></tr><tr ><td class="fontSizes">O Cliente concorda em fornecer ao Vendedor informações sobre todos os perigos ou materiais perigosos que o pessoal do Vendedor pode';
		returnVal += 'encontrar ao realizar serviços para o Cliente e familiarizar o Vendedor, seus funcionários e contratados com o Programa de Comunicação de';
		returnVal += 'Risco do Cliente. Se a instalação do Cliente tiver um plano de manutenção de amianto, a aplicabilidade do plano aos serviços do Vendedor';
		returnVal += 'deve ser especificamente apontada para o Vendedor, e uma cópia do plano deve ser fornecida ao Vendedor antes do início do trabalho do';
		returnVal += 'Vendedor.';
		returnVal += '</td></tr><tr ><td class="fontSizes">O Cliente deve garantir a segurança da área de trabalho e dos funcionários do Vendedor e concorda em defender, indenizar e manter o';
		returnVal += 'Vendedor, seus funcionários e contratados, e suas seguradoras (as \'Partes Indenizadas\') protegidas de toda e qualquer sinistro, demandas,';
		returnVal += 'perdas, passivos, multas, penalidades (incluindo, mas não se limitando às penalidades da OSHA), custos (incluindo, mas não limitados a';
		returnVal += 'honorários advocatícios) ou outras responsabilidades sofridas ou incorridas pelas Partes Indenizadas como resultado de não fazer Então.';
		returnVal += '</td></tr><tr ><td class="fontSizes">B. CONDIÇÕES INESPERADAS OU PERIGOSAS.';
		returnVal += '</td></tr><tr ><td class="fontSizes">Se forem descobertas condições imprevistas (como a descoberta de substâncias ou condições perigosas) que podem aumentar o tempo ou a';
		returnVal += 'despesa de desempenho, o Vendedor terá direito a compensação adicional pelos efeitos de tais condições inesperadas. Se o Vendedor e o';
		returnVal += '</td></tr><tr ><td class="fontSizes">Cliente não concordarem com tal compensação adicional, o Vendedor poderá parar o trabalho sem responsabilidade e o Cliente pagará ao';
		returnVal += 'Vendedor por quaisquer serviços já realizados, a preços por hora do Vendedor. Se o Vendedor encontrar materiais que acredita serem';
		returnVal += 'perigosos, o Vendedor pode suspender seus serviços até que testes e análises adequados sejam realizados para confirmar se tais materiais';
		returnVal += 'são perigosos ou não. Em nenhum caso o Vendedor ou seus contratantes serão responsáveis pela remoção, redução ou descarte de';
		returnVal += 'quaisquer materiais perigosos (incluindo, mas não se limitando ao amianto, amianto contendo materiais, resíduos perigosos ou resíduos';
		returnVal += 'infecciosos).';
		returnVal += '</td></tr><tr ><td class="fontSizes">VIII Multa';
		returnVal += '</td></tr><tr ><td class="fontSizes">A. Caso o Cliente desista da compra efetuada antes do pagamento de quaisquer valores, será devida uma multa de 20% a título de multa,';
		returnVal += 'que deverá ser pago em até 30 dias.';
		returnVal += '</td></tr><tr ><td class="fontSizes">B. Caso o Cliente desista da compra efetuada depois do pagamento de quaisquer valores, o valor será retido pela Vendedora, sem prejuízo';
		returnVal += 'de eventual cobrança de valores por perdas e danos.';
		returnVal += '</td></tr><tr ><td class="fontSizes">C. A não cobrança da multa ou a devolução do valor adiantado pela Vendedora, será entendida como mera liberalidade da Vendedora, não';
		returnVal += 'resultando em qualquer reconhecimento de direitos.';
		returnVal += '</td></tr><tr ><td class="fontSizes">XIV. Regulatório:';
		returnVal += '</td></tr><tr ><td class="fontSizes">A. A pedido do Vendedor, o Cliente fornecerá documentações aplicáveis ao seu negocio perante as autoridades sanitárias a qualquer';
		returnVal += 'momento da negociação e também após o fechamento do pedido, sendo que tais documentações visam informações suficientes para permitir';
		returnVal += 'que o Vendedor avalie a regularização sanitária do Cliente.';
		returnVal += '</td></tr> <tr ><td>.';
		returnVal += '</td></tr> <tr class="html2pdf__page-break"><td>';
		returnVal += '</td></tr><tr ><td class="fontSizes">XV. IRREVOGABILIDADE';
		returnVal += 'Esta proposta será sujeita a avaliação cadastral e se aprovada, será firmada de forma irrevogável e irretratável, não comportando';
		returnVal += 'arrependimento.';
		returnVal += '</td></tr><tr ><td class="fontSizes">XVI . Conformidade com a Lei 13.709/2018, a Lei Geral de Proteção de Dados (LGPD):';
		returnVal += '</td></tr><tr ><td class="fontSizes">A. As Partes protegem a confidencialidade de dados pessoais e dados sensíveis que lhe são confiados pelos titulares desses dados.';
		returnVal += '</td></tr><tr ><td class="fontSizes">B.';
		returnVal += '</td></tr><tr ><td class="fontSizes">XVII. DIREITOS';
		returnVal += '</td></tr><tr ><td class="fontSizes">A. O Cliente não esta autorizado desenvolver réplica, reprodução, cópia de quaisquer partes ou no todo, do projeto, equipamento e';
		returnVal += 'acessórios objeto desta proposta, sem a devida autorização por escrito, sob pena de ação judicial por dano moral e intelectual, assim como a';
		returnVal += 'execução de serviços de assistência técnica desqualificada.';
		returnVal += '</td></tr><tr ><td class="fontSizes">B. PATENTES, MARCAS, DIREITOS AUTORAIS E DE SOFTWARE – O Vendedor garante que os produtos que fabrica, nos termos do';
		returnVal += 'seu projeto, serão entregues livres de qualquer direito legítimo para violação de qualquer patente dos Estados Unidos ou Brasil, marca';
		returnVal += 'registrada ou direito autoral. Caso o Vendedor seja notificada, por escrito, sobre qualquer alegação de violação, o Vendedor defenderá ou';
		returnVal += 'pode resolver à sua custa qualquer reclamação; no entanto, desde que o Cliente coopere com o Vendedor na defesa de qualquer';
		returnVal += 'reclamação. O projeto do Vendedor é adequado aos mais criteriosos requisitos normativos e operacionais, portanto, seu desenho,';
		returnVal += 'instrumentação e automação seguiram rigorosos ensaios, com a dedicação das áreas de marketing e engenharia e são isentos de quaisquer';
		returnVal += 'alterações que não sejam motivadas por requisitos normativos.';
		returnVal += '</td></tr><tr ><td class="fontSizes">C. O Tempo de vida útil dos produtos ofertados nesta proposta é diretamente proporcional aos cuidados e ao programa de manutenção';
		returnVal += 'preventiva e corretiva aplicados ao longo de sua utilização.';
		returnVal += '</td></tr><tr ><td class="fontSizes">XVI. Eleição de foro:';
		returnVal += '</td></tr><tr ><td class="fontSizes">Fica eleito o foro da Cidade de São Paulo do estado de São Paulo para dirimir quaisquer dúvidas oriundas do presente contrato.';
		returnVal += '</td></tr><tr ><td class="fontSizes">XVII. Emitente Nota Fiscal:';
		returnVal += '</td></tr><tr ><td class="fontSizes">STERIS SOLUTIONS DO BRASIL IMPORTACAO E COMERCIALIZACAO DE PRODUTOS DA SAUDE LTDA';
		returnVal += '</td></tr><tr ><td class="fontSizes">Av, Piraíba,352 - Sala 10 - Centro Comercial Jubran - CEP: 06460-121 - Barueri - SP, Brasil';
		returnVal += '</td></tr><tr ><td class="fontSizes">CNPJ: 59.233.783/0004-49		</td></tr>';
		return returnVal;
	}

	public static Map<Id, List<OptionalItem>> getResources(Set<Id> prodIdSet) {
		Map<Id, List<OptionalItem>> contextMap = new Map<Id, List<OptionalItem>>();
		for(TipoRecursoProduto__c record : [SELECT id, Sequencial__c, IdentificadorChave__c, Produto__c, TipoRecurso__r.RecursoProduto__r.Name, TipoRecurso__r.DescricaoRecurso__c
                                            FROM TipoRecursoProduto__c 
                                            WHERE Produto__c IN :prodIdSet
                                            ORDER BY Produto__c DESC, Sequencial__c ASC]){
            if(!contextMap.containsKey(record.Produto__c))
                contextMap.put(record.Produto__c, new List<OptionalItem>());
            contextMap.get(record.Produto__c).add(new OptionalItem(record));
		}
		return contextMap;
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
					CurrencyIsoCode,
				   	Name,
				   Account.Name,
				   Account.ShippingStreet,
				   CreatedDate,
				   ExpirationDate,
				   Account.ShippingCity,
				   Account.ShippingState,
				   Account.ShippingPostalCode,
				   Contact.Name,
				   Contact.Phone,
				   Contact.Account.Name,
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
						   ProdutoSemEstrutura__c,
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
		public String recordType {get; set;}
		public String currencyIsos {get; set;}
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
		public String usEmail {get;set;}
		public String createdDate {get;set;}
		public String condicao {get;set;}

		public String expirationDate {get;set;}

		public String today {get;set;}
		public String proposal {get;set;}
		public String paymentCondition {get;set;}
		public String freight {get;set;}
		public String totalPrice {get;set;}
		public String discount {get;set;}

		public List<QuoteItem> itemList {get; set;}
		public List<QuoteItem> itemWithoutStructureList {get; set;}
		public Boolean hasProductExceptionDataTotal {get;set;}
		public String productExceptionDataTotal {get;set;}

		public QuoteData() {
			this.name = '';
			this.recordType = '';
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
			this.usEmail = '';
			this.createdDate = '';
			this.condicao = '';
			
			this.expirationDate = '';

			this.itemList = new List<QuoteItem>();
			this.itemWithoutStructureList = new List<QuoteItem>();
		}
		public QuoteData(Quote currenctQuote) {
			this();
            User us = [SELECT id, NAme, Email FROM USER WHERE ID = : UserInfo.getUserId() LIMIT 1];

			this.name = currenctQuote.Name;
			this.recordType = ' para Distribuição Direta';
			this.currencyIsos = currenctQuote.CurrencyIsoCode;
			this.accountName = currenctQuote.Account.Name;
			this.shippingStreet = currenctQuote.Account.ShippingStreet;
			this.createdDate = currenctQuote.CreatedDate.format('dd/MM/yyyy');
			this.condicao = '30/60/90 DDL';
			this.expirationDate = this.formatDate(currenctQuote.expirationDate);
			this.shippingCity = currenctQuote.Account.ShippingCity;
			this.shippingState = currenctQuote.Account.ShippingState;
			this.shippingPostalCode = currenctQuote.Account.ShippingPostalCode;
			this.contactName = currenctQuote.Contact.Name;
			this.contactPhone = currenctQuote.Contact.Phone;
			this.contactAccountName = currenctQuote.Contact.Account.Name;

			this.today = DateTime.now().format('dd/MM/yyyy');
			this.proposal = '#1412812';
			this.freight = '1213';
			this.totalPrice = currenctQuote.TotalPrice == null ? '' : convertToBRL(currenctQuote.TotalPrice);
			this.discount = currenctQuote.Discount == null ? '' : convertToBRL(currenctQuote.Discount * 100);

			
			this.accountAddress = '';
            this.prazoEntrega = '22 Dias';
            this.prazoGarantia = '21 Dias';
            this.instalacao = 'Instalação Obrigatoria';
            this.frete = this.freight;
			this.addressDelivery = 'Rua antonio camargo, 133'; //currenctQuote.account.ShippingStreet +', '+currenctQuote.account.ShippingCity +', '+currenctQuote.account.ShippingPostalCode;
			this.createdBy = 'Usuario do Sistema';
			this.usEmail = 'user@user.com';

			this.fillQuoteItemList(currenctQuote);
		}
    	public String formatDate(Date dts){
    	    return dts == null ? '- ' : (dts.day()+'/'+dts.month()+'/'+dts.year());
    	}

		public void fillQuoteItemList(Quote currenctQuote) {
			List<QuoteLineItem> quoteLineItemList = new List<QuoteLineItem>();
			Map<Id, List<QuoteLineItem>> parentProductIdToAccessoryItemListMap = new Map<Id, List<QuoteLineItem>>();

			Decimal totalValue= 0;
			Set<id> productIdSet = new Set<id>();
			Set<String> estruturaIdSet = new Set<String>();
			for (QuoteLineItem retrievedItem : currenctQuote.QuoteLineItems) {
				if (!String.isBlank(retrievedItem.ParentProduct__c)) {
					if (!parentProductIdToAccessoryItemListMap.containsKey(retrievedItem.ParentProduct__c)) {
						parentProductIdToAccessoryItemListMap.put(retrievedItem.ParentProduct__c, new List<QuoteLineItem>());
					}
					parentProductIdToAccessoryItemListMap.get(retrievedItem.ParentProduct__c).add(retrievedItem);
				}
				else if(!retrievedItem.ProdutoSemEstrutura__c){
					quoteLineItemList.add(retrievedItem);
				}
				
				// if(retrievedItem.ParentProduct__c == null && retrievedItem.Product2.EstruturaProduto__c == null && !parentProductIdToAccessoryItemListMap.containsKey(retrievedItem.Product2Id)){
				if(retrievedItem.ProdutoSemEstrutura__c){
					this.itemWithoutStructureList.add(new QuoteItem(retrievedItem));			
					totalValue += retrievedItem.TotalPrice;
				}

				productIdSet.add(retrievedItem.Product2Id);
				estruturaIdSet.add(retrievedItem.Product2.EstruturaProduto__c);
			}

			this.hasProductExceptionDataTotal = !this.itemWithoutStructureList.isEmpty();
			this.productExceptionDataTotal = convertToBRL(totalValue);
		
			Map<Id, List<OptionalItem>> productIdToResourceListMap = getResources(productIdSet);
			Map<Id, ContentVersion> itemToImageMap = getImages(productIdSet);
		
			for (QuoteLineItem retrievedItem : quoteLineItemList) {
				this.itemList.add(
					new QuoteItem(
						retrievedItem,
						productIdToResourceListMap.containsKey(retrievedItem.Product2Id) ? productIdToResourceListMap.get(retrievedItem.Product2Id) : new List<OptionalItem>(),
						itemToImageMap,
						parentProductIdToAccessoryItemListMap.get(retrievedItem.Product2Id)
					)
				);
			}
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

		public QuoteItem(QuoteLineItem currentItem) {
			this.name = currentItem.Product2.ProductCode +'-'+currentItem.Product2.Name;
			this.nameWithoutCode = currentItem.Product2.Name;
			this.hasStructures = currentItem.Product2.EstruturaProduto__c != null;
			this.hasExceptionKit = false;
			this.hasRequiredKit = false;
			this.hasOptionalKit = false;
			this.image = '';
			this.extension = '';

			this.optionalList = new List<OptionalItem>();

			this.kitExceptionDataList = new List<KitData>();
			this.kitRequiredDataList = new List<KitData>();
			this.kitOpcionalDataList = new List<KitData>();

			this.kitExceptionDataSubTotal = 0;
			this.kitRequiredDataSubTotal = 0;
			this.kitOpcionalDataSubTotal = 0;

			this.kitExceptionDataTotal = '';
			this.kitRequiredDataTotal =  '';
			this.kitOpcionalDataTotal =  '';
			this.quantity = currentItem.Quantity;
			this.unitPrice =  convertToBRL(currentItem.UnitPrice);
			this.totalPriceEquip =  convertToBRL(currentItem.TotalPrice);
			this.totalPrice =  convertToBRL(currentItem.TotalPrice);
		}
		public QuoteItem(
			QuoteLineItem currentItem,
			List<OptionalItem> productIdToResourceListMap,
			Map<Id, ContentVersion> productIdToImageMap,
			List<QuoteLineItem> accessoryItemList
		) {
			this(currentItem);

			if (productIdToImageMap.containsKey(currentItem.Product2Id)) {
				Blob imageData = (Blob)productIdToImageMap.get(currentItem.Product2Id).VersionData;

				this.image = EncodingUtil.base64Encode(imageData);
				this.extension = productIdToImageMap.get(currentItem.Product2Id).FileExtension;
			}

			this.optionalList = productIdToResourceListMap;

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

			this.acessoryValues =   convertToBRL(this.kitExceptionDataSubTotal + this.kitRequiredDataSubTotal + this.kitOpcionalDataSubTotal);
			this.totalPrice =  convertToBRL(currentItem.TotalPrice  + this.kitExceptionDataSubTotal + this.kitRequiredDataSubTotal + this.kitOpcionalDataSubTotal);
		}

	}

	public class OptionalItem {
		public String name {get; set;}
		public String description {get; set;}

		public OptionalItem(TipoRecursoProduto__c retrievedType) {
			this.name = retrievedType.TipoRecurso__r.RecursoProduto__r.Name;
			this.description = retrievedType.TipoRecurso__r.DescricaoRecurso__c;
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