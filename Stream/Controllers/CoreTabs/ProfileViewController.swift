//
//  ProfileViewController.swift
//  Stream
//
//  Created by Alisher Abdulin on 08.01.2023.
//

import UIKit

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(PostPreviewTableViewCell.self, forCellReuseIdentifier: PostPreviewTableViewCell.identifier)
        return tableView
    }()
    
    private var user: User?
    
    let currentEmail: String
    
    init(currentEmail: String) {
        self.currentEmail = currentEmail
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    private let userName: UILabel = {
        let label = UILabel()
        label.text = UserDefaults.standard.string(forKey: "email")
        label.font = UIFont.systemFont(ofSize: 30, weight: .medium)
        label.textAlignment = .center
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        //        view.addSubview(profileImage)
        view.addSubview(userName)
        setUpSignOutButton()
        setUpTable()
        fetchPosts()
        // Do any additional setup after loading the view.
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
        
    }
    
    
    private func setUpTable() {
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        setUpTableHeader()
        fetchProfileData()
    }
    
    
    
    func setUpTableHeader(profilePhotoRef: String? = nil, name: String? = nil) {
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.width, height: view.width/1.5))
        
        headerView.backgroundColor = .systemBackground
        
        headerView.isUserInteractionEnabled = true
        headerView.clipsToBounds = true
        
        tableView.tableHeaderView = headerView
        
        //profile picture
        let profileImage = UIImageView(image: UIImage(systemName: "person.crop.circle.fill"))
        
        profileImage.layer.cornerRadius = 75
        profileImage.tintColor = .systemGray
        profileImage.layer.masksToBounds = true
        profileImage.contentMode = .scaleAspectFit
        
        profileImage.frame = CGRect(x: view.width-(view.width/2)-75, y: 10, width: 150, height: 150)
  
        profileImage.isUserInteractionEnabled = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapProfileImage))
        profileImage.addGestureRecognizer(tap)
        
        //email or name label
        let label = UILabel(frame: CGRect(x: 0, y: profileImage.bottom + 10, width: view.width, height: 50))
        headerView.addSubview(label)
        label.text = name
        label.font = UIFont.systemFont(ofSize: 35, weight: .semibold)
        label.textAlignment = .center
        
        
        
        headerView.addSubview(profileImage)
        
        
        
        
        
        
//        if let name = name {
//            title = name
//        }
        
        if let ref = profilePhotoRef {
            // fetch image
            StorageManager.shared.downloadUrlForProfilePicture(path: ref) { url in
                guard let url = url else {
                    return
                }
                let task = URLSession.shared.dataTask(with: url) { data, _, _ in
                    guard let data = data else {
                        return
                    }
                    DispatchQueue.main.async {
                        profileImage.image = UIImage(data: data)
                    }
                }
                
                task.resume()
            }
            
        }
        
        
    }
    
    
    @objc private func didTapProfileImage() {
        guard let myEmail = UserDefaults.standard.string(forKey: "email"),
        myEmail == currentEmail else {
            return
        }
       
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true)
    }

    private func fetchProfileData() {
        DatabaseManager.shared.getUser(email: currentEmail) { [weak self] user in
            guard let user = user else {
                return
            }
            self?.user = user
            DispatchQueue.main.async {
                self?.setUpTableHeader(
                    profilePhotoRef: user.profilePictureRef,
                    name: user.name)
            }
        }
    }
    
    private func setUpSignOutButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Sign out",
            style: .done,
            target: self,
            action: #selector(didTapSignOut))
        
    }
    
    ///Sign out function
    @objc private func didTapSignOut() {
        let sheet = UIAlertController(title: "Sign out", message: "Are you sure you want to sign out", preferredStyle: .actionSheet)
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        sheet.addAction(UIAlertAction(title: "Sign out", style: .destructive, handler: { UIAlertAction in
            AuthManager.shared.signOut { success in
                if success {
                    
                    DispatchQueue.main.async {
                        UserDefaults.standard.set(nil, forKey: "email")
                        UserDefaults.standard.set(nil, forKey: "name")
                        
                        UserDefaults.standard.set(false, forKey: "premium")
                        
                        let signInVC = SignInViewController()
//                        signInVC.navigationItem.largeTitleDisplayMode = .always
                         
                        let navVC = UINavigationController(rootViewController: signInVC)
//                        navVC.navigationBar.prefersLargeTitles = true
                        navVC.modalPresentationStyle = .fullScreen
                        self.present(navVC, animated: true, completion: nil)
                        
                    }
                }
            }
        }))
        present(sheet, animated: true)
    }
    

    
    
    //MARK: - Table settings
    
    private var posts: [StreamPost] = []
    
    private func fetchPosts() {
       
        print("Fetching posts")
        
        DatabaseManager.shared.getPosts(for: currentEmail) { [weak self] posts in
            self?.posts = posts
            print("Found\(posts.count)")
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let post = posts[indexPath.row]
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PostPreviewTableViewCell.identifier, for: indexPath) as?
                PostPreviewTableViewCell else {
            fatalError()
        }
        cell.configure(with: .init(title: post.title, bodyText: post.text, imageUrl: post.headerImageUrl))
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 270
    }
    

        
        
        
    }
        
        

    //MARK: -Extensions
    
    
    
extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        guard let image = info[.editedImage] as? UIImage else {
            return
        }
        
        StorageManager.shared.uploadUserProfilePicture(
            email: currentEmail,
            image: image) { [weak self] success in
                guard let strongSelf = self  else {
                    return
                }
                if success {
                    //update database
                    DatabaseManager.shared.updateProfilePhoto(email: strongSelf.currentEmail) { updated in
                        guard updated else {
                            return
                        }
                        DispatchQueue.main.async {
                            print("upload successful")
                            strongSelf.fetchProfileData()
                        }
                    }
                }
            }
    }
}
