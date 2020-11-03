//
//  DetailBeerViewController.swift
//  BiteMe
//
//  Created by Jan Krzempek on 18/09/2020.
//  Copyright © 2020 Jan Krzempek. All rights reserved.
//

import UIKit

class DetailBeerViewController: UIViewController {
    
    var nameOfBeer = "-"
    var BeerAlco = "-"
    var BeerIBU = "-"
    var BeerBack = "-"
    var WGALabelData = "-"
    
    @IBOutlet weak var imageViewDetaild: UIImageView!
    @IBOutlet weak var alcoLabel: UILabel!
    @IBOutlet weak var BeerIBULabel: UILabel!
    @IBOutlet weak var BeerBackLabel: UILabel!
    @IBOutlet weak var BeerNameLabel: UILabel!
    @IBOutlet weak var WGALabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        BeerBackLabel.layer.masksToBounds = true
        alcoLabel.layer.masksToBounds = true
        BeerIBULabel.layer.masksToBounds = true
        WGALabel.layer.masksToBounds = true
        
        BeerBackLabel.layer.cornerRadius = 10
        BeerIBULabel.layer.cornerRadius = 10
        alcoLabel.layer.cornerRadius = 10
        WGALabel.layer.cornerRadius = 10
        
        BeerNameLabel.text = "\(nameOfBeer)"
        alcoLabel.text = "\(BeerAlco) %"
        BeerIBULabel.text = "\(BeerIBU)"
        BeerBackLabel.text = "\(BeerBack)"
        WGALabel.text = "\(WGALabelData)"
        
       
       
    }
    


}
