//
//  ViewController.swift
//  SuperPicker
//
//  Created by Roi Mulia on 10/12/2019.
//  Copyright © 2019 Craftiz. All rights reserved.
//

import UIKit

import GalleryPicker
import CoreUI

protocol MediaPickerViewControllerDelegate: AnyObject {
    func mediaPickerNavigationControllerWantsToOpenAlbums(_ mediaPickerViewController: MediaPickerViewController)
    func mediaPickerNavigationControllerDonePressed(_ mediaPickerViewController: MediaPickerViewController)
}

class MediaPickerViewController: UIViewController {
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private enum PickerConstants {
        static let basketHeight: CGFloat = 140
        static let segmentHeight: CGFloat = 46
    }
    
    override var prefersStatusBarHidden: Bool { return false }
        
    private let pickerViewController: PickerViewController
    private let unsplashPhotoPickerViewController: UIViewController
    private let basketViewController: BasketViewController
    weak var delegate: MediaPickerViewControllerDelegate?

    init(pickerViewController: PickerViewController,
         unsplashPhotoPickerViewController: UIViewController,
         basketViewController: BasketViewController,
         with initialTitle: String) {
        self.pickerViewController = pickerViewController
        self.unsplashPhotoPickerViewController = unsplashPhotoPickerViewController
        self.basketViewController = basketViewController
        super.init(nibName: nil, bundle: nil)
        setAlbumLabel(title: initialTitle)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.decelerationRate = .fast
        view.bounces = false
        view.clipsToBounds = true
        view.isPagingEnabled = true
        view.showsHorizontalScrollIndicator = false
        //view.delaysContentTouches = false
        view.contentInsetAdjustmentBehavior = .never
        view.canCancelContentTouches = false
        view.delegate = self
        view.backgroundColor = .clear
        return view
    }()

    let tabView = MediaPickerTabView()


    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Constants.colorScheme.background
        
        setupScrollViewConstraints()
        setupBasketConstraints()

        navigationItem.hidesBackButton = true
        let closeButton = BounceButton()
        let image = UIImage(systemName: "xmark")
        closeButton.setImage(image, for: .normal)
        closeButton.tintColor = Constants.colorScheme.title
        closeButton.addTarget(self, action: #selector(self.closeTapped), for: .touchUpInside)
        navigationItem.leftBarButtonItem = .init(customView: closeButton)
        
        tabView.delegate = self
    }
    
    func setupScrollViewConstraints() {
        tabView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tabView)
        
        NSLayoutConstraint.activate([
            tabView.heightAnchor.constraint(equalToConstant: PickerConstants.segmentHeight),
            tabView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -32),
            tabView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tabView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])


        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        scrollView.topAnchor.constraint(equalTo: tabView.bottomAnchor, constant: 16).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        
        guard let leftMostView = pickerViewController.view else {
            return
        }
        
        leftMostView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(leftMostView)
        leftMostView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor).isActive = true
        leftMostView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        leftMostView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
        leftMostView.heightAnchor.constraint(equalTo: scrollView.heightAnchor).isActive = true
        
        addChild(pickerViewController)
        pickerViewController.didMove(toParent: self)
        
        addChild(unsplashPhotoPickerViewController)
        guard let rightMostView = unsplashPhotoPickerViewController.view else {
            return
        }
        rightMostView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(rightMostView)
        rightMostView.leadingAnchor.constraint(equalTo: leftMostView.trailingAnchor).isActive = true
        rightMostView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor).isActive = true
        rightMostView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        rightMostView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
        rightMostView.heightAnchor.constraint(equalTo: scrollView.heightAnchor).isActive = true
        unsplashPhotoPickerViewController.didMove(toParent: self)
        
        scrollView.backgroundColor = Constants.colorScheme.background
        

    }
    
    func setupBasketConstraints() {
        
        // MARK: - BasketViewController
        addChild(basketViewController)
        guard let basketViewControllerView = basketViewController.view else {
            return
        }
        basketViewControllerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(basketViewControllerView)
        basketViewControllerView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        basketViewControllerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        basketViewControllerView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        basketViewControllerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -PickerConstants.basketHeight).isActive = true
        basketViewController.didMove(toParent: self)
   }

    func setAlbumLabel(title: String) {
        loadViewIfNeeded()
        tabView.galleryButton.setTitle(title, for: .normal)
    }
 
    
    @objc func closeTapped() {
        Haptic.selection.generate()
        delegate?.mediaPickerNavigationControllerDonePressed(self)
    }
   
    func albumsDismissed() {
        tabView.galleryButton.isAlbumPresented = false
    }
}




extension MediaPickerViewController: MediaPickerTabViewDelegate {
   
    func mediaPickerTabView(_ view: MediaPickerTabView, isSelectingType type: MediaPickerTabView.MediaPickerTabButtonType) {
        view.galleryButton.isAlbumPresented = true
        delegate?.mediaPickerNavigationControllerWantsToOpenAlbums(self)
    }
    
    func mediaPickerTabView(_ view: MediaPickerTabView, isFocusingOnType type: MediaPickerTabView.MediaPickerTabButtonType) {
        scrollView.setContentOffset(.init(x: scrollView.bounds.width * CGFloat(type.rawValue), y: scrollView.contentOffset.y), animated: true)
    }
    
}

extension MediaPickerViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        unsplashPhotoPickerViewController.view.endEditing(true)
        let precentage = (scrollView.contentOffset.x) /  (scrollView.contentSize.width - scrollView.bounds.width)
        let clampedPrecentage = min(max(precentage, 0), 1)
        tabView.progress = clampedPrecentage
        tabView.setNeedsLayout()
        tabView.layoutIfNeeded()
    }
    
}
