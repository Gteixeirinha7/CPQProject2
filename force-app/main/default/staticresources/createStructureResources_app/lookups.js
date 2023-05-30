function Lookups(){};

(function (apexController, window, toastr){

    Lookups.clienteId = null;
    Lookups.hierarchyId = null;
    Lookups.representanteId = null;

    Lookups.doneTypingInterval = 550;

    Lookups.idToTable = {
        "ClienteLkp": "Account",
        // "HierarquiaLkp": "Hierarchy",
        "RepresentanteLkp": "Representante__c"
    };

    Lookups.tableToData = {
        "Account": {
            "url": window.LABEL_TO_ICON.account
        },
        // "Hierarquia": {
        //     "url": window.LABEL_TO_ICON.account
        // },
        "Representante__c": {
            "url": window.LABEL_TO_ICON.account
        },
    };

    Lookups.idToRefferingInput = {
        "ClienteLkp": "ClienteLkp_hidden",
        // "HierarquiaLkp": "HierarquiaLkp_hidden",
        "RepresentanteLkp": "RepresentanteLkp_hidden"
    };

    Lookups.idToJSProp = {
        'ClienteLkp': 'clienteId',
        // 'HierarquiaLkp': 'hierarchyId',
        'RepresentanteLkp': 'representanteId'
    };

    Lookups.idToSetLookupCallback = {
    };

    Lookups.idToClearCallback = {
    };

    Lookups.idToSearchField = {
    };

    Lookups.idToKeyupCallback = {
    };

    Lookups.idToQueryFilter = {
    };
    
    Lookups.addFocusEvent = function (optionElement) {


        var e = $(optionElement);

        e.focusin(function () {
            e.addClass('slds-has-focus');
        });

        e.blur(function () {
            e.removeClass('slds-has-focus');

            var targetId = e.attr('aria-controls');
            var targetElement = $('#' + targetId);

            if (targetElement.find('li:active:not(.search-item)').length) {
                return;
            } else {
                e.val('');
                Lookups.isSearching = false;
                targetElement.parent().find('.form-icon-loading-lookup').addClass('hidden');
                targetElement.parent().find('.form-icon-search-lookup').removeClass('hidden');
            }

            targetElement.addClass('hidden');
        })
    };

    Lookups.addKeyUpEvent = function (optionElement, table, field, callback) {


        $(optionElement).keyup(function () {

            Lookups.isSearching = true;
            optionElement.parent().find('.form-icon-loading-lookup').removeClass('hidden');
            optionElement.parent().find('.form-icon-search-lookup').addClass('hidden');

            clearTimeout(Lookups.typingTimer);

            if ($(optionElement).val()) {

                Lookups.typingTimer = setTimeout(function () {
                    doneTyping(callback)
                }, Lookups.doneTypingInterval);
            } else {
                optionElement.parent().find('.form-icon-loading-lookup').addClass('hidden');
                optionElement.parent().find('.form-icon-search-lookup').removeClass('hidden');
            }
        });

        function doneTyping(callback) {


            var containerElement = document.getElementById($(optionElement).attr('id')).classList;
            var queryFilter = Lookups.idToQueryFilter[optionElement.prop('id')];
            queryFilter = queryFilter ? JSON.stringify(queryFilter) : null;
            if (Lookups.isSearching && !containerElement.contains('slds-input-has-icon_left-right')) {
                Lookups.searchLookup(optionElement, table, field, queryFilter, callback);
            }
        }
    };

    Lookups.searchLookup = function (element, table, field, filter, callback) {
        var term = $(element).val();
        Visualforce.remoting.Manager.invokeAction(
            apexController.urls['SEARCH_LOOKUP'],
            term, table, field, filter,
            function (result, event) {
                if ($(element).val()) {
                    Lookups.fillLookupOptions(element, table, result)
                    if (typeof callback == 'function') {
                        callback();
                    }
                }
            }, { escape: false, timeout: 120000 }
        );
    };

    Lookups.getLookupList = function (element, table, result) {
        var toReturn = `
            <ul class="slds-listbox slds-listbox_vertical" role="presentation">
            <li role="presentation" class="search-item slds-listbox__item result-li">
                <div aria-selected="true" id="option-${table}" class="slds-media slds-listbox__option slds-listbox__option_entity slds-listbox__option_term slds-has-focus" role="option">
                    <span class="slds-media__figure">
                        <span class="slds-icon_container slds-icon-utility-search" title="Pesquisar: ">
                            <svg class="slds-icon slds-icon_x-small slds-icon-text-default" aria-hidden="true">
                                <use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="${Lookups.tableToData[table].url}" />
                            </svg>
                            <span class="slds-assistive-text">Nome</span>
                        </span>
                    </span>
                    <span class="slds-media__body">
                        <span class="slds-listbox__option-text slds-listbox__option-text_entity">Resultados para: ${$(element).val()}</span>
                    </span>
                </div>
            </li>`;
        for (var x = 0; x < result.length; x++) {
            toReturn += Lookups.getLine(table, result[x]);
        }
        toReturn += '</ul>';
        return toReturn;
    };

    Lookups.getLine = function (table, item) {
        return `<li role="presentation" class="slds-listbox__item">
            <div class="slds-media slds-listbox__option slds-listbox__option_entity slds-listbox__option_has-meta" role="option">
                <span class="slds-media__figure">
                    <span class="slds-icon_container slds-icon-standard-account">
                        <svg class="slds-icon slds-icon_small" aria-hidden="true">
                            <use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href=${Lookups.tableToData[table].url}/>
                        </svg>
                    </span>
                </span>
                <span class="slds-media__body">
                    <span class="slds-listbox__option-text slds-listbox__option-text_entity">
                        <span>
                        ${item.name}
                    </span>
                    <span class="slds-listbox__option-meta slds-listbox__option-meta_entity">${[table, item.returningFields].join(' • ')}</span>
                </span>
            </div>
        </li>`;
    };

    Lookups.setLookup = function (inputElement, table, item, withoutCallback) {

        clearTimeout(Lookups.typingTimer);

        var previousId = $(inputElement).attr('id');
        var containerElement = inputElement.parent();

        containerElement.addClass('slds-input-has-icon_left-right')
        containerElement.html(
            `<span class="slds-icon_container slds-icon-standard-account slds-combobox__input-entity-icon" title="${table}">
                <svg class="slds-icon slds-icon_small" aria-hidden="true">
                    <use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="${Lookups.tableToData[table].url}" />
                </svg>
                <span class="slds-assistive-text">${table}</span>
            </span>
            ${inputElement.prop('outerHTML')}
            ${inputElement.next().prop('outerHTML')}
            <div class="form-icon-group slds-input__icon-group slds-input__icon-group_right">
                <div role="status" class="hidden form-lookup-icon form-icon-loading-lookup slds-spinner slds-spinner_brand slds-spinner_x-small slds-input__spinner">
                    <div class="slds-spinner__dot-a"></div>
                    <div class="slds-spinner__dot-b"></div>
                </div>
                <button class="hidden form-lookup-icon form-icon-search-lookup slds-input__icon slds-input__icon_right slds-button slds-button_icon">
                    <svg class="slds-icon slds-icon slds-icon_x-small slds-icon-text-default" aria-hidden="true">
                    <use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="${
            LABEL_TO_ICON['search']}" />
                </svg>
                <span class="slds-assistive-text">Resultados</span>
                </button>
                <button class="form-remove-lookup-button slds-button slds-button_icon slds-input__icon slds-input__icon_right" title="Limpar" onclick="Lookups.clearLookup(this)">
                    <svg class="slds-button__icon" aria-hidden="true">
                        <use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="${window.LABEL_TO_ICON['clear']}"/>
                    </svg>
                    <span class="slds-assistive-text">Limpar</span>
                </button>
            </div>`
        )
        inputElement = $('#' + previousId);
        inputElement.val(item.name);
        inputElement.next().val(item.id);
        inputElement.removeClass('slds-has-focus');


        Lookups[Lookups.idToJSProp[inputElement.attr('id')]] = item.id;

        var targetId = inputElement.attr('aria-controls');
        var listElement = $('#' + targetId);

        inputElement.prop('disabled', 'disabled')
        listElement.addClass('hidden');
        valueElement = $('#' + Lookups.idToRefferingInput[inputElement.attr('id')]);
        if (!withoutCallback) {
            if (typeof Lookups.idToSetLookupCallback[inputElement.prop('id')] == 'function') {
                Lookups.idToSetLookupCallback[inputElement.prop('id')](item.id);
            }
        }

        Lookups.assignValueToProp(inputElement.attr('id'), valueElement.val());
    };

    Lookups.assignValueToProp = function (id, value) {
        if (Lookups.idToJSProp[id]) {
            Lookups[Lookups.idToJSProp[id]] = value;
        }
    };

    Lookups.fillLookupOptions = function (element, table, result) {
        var targetId = $(element).attr('aria-controls');
        var targetElement = $('#' + targetId);
        var containerElement = document.getElementById($(element).attr('id')).classList;
        targetElement.addClass('hidden');
        if (!containerElement.contains('slds-input-has-icon_left-right')) {

            var elementContent = Lookups.getLookupList(element, table, result);

            targetElement.html(elementContent);
            (function (targetElement, result) {
                targetElement.find('li:not(.result-li)').each(function (index, liItem) {
                    (function (index, liItem) {
                        (function (a, b, d) {
                            $(liItem).click(function () {
                                Lookups.setLookup(a, b, d)
                            });
                        })(targetElement.parent().find('[role="textbox"]'), table, result[index])
                    })(index, liItem)
                });
            })(targetElement, result)


            targetElement.parent().find('.form-icon-loading-lookup').addClass('hidden');
            targetElement.parent().find('.form-icon-search-lookup').removeClass('hidden');
            targetElement.removeClass('hidden');
        }
    };

    Lookups.clearLookup = function (btnElement) {


        var input = $(btnElement).parent().parent().find('input:not(.hidden-input)');
        var hiddenInput = $(btnElement).parent().parent().find('input.hidden-input');
        var inputContainer = input.parent();

        input.val('').removeAttr('disabled');
        hiddenInput.val('').removeAttr('disabled');

        inputContainer.children('span').remove();
        inputContainer.find('.form-remove-lookup-button').remove();

        inputContainer.removeClass('slds-input-has-icon_left-right');

        inputContainer.find('.form-icon-loading-lookup').addClass('hidden');
        inputContainer.find('.form-icon-search-lookup').removeClass('hidden');

        if (typeof Lookups.idToClearCallback[input.prop('id')] == 'function') {
            Lookups.idToClearCallback[input.prop('id')]();
        }

        Lookups.addKeyUpEvent(input, Lookups.idToTable[input.prop('id')], Lookups.idToSearchField[input.prop('id')] || 'name', Lookups.idToKeyupCallback[input.prop('id')]);
        Lookups.addFocusEvent(input);
        Lookups.assignValueToProp(input.attr('id'), null);
    };

    Lookups.initializeLookups = function () {
        var keys = Object.keys(Lookups.idToTable);
        for (var x = 0; x < keys.length; x++) {
            var key = keys[x];
            Lookups.addKeyUpEvent($('#' + key), Lookups.idToTable[key], (Lookups.idToSearchField[key] || 'name'), Lookups.idToKeyupCallback[key]);
            Lookups.addFocusEvent($('#' + key));
        }
    }

})(window.apexController, window, toastr);