//
//  BeerLibraryTableViewController.swift
//  BiteMe
//
//  Created by Jan Krzempek on 05/09/2020.
//  Copyright © 2020 Jan Krzempek. All rights reserved.
//

import UIKit
import Firebase
import FirebaseCore
import FirebaseFirestore
import FirebaseStorage
import FirebaseFirestoreSwift

class BeerLibraryTableViewController: UITableViewController, UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        filteredTableData.removeAll(keepingCapacity: false)
        let searchPredicate = NSPredicate(format: "SELF CONTAINS[c] %@", searchController.searchBar.text!)
        let array = (nameArray as NSArray).filtered(using: searchPredicate)
        filteredTableData = array as! [String]
        self.tableView.reloadData()
    }
    
    var dataDescription = [String]()
    var dataDescriptionDetail = [String]()
    var dataDescriptionDetailWithString = ""
    var stringWithData = ""
    var stringWithDataDetail = ""
    var IDDocumentArray : [String] = []
    var array : [String] = []
    var arrayDetail : [String] = []
    var mainArray : [String] = []
    var mainArrayDetail : [String] = []
    var db: Firestore!
    var nameValue = ""
    var TestString : String = ""
    var TestStringDetail : String = ""
    var arr = [[String]]()
    var counter = 0
    var mainCounter = 0
    var nameArray : [String] = []
    var nameArrayDetail : [String] = []
    var filteredTableData = [String]()
    var resultSearchController = UISearchController()
    var shouldShowSearchResults = false
    var IsThirdTime = true
    var IsThirdTimeDetail = true
    var countToThree = 0
    var indexTaken = 0
    var indexTakenFinished = 0
    var fullPath = ""
    
    
    override func viewWillAppear(_ animated: Bool) {
        arr = []
        nameArray = []
        array = []
        mainArray = []
        countToThree = 0
        IsThirdTime = true
        getCollection()
        tableView.reloadData()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        // [END setup]
        db = Firestore.firestore()
        
        resultSearchController = ({
            let controller = UISearchController(searchResultsController: nil)
            controller.searchResultsUpdater = self
            controller.obscuresBackgroundDuringPresentation = false
            controller.searchBar.sizeToFit()
            tableView.tableHeaderView = controller.searchBar
            return controller
        })()
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    
        @IBAction func RefreshControl(_ sender: UIRefreshControl) {
            arr = []
            nameArray = []
            array = []
            mainArray = []
            countToThree = 0
            IsThirdTime = true
            getCollection()
            tableView.reloadData()
            sender.endRefreshing()
    
        }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if  (resultSearchController.isActive) {
            return filteredTableData.count
        } else {
            return nameArray.count
        }
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if resultSearchController.isActive == false {
            if (storyboard?.instantiateViewController(identifier: "BeerDataViewController") as? DetailBeerViewController) != nil {
                fullPath = ""
                let vc = storyboard?.instantiateViewController(identifier: "BeerDataViewController") as? DetailBeerViewController
                let name = IDDocumentArray[indexPath.row]
                let indexSelected = indexPath.row
                var indexForFullData = 0
                if indexSelected == 0 {
                    indexForFullData = 0
                } else {
                    indexForFullData = (((indexSelected) * 5))
                }
                vc?.nameOfBeer = nameArray[indexPath.row]
                vc?.BeerAlco = mainArray[indexForFullData + 1]
                vc?.BeerIBU = mainArray[indexForFullData + 2]
                if mainArray[indexForFullData + 3] == "0" {
                    vc?.BeerBack = "No :("
                } else  {
                    vc?.BeerBack = "Yes!"
                }
                vc?.WGALabelData = mainArray[indexForFullData + 4]
                //po indeksie zdobywanie danych odnośnie tego piwka
                let resuts = getCollectionOfName(nameID: name)
                
                
                let PathOfFile = ".JPG"
                let nameOfPathFile = name
                fullPath = nameOfPathFile + PathOfFile
                
                let StorageRef = Storage.storage().reference(withPath: "Beer/" + fullPath)
                StorageRef.getData(maxSize: 4 * 1024 * 1024) { [weak self] (data, error) in
                    if error != nil {
                        vc?.imageViewDetaild.image = UIImage(systemName: "clear")
                    }
                    if let dataa = data {
                        vc?.imageViewDetaild.image = UIImage(data: dataa)
                    }
                }
                self.navigationController?.pushViewController(vc!, animated: true)
            }
        } else {
            let vc = storyboard?.instantiateViewController(identifier: "BeerDataViewController") as? DetailBeerViewController
            let currentChoice = filteredTableData[indexPath.row]
            for index in 0...nameArray.count - 1 {
                if nameArray[index] == currentChoice {
                    indexTaken = index
                }
            }
            if indexTaken == 0 {
                indexTakenFinished = 0
            } else {
                indexTakenFinished = (((indexTaken) * 5))
            }
            vc?.nameOfBeer = nameArray[indexTaken]
            let PathOfFile = ".JPG"
            let nameOfPathFile = IDDocumentArray[indexTaken]
            fullPath = nameOfPathFile + PathOfFile
            let StorageRef = Storage.storage().reference(withPath: "Beer/" + fullPath)
            StorageRef.getData(maxSize: 4 * 1024 * 1024) { [weak self] (data, error) in
                if error != nil {
                    vc?.imageViewDetaild.image = UIImage(systemName: "clear")
                }
                if let dataa = data {
                    vc?.imageViewDetaild.image = UIImage(data: dataa)
                }
            }
            vc?.BeerAlco = mainArray[indexTakenFinished + 1]
            vc?.BeerIBU = mainArray[indexTakenFinished + 2]
            if mainArray[indexTakenFinished + 3] == "0" {
                vc?.BeerBack = "No :("
            } else  {
                vc?.BeerBack = "Yes!"
            }
            self.view.endEditing(true)
            self.navigationController?.pushViewController(vc!, animated: true)
            resultSearchController.isActive = false
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        return 100.0;//Your custom row height
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath) as! TableCellTableViewCell
        // Configure the cell...
        if (resultSearchController.isActive) {
            cell.CellsNameLabel?.text = filteredTableData[indexPath.row]
        }
        else {
            cell.CellsNameLabel?.text = nameArray[indexPath.row]
            let indexSelected = indexPath.row
            var indexForFullData = 0
            if indexSelected == 0 {
                indexForFullData = 0
            } else {
                indexForFullData = (((indexSelected) * 5))
            }
            cell.CellsAlcoLabel.text = mainArray[indexForFullData + 1] + "%"
            if mainArray[indexForFullData + 3] == "0" {
                cell.CellsBackBottleLabel.text = "Back Bottle: No"
            } else  {
                cell.CellsBackBottleLabel.text = "Back Bottle: Yes"
            }
            //try to add image too
            let name = IDDocumentArray[indexPath.row]
            let PathOfFile = ".JPG"
            let nameOfPathFile = name
            fullPath = "Beer/" + nameOfPathFile + PathOfFile
            
            let StorageRef = Storage.storage().reference(withPath: fullPath)
            StorageRef.getData(maxSize: 4 * 1024 * 1024) { [weak self] (data, error) in
                if error != nil {
                    cell.CellsImage.image = UIImage(systemName: "clear")
                }
                if let dataa = data {
                    cell.CellsImage.image = UIImage(data: dataa)
                }
            }
            
        }
        return cell
    }
}

