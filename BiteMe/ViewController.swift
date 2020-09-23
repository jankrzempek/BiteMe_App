//
//  ViewController.swift
//  BiteMe
//
//  Created by Jan Krzempek on 09/08/2020.
//  Copyright © 2020 Jan Krzempek. All rights reserved.
//

import UIKit
import CoreML
import Vision
import Firebase
import FirebaseCore
import FirebaseFirestore
import FirebaseFirestoreSwift



class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var IsBackLabelData: UILabel!
    @IBOutlet weak var IBULabelData: UILabel!
    @IBOutlet weak var NameLabelData: UILabel!
    @IBOutlet weak var TestingLabel: UILabel!
    var db: Firestore!
    @IBOutlet weak var BlessYouLabel: UILabel!
    @IBOutlet weak var BeerCanGiveIItBack: UILabel!
    @IBOutlet weak var BeerIBULabel: UILabel!
    @IBOutlet weak var BeerPercentLabel: UILabel!
    @IBOutlet weak var BeerNameLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    let imagePicker = UIImagePickerController()
    var array : [String] = []
    var TestString : String = ""
    var countBreaks = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        BlessYouLabel.text = "Scan a beer, please!"
        IsBackLabelData.layer.masksToBounds = true
        IBULabelData.layer.masksToBounds = true
        NameLabelData.layer.masksToBounds = true
        TestingLabel.layer.masksToBounds = true
        BlessYouLabel.layer.masksToBounds = true
        BeerPercentLabel.layer.masksToBounds = true
        BeerIBULabel.layer.masksToBounds = true
        BeerCanGiveIItBack.layer.masksToBounds = true
        
        IsBackLabelData.layer.cornerRadius = 18
        IBULabelData.layer.cornerRadius = 18
        NameLabelData.layer.cornerRadius = 8
        TestingLabel.layer.cornerRadius = 18
        BlessYouLabel.layer.cornerRadius = 8
        BeerPercentLabel.layer.cornerRadius = 18
        BeerIBULabel.layer.cornerRadius = 18
        BeerCanGiveIItBack.layer.cornerRadius = 18
        
          imageView.layer.borderWidth = 4
         
          imageView.layer.masksToBounds = false
          imageView.layer.borderColor = UIColor.lightGray.cgColor
          imageView.layer.cornerRadius = imageView.frame.height/3
          imageView.clipsToBounds = true
        
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
        let settings = FirestoreSettings()

               Firestore.firestore().settings = settings
               // [END setup]
               db = Firestore.firestore()
       
    }
    
    struct BeerModel{
        var name: String
        var percent: String
        var IBU: String
        var IsBack: String
    }
    
    func printOut(name: String, percent: String, IBU: String, GiveBack: String){
        BeerNameLabel.text = name
        BeerPercentLabel.text = percent
        BeerIBULabel.text = IBU
        BeerCanGiveIItBack.text = GiveBack
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let imagePicked = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            imageView.image = imagePicked
            guard let ciiImage = CIImage(image: imagePicked) else {
                fatalError("Sorry")
            }
            detect(image: ciiImage)
        }
        imagePicker.dismiss(animated: true, completion: nil)
       
    }
    
    
    func detect(image: CIImage){
        guard let model = try? VNCoreMLModel(for: BeerImageClassifier_1_1_0_2().model) else {
            fatalError("Sorry")
        }
        let request = VNCoreMLRequest(model: model) { (request, error) in
            guard let results = request.results as? [VNClassificationObservation] else {
                fatalError("Sorry")
            }
        
            if let firstResult = results.first{
                let nameL = firstResult.identifier
                self.BlessYouLabel.text = "Analizing!"
                self.getCollection(name: nameL)
                print(results)
                print("++++++++++++++++++++")
                print(nameL)
            }
        }
        let handler = VNImageRequestHandler(ciImage: image)
        
        do {
            try handler.perform([request])
        }
        catch {
            print(error)
        }
        
    }
    
    @IBAction func cameraTapped(_ sender: UIBarItem) {
        present(imagePicker, animated: true, completion: nil)
    }
    


    private func getCollection(name : String) {
       // [START get_collection]
    array = []
    let docRef = db.collection("BeerData").document(name)
        docRef.getDocument { [self] (document, error) in
        if let document = document, document.exists {
            var dataDescription = document.data().map(String.init(describing:)) ?? "nil"
            //print("Document data: \(dataDescription)")
            //print(dataDescription)
            /*
             index 0: Full name
             index 1: percent
             index 2: IBU
             index 3: CanGiveItBack
             
             example:
             
             [("Książęcę Pszeniczne","4.9","5","1")]
             */
            for (index, char) in dataDescription.enumerated() {
                if char != ">" {
                    dataDescription.removeFirst()
                } else {
                    dataDescription.removeFirst()
                    break;
                }
            }
            //print(dataDescription)
//          
        //VERSION READY TO USE WITH FULL NAME
            for (_, char) in dataDescription.enumerated() {

                if char != "[" && char != "]" && char != "(" && char != ")" && char != "," && char != "\n" {
                    self.TestString += String(char)
                }
                if char == "," {
                    if self.TestString != "" {
                        self.array.append(String(self.TestString))
                       // print(self.TestString)
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
            //print(self.array)
          
            if self.array.count == 4 {
                let IBUValue = self.array[2]
           
            self.NameLabelData.text = String(self.array[0])
            
           
            self.TestingLabel.text = "\(String(self.array[1])) %"
            switch Int(IBUValue)! {
            case 0...20:
                self.IBULabelData.text = "\(IBUValue) - 😃"
            case 21...60:
                self.IBULabelData.text = "\(IBUValue) - 😉"
            case 61...80:
                self.IBULabelData.text = "\(IBUValue) - 😳"
            default:
                self.IBULabelData.text = "\(IBUValue) - 😵"
            }
        
               
            if String(self.array[3]) == "1" {
            self.IsBackLabelData.text = "Yes!"
            } else {
            self.IsBackLabelData.text = "No :("
            }
            
                self.BlessYouLabel.text = "Have a Good 🍺!"
            
                
            } else {
                self.BlessYouLabel.text = "Problem with data, sorry."
                self.NameLabelData.text = " - "
                self.TestingLabel.text = " - "
                self.IBULabelData.text = " - "
                self.IsBackLabelData.text = " - "
            }
        } else {
            print("Document does not exist")
            self.BlessYouLabel.text = "No Data yet :("
            self.NameLabelData.text = " - "
            self.TestingLabel.text = " - "
            self.IBULabelData.text = " - "
            self.IsBackLabelData.text = " - "
        }
    }
}
}
