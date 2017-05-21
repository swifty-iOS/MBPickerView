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
    @IBOutlet weak var pageSlider: UISlider!
    @IBOutlet weak var pageScaleSlider: UISlider!
    
    @IBOutlet weak var labelPageScale: UILabel!
    let pageCount = 10
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pagePickerView.showAllItem = UIDevice.current.userInterfaceIdiom == .pad
        pagePickerView.delegate = self
        pagePickerView.dataSource = self
        pagePickerView.allowSelectionWhileScrolling = false
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func sliderViewChanged(_ sender: UISlider) {
        if pagePickerView.currentItem != Int(sender.value) {
            pagePickerView.selectItem(Int(sender.value), animation: true)
        }
    }
    
    @IBAction func pageScaleChange(_ sender: UISlider) {
        pagePickerView.itemPadingScale = CGFloat(sender.value)
        labelPageScale.text = "Select page scale: \(sender.value)"
    }
}

extension ViewController: MBPickerViewDelegate, MBPickerViewDataSource {
    
    func pickerViewNumberOfItems(_ pickerView: MBPickerView) -> Int {
        pageSlider.maximumValue = max(0, Float(pageCount-1))
        pageScaleSlider.maximumValue = max(0, Float(pageCount-1))
        pageScaleSlider.value = Float(pagePickerView.itemPadingScale)
        labelPageScale.text = "Select page scale: \(pageScaleSlider.value)"
        return pageCount
    }
    
    func pickerView(_ pickerView: MBPickerView, titleAtItem item: Int) -> String {
        return "Page \(item+1)"
    }
    
    func pickerView(_ pickerView: MBPickerView, didSelectItem item: Int) {
        print("Select item \(item+1) = \(Date())")
        label.text = "Selected item: \(item+1)"
        pageSlider.value = Float(item)
    }
}
