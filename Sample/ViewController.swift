//
//  ViewController.swift
//  Sample
//
//  Created by Manish Bhande on 14/05/17.
//  Copyright © 2017 Manish Bhande. All rights reserved.
//

import UIKit

struct AppName {
    var title: String = ""
    var image: UIImage?
    
    static func defaultApps() -> [AppName] {
        return [AppName(title: "Amazon", image: #imageLiteral(resourceName: "Amazon")),
        AppName(title: "Android", image: #imageLiteral(resourceName: "Android")),
        AppName(title: "Blackberry", image: #imageLiteral(resourceName: "Blackberry")),
        AppName(title: "Chrome", image: #imageLiteral(resourceName: "Chrome")),
        AppName(title: "Facebook", image: #imageLiteral(resourceName: "Facebook")),
        AppName(title: "Google Drive", image: #imageLiteral(resourceName: "GoogleDrive")),
        AppName(title: "Messenger", image: #imageLiteral(resourceName: "Messenger")),
        AppName(title: "Twitter", image: #imageLiteral(resourceName: "Twitter")),
        AppName(title: "Whats app", image: #imageLiteral(resourceName: "Whatsapp")),
        AppName(title: "Youtube", image: #imageLiteral(resourceName: "Youtube"))]
    }
}



class ViewController: UIViewController {
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var pagePickerView: MBPickerView!
    @IBOutlet weak var pageSlider: UISlider!
    @IBOutlet weak var pageScaleSlider: UISlider!
    
    @IBOutlet weak var labelPageScale: UILabel!
    let apps = AppName.defaultApps()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pagePickerView.selectItem(2, animation: false)
        pagePickerView.showAllItem = UIDevice.current.userInterfaceIdiom == .pad
        pagePickerView.delegate = self
        pagePickerView.dataSource = self
        pagePickerView.allowSelectionWhileScrolling = false
       // pagePickerView.selectItem(2, animation: true)
        
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
        pageSlider.maximumValue = max(0, Float(apps.count-1))
        pageScaleSlider.maximumValue = max(0, Float(apps.count-1))
        pageScaleSlider.value = Float(pagePickerView.itemPadingScale)
        labelPageScale.text = "Select page scale: \(pageScaleSlider.value)"
        return apps.count
    }
    
    func pickerView(_ pickerView: MBPickerView, viewAtItem item: Int) -> UIView {
        if let view =  PickerCell.loadFromNib() {
            view.imageView.image = apps[item].image
            view.labelTitle.text = apps[item].title
            view.alpha = pickerView.currentItem == item ? 1 : 0.3
            view.backgroundColor = .clear
            return view
        }
        return UIView()
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