private extension BeerLibraryTableViewController{
    private func getCollectionOfName(nameID : String) -> Array<Any> {
        
        let docRef = db.collection("BeerData").document(nameID)
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                self.dataDescriptionDetailWithString = document.data().map(String.init(describing:)) as! String
                self.stringWithDataDetail = self.dataDescriptionDetailWithString
                for (index, char) in self.stringWithDataDetail.enumerated(){
                    if char != ">" {
                        self.stringWithDataDetail.removeFirst()
                    } else {
                        self.stringWithDataDetail.removeFirst()
                        break;
                    }
                }
                //VERSION READY TO USE WITH FULL NAME
                for (_, char) in self.stringWithDataDetail.enumerated() {
                    if char != "[" && char != "]" && char != "(" && char != ")" && char != "," && char != "\n" {
                        self.TestStringDetail += String(char)
                    }
                    if char == "," {
                        if self.TestStringDetail != "" {
                            self.arrayDetail.append(String(self.TestStringDetail))
                            self.TestStringDetail = ""
                        }
                        
                    }
                    if char == ")" {
                        if self.TestStringDetail != "" {
                            self.arrayDetail.append(String(self.TestStringDetail))
                            //print(self.TestStringDetail)
                            self.TestStringDetail = ""
                        }
                        
                    }
                    
                }
                // print(self.arrayDetail)
                if self.arrayDetail.count != 0 {
                    for elem in 0...self.arrayDetail.count-1 {
                        if self.IsThirdTimeDetail {
                            self.nameArrayDetail.append(self.arrayDetail[elem])
                            self.IsThirdTimeDetail = false
                        }
                        self.mainArrayDetail.append(self.arrayDetail[elem])
                        self.countToThree += 1
                        if self.countToThree == 5 {
                            self.IsThirdTimeDetail = true
                            self.countToThree = 0
                        }
                        
                    }
                }
                
                self.arrayDetail = []
                self.stringWithData = ""
                self.tableView.reloadData()
            } else {
                //print("Document does not exist")
            }
        }
        return mainArrayDetail
    }
}

private extension BeerLibraryTableViewController{
    private func getCollection() {
        // [START get_collection]
        db.collection("BeerData").getDocuments() { [self] (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    self.dataDescription = document.data().map(String.init(describing:))
                    self.stringWithData = self.dataDescription.joined(separator: "")
                    for (index, char) in self.stringWithData.enumerated(){
                        if char != ">" {
                            self.stringWithData.removeFirst()
                        } else {
                            self.stringWithData.removeFirst()
                            break;
                        }
                    }
                    //VERSION READY TO USE WITH FULL NAME
                    for (_, char) in self.stringWithData.enumerated() {
                        
                        if char != "[" && char != "]" && char != "(" && char != ")" && char != "," && char != "\n" {
                            self.TestString += String(char)
                        }
                        if char == "," {
                            if self.TestString != "" {
                                self.array.append(String(self.TestString))
                                self.TestString = ""
                                
                            }
                            
                        }
                        if char == ")" {
                            if self.TestString != "" {
                                self.array.append(String(self.TestString))
                                self.TestString = ""
                            }
                            
                        }
                        
                    }
                    print(self.array)
                    if self.array.count != 0 {
                        for elem in 0...self.array.count-1 {
                            if self.IsThirdTime {
                                self.nameArray.append(self.array[elem])
                                IDDocumentArray.append(document.documentID)
                                self.IsThirdTime = false
                            }
                            self.mainArray.append(self.array[elem])
                            self.countToThree += 1
                            if self.countToThree == 5 {
                                self.IsThirdTime = true
                                self.countToThree = 0
                            }
                        }
                    }
                    self.array = []
                    self.stringWithData = ""
                }
                self.tableView.reloadData()
                print("------------------------------")
            }
        }
    }
}
