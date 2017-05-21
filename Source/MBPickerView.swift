//
//  MBPickerView.swift
//
//
//  Created by Manish Bhande on 14/05/17.
//  Copyright © 2017 Manish Bhande. All rights reserved.
//

import UIKit

/// Define Picker title attributes
struct PickerTitleAttributes {
    var color: UIColor!
    var font: UIFont!
    
    /// Initialize Picker Title Attributes
    init(color: UIColor, font: UIFont) {
        self.color = color
        self.font = font
    }
}
// MARK: -
/// Define selcted and deselected attrinutes item title
struct MBPickerViewTitleAttribute {
    var selectedAttribues: PickerTitleAttributes!
    var deselectedAttributes: PickerTitleAttributes!
    
    /// Initialize selected and deselected attributes
    /// Which will displayed on pickerView items
    init(selectedAttribues: PickerTitleAttributes, deselectedAttributes: PickerTitleAttributes) {
        self.selectedAttribues = selectedAttribues
        self.deselectedAttributes = deselectedAttributes
    }
    
    /// Setting default title attibutes
    fileprivate static func defaultAttribute() -> MBPickerViewTitleAttribute {
        return MBPickerViewTitleAttribute(
            selectedAttribues: PickerTitleAttributes(color: .black, font: UIFont.boldSystemFont(ofSize: 17)),
            deselectedAttributes: PickerTitleAttributes(color: .lightGray, font: UIFont.systemFont(ofSize: 17)))
    }
}
// MARK: -
/// Delegate for handling various event
@objc protocol MBPickerViewDelegate {
    
    /// This delegate called when item is selected and visible on PickerView
    ///
    /// - Parameters:
    ///   - pickerView: MBPickerView
    ///   - item: Int
    @objc optional func pickerView(_ pickerView: MBPickerView, didSelectItem item: Int)
    
    /// This delegate called when picker is scroll,
    /// this will called only if user scrolls pikcer and not while selecting item
    ///
    /// - Parameters:
    ///   - pickerView: MBPickerView
    ///   - scrollView: UIScrollView
    @objc optional func pickerView(_ pickerView: MBPickerView, didScroll scrollView: UIScrollView)
    
    /// This delegate will called once scroll ends,
    /// this will called only if user scrolls pikcer and not while selecting item
    ///
    /// - Parameters:
    ///   - pickerView: MBPickerView
    ///   - scrollView: UIScrolView
    @objc optional func pickerView(_ pickerView: MBPickerView, didScrollEnd scrollView: UIScrollView)
    
    /// This delegate will called when user touches on Picker
    ///
    /// - Parameters:
    ///   - pickerView: MBPickerView
    ///   - touches: Set<UITouch>
    @objc optional func pickerView(_ pickerView: MBPickerView, didTouchBegan touches: Set<UITouch>)
    
    /// This delegate will called when user removes touches on Picker
    ///
    /// - Parameters:
    ///   - pickerView: MBPickerView
    ///   - touches: Set<UITouch>
    @objc optional func pickerView(_ pickerView: MBPickerView, didTouchEnded touches: Set<UITouch>)
}
// MARK: -
/// This delegate is used to confiure picker data set
@objc protocol MBPickerViewDataSource {
    
    /// Set number of items in Picker View
    ///
    /// - Parameter pickerView: MBPickerView
    /// - Returns: Int
    @objc func pickerViewNumberOfItems(_ pickerView: MBPickerView) -> Int
    
    /// Set view at speficic item
    ///
    /// - Parameters:
    ///   - pickerView: MBPickerView
    ///   - item: Int
    /// - Returns: UIView
    @objc optional func pickerView(_ pickerView: MBPickerView, viewAtItem item: Int) -> UIView
    
    /// Title of item at specific index, will not called if viewAtItem implemented
    /// *** will not called if viewAtItem implemented ***
    ///
    /// - Parameters:
    ///   - pickerView: MBPickerView
    ///   - item: Item index of title
    /// - Returns: String
    @objc optional func pickerView(_ pickerView: MBPickerView, titleAtItem item: Int) -> String
    
    /// Set color for item at specific index
    /// ***  will not called if viewAtItem implemented ***
    ///
    /// - Parameters:
    ///   - pickerView: MBPickerView
    ///   - item: Item index of title background color
    /// - Returns: UIColor
    @objc optional func pickerView(_ pickerView: MBPickerView, titleBackgroundColorAtItem item: Int) -> UIColor
}

// MARK: -

/// This Picker class which give veticle picker view same UIPickerView
class MBPickerView: UIView {
    
    /// Set title padding scale to view left and right tiltle / view
    var itemPadingScale: CGFloat = 0.5 {
        didSet { reloadData() }
    }
    
    /// Get current item index of picker view
    var currentItem: Int? {
        guard let index = lastSelectedIndex else { return nil }
        return index.item
    }
    
    fileprivate var allowSelectionWhileScrolling: Bool = false
    
