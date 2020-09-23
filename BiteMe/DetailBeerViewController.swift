//
//  DetailBeerViewController.swift
//  BiteMe
//
//  Created by Jan Krzempek on 18/09/2020.
//  Copyright © 2020 Jan Krzempek. All rights reserved.
//

import UIKit

class DetailBeerViewController: UIViewController {
    
    
    @IBOutlet weak var alcoLabel: UILabel!
    var nameOfBeer = "-"
    var BeerAlco = "-"
    var BeerIBU = "-"
    var BeerBack = "-"
    
    @IBOutlet weak var BeerBackLabel: UILabel!
    @IBOutlet weak var BeerIBULabel: UILabel!
    @IBOutlet weak var BeerNameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        BeerBackLabel.layer.masksToBounds = true
        alcoLabel.layer.masksToBounds = true
        BeerIBULabel.layer.masksToBounds = true
        BeerBackLabel.layer.cornerRadius = 10
        BeerIBULabel.layer.cornerRadius = 10
        alcoLabel.layer.cornerRadius = 10
        BeerNameLabel.text = "\(nameOfBeer)"
        alcoLabel.text = "\(BeerAlco) %"
        BeerIBULabel.text = "\(BeerIBU)"
        BeerBackLabel.text = "\(BeerBack)"
       
    }
    


}
