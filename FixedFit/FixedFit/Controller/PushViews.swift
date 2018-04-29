//
//  PushViews.swift
//  FixedFit
//
//  Created by Mario Buenrostro on 4/7/18.
//  Copyright © 2018 UNLV. All rights reserved.
//

import UIKit

//Class used to push views onto the navigation stack or present the informationVC
//Function parameters names: executeTransition(vcName, storyboardName, newString, newMode)

/*
//Function calling structure:
 
 guard let vc = PushViews.executeTransition(vcName, storyboardName, title for view if needed, mode if needed) else {return}
 
 //Check if the View Controller is of a certain View Controller type that you need to downcast to.
 if let vc = vc as? VC_ClassType{
 
 //if VC_ClassType is SupportVC
    then vc.selectedClass = subclass of MainSupportFramework //(Notes are in the button section of the comments)
 //
 
 //Push View Controller onto Navigation Stack
 self.navigationController?.pushViewController(vc, animated: true)
 
 //Otherwise, present the informationVC when an error has occured
 } else if let vc = vc as? InformationVC{
 self.present(vc, animated: true, completion: nil)
 }
 
 */

/*
 Note, for instantiating SupportVC, the selectedClass variable of type MainSupportFramework must be assigned before view controller is push onto the stack with the correct class corresponding to the topic that the SupportVC is being generated for.
 
 Each topic of the tutorial must have a corresponding class that inherits from the MainSupportFramework class that contains a images and messages array that will contain the information relative to the topic. So each subclass must initialize both of those variables with the correct information for the topic.
 */
struct PushViewKeys{
    
    //Views
    static let userfinderVC = "UserFinderVC"
    static let supportVC = "SupportVC"
    static let userviewVC = "UserViewVC"
    static let categoriesVC = "CategoriesVC"
    static let tutorialVC = "TutorialVC"
    
    //Storyboards
    static let userfinder = "UserFinder"
    static let home = "Home"
}
class PushViews {

    //Function used to execute transitions from a view to a new view that needs to be instantiated on the navigation stack
    //The function will return an instance of a ViewController that the calling function will have to present or push.
    static func executeTransition(vcName: String, storyboardName: String, newString:String, newMode:String? = nil) -> UIViewController?{
        
        //Message used to monitor if cases are correct
        var errorMessage = ""
        
        if(vcName.isEmpty || storyboardName.isEmpty || newString.isEmpty){
            
            //Modify errorMessage vairable to produce correct error message
            errorMessage = "Error: Invalid String Parameters"
            
        } else {
            
            //Initial view controller
            var vc: UIViewController!
            let storyboard = UIStoryboard(name: storyboardName, bundle:nil)
            
            if(vcName == PushViewKeys.userfinderVC && newMode != nil){
                
                let storyboard = UIStoryboard(name: storyboardName, bundle:nil)
                vc = storyboard.instantiateInitialViewController() as! UserFinderVC
                
                if let vc = vc as? UserFinderVC{
                    //Initialize the title of the ViewController and mode if needed
                    vc.mode = newMode!
                    vc.viewTitle = newString
                }
                
            } else if(vcName == PushViewKeys.supportVC && newMode != nil){
                vc = storyboard.instantiateViewController(withIdentifier: "SupportVC")  as! SupportVC
                
                //Initialize the title of the ViewController
                if let currentVC = vc as? SupportVC{
                    currentVC.viewTitle = newString
                    currentVC.mode = newMode
                }
                
                //For UserViewVC, the title should be the user name of the searched person
            } else if(vcName == PushViewKeys.userviewVC){
                vc = storyboard.instantiateViewController(withIdentifier: "UserViewVC") as! UserViewVC
                
                //Initialize the selecte user's uid for the ViewController
                if let currentVC = vc as? UserViewVC{
                    currentVC.uid = newString
                }
                
            } else if(vcName == PushViewKeys.categoriesVC){
                vc = storyboard.instantiateViewController(withIdentifier: "CategoriesVC") as! CategoriesVC
                
                //Initialize the title of the ViewController
                if let currentVC = vc as? CategoriesVC{
                    currentVC.viewTitle = newString
                }
                
            } else if(vcName == PushViewKeys.tutorialVC){
                vc = storyboard.instantiateViewController(withIdentifier: "TutorialVC") as! TutorialVC
                
                //Initialize the title of the ViewController
                if let currentVC = vc as? TutorialVC{
                    currentVC.viewTitle = newString
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
