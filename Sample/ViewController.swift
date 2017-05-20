//
//  ViewController.swift
//  Sample
//
//  Created by Manish Bhande on 14/05/17.
//  Copyright © 2017 Manish Bhande. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var pagePickerView: MBPickerView!
    @IBOutlet weak var slider: UISlider!

    override func viewDidLoad() {
        super.viewDidLoad()
        pagePickerView.showAllItem = UIDevice.current.userInterfaceIdiom == .pad
        pagePickerView.delegate = self
        pagePickerView.dataSource = self
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func sliderViewChanged(_ sender: UISlider) {
        pagePickerView.selectItem(Int(sender.value))
    }

}

extension ViewController: MBPickerViewDelegate, MBPickerViewDataSource {

    func pickerViewNumberOfItems(_ pickerView: MBPickerView) -> Int {
        slider.maximumValue = 6
        return 7
    }

    func pickerView(_ pickerView: MBPickerView, titleAtItem item: Int) -> String {
        return "Page \(item+1)"
    }

    func pickerView(_ pickerView: MBPickerView, willSelectItem item: Int) {
        label.text = "Will select item: \(item+1)"
    }

    func pickerView(_ pickerView: MBPickerView, didSelectItem item: Int) {
        label.text = "Selected item: \(item+1)"
        slider.value = Float(item)
    }
}
