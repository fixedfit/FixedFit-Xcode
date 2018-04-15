//
//  ChooseUserPhotoVC.swift
//  FixedFit
//
//  Created by Esmeralda Salas on 4/14/18.
//  Copyright © 2018 UNLV. All rights reserved.
//

import UIKit
protocol PhotoSourceDelegate{
    func didChooseOption(choice: String)
}
class ChooseUserPhotoVC: UIViewController {

    //References of main view
    @IBOutlet weak var SelectView: UIView!
    
    //References of button
    @IBOutlet weak var CancelButton: UIButton!
    @IBOutlet weak var CameraButton: UIButton!
    @IBOutlet weak var PhotoLibraryButton: UIButton!
    @IBOutlet weak var DefaultPhotoButton: UIButton!
    
    //Initial Delegate
    var delegate: PhotoSourceDelegate?
    
    //Initial ButtonData
    var button: ButtonData!
    
    //Initializers
    init(button: ButtonData){
        super.init(nibName: "ChooseUserPhotoVC", bundle: nil)
        self.modalTransitionStyle = .crossDissolve
        self.modalPresentationStyle = .overFullScreen
        
        self.button = button
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Set the color scheme for each button
        self.CameraButton.setTitleColor(.fixedFitPurple, for: .normal)
        self.PhotoLibraryButton.setTitleColor(.fixedFitBlue, for: .normal)
        self.DefaultPhotoButton.setTitleColor(.fixedFitBlack, for: .normal)
        
        //Set up font size for all buttons
        let buttonFont = UIFont.systemFont(ofSize:18, weight: UIFont.Weight.semibold)
        
        self.CameraButton.titleLabel?.font = buttonFont
        self.PhotoLibraryButton.titleLabel?.font = buttonFont
        self.DefaultPhotoButton.titleLabel?.font = buttonFont
        self.CancelButton.titleLabel?.font = buttonFont
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //Actions to be performed
    @IBAction func cancelSelected(_ sender: UIButton) {
        delegate?.didChooseOption(choice: EditorKeys.cancel.rawValue)
        self.dismiss(animated: true, completion: button?.action)
    }
    @IBAction func SelectDefaultPhoto(_ sender: UIButton) {
        delegate?.didChooseOption(choice: EditorKeys.defaultPhoto.rawValue)
        self.dismiss(animated: true, completion: button?.action)
    }
    @IBAction func SelectFromPhotoLibrary(_ sender: UIButton) {
        delegate?.didChooseOption(choice: EditorKeys.library.rawValue)
        self.dismiss(animated: true, completion: button?.action)
    }
    @IBAction func SelectFromCamera(_ sender: UIButton) {
        delegate?.didChooseOption(choice: EditorKeys.camera.rawValue)
        self.dismiss(animated: true, completion: button?.action)
    }
    
}
