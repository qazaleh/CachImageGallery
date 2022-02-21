
import UIKit

class GridViewCell: UICollectionViewCell {
    
    lazy private var imageView : UIImageView = {
        let imgView = UIImageView()
        imgView.backgroundColor = .systemGray
        imgView.contentMode = .scaleAspectFill
        imgView.clipsToBounds = true
        imgView.layer.cornerRadius = 5
        imgView.translatesAutoresizingMaskIntoConstraints = false
        return imgView
    }()
    
    lazy private var loading : UIActivityIndicatorView = {
        let acInd = UIActivityIndicatorView()
        acInd.color = .white
        acInd.hidesWhenStopped = true
        acInd.translatesAutoresizingMaskIntoConstraints = false
        
        return acInd
    }()
    private var session : URLSessionDataTask?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        session?.cancel()
    }
}

extension GridViewCell {
    
    func setupUI(){
        addSubview(imageView)
        imageView.addSubview(loading)
        
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            loading.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
            loading.centerYAnchor.constraint(equalTo: imageView.centerYAnchor)
        ])
    }
    
    func setLoading(start:Bool) {
        if start {
            loading.startAnimating()
        }else {
            loading.stopAnimating()
        }
    }
    
    
    func downloadImage(_ galleryItem : GalleryItem?){
        if let item = galleryItem {
            if let thumbnailURL = item.thumbnail_url, let downloadURL = URL(string: thumbnailURL) {
                setLoading(start: true)
                self.imageView.image = nil
                self.session = ImageDownloader.downloadImage(downloadURL,true) {[weak self] img, status in
                    DispatchQueue.main.async {
                        if status{
                            self?.setLoading(start: false)
                            self?.imageView.image = img
                        }else {
                            self?.setLoading(start: false)
                        }
                    }
                }
            }
        }
    }
    
}
