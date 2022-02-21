//
//  GridViewController.swift
//  KiliaroCodeChallenge
//
//  Created by qazal on 2/20/22.
//

import UIKit

class GridViewController: UIViewController {

    private let loading : UIActivityIndicatorView = {
        let acInd = UIActivityIndicatorView()
        acInd.color = .white
        acInd.hidesWhenStopped = true
        acInd.translatesAutoresizingMaskIntoConstraints = false
        
        return acInd
    }()
    private let errorLabel : UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = .white
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 15)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private var collectionView : UICollectionView?
    private let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
    
    private var imageList : [GalleryItem] = []
    private let cacheManager = CacheManager()
    
    
    override func loadView() {
        super.loadView()
        view.backgroundColor = .black
        setupNavigarionController()
        setupGridView()
        setupLoading()
        setupRefreshButton()
        setupErrorLabel()
        
        //check for old saved response in user default and retrieve the old list
        if let cachedGallery = UserDefaults.standard.data(forKey: AppConstant.dataChacheFileName){
            let galleryList = try! JSONDecoder().decode([GalleryItem].self, from: cachedGallery)
            self.imageList = galleryList
            self.collectionView?.isHidden = false
            self.errorLabel.isHidden = true
            self.collectionView?.reloadData()
        }else {
            //otherwise fetch data from the server
            loading.startAnimating()
            fetchData()
        }
        
    }
    //invalidate old response and all image cache
    @objc func refreshList(){
        UserDefaults.standard.setValue(nil, forKey: AppConstant.dataChacheFileName)
        collectionView?.isHidden = true
        setLoading(start: true)
        cacheManager.cleanUp(list: imageList)
        imageList = []
        collectionView?.reloadData()
        fetchData()
    }
    
    
}

extension GridViewController {
    //setup collection view and collection layout
    func setupGridView(){
        
        layout.sectionInset = UIEdgeInsets(top: 20, left: 10, bottom: 10, right: 10)
        collectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        collectionView?.register(GridViewCell.self, forCellWithReuseIdentifier:GridViewCell.cellId)
        self.view.addSubview(collectionView ?? UICollectionView())
        
        collectionView?.delegate = self
        collectionView?.dataSource = self
        collectionView?.isHidden = true
        
    }
    //setup activity indicator
    func setupLoading(){
        
        view.addSubview(loading)
        
        NSLayoutConstraint.activate([
            loading.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loading.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    //setup error label
    func setupErrorLabel(){
        view.addSubview(errorLabel)
        errorLabel.isHidden = true
        NSLayoutConstraint.activate([
            errorLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            errorLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            errorLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            errorLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
        ])
    }
    //setup refresh button on navigation bar
    func setupRefreshButton(){
        
        let refreshButton = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refreshList))
        refreshButton.tintColor = .white
        self.navigationItem.rightBarButtonItem = refreshButton
        
    }
    // start/stop activity indicator depend on start input
    func setLoading(start : Bool) {
        if start{
            self.loading.startAnimating()
            collectionView?.isHidden = true
            errorLabel.isHidden = true
        }else{
            self.loading.stopAnimating()
            collectionView?.isHidden = false
        }
    }
    //show error label when error is detected
    func showErrorLabel(errorMessage:String){
        errorLabel.isHidden = false
        collectionView?.isHidden = true
        setLoading(start: false)
        errorLabel.text = errorMessage
    }
    //setup navigation controller
    func setupNavigarionController() {
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.toolbar.setShadowImage(UIImage(), forToolbarPosition: .any)
        self.navigationController?.navigationBar.barTintColor = UIColor.black
        let navigationTitle = UILabel()
        navigationTitle.text = "Test Album"
        navigationTitle.textColor = .white
        navigationTitle.font = UIFont.boldSystemFont(ofSize: navigationTitle.font.pointSize)
        navigationTitle.sizeToFit()
        let leftItem = UIBarButtonItem(customView: navigationTitle)
        self.navigationItem.leftBarButtonItem = leftItem
    }
    //save api response to user default
    func cacheAllData(){
        let galleryData = try! JSONEncoder().encode(imageList)
        UserDefaults.standard.setValue(galleryData, forKey: AppConstant.dataChacheFileName)
    }
    // fetch list from api
    func fetchData(){
        collectionView?.isHidden = true
        setLoading(start: true)
        if let url = URL(string: AppConstant.apiUrl){
            NetworkManager.getGallery(url: url){[weak self] (result : Result<[GalleryItem]>) in
                switch(result) {
                case .failure(_):
                    DispatchQueue.main.async {
                        self?.showErrorLabel(errorMessage: AppConstant.networkErrorMessage)
                        return
                    }
                case .success(let imgList):
                    DispatchQueue.main.async {
                        self?.imageList = imgList
                        self?.collectionView?.reloadData()
                        self?.collectionView?.isHidden = false
                        self?.setLoading(start: false)
                        self?.cacheAllData()
                    }
                    
                }
            }
        }
    }
    
    
}


extension GridViewController : UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier:GridViewCell.cellId, for: indexPath) as! GridViewCell
        cell.downloadImage(imageList[indexPath.row])
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = imageList[indexPath.row]
        let detailView = FullImageViewController(item: item)
        self.present(detailView, animated: true, completion: nil)
    }
}

extension GridViewController : UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageList.count
    }
}

extension GridViewController : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        //        set three column (same width and height)
        //        api did not had additional parameter in the thumbnail_url to autoresize the item's height
        return CGSize(width: (UIScreen.main.bounds.size.width / 3) - 15, height: (UIScreen.main.bounds.size.width / 3) - 15)
    }
    
}

