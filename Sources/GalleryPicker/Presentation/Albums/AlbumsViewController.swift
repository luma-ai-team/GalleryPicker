//
//  Copyright © 2020 Craftiz. All rights reserved.
//

import UIKit
import CoreUI

protocol AlbumsViewInput: AnyObject {
    func update(with viewModel: AlbumsViewModel, force: Bool, animated: Bool)
}

protocol AlbumsViewOutput: AnyObject {
    func viewDidLoad()
    func viewWillDisappear()
    func didSelect(album: Album)
}

public final class AlbumsViewController: UIViewController {
    
    public override var prefersStatusBarHidden: Bool { return true }
    
    private var viewModel: AlbumsViewModel
    private let output: AlbumsViewOutput

    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.delegate = self
        tableView.dataSource = self
        tableView.showsVerticalScrollIndicator = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 1))
        return tableView
    }()
    
    // MARK: - Lifecycle
    
    init(viewModel: AlbumsViewModel, output: AlbumsViewOutput) {
        self.viewModel = viewModel
        self.output = output
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        tableView.register(DrawerTableVieWCell.self, forCellReuseIdentifier: DrawerTableVieWCell.identifier)
        tableView.sectionHeaderHeight = 10
        
        let nib = UINib(nibName: AlbumsTableViewCell.identifier, bundle: Bundle.module)
        tableView.register(nib, forCellReuseIdentifier: AlbumsTableViewCell.identifier)
        
        output.viewDidLoad()
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        output.viewWillDisappear()
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    public override func viewWillAppear(_ animated: Bool) {
         super.viewWillAppear(animated)
         tableView.reloadData()
     }
}

extension AlbumsViewController: UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - UITableViewDelegate && UITableViewDataSource implementation
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        return viewModel.albums.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
     
        guard indexPath.section == 1 else {
            let cell = tableView.dequeueReusableCell(withIdentifier: DrawerTableVieWCell.identifier, for: indexPath) as? DrawerTableVieWCell
            cell?.drawerView.backgroundColor = viewModel.colorScheme.title
            cell?.selectionStyle = .none
            cell?.layoutIfNeeded()
            return cell ?? .init()
        }
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: AlbumsTableViewCell.identifier, for: indexPath) as? AlbumsTableViewCell else {
            return .init()
        }
        
        let album = viewModel.albums[indexPath.row]
        cell.configure(with: album, colorScheme: viewModel.colorScheme)
        cell.selectionStyle = .none
        
        GalleryAssetService.shared.fetchThumbnail(for: album,
                                                  size: .init(width: 100, height: 100),
                                                  filter: viewModel.filter.ignoringAuxiliaryPredicate()) { [weak self] (_: UIImage?) in
            guard let self = self else { return }
            guard cell.album?.identifier == album.identifier else {
                return
            }

            cell.configure(with: album, colorScheme: viewModel.colorScheme)
        }

        return cell
    }
    

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        Haptic.selection.generate()
        let album = viewModel.albums[indexPath.row]
        output.didSelect(album: album)
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 27
        }
        return 100
    }
}

// MARK: - AlbumsViewInput

extension AlbumsViewController: AlbumsViewInput, ForceViewUpdate {
    
    func update(with viewModel: AlbumsViewModel, force: Bool, animated: Bool) {
        self.viewModel = viewModel

        view.backgroundColor = viewModel.colorScheme.foreground
        tableView.reloadData()
    }
}
