import { LightningElement, api } from 'lwc';

export default class AppIcon extends LightningElement {
    @api iconName;     // utility:home
    @api size = 'small'; 
    @api alternativeText = ''; 
    @api variant;      
    @api className = ''; 
}