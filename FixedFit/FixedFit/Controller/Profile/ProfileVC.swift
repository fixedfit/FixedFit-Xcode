//
//  ProfileVC.swift
//  FixedFit
//
//  Created by Amanuel Ketebo on 2/20/18.
//  Edited by Mario Buenrostro on 3/2/2018.
//
//  Copyright © 2018 UNLV. All rights reserved.
//

import UIKit
enum ProfileOutfitKeys: String{
    case all = "all"
    case publicOutfits = "public"
    case privateOutfits = "private"
    case cancel = "cancel"
}
class ProfileVC: UIViewController, UIGestureRecognizerDelegate, OutfitSelectorDelegate {
    enum CurrentDisplay {
        case outfit
        case likes
        case favorite
    }

    let firebaseManager = FirebaseManager.shared
    let userStuffManager = UserStuffManager.shared
    
    //MARK: varible used to determine if the outfit selection was already being presented or if it is not being presented
    var outfitDisplayed: Bool!
    var outfitdisplayingStatus: String!

    var selectedOutfit: Outfit!

    let outfitsVC = UIStoryboard.outfitsVC as! OutfitsVC
    let likedOutfitsVC = UIStoryboard.outfitsVC as! OutfitsVC
    let favoritedOutfitsVC = UIStoryboard.outfitsVC as! OutfitsVC

    @IBOutlet weak var childVCView: UIView!
    @IBOutlet weak var UserChildVCView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Set Initial state of outfitDisplayed when the profile view is loaded
        self.outfitDisplayed = false

        childVCView.addSubview(outfitsVC.view)
        outfitsVC.view.fillSuperView()
        outfitsVC.outfitsType = .outfits
        outfitsVC.outfits = userStuffManager.closet.outfits
        self.addChildViewController(outfitsVC)

        childVCView.addSubview(likedOutfitsVC.view)
        likedOutfitsVC.view.fillSuperView()
        likedOutfitsVC.outfitsType = .liked
        likedOutfitsVC.outfits = []
        self.addChildViewController(likedOutfitsVC)

        childVCView.addSubview(favoritedOutfitsVC.view)
        favoritedOutfitsVC.view.fillSuperView()
        favoritedOutfitsVC.outfitsType = .favorited
        favoritedOutfitsVC.outfits = userStuffManager.closet.favoriteOutfits()
        self.addChildViewController(favoritedOutfitsVC)
    }
    
    override func viewWillAppear(_ animated: Bool) {

        ////Fetch the selected user's information from firebase by using the observers
        self.firebaseManager.ref.child(FirebaseKeys.users.rawValue).child(self.userStuffManager.userInfo.uid).child(FirebaseKeys.username.rawValue).observe(.value, with: {(snapshot) in
            
            //retrieve the User's username
            if let username = snapshot.value as? String {
                
                //set the User's username
                self.navigationItem.title = username
            }
        })
        
    }

    @IBAction func EditTransition(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "EditTransition", sender: self)
    }

    @IBAction func tappedOutfits(_ sender: UITapGestureRecognizer) {
        
        //Initialize outfit displaying status
        self.outfitdisplayingStatus = ""
        
        //Initialize a DispatchGroup to notify main to execute the viewing of the specific outfits
        let dispatch = DispatchGroup()
        
        //Determine if the button for the outfit Displaying is already selected
        if(outfitDisplayed == true){
            
            dispatch.enter()
            //Generate the button and the outfitSelecitonVC to show the nibfile's view to the user
            let button = ButtonData(title: "", color: UIColor()){
                dispatch.leave()
            }
            
            let outfitSelectorVC = OutfitSelectionVC(button: button)
            outfitSelectorVC.delegate = self
            self.present(outfitSelectorVC, animated: true, completion: nil)
        }
        
        //Make main execute this section strictly after the OutfitSelectionVC has been dismissed
        //This section will perform the displaying of certain outfits, either all outfits, public outfits, or private outfits
        dispatch.notify(queue: .main){
            
            //Detemine which set of outfits where chosen to be displayed
            //Call function to fetch correct outfits in userStuffManager.closet.outfits
            
            
            //If the outfit button is was tapped, then make the boolean value of the outfitDisplayed variable to true
            self.outfitsVC.outfits = self.userStuffManager.closet.outfits
            self.outfitDisplayed = true
            self.likedOutfitsVC.view.isHidden = true
            self.favoritedOutfitsVC.view.isHidden = true
        }
    }

    @IBAction func tappedLiked(_ sender: UITapGestureRecognizer) {
        
        //If the liked button is was tapped, then make the boolean value of the outfitDisplayed variable to false
        self.outfitDisplayed = false
        
        //Display only the outfits of other user's that the current user liked
        likedOutfitsVC.outfits = []
        likedOutfitsVC.view.isHidden = false
        favoritedOutfitsVC.view.isHidden = true
    }

    @IBAction func tappedFavorited(_ sender: UITapGestureRecognizer) {

        //If the liked button is was tapped, then make the boolean value of the outfitDisplayed variable to false
        self.outfitDisplayed = false
        
        //Display only the outfits that belongs to the current user that they liked
        favoritedOutfitsVC.outfits = userStuffManager.closet.favoriteOutfits()
        favoritedOutfitsVC.view.isHidden = false
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let outfitItemsVC = segue.destination as? OutfitItemsVC {
            outfitItemsVC.outfit = selectedOutfit
        } else if let vc = segue.destination as? UserProfileInfoVC {
            vc.uid = userStuffManager.userInfo.uid
            vc.currentUserCheck = true
        }
    }

    //Implement the function of the OutfitSelectionVC
    func displaySelection(selection:String){
        self.outfitdisplayingStatus = selection
    }
}
