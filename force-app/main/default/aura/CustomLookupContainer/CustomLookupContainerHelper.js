({
    createObjValues : function(component, event, helper) {
        var obj = {}; 
        obj.sObjectApiName = (component.get("v.ObjectName") != null) ? component.get("v.ObjectName") : ''; 
        obj.recordTypeId = (component.get("v.RecordTypeId") != null) ? component.get("v.RecordTypeId") : '';
        obj.field1 = (component.get("v.Field1ApiName") != null) ? component.get("v.Field1ApiName") : '';
        obj.field2 = (component.get("v.Field2ApiName") != null) ? component.get("v.Field2ApiName") : '';
        obj.field3 = (component.get("v.Field3ApiName") != null) ? component.get("v.Field3ApiName") : '';
        obj.fieldfilter = (component.get("v.FilterField") != null) ? component.get("v.FilterField") : '';

        if (component.get("v.FilterValue") != null){
            switch (component.get("v.FilterValue").toLowerCase()) {
                case 'child.field1':
                    obj.valuefilter = (component.get("v.Field1ApiName") != null) ? component.get("v.Field1ApiName") : '';
                    break;
                case 'child.field2':
                    obj.valuefilter = (component.get("v.Field2ApiName") != null) ? component.get("v.Field2ApiName") : '';
                    break;
                case 'child.field3':
                    obj.valuefilter = (component.get("v.Field3ApiName") != null) ? component.get("v.Field3ApiName") : '';
                    break;
                case 'parent.field1':
                    if (component.get("v.masterFilterValueOBJ") != null){
                        obj.valuefilter = (component.get("v.masterFilterValueOBJ").field1 != null) ? component.get("v.masterFilterValueOBJ").field1 : '';
                    }else{
                        obj.valuefilter = '';
                    }
                    break;
                case 'parent.field2':
                    if (component.get("v.masterFilterValueOBJ") != null){
                        obj.valuefilter = (component.get("v.masterFilterValueOBJ").field2 != null) ? component.get("v.masterFilterValueOBJ").field2 : '';
                    }else{
                        obj.valuefilter = '';
                    }
                    break;
                case 'parent.field3':
                    if (component.get("v.masterFilterValueOBJ") != null){
                        obj.valuefilter = (component.get("v.masterFilterValueOBJ").field3 != null) ? component.get("v.masterFilterValueOBJ").field3 : '';
                    }else{
                        obj.valuefilter = '';
                    }
                    break;
                default:
                    obj.valuefilter = component.get("v.FilterValue");
                    break;
            }
        }
        obj.fieldfilterParent = (component.get("v.FilterFieldParent") != null) ? component.get("v.FilterFieldParent") : '';
        obj.fieldfilterParentValue = (component.get("v.masterFilterValueOBJ") != null) ?  component.get("v.masterFilterValueOBJ").Id : '';

        if(component.get('v.parentChild') == 'Parent'){
            //component.set("v.isSearch",true);
            component.set("v.RecordId",component.get("v.IdResult"));
        }else if(component.get('v.parentChild') == 'Child'){
            //component.set("v.isSearch",(!$A.util.isEmpty(component.get("v.IdResult"))));
            component.set("v.IdResult",null);
        }

        component.set("v.isSearch",(component.get('v.parentChild') == 'Parent') ? true : (component.get("v.masterFilterValueOBJ") != null) ? !$A.util.isEmpty(component.get("v.masterFilterValueOBJ").Id) : false);   
        
        if(!$A.util.isEmpty(obj)) component.set("v.StrObj",JSON.stringify(obj));

        component.set("v.Spinner",false) ;
    },
    handleLookupUpdateHelper : function(component, event, helper) {
        var result = event.getParam('value');
        
        if(result != null){
            component.set("v.IdResult",(!$A.util.isEmpty(result.Id)) ? result.Id : null);
            component.set("v.Field1Result",(!$A.util.isEmpty(result.field1)) ? result.field1 : null);
            component.set("v.Field2Result",(!$A.util.isEmpty(result.field2)) ? result.field2 : null);
            component.set("v.Field3Result",(!$A.util.isEmpty(result.field3)) ? result.field3 : null);
        }else{
            component.set("v.IdResult",'')
            component.set("v.Field1Result",'')
            component.set("v.Field2Result",'')
            component.set("v.Field3Result",'')
        }

        helper.hlpCheckValidity(component, event);
        
        /*if(component.get('v.parentChild') == 'Child'){
            component.set("v.isSearch",(!$A.util.isEmpty(component.get("v.IdResult"))));
        } */

        if(component.get('v.parentChild') == 'Parent'){
            helper.fireSaveFilter(component,result);
        }
    },
    hlpCheckValidity: function (component, event) {
        var selectedValue = !$A.util.isEmpty(component.get("v.IdResult")) ? component.get("v.IdResult") : '';

        component.set("v.validate", function () {
            return (!component.get("v.Required") || (selectedValue && !$A.util.isEmpty(selectedValue))) ? {isValid: true} : {isValid: false,errorMessage: "Por favor selecione um registro."}
        });
    },
    fireSaveFilter : function(component, record){
        var ev = $A.get('e.c:CustomLookupContainerEvent'); 
        ev.setParams({
            'MasterFilterValueOBJ' : record,
            'parent': component.get('v.cmpId')
        });
        ev.fire();
    }
})