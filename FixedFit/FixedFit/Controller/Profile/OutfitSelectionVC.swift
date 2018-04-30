//
//  OutfitSelectionVC.swift
//  FixedFit
//
//  Created by Esmeralda Salas on 4/21/18.
//  Copyright © 2018 UNLV. All rights reserved.
//

import UIKit
protocol OutfitSelectorDelegate{
    func displaySelection(selection:String)
}
class OutfitSelectionVC: UIViewController {

    //References to the view
    @IBOutlet weak var OutfitSelectionView: UIView!
    
    //References to the button that will be used to control the button's colors and font
    @IBOutlet weak var AllOutfitButton: UIButton!
    @IBOutlet weak var PublicOutfitsButton: UIButton!
    @IBOutlet weak var PrivateOutfitsButton: UIButton!
    @IBOutlet weak var CancelButton: UIButton!
    
    //Initial Delegate
    var delegate:OutfitSelectorDelegate?
    
    //Variables
    var button:ButtonData!
    
    //Initializers
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    init(button: ButtonData){
        super.init(nibName: "OutfitSelectionVC", bundle: nil)
        self.modalTransitionStyle = .crossDissolve
        self.modalPresentationStyle = .overFullScreen
        self.button = button
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Assign the colors to each button
        self.AllOutfitButton.setTitleColor(.fixedFitPurple, for: .normal)
        self.PublicOutfitsButton.setTitleColor(.fixedFitBlue, for: .normal)
        self.PrivateOutfitsButton.setTitleColor(.fixedFitBlack, for: .normal)
        
        //Set up font size for all buttons
        let buttonFont = UIFont.systemFont(ofSize:18, weight: UIFont.Weight.semibold)
        
        //Assign the fonts to each button
        self.AllOutfitButton.titleLabel?.font = buttonFont
        self.PublicOutfitsButton.titleLabel?.font = buttonFont
        self.PrivateOutfitsButton.titleLabel?.font = buttonFont
        self.CancelButton.titleLabel?.font = buttonFont
 
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Actions that will pass back the value of the view controller
    @IBAction func AllOutfitsTapped(_ sender: UIButton) {
        delegate?.displaySelection(selection: ProfileOutfitKeys.all.rawValue)
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func PublicOutfitsTapped(_ sender: UIButton) {
        delegate?.displaySelection(selection: ProfileOutfitKeys.publicOutfits.rawValue)
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func PrivateOutfitsTapped(_ sender: UIButton) {
        delegate?.displaySelection(selection: ProfileOutfitKeys.privateOutfits.rawValue)
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func CancelTapped(_ sender: UIButton) {
        delegate?.displaySelection(selection: ProfileOutfitKeys.cancel.rawValue)
        self.dismiss(animated: true, completion: nil)
    } 

}