    /// Show all item in picker view, once set true titlePadding will not work here
    var showAllItem = false {
        didSet { reloadData() }
    }
    
    /// Set title text color for MBPicker View
    var titleAttributes: MBPickerViewTitleAttribute! = MBPickerViewTitleAttribute.defaultAttribute() {
        didSet { reloadData() }
    }
    
    /// Select a specific item in MBPickerView with animation
    ///
    @discardableResult
    func selectItem(_ item: Int, animation: Bool = false) -> Bool {
        if item >= 0 && item < itemCount {
            let newIndex = IndexPath(item: item, section: 0)
            pickerCollectionView.scrollToItem(at: newIndex, at: .centeredHorizontally, animated: animation)
            var reloadIndex = pickerCollectionView.visibleIndexPath
            if let index = lastSelectedIndex {
                reloadIndex = prepareCellsToRealod(currentIndex: index, newIndex: newIndex)
            }
            lastSelectedIndex = newIndex
            pickerCollectionView.reloadItems(at:reloadIndex)
            return true
        }
        return false
    }
    
    /// Set delegate to get call back of various events
    weak var delegate: MBPickerViewDelegate?
    
    /// Set to manupate and configure data set for pikcer view
    weak var dataSource: MBPickerViewDataSource? {
        didSet { reloadData() }
    }
    
    /// Reload data, it will call all the data source
    public func reloadData() {
        pickerCollectionView.reloadData()
        if itemCount > 0, let index = lastSelectedIndex {
            pickerCollectionView.scrollToItem(at: index, at: .centeredHorizontally, animated: false)
        }
    }
    
    /// Calulate cell width and padding
    fileprivate func prepareForReload() {
        if let flowLayout = pickerCollectionView.collectionViewLayout as? PickerFlowLayout {
            if showAllItem {
                let cellWidth =  bounds.width/CGFloat(itemCount)
                flowLayout.itemSize = CGSize(width: cellWidth, height: bounds.height)
                flowLayout.sectionInset = UIEdgeInsets.zero
            } else if itemPadingScale >= 0 {
                let cellWidth =  max(bounds.width/((itemPadingScale*2)+1), bounds.width/CGFloat(itemCount))
                let pading = (bounds.width/2) - (cellWidth/2)
                flowLayout.itemSize = CGSize(width: cellWidth, height: bounds.height)
                flowLayout.sectionInset = UIEdgeInsets(top: 0, left: pading, bottom: 0, right: pading)
            } else {
                flowLayout.itemSize = CGSize(width: bounds.width, height: bounds.height)
                flowLayout.sectionInset = UIEdgeInsets.zero
            }
        }
    }
    
    /// Number of item in picker
    fileprivate var itemCount = 0
    
    /// Maintain last selected index to handle title color
    fileprivate var lastSelectedIndex: IndexPath? {
        didSet {
            if let index = lastSelectedIndex {
                delegate?.pickerView?(self, didSelectItem: index.item)
            }
        }
    }
    
    /// Collection View to view manage items
    fileprivate var pickerCollectionView =  PickerCollectionView(frame: .zero, collectionViewLayout: PickerFlowLayout())
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialSetup()
    }
    
    /// Setup collection view and delegates
    private func initialSetup() {
        pickerCollectionView.pickerView = self
        pickerCollectionView.backgroundColor = UIColor.clear
        pickerCollectionView.showsHorizontalScrollIndicator = false
        pickerCollectionView.register(CollectionCell.self, forCellWithReuseIdentifier: "CollectionCell")
        addSubview(pickerCollectionView)
        pickerCollectionView.dataSource = self
        pickerCollectionView.delegate = self
    }
    
    /// Adjust frame of collection view and reload data
    override func layoutSubviews() {
        super.layoutSubviews()
        pickerCollectionView.frame = bounds
        reloadData()
    }
    
    fileprivate func prepareCellsToRealod(currentIndex: IndexPath, newIndex: IndexPath) -> [IndexPath] {
        var reloadIndexes: [IndexPath] = []
        if !showAllItem {
            reloadIndexes = pickerCollectionView.visibleIndexPath
        } else if currentIndex != newIndex {
            reloadIndexes = [newIndex, currentIndex]
        } else {
            reloadIndexes = [currentIndex]
        }
        return reloadIndexes
    }
    
}

// MARK: -

