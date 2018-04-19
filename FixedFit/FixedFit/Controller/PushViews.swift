//
//  PushViews.swift
//  FixedFit
//
//  Created by Mario Buenrostro on 4/7/18.
//  Copyright © 2018 UNLV. All rights reserved.
//

import UIKit

//Class used to push views onto the navigation stack or present the informationVC
//Function parameters names: executeTransition(vcName, storyboardName, newTitle, newMode)

/*
//Function calling structure:
 
 guard let vc = PushViews.executeTransition(vcName, storyboardName, title for view if needed, mode if needed) else {return}
 
 //Check if the View Controller is of a certain View Controller type that you need to downcast to.
 if let vc = vc as? VC_ClassType{
 
 //Push View Controller onto Navigation Stack
 self.navigationController?.pushViewController(vc, animated: true)
 
 //Otherwise, present the informationVC when an error has occured
 } else if let vc = vc as? InformationVC{
 self.present(vc, animated: true, completion: nil)
 }
 
 */

class PushViews {

    //Function used to execute transitions from a view to a new view that needs to be instantiated on the navigation stack
    //The function will return an instance of a ViewController that the calling function will have to present or push.
    static func executeTransition(vcName: String, storyboardName: String, newTitle:String, newMode:String? = nil) -> UIViewController?{
        
        //Message used to monitor if cases are correct
        var errorMessage = ""
        
        if(vcName.isEmpty || storyboardName.isEmpty || newTitle.isEmpty){
            
            //Modify errorMessage vairable to produce correct error message
            errorMessage = "Error: Invalid String Parameters"
            
        } else {
            
            //Initial view controller
            var vc: UIViewController!
            let storyboard = UIStoryboard(name: storyboardName, bundle:nil)
            
            if(vcName == "UserFinderVC" && newMode != nil){
                
                let storyboard = UIStoryboard(name: storyboardName, bundle:nil)
                vc = storyboard.instantiateInitialViewController() as! UserFinderVC
                
                if let vc = vc as? UserFinderVC{
                    //Initialize the title of the ViewController and mode if needed
                    vc.mode = newMode!
                    vc.viewTitle = newTitle
                }
                
            } else if(vcName == "SupportVC" || vcName == "UserViewVC" || vcName == "CategoriesVC"){
                
                if(vcName == "SupportVC"){
                    vc = storyboard.instantiateViewController(withIdentifier: "SupportVC")  as! SupportVC
                    
                    //Initialize the title of the ViewController
                    if let currentVC = vc as? SupportVC{
                        currentVC.viewTitle = newTitle
                    }
                    
                    //For UserViewVC, the title should be the user name of the searched person
                } else if(vcName == "UserViewVC"){
                    vc = storyboard.instantiateViewController(withIdentifier: "UserViewVC") as! UserViewVC
                    
                    //Initialize the title of the ViewController
                    if let currentVC = vc as? UserViewVC{
                        currentVC.uid = newTitle
                    }
                    
                } else if(vcName == "CategoriesVC"){
                    vc = storyboard.instantiateViewController(withIdentifier: "CategoriesVC") as! CategoriesVC
                    
                    //Initialize the title of the ViewController
                    if let currentVC = vc as? CategoriesVC{
                        currentVC.viewTitle = newTitle
                    }
                }
                
            } else {
                errorMessage = "Error: Unknown view controller name"
            }
            
            //Return view controller if no error has occured
            if(errorMessage.isEmpty){
                return vc
            }
        }
        
        if(!(errorMessage.isEmpty)){
            //Generate informationVC to let user know that there was an error in transition
            let rightButtonData = ButtonData(title: "Ok", color: .fixedFitBlue, action: nil)
            let informationVC = InformationVC(message: errorMessage, image: UIImage(named: "error diagram"), leftButtonData: nil, rightButtonData: rightButtonData)
            return informationVC
        }
        
        return nil
    }
}
