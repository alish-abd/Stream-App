//
//  CreateNewPostViewController.swift
//  Stream
//
//  Created by Alisher Abdulin on 11.01.2023.
//

import UIKit

import UIKit

class CreateNewPostViewController: UIViewController {
    
    //Title field
    private let titleField: UITextField = {
        let field = UITextField()
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 50))
        field.leftViewMode = .always
        field.autocapitalizationType = .words
        field.autocorrectionType = .yes
        field.placeholder = "Enter title..."
        field.backgroundColor = .secondarySystemBackground
        field.layer.cornerRadius = 10
        field.layer.masksToBounds = true
        return field
    }()
    
    //Image header
    private var headerImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.isUserInteractionEnabled = true
        imageView.image = UIImage(named: "add-image")
        imageView.tintColor = .systemGray
        imageView.clipsToBounds = true
        imageView.backgroundColor = .tertiarySystemBackground
        imageView.layer.cornerRadius = 10
        return imageView
        
    }()
    
    //Textview for post
    private let textView: UITextView = {
        let textView = UITextView()
        textView.isEditable = true
        textView.font = .systemFont(ofSize: 28)
        textView.backgroundColor = .secondarySystemBackground
        textView.layer.cornerRadius = 10
        return textView
    }()
    
    private var selectedHeaderImage: UIImage?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(headerImageView)
        view.addSubview(titleField)
        view.addSubview(textView)
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapHeader))
        headerImageView.addGestureRecognizer(tap)
        configureButtons()
        
        
        
    }
    
    @objc private func didTapHeader() {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        present(picker, animated: true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        titleField.frame = CGRect(x: 10, y: view.safeAreaInsets.top, width: view.width-20, height: 50)
        headerImageView.frame = CGRect(x: 10, y: titleField.bottom + 10, width: view.width - 20, height: 160)
        textView.frame = CGRect(x: 10, y: headerImageView.bottom + 10, width: view.width - 20, height: view.height - 210 - view.safeAreaInsets.top)
    }
    
    private func configureButtons() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Cancel",
            style: .done,
            target: self,
            action: #selector(didTapCancel))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Post",
            style: .done,
            target: self,
            action: #selector(didTapPost))
    }
    
    
    
    @objc private func didTapCancel() {
        dismiss(animated: true)
    }
    
    @objc private func didTapPost () {
        //Check data and make post
        guard let title = titleField.text,
              let body = textView.text,
              let email = UserDefaults.standard.string(forKey: "email"),
              let headerImage = selectedHeaderImage,
              !title.trimmingCharacters(in: .whitespaces).isEmpty,
              !body.trimmingCharacters(in: .whitespaces).isEmpty else {
            
            let alert = UIAlertController(
                title: "Enter post detail",
                message: "Please enter a title, body and select an image to continue",
                preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel))
            present(alert, animated: true)
            return
        }
        
        let newPostId = UUID().uuidString
        
        //upload header image
        StorageManager.shared.uploadBlogHeaderImage(
            email: email,
            image: headerImage,
            postId: newPostId
        ) { success in
            guard success else {
                return
            }
            StorageManager.shared.downloadUrlForPostHeader(email: email, postId: newPostId) { url in
                guard let headerUrl = url else {
                    print("Failed to upload url for header")
                    return
                }
                
                //insertion of post into database
                let post = StreamPost(
                    identifier: newPostId,
                    title: title,
                    timestamp: Date().timeIntervalSince1970,
                    headerImageUrl: headerUrl,
                    text: body)
                
                
                DatabaseManager.shared.insert(blogPost: post, email: email) { [weak self] posted in
                    guard posted else {
                        
                        print("Failed to post new blog article")
                        return
                    }
                    
                    DispatchQueue.main.async {
                        self?.didTapCancel()
                    }
                }
            }
            
            
        }
    }
    
}

extension CreateNewPostViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        guard let image = info[.originalImage] as? UIImage else {
            return
        }
        selectedHeaderImage = image
        headerImageView.image = image
    }
}
