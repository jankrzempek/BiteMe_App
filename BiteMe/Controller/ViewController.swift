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
import FirebaseStorage
import FirebaseFirestore
import CircleProgressBar
import FirebaseStorage

class ViewController: UIViewController, UINavigationControllerDelegate {
    
    @IBOutlet weak var WGASquare: UIView!
    @IBOutlet weak var IsBackSquare: UIView!
    @IBOutlet weak var IBUSquare: UIView!
    @IBOutlet weak var AlcoholSquare: UIView!
    
    @IBOutlet weak var libraryButton: UIButton!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var ConfidenceLabel: UILabel!
    @IBOutlet weak var NameLabelData: UILabel!
    @IBOutlet weak var BlessYouLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var AlcoholLabel: UILabel!
    @IBOutlet weak var IBULabel: UILabel!
    @IBOutlet weak var WGALabel: UILabel!
    @IBOutlet weak var IsBackLabel: UILabel!
    
    
    @IBOutlet weak var helpImproveButton: UIButton!
    
    let settings = FirestoreSettings()
    let db = Firestore.firestore()
    let storage = Storage.storage().reference()
    
    var countBreaks = 0
    let imagePicker = UIImagePickerController()
    var array : [String] = []
    var TestString : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        BlessYouLabel.text = "Naciśnij przycisk kamery i skanuj!"
        
        NameLabelData.layer.masksToBounds = true
        BlessYouLabel.layer.masksToBounds = true
        imageView.layer.masksToBounds = false
        AlcoholSquare.layer.masksToBounds = true
        IBUSquare.layer.masksToBounds = true
        WGASquare.layer.masksToBounds = true
        IsBackSquare.layer.masksToBounds = true
        
        NameLabelData.layer.cornerRadius = 8
        BlessYouLabel.layer.cornerRadius = 8
        imageView.layer.cornerRadius = imageView.frame.height/8
        AlcoholSquare.layer.cornerRadius = 18
        IBUSquare.layer.cornerRadius = 18
        WGASquare.layer.cornerRadius = 18
        IsBackSquare.layer.cornerRadius = 18
        
        imageView.layer.borderWidth = 4
        imageView.clipsToBounds = true
        
        AlcoholSquare.layer.borderWidth = 3
        AlcoholSquare.layer.borderColor = UIColor.black.cgColor
        AlcoholSquare.clipsToBounds = true
        
        IBUSquare.layer.borderWidth = 3
        IBUSquare.layer.borderColor = UIColor.black.cgColor
        IBUSquare.clipsToBounds = true
        
        WGASquare.layer.borderWidth = 3
        WGASquare.layer.borderColor = UIColor.black.cgColor
        WGASquare.clipsToBounds = true
        
        IsBackSquare.layer.borderWidth = 3
        IsBackSquare.layer.borderColor = UIColor.black.cgColor
        IsBackSquare.clipsToBounds = true
        
        BlessYouLabel.layer.borderWidth = 3
        BlessYouLabel.layer.borderColor = UIColor.orange.cgColor
        BlessYouLabel.clipsToBounds = true
        
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        
        Firestore.firestore().settings = settings
    }
    
    @IBAction func CameraButtonTapped(_ sender: UIButton) {
        imagePicker.sourceType = .camera
        present(imagePicker, animated: true, completion: nil)
    }
    @IBAction func libraryButtonTapped(_ sender: Any) {
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    @IBAction func helpImproveAction(_ sender: Any) {
        print(NameLabelData.text ?? "None")
        let identifier = UUID()
        if let imageData = imageView.image?.pngData() {
            storage.child("ImproveBeers/\(identifier.uuidString).png").putData(imageData, metadata: nil) { _, error in
                guard error == nil else {
                    print("error")
                    return
                }
            }
        }
    }
}

extension ViewController : UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let imagePicked = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            imageView.image = imagePicked
            guard let ciiImage = CIImage(image: imagePicked) else {
                fatalError("Sorry")
            }
            detectBottle(image: ciiImage)
        }
        imagePicker.dismiss(animated: true, completion: nil)
        
    }
}

private extension ViewController{
    
    /*
     index 0: Full name
     index 1: percent
     index 2: IBU
     index 3: CanGiveItBack
     index 4: koncenrat
     
     example:
     
     [("Książęcę Pszeniczne","4.9","5","1","0")]
     
     */
    
    func getCollection(name : String) {
        // [START get_collection]
        array = []
        let docRef = db.collection("BeerData").document(name)
        docRef.getDocument { [self] (document, error) in
            if let document = document, document.exists {
                var dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                
                for (index, char) in dataDescription.enumerated() {
                    if char != ">" {
                        dataDescription.removeFirst()
                    } else {
                        dataDescription.removeFirst()
                        break;
                    }
                }
                //VERSION READY TO USE WITH FULL NAME
                for (_, char) in dataDescription.enumerated() {
                    
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
                if self.array.count == 5 {
                    //uploading real photo
                    //finish uploading
                    var IBU = Double(self.array[2])
                    let IBUVAL = self.array[2]
                    let firstArray = self.array[1]
                    let WGABeer = Double(self.array[4])
                    AlcoholLabel.text = firstArray + "%"
                    self.NameLabelData.text = String(self.array[0])
                    IBULabel.text = IBUVAL
                    WGALabel.text = String(WGABeer!)
                    if self.array[3] == "1" {
                        IsBackLabel.text = "Tak"
                    } else {
                        IsBackLabel.text = "Nie"
                    }
                    
                    // 15% of alcohol is taken as the macimum possible value
                    
                    self.BlessYouLabel.text = "Na Zdrowie 🍺!"
                } else {
                    self.BlessYouLabel.text = "Problem z danymi, wybacz."
                    self.NameLabelData.text = "---"
                }
            } else {
                print("Document does not exist")
                self.BlessYouLabel.text = "Nie posiadam danych :("
                self.NameLabelData.text = "---"
            }
        }
    }
}

private extension ViewController{
    func detect(image: CIImage){
        guard let model = try? VNCoreMLModel(for: BeerImageClassifier_1_1_03().model) else {
            fatalError("Wybacz")
        }
        let request = VNCoreMLRequest(model: model) { (request, error) in
            guard let results = request.results as? [VNClassificationObservation] else {
                fatalError("Wybacz")
            }
            
            if let firstResult = results.first{
                let nameL = firstResult.identifier
                self.BlessYouLabel.text = "Analizuję!"
                self.getCollection(name: nameL)
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
}

private extension ViewController{
    func detectBottle(image: CIImage){
        guard let model = try? VNCoreMLModel(for: IfIsABottleModel_1().model) else {
            fatalError("Sorry")
        }
        let request = VNCoreMLRequest(model: model) { (request, error) in
            guard let results = request.results as? [VNClassificationObservation] else {
                fatalError("Sorry")
            }
            
            if let firstResult = results.first{
                if firstResult.identifier == "Bottle" {
                    self.detect(image: image)
                } else {
                    self.BlessYouLabel.text = "To nie jest butelka piwa"
                    self.NameLabelData.text = "Nazwa na to nie istnieje"
                    self.AlcoholLabel.text = "-"
                    self.IBULabel.text = "-"
                    self.WGALabel.text = "-"
                    self.IsBackLabel.text = "-"
                }
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
}
