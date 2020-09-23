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
    //var filteredData = nameArray
    var shouldShowSearchResults = false
    var IsThirdTime = true
    var IsThirdTimeDetail = true
    var countToThree = 0
    var indexTaken = 0
    var indexTakenFinished = 0
    
    
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
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        if  (resultSearchController.isActive) {
            return filteredTableData.count
            
            //print(filteredTableData)
        } else {
            //print(nameArray)
          
            return nameArray.count
        }
      
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if resultSearchController.isActive == false {
        if (storyboard?.instantiateViewController(identifier: "BeerDataViewController") as? DetailBeerViewController) != nil {
            
            let vc = storyboard?.instantiateViewController(identifier: "BeerDataViewController") as? DetailBeerViewController
            print("Just BEFORE")
            //print(nameArray)
            print("IDDOCU!!!!!!!!!!")
            print(self.mainArray)
            //print(IDDocumentArray[indexPath.row])
            let name = IDDocumentArray[indexPath.row]
            print(indexPath.row)
            let indexSelected = indexPath.row
            print("index Selected \(indexSelected)")
            var indexForFullData = 0
            if indexSelected == 0 {
            indexForFullData = 0
            } else {
            indexForFullData = (((indexSelected) * 4)) 
                //print("index full date \(indexForFullData)")
            }
            vc?.nameOfBeer = nameArray[indexPath.row]
               
                    print(mainArray[indexForFullData])
                    vc?.BeerAlco = mainArray[indexForFullData + 1]
                    vc?.BeerIBU = mainArray[indexForFullData + 2]
                    if mainArray[indexForFullData + 3] == "0" {
                        vc?.BeerBack = "No :("
                    } else  {
                        vc?.BeerBack = "Yes!"
                    }
                
        
            //po indeksie zdobywanie danych odnośnie tego piwka
            let resuts = getCollectionOfName(nameID: name)
           
            print("MAINARRAYCOUNT!!!!")
            //print(mainArrayDetail.count)
            //nameArrayDetail = []
            //mainArrayDetail = []
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
            indexTakenFinished = (((indexTaken) * 4))
                print("index full date \(indexTakenFinished)")
            }
            vc?.nameOfBeer = nameArray[indexTaken]
               
                   
                    vc?.BeerAlco = mainArray[indexTakenFinished + 1]
                    vc?.BeerIBU = mainArray[indexTakenFinished + 2]
                    if mainArray[indexTakenFinished + 3] == "0" {
                        vc?.BeerBack = "No :("
                    } else  {
                        vc?.BeerBack = "Yes!"
                    }
            self.view.endEditing(true)
            self.navigationController?.pushViewController(vc!, animated: true)
            
        }
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath) as! TableCellTableViewCell
        
        
        // Configure the cell...
        //print("ArrayIndex \(array[indexPath.row])+++++++++++++++++++++++")
        
        
        
        if (resultSearchController.isActive) {
            cell.textLabel?.text = filteredTableData[indexPath.row]
            
            return cell
        }
        else {
            cell.textLabel?.text = nameArray[indexPath.row]
            //print(nameArray[indexPath.row])
            return cell
        }
        //cell.textLabel?.text = nameArray[indexPath.row]
        return cell
    }
    
    private func getCollection() {
        // [START get_collection]
        
        db.collection("BeerData").getDocuments() { [self] (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    self.dataDescription = document.data().map(String.init(describing:))
                    
                    //print("\(document.documentID) => \(document.data())")
                    self.stringWithData = self.dataDescription.joined(separator: "")
                    //print(self.stringWithData)
                    
                    
                    
                    for (index, char) in self.stringWithData.enumerated(){
                        if char != ">" {
                            self.stringWithData.removeFirst()
                        } else {
                            self.stringWithData.removeFirst()
                            break;
                        }
                    }
                    //  print(stringWithData)
                    //
                    //VERSION READY TO USE WITH FULL NAME
                    for (_, char) in self.stringWithData.enumerated() {
                        
                        if char != "[" && char != "]" && char != "(" && char != ")" && char != "," && char != "\n" {
                            self.TestString += String(char)
                        }
                        if char == "," {
                            if self.TestString != "" {
                                //print(self.mainCounter)
                                //print(self.counter)
                                //arr[mainCounter][counter] = self.TestString
                                self.array.append(String(self.TestString))
                                //print(self.TestString)
                                self.TestString = ""
                                
                                
                            }
                            
                        }
                        if char == ")" {
                            if self.TestString != "" {
                                self.array.append(String(self.TestString))
                                //print(self.TestString)
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
                            if self.countToThree == 4 {
                                self.IsThirdTime = true
                                self.countToThree = 0
                            }
                        }
                    }
                    
                    
                    self.array = []
                    self.stringWithData = ""
                    //print(self.mainArray)
                    //print(IDDocumentArray)
                    
                    
                    
                }
                self.tableView.reloadData()
                //print("-----------------------------")
                //print(self.arr)
                print("------------------------------")
            }
            
            /*
             index 0: Full name
             index 1: percent
             index 2: IBU
             index 3: CanGiveItBack
             
             example:
             
             [("Książęcę Pszeniczne","4.9","5","1")]
             */
            
            
            
            
            
            
            //print(self.mainArray)
        }
        
        
//        print("ARRR is PRINTED!")
//       print(nameArray)
//        print("-----------------")
    }
    
    private func getCollectionOfName(nameID : String) -> Array<Any> {
        
        let docRef = db.collection("BeerData").document(nameID)
        
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                self.dataDescriptionDetailWithString = document.data().map(String.init(describing:)) as! String
                
                //print(document.documentID)
                self.stringWithDataDetail = self.dataDescriptionDetailWithString
                //print("stringwithdata")
                //print(self.stringWithDataDetail)
                
                
                
                for (index, char) in self.stringWithDataDetail.enumerated(){
                    if char != ">" {
                        self.stringWithDataDetail.removeFirst()
                    } else {
                        self.stringWithDataDetail.removeFirst()
                        break;
                    }
                }
                //  print(stringWithData)
                //
                //VERSION READY TO USE WITH FULL NAME
                for (_, char) in self.stringWithDataDetail.enumerated() {
                    
                    if char != "[" && char != "]" && char != "(" && char != ")" && char != "," && char != "\n" {
                        self.TestStringDetail += String(char)
                    }
                    if char == "," {
                        if self.TestStringDetail != "" {
                            //print(self.mainCounter)
                            //print(self.counter)
                            //arr[mainCounter][counter] = self.TestString
                            self.arrayDetail.append(String(self.TestStringDetail))
                            //print(self.TestStringDetail)
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
                            //self.IDDocumentArray.append(document.documentID)
                            self.IsThirdTimeDetail = false
                        }
                        self.mainArrayDetail.append(self.arrayDetail[elem])
                        self.countToThree += 1
                        if self.countToThree == 4 {
                            self.IsThirdTimeDetail = true
                            self.countToThree = 0
                        }
                        
                    }
                }
                
                self.arrayDetail = []
                self.stringWithData = ""
                //print(self.mainArrayDetail)
                //print(self.IDDocumentArray)
                
                
                
                
                self.tableView.reloadData()
               // print("-----------------------------")
                //print("-----------------------------")
                
               // print(self.mainArrayDetail)
                //print(self.mainArrayDetail.count)
                //print("------------------------------")
                
                
                //print("Document data: \(self.dataDescriptionDetail)")
                
            } else {
                //print("Document does not exist")
            }
        }
        return mainArrayDetail
    }
}

