({
    doInit : function(component, event, helper) {       
        component.set("v.Spinner",true);
        helper.createObjValues(component, event, helper);
        helper.hlpCheckValidity(component, event,helper);
    },
    handleLookupUpdate : function(component, event, helper) {
        helper.handleLookupUpdateHelper(component, event, helper);
    },
    getMasterFilterValue : function(component, event, helper) {
        if((component.get('v.parentChild') == 'Child')){
            component.set("v.masterFilterValueOBJ", event.getParam("MasterFilterValueOBJ"));
        }
    },
})