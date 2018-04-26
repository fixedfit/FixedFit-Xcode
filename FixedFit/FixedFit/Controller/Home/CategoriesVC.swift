//
//  CategoriesVC.swift
//  FixedFit
//
//  Created by Esmeralda Salas on 4/7/18.
//  Copyright © 2018 UNLV. All rights reserved.
//

import UIKit

class CategoriesVC: UIViewController, UserInfoDelegate{
    
    private let firebaseManager = FirebaseManager.shared
    
    //Initial title variable for the View Controller
    var viewTitle: String!
    
    //Initial variable for new category
    var newCategory: String!
    
    //Initial variable to hold the categories
    var categories: [String] = []
    
    //Hold the array of default categories to ignore changes on them
    static let defaultCategories = ["tops", "bottoms","footwear","accessories"]
    
    //Reference to the category view
    @IBOutlet var CategoryView: UIView!
    
    //Reference to the table view
    @IBOutlet weak var TableView: UITableView!
    
    //Reference to the category button and label
    @IBOutlet weak var AddCategoryButton: UIBarButtonItem!
    @IBOutlet weak var CategoryStatusLabel: UILabel!
    
    //Variable to determine if the operation has been cancelled
    var cancelled: Bool!
    
    //Loading and initializing functions
    override func viewDidLoad(){
        super.viewDidLoad()
        
        setupView()
        
    }
    func setupView(){
        self.navigationItem.title = viewTitle
        self.TableView.delegate = self
        self.TableView.dataSource = self
        self.TableView.tableFooterView = UIView()
        
        //Retrieve the categories array from firebase
        self.firebaseManager.fetchCustomCategories(){ (categoryList) in
            if categoryList == nil{
                self.categories = []
                self.CategoryStatusLabel.isHidden = false
            } else {
                self.categories = categoryList!
                self.CategoryStatusLabel.isHidden = true
                
                //Remove the default list of categories to only reveal the custom categories
                
            }
            self.TableView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        //Show or hidden the no category label
        if (self.categories.count == 0){
            self.CategoryStatusLabel.isHidden = false
        } else {
            self.CategoryStatusLabel.isHidden = true
        }
    }
    
    //Action when the button is selected to add a new category
    @IBAction func AddCategorySelected(_ sender: UIBarButtonItem) {
        
        //Initialize a dispatch
        let dispatch = DispatchGroup()
        
        //Initialize button action and enter block
        dispatch.enter()
        let button = ButtonData(title: "", color: UIColor()){
            dispatch.leave()
        }
        
        //Instantiate view controller and present it
        let vc = ChangeUserInfoVC(buttonAction: button, changingInfoMode: SettingKeys.newCategory.rawValue)
        vc.delegate = self
        self.present(vc, animated: true, completion: nil)
        
        //Wait until the user has entered the new category
        dispatch.notify(queue: .main){
            
            //If the user cancelled, then just return
            if(self.cancelled == true){
                return
                
            //Determine if the category already exist or not
            } else if(self.categories.contains(self.newCategory)){
                self.presentInfoVC()
                return
            }
            
            ////Append the new category to the array
            self.categories.append(self.newCategory)
            
            let indexPath = IndexPath(row: (self.categories.count - 1), section: 0)
            
            self.TableView.beginUpdates()
            self.TableView.insertRows(at: [indexPath], with: .automatic)
            self.TableView.endUpdates()
        }
    }
    
    //Function used to present an information vc when the category could not be added
    private func presentInfoVC(){
        let buttonDataRight = ButtonData(title: "OK", color: .fixedFitBlue, action: nil)
        let secondInformationVC = InformationVC(message: "Entry already in Categories list", image: UIImage(named: "error diagram"), leftButtonData: nil, rightButtonData: buttonDataRight)
        
        self.present(secondInformationVC, animated: true, completion:nil)
    }
    
    //Store the current category array into firebase
    override func viewWillDisappear(_ animated: Bool) {
        
        //Append the array of default categories
        
        
        //Update the array of strings to firebase
        self.firebaseManager.updateCustomCategorie(categories: self.categories)
        
    }
    
    //ChangeUserInfoVC function:
    /*
     Function used to retrieve the new category that the user inputed
    */
    func saveUserInfo(userInfo: String, cancel: Bool) {
        self.newCategory = userInfo
        self.cancelled = cancel
    }
}

extension CategoriesVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //Initialize each table view cell with the user's categories
        let cell = tableView.dequeueReusableCell(withIdentifier: CategorySettingCell.identifier, for: indexPath) as! CategorySettingCell
        
        //obtain the current index value at the indexPath
        let index = indexPath.row
        
        //Obtain the selected category
        let category = self.categories[index]
        
        //Configure the cell
        cell.configure(category: category)
        
        return cell
    }
}

extension CategoriesVC: UITableViewDelegate {
    //Functions for table view cells height and editing style
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        //Obtain the index of the cell
        let index = indexPath.row
        
        if editingStyle == .delete{
            self.categories.remove(at: index)
            self.TableView.reloadData()
        }
    }
}
