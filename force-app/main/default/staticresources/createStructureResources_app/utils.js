function Utils(){};

(function(apexController, window, toastr){
    window.request = function(remoteAction, args) {
        return new Promise(function(resolve, reject){
            Visualforce.remoting.Manager.invokeAction(
              remoteAction,
              ...args,
              function (response, event) {
                if (event.status) {
                  resolve(response);
                } else {
                  console.log(event);
                  reject(event);
                }
              }
            );
        })
    };

    Utils.createRecords = function (requestRecords) {
        return request(apexController.urls['CREATE_RECORDS'], [requestRecords]).then(result => {
            if (result.hasError) {
                throw new Error(result.message);
            }
            return result;
        }).catch(error => {
            throw new Error(error.message);
        });
    };

    Utils.getRecords = function (requestRecords) {
        return request(apexController.urls['GET_RECORDS'], [requestRecords]).then(result => {
            if (result.hasError) {
                throw new Error(result.message);
            }
            return result;
        }).catch(error => {
            throw new Error(error.message);
        });
    };
})(window.apexController, window, toastr);
