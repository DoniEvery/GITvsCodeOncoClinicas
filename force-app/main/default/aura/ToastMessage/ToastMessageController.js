({
    invoke : function(component, event, helper) {
        var message = component.get("v.messageText");
        var type = component.get("v.type");
        helper.showToast(component, event, helper, type, message);

    }
})