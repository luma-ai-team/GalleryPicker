//
//  BasketViewController.swift
//  SuperPicker
//
//  Created by Roi Mulia on 12/12/2019.
//  Copyright © 2019 Craftiz. All rights reserved.
//

import UIKit

import GalleryPicker
import CoreUI

protocol BasketViewInput: AnyObject {
    func maxSelectionAnimation()
    func update(with viewModel: BasketViewModel, force: Bool, animated: Bool)
}

protocol BasketViewOutput: AnyObject {
    func viewDidLoad()
    func wantsToDeleteSlot(slot: Slot)
    func wantsToSelectSlot(slot: Slot)
    func doneTapped()
    
}

class BasketViewController: UIViewController {
    
    private var viewModel: BasketViewModel
    private let output: BasketViewOutput
    
    @IBOutlet weak var counterLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var doneButton: ExtendedHitTestButton!
    
    var slots: [Slot] {
        return viewModel.slots
    }

    init(viewModel: BasketViewModel, output: BasketViewOutput) {
        self.viewModel = viewModel
        self.output = output
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: "BasketCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "BasketCollectionViewCell")
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 54, height: 76) // Adjust as needed
        layout.sectionInset = .init(top: 0, left: 16, bottom: 0, right: 16)
        layout.minimumLineSpacing = 10 // Adjust as needed
        layout.scrollDirection = .horizontal
        
        collectionView.setCollectionViewLayout(layout, animated: false)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear
        
        counterLabel.textColor = Constants.colorScheme.subtitle
        
        view.backgroundColor = Constants.colorScheme.foreground
        view.clipsToBounds = true
        view.roundCorners(to: .custom(10))
        view.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]

        output.viewDidLoad()
        
    }
    
    @IBAction func doneTapped(_ sender: Any) {
        output.doneTapped()
    }
    
}


extension BasketViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return slots.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BasketCollectionViewCell", for: indexPath) as! BasketCollectionViewCell
        
        let slot = slots[indexPath.item]
        cell.slot = slot
        cell.delegate = self
        cell.timeLabel.text = "\(slot.time.rounded())s"
        cell.timeLabel.font = UIFont.monospacedSystemFont(ofSize: 12, weight: .medium)
        cell.backgroundColor = .clear
        cell.imageView.backgroundColor = Constants.colorScheme.background
        cell.selectionView.alpha = 0
        cell.imageView.layer.borderColor = Constants.colorScheme.title.cgColor
        cell.imageView.layer.borderWidth = viewModel.selectedSlot === slot ? 2 : 0
        
        guard let mediaItem = slot.mediaItem else {
            cell.imageView.image = nil
            cell.deleteButton.alpha = 0
            return cell
        }
        
        cell.deleteButton.alpha = 1
        cell.imageView.image = mediaItem.thumbnail
        cell.selectionView.alpha = 1
        cell.imageView.layer.borderWidth = 0
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let slot = slots[indexPath.item]
        guard slot.mediaItem == nil else {
            return
        }
        
        Haptic.selection.generate()
        output.wantsToSelectSlot(slot: slot)
    }
    
}


extension BasketViewController: BasketCollectionViewCellDelegate {
    func basketCollectionViewCell(_ basketCollectionViewCell: BasketCollectionViewCell, wantsDeleteWithSlot slot: Slot) {
        output.wantsToDeleteSlot(slot: slot)
    }
    
    
}

extension BasketViewController: BasketViewInput, ForceViewUpdate {
    func maxSelectionAnimation() {
        Haptic.notification(.error).generate()
        //collectionView.shake()
    }
    
    func update(with viewModel: BasketViewModel, force: Bool, animated: Bool) {
        loadViewIfNeeded()
        
        let oldViewModel = self.viewModel
        self.viewModel = viewModel
        
        collectionView.reloadData()
        
        if let selectedIndex = viewModel.slots.firstIndex(where: { $0 === viewModel.selectedSlot}) {
            collectionView.scrollToItem(at: .SubSequence(item: selectedIndex, section: 0), at: .centeredHorizontally, animated: true)
        }
        
        let selectedSlotsCount = viewModel.slots.filter { $0.mediaItem != nil}.count
        
        doneButton.isEnabled = selectedSlotsCount > 0
        counterLabel.text = "\(selectedSlotsCount)/\(viewModel.slots.count) clips selected"
    }
    
}