extension MBPickerView: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    // MARK: UICollectionView degate and Data Source
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        itemCount = 0
        if let count = dataSource?.pickerViewNumberOfItems(self), count > 0 {
            itemCount = count
        }
        if itemCount > 0, lastSelectedIndex == nil {
            lastSelectedIndex = IndexPath(item: 0, section: 0)
        }
        prepareForReload()
        return itemCount
    }
    /// Set cell for UICollection View
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionCell", for: indexPath) as? CollectionCell {
            
            if let view = dataSource?.pickerView?(self, viewAtItem: indexPath.item) {
                view.frame = CGRect(x: 0, y: 0, width: cell.bounds.width, height: cell.bounds.height)
                cell.addSubview(view)
                return cell
            }
            
            // Set up default titles delegat
            cell.setup(titleAttributes, selected: lastSelectedIndex == indexPath)
            cell.labelTitle?.text = dataSource?.pickerView?(self, titleAtItem: indexPath.item)
            if let bgColor = dataSource?.pickerView?(self, titleBackgroundColorAtItem: indexPath.item) {
                cell.backgroundColor = bgColor
            } else {
                cell.backgroundColor = .clear
            }
            return cell
        }
        return UICollectionViewCell()
    }
    
    /// Collection view did select item
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        var reloadIndex = pickerCollectionView.visibleIndexPath
        if let index = lastSelectedIndex {
            reloadIndex = prepareCellsToRealod(currentIndex: index, newIndex: indexPath)
        }
        lastSelectedIndex = indexPath
        collectionView.reloadItems(at:reloadIndex)
    }
}

//MARK: -
extension MBPickerView: UIScrollViewDelegate {
    //MARK: UIScrollViewDelegate
    /// Scroll view delegate to manage select center item
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        didScrollEnd(scrollView)
    }
    /// Scroll view delegate to manage select center item
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate { didScrollEnd(scrollView) }
    }
    /// Scroll view delegate to manage select center item
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        delegate?.pickerView?(self, didScroll: scrollView)
        if allowSelectionWhileScrolling {
            let indexPath = pickerCollectionView.centerIndex()
            if indexPath != lastSelectedIndex {
                lastSelectedIndex = indexPath
                pickerCollectionView.reloadItems(at: pickerCollectionView.visibleIndexPath)
            }
        }
    }
    
    /// Select item which near to center of collection View
    func didScrollEnd(_ scrollView: UIScrollView) {
        delegate?.pickerView?(self, didScrollEnd: scrollView)
        if !allowSelectionWhileScrolling {
            lastSelectedIndex = pickerCollectionView.centerIndex()
        }
        if let index = lastSelectedIndex {
            pickerCollectionView.scrollToItem(at: index, at: .centeredHorizontally, animated: true)
            pickerCollectionView.reloadItems(at: pickerCollectionView.visibleIndexPath)
        }
    }
}

// MARK: -
fileprivate class PickerCollectionView: UICollectionView {
    
    weak var pickerView: MBPickerView?
    
    /// Call delegate method to handle toches
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        pickerView?.delegate?.pickerView?(pickerView!, didTouchBegan: touches)
    }
    /// Call delegate method to handle toches
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        pickerView?.delegate?.pickerView?(pickerView!, didTouchEnded: touches)
    }
    
    /// Get all visible cell indexPath
    var visibleIndexPath: [IndexPath] {
        var indexes: [IndexPath] = []
        for each in visibleCells {
            if let indexPath = indexPath(for: each) { indexes.append(indexPath) }
        }
        return indexes
    }
    
    func centerIndex() -> IndexPath? {
        guard self.numberOfItems(inSection: 0) > 0, let flowLayout = collectionViewLayout as? PickerFlowLayout else { return nil }
        
        var centerPoint = self.contentOffset.x + (bounds.width/2)
        centerPoint = centerPoint - flowLayout.sectionInset.left
        let itemIndex = max(Int(ceil(centerPoint/flowLayout.itemSize.width))-1, 0)
        let indexPath = IndexPath(item: min(itemIndex, self.numberOfItems(inSection: 0)-1), section: 0)
        return indexPath
    }
    
}

// MARK: -
private class PickerFlowLayout: UICollectionViewFlowLayout {
    /// Setup default values for flow layout
    override func prepare() {
        super.prepare()
        scrollDirection = .horizontal
        minimumLineSpacing = 0
        minimumInteritemSpacing = 0
    }
}

// MARK: -
fileprivate class CollectionCell: UICollectionViewCell {
    
    var labelTitle: UILabel? {
        didSet {
            labelTitle?.numberOfLines = 0
            labelTitle?.textAlignment = .center
            labelTitle?.lineBreakMode = .byWordWrapping
            labelTitle?.frame = bounds
        }
    }
    /// Create label and default properties
    func setup(_ attribute: MBPickerViewTitleAttribute, selected: Bool) {
        if labelTitle == nil {
            labelTitle = UILabel()
            addSubview(labelTitle!)
        }
        setAttributes(attribute: selected ? attribute.selectedAttribues : attribute.deselectedAttributes)
    }
    /// Set title attributes to UILable
    ///
    /// - Parameter attribute: PickerTitleAttributes
    func setAttributes(attribute: PickerTitleAttributes) {
        labelTitle?.font = attribute.font
        labelTitle?.textColor = attribute.color
    }
    /// Update label frames
    override func layoutSubviews() {
        super.layoutSubviews()
        labelTitle?.frame = bounds
    }
}
