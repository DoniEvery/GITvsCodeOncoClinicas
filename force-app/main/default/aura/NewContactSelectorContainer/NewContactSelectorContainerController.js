({
	handlePageChange: function () {
		$A.get('e.force:refreshView').fire();
	},

	refresh: function (component) {
		var contactSelectorCmp = component.find('contactSelector');
		contactSelectorCmp.reset();

		$A.get('e.force:refreshView').fire();
	},
	closeMethodInAuraController: function (component, event, helper) {
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            workspaceAPI.closeTab({tabId: focusedTabId});
        })
        .catch(function(error) {
            console.log(error);
        });

	}
});