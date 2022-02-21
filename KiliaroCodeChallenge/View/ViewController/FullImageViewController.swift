
import UIKit

class FullImageViewController: UIViewController {
    
    private var galleryItem : GalleryItem?
    
    private var imageView : UIImageView!
    private let loading : UIActivityIndicatorView = {
        let acInd = UIActivityIndicatorView()
        acInd.color = .white
        acInd.hidesWhenStopped = true
        acInd.translatesAutoresizingMaskIntoConstraints = false
        
        return acInd
    }()
    private let dateLabel : UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var session : URLSessionDataTask?
    
    override func loadView() {
        super.loadView()
        setupUI()
        loadPageData()
        setupGesture()
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        //cancel current image download request when view did disappear
        if let s = session {
            s.cancel()
        }
        
    }
    init(item:GalleryItem?) {
        //inject gallery item to the controller
        self.galleryItem = item!
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.galleryItem = nil
    }
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        // dissmiss controller using tap on the image
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension FullImageViewController {
    //setup ui elements
    func setupUI(){
        
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        view.backgroundColor = .black
        
        let labelBackground = UIView()
        labelBackground.backgroundColor = .purple
        labelBackground.alpha = 0.7
        labelBackground.layer.cornerRadius = 6
        labelBackground.translatesAutoresizingMaskIntoConstraints = false
        
        imageView = UIImageView(frame: view.frame)
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.backgroundColor = .black
        imageView.layer.cornerRadius = 15
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = UIColor.white.cgColor
        view.backgroundColor = .black
        view.addSubview(imageView)
        imageView.addSubview(labelBackground)
        imageView.addSubview(loading)
        labelBackground.addSubview(dateLabel)
        
        NSLayoutConstraint.activate([
            labelBackground.topAnchor.constraint(equalTo: imageView.topAnchor,constant: 20),
            labelBackground.leftAnchor.constraint(equalTo: imageView.leftAnchor,constant: 20),
            labelBackground.rightAnchor.constraint(equalTo: imageView.rightAnchor,constant: -20),
            labelBackground.heightAnchor.constraint(equalToConstant: 50),
            dateLabel.leadingAnchor.constraint(equalTo: labelBackground.leadingAnchor,constant: 2),
            dateLabel.trailingAnchor.constraint(equalTo: labelBackground.trailingAnchor,constant: -2),
            dateLabel.centerYAnchor.constraint(equalTo: labelBackground.centerYAnchor),
            loading.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
            loading.centerYAnchor.constraint(equalTo: imageView.centerYAnchor),
            
        ])
        
        
    }
    //setup tap gesture for image view to dissmiss the controller
    func setupGesture(){
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tapGesture)
    }
    //load image from download_url
    func loadPageData(){
        loading.startAnimating()
        guard let item = galleryItem else {
            return
        }
        if let date = item.created_at {
            dateLabel.text = "created at: " + date
        }
        if let urlString = item.download_url, let downloadURL = URL(string: urlString) {
            self.imageView.image = nil
            self.session = ImageDownloader.downloadImage(downloadURL,false) {[weak self] img, status in
                DispatchQueue.main.async {
                    if status{
                        self?.loading.stopAnimating()
                        self?.imageView.image = img
                    }else {
                        //we can handle placeholder image or relaod button to redownload
                    }
                }
            }
        }
    }
}
