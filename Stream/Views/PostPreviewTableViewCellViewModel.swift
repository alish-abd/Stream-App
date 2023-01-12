//
//  PostPreviewTableViewCell.swift
//  Thoughts
//
//  Created by Alisher Abdulin on 06.01.2023.
//

import UIKit

class PostPreviewTableViewCellViewModel {
    let title: String
    let bodyText: String
    let imageUrl: URL?
    var imageData: Data?
    
    init(title: String, bodyText: String, imageUrl: URL?) {
        self.title = title
        self.bodyText = bodyText
        self.imageUrl = imageUrl
    }
}

class PostPreviewTableViewCell: UITableViewCell {
    
    static let identifier = "PostPreviewTableViewCell"
    
    
    private let postImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.masksToBounds = true
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.contentMode = .scaleAspectFill
        return imageView
        
    }()
    
    private let postTitleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 23, weight: .semibold)
        return label
    }()
    
    private let postBodyLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        
        label.font = .systemFont(ofSize: 15, weight: .regular)
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear // very important
        layer.cornerRadius = 10
        layer.masksToBounds = false
       
        
//        layer.shadowRadius = 4
//        layer.shadowOffset = CGSize(width: 0, height: 0)
//        layer.shadowColor = UIColor.black.cgColor
//        layer.borderColor = UIColor.gray.cgColor
//        layer.borderWidth = 1
        
        contentView.clipsToBounds = true
        contentView.addSubview(postImageView)
        contentView.addSubview(postTitleLabel)
        contentView.addSubview(postBodyLabel)
//        contentView.backgroundColor = .systemGray
        contentView.layer.cornerRadius = 10
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
        contentView.backgroundColor = UIColor(named: "blog-color")
        contentView.layer.borderColor = UIColor.blue.cgColor
        
        postImageView.frame = CGRect(
            x: 5,
            y: 5,
            width: contentView.width-10,
            height: 150
        )
        postTitleLabel.frame = CGRect(
            x: 10,
            y: postImageView.bottom+20, width: contentView.width,
            height: 25
        )
        postBodyLabel.frame = CGRect(
            x: 10,
            y: postTitleLabel.bottom+5, width: contentView.width-20,
            height: 30)
    }

   
    override func prepareForReuse() {
        super.prepareForReuse()
        postTitleLabel.text = nil
        postBodyLabel.text = nil
        postImageView.image = nil
    }
    
    func configure(with viewModel: PostPreviewTableViewCellViewModel) {
        postTitleLabel.text = viewModel.title
        postBodyLabel.text = viewModel.bodyText
        
        
        
        if let data = viewModel.imageData {
            postImageView.image = UIImage(data: data)
        }
        
        else if let url = viewModel.imageUrl {
            //Fetch image and cache
            let task = URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
                guard let data = data else {
                    return
                }
                
                viewModel.imageData = data
                DispatchQueue.main.async {
                    self?.postImageView.image = UIImage(data: data)
                }
            }
            task.resume()
        }
    }
}
    
