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

    /// Initialize Picker TitleAttributes
    ///
    /// - Parameters:
    ///   - color: UIColor
    ///   - font: UIFont
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
    ///
    /// - Parameters:
    ///   - selectedAttribues: PickerTitleAttributes
    ///   - deselectedAttributes: PickerTitleAttributes
    init(selectedAttribues: PickerTitleAttributes, deselectedAttributes: PickerTitleAttributes) {
        self.selectedAttribues = selectedAttribues
        self.deselectedAttributes = deselectedAttributes
    }

    /// Setting default title attibutes
    ///
    /// - Returns: MBPickerViewTitleAttribute
    fileprivate static func defaultAttribute() -> MBPickerViewTitleAttribute {
        return MBPickerViewTitleAttribute(
            selectedAttribues: PickerTitleAttributes(color: .black, font: UIFont.boldSystemFont(ofSize: 17)),
            deselectedAttributes: PickerTitleAttributes(color: .lightGray, font: UIFont.systemFont(ofSize: 17)))
    }
}

// MARK: -
/// Delegate for handling various event
@objc protocol MBPickerViewDelegate {

    /// This delegate let you know which item is going to display
    ///
    /// - Parameters:
    ///   - pickerView: MBPickerView
    ///   - item: Int
    @objc optional func pickerView(_ pickerView: MBPickerView, willSelectItem item: Int)

    /// This delegate called when item is selected and visible on PickerView
    ///
    /// - Parameters:
    ///   - pickerView: MBPickerView
    ///   - item: Int
    @objc optional func pickerView(_ pickerView: MBPickerView, didSelectItem item: Int)

    /// This delegate called when picker is scroll, this will called only if user scrolls pikcer and not while selecting item
    ///
    /// - Parameters:
    ///   - pickerView: MBPickerView
    ///   - scrollView: UIScrollView
    @objc optional func pickerView(_ pickerView: MBPickerView, didScroll scrollView: UIScrollView)

    /// This delegate will called once scroll ends, this will called only if user scrolls pikcer and not while selecting item
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
    var titlePaddingScale: CGFloat = 0.8 {
        didSet { reloadData() }
    }

    /// Show all item in picker view, once set true titlePadding will not work here
    var showAllItem = false {
        didSet { reloadData() }
    }

    /// Set title text color for MBPicker View
    var titleAttributes: MBPickerViewTitleAttribute! = MBPickerViewTitleAttribute.defaultAttribute() {
        didSet { reloadData() }
    }

    /// Select a specific item in MBPickerView
    ///
    /// - Parameter item: Int, must less than total item count
    /// - Returns: Bool, either item is selcted or not
    @discardableResult
    func selectItem(_ item: Int) -> Bool {
        if item < itemCount {
            let path = IndexPath(item: item, section: 0)
            collectionView(pickerCollectionView, didSelectItemAt: path)
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
    public func  reloadData() {
        pickerCollectionView.reloadData()
        if pickerCollectionView.numberOfItems(inSection: 0) > 0 {
            collectionView(pickerCollectionView, didSelectItemAt: lastSelectedIndex)
        }
    }

    /// Set title padding to view other item from Picker View
    fileprivate var titlePadding: CGFloat {
        if showAllItem { return 0 }
        return pickerCollectionView.bounds.width*titlePaddingScale/3
    }

    /// Number of item in picker
    fileprivate var itemCount = 0

    /// Maintain last selected index to handle title color
    fileprivate var lastSelectedIndex: IndexPath = IndexPath(item: 0, section: 0)

    /// Calculate item width along with scale padding
    fileprivate var cellWidth: CGFloat {
        if showAllItem {
            return pickerCollectionView.bounds.width/CGFloat(itemCount)
        }
        return max(pickerCollectionView.bounds.width - (titlePadding*2), 0)
    }

    /// Collection View to view manage items
    fileprivate var pickerCollectionView =  PickerCollectionView(frame: .zero, collectionViewLayout: PickerFlowLayout())

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialSetup()
    }

    /// Setup collection view and delegates
    func initialSetup() {
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
        pickerCollectionView.reloadData()
    }
}

// MARK: -

extension MBPickerView: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {

    // MARK: UICollectionView degate and Data Source
  // MARK: -

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        itemCount = dataSource?.pickerViewNumberOfItems(self) ?? 0
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
            cell.labelTitle?.text = dataSource?.pickerView?(self, titleAtItem: indexPath.item) ?? ""
            cell.backgroundColor = dataSource?.pickerView?(self, titleBackgroundColorAtItem: indexPath.item) ?? .clear
            return cell
        }
        return UICollectionViewCell()
    }

    /// Calulate size for item for UICollection view
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: cellWidth, height: collectionView.bounds.height)
    }

    /// Collection view did select item
    /// Call Picker view delegates
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.pickerView?(self, willSelectItem: indexPath.item)
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        var reloadIndexes: [IndexPath] = []
        if !showAllItem {
            reloadIndexes = collectionView.visibleIndexPath
        } else if indexPath != lastSelectedIndex {
              reloadIndexes = [lastSelectedIndex, indexPath]
        } else {
            reloadIndexes = [indexPath]
        }
        lastSelectedIndex = indexPath
        pickerCollectionView.reloadItems(at:reloadIndexes)
        delegate?.pickerView?(self, didSelectItem: indexPath.item)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: titlePadding, bottom: 0, right: titlePadding)
    }

    /// Scroll view delegate to manage select center item
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        didScrollEnd(scrollView)
    }

    /// Scroll view delegate to manage select center item
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            didScrollEnd(scrollView)
        }
    }

    /// Scroll view delegate to manage select center item
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        delegate?.pickerView?(self, didScroll: scrollView)
    }

    /// Select item which near to center of collection View
    func didScrollEnd(_ scrollView: UIScrollView) {
        delegate?.pickerView?(self, didScrollEnd: scrollView)
        var centerPoint = scrollView.contentOffset.x + (scrollView.bounds.width/2)
        centerPoint = centerPoint - titlePadding
        let indexPath = IndexPath(item: Int(ceil(centerPoint/cellWidth))-1, section: 0)
        collectionView(pickerCollectionView, didSelectItemAt: indexPath)
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
}
// MARK: -
fileprivate extension UICollectionView {

    /// Get all visible cell indexPath
    var visibleIndexPath: [IndexPath] {
        var indexes: [IndexPath] = []
        for each in visibleCells {
            if let indexPath = indexPath(for: each) {
                indexes.append(indexPath)
            }
        }
        return indexes
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
