window.embedded_svc.snippetSettingsFile = (function() {
    return {
        prechatInit: function(prechatForm, callback) {
            const userId = window.loggedInUserId || 'anonymous';

            prechatForm.setCustomDetails({
                label: "UserId",
                value: userId,
                displayToAgent: true
            });

            callback();
        }
    };
})();