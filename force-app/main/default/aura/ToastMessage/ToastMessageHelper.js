({
    showToast : function(component, event, helper, type, message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "message": message,
            "type": type,
            "duration": 10,
            "mode": "dismissible",
        });
        toastEvent.fire();
    }
})