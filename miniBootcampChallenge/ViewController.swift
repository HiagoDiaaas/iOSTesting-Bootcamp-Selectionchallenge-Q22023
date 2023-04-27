//
//  ViewController.swift
//  miniBootcampChallenge
//

// TODO: 1.- Implement a function that allows the app downloading the images without freezing the UI or causing it to work unexpected way

// Solution for TODO 1:
// Implemented an asynchronous image downloading method inside the ImageCell class.
// This method is called in the cellForItemAt method, which prevents the UI from freezing
// and allows smooth scrolling in the UICollectionView.




// TODO: 2.- Implement a function that allows to fill the collection view only when all photos have been downloaded, adding an animation for waiting the completion of the task.

// Solution for TODO 2:
// Downloaded all images before displaying them in the UICollectionView using a DispatchGroup.
// Added an activity indicator to show a loading animation while waiting for the images to download.
// Used UIView.transition to animate the UICollectionView after all images have been downloaded.

import UIKit

class ViewController: UICollectionViewController {
    
    private lazy var urls: [URL] = URLProvider.urls
    private var images: [UIImage?] = []
    private var useAsyncImageLoading = false // Set this flag to true for async image loading (Challenge 1)
    private var activityIndicator: UIActivityIndicatorView?
    
    private struct Constants {
        static let title = "Mini Bootcamp Challenge"
        static let cellID = "imageCell"
        static let cellSpacing: CGFloat = 1
        static let columns: CGFloat = 3
        static var cellSize: CGFloat?
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = Constants.title
        
        if useAsyncImageLoading {
            collectionView.reloadData()
        } else {
            setupActivityIndicator()
            downloadAllImages()
        }
    }
    
    // Setup the activity indicator for showing a loading animation
    private func setupActivityIndicator() {
        activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator?.center = view.center
        activityIndicator?.startAnimating()
        view.addSubview(activityIndicator!)
        view.bringSubviewToFront(activityIndicator!)
    }
    
    // Remove the activity indicator from the view hierarchy
    private func removeActivityIndicator() {
        activityIndicator?.removeFromSuperview()
        activityIndicator = nil
    }

    // Method to download all images
    private func downloadAllImages() {
        // Create a DispatchGroup to wait for all images to download
        let group = DispatchGroup()
        images = Array(repeating: nil, count: urls.count)
        
        // Download each image and store it in the images array
        for (index, url) in urls.enumerated() {
            group.enter()
            URLSession.shared.dataTask(with: url) { data, _, _ in
                if let data = data, let image = UIImage(data: data) {
                    self.images[index] = image
                }
                group.leave()
            }.resume()
        }
        
        // Animate the collection view after all images have been downloaded
        group.notify(queue: .main) {
            self.removeActivityIndicator()
            UIView.transition(with: self.collectionView,
                              duration: 0.5,
                              options: .transitionCrossDissolve,
                              animations: { self.collectionView.reloadData() },
                              completion: nil)
        }
    }
}


// MARK: - UICollectionView DataSource, Delegate
extension ViewController {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        urls.count
    }
    
    // Updated cellForItemAt method to use the configure(with:) method for asynchronous image downloading
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.cellID, for: indexPath) as? ImageCell else { return UICollectionViewCell() }

            if useAsyncImageLoading {
                let url = urls[indexPath.row]
                cell.configure(with: url) // Call the configure method with the image URL
            } else {
                cell.display(images[indexPath.row])
            }
            
            return cell
        }
}

// MARK: - UICollectionView FlowLayout
extension ViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if Constants.cellSize == nil {
            let layout = collectionViewLayout as! UICollectionViewFlowLayout
            let emptySpace = layout.sectionInset.left + layout.sectionInset.right + (Constants.columns * Constants.cellSpacing - 1)
            Constants.cellSize = (view.frame.size.width - emptySpace) / Constants.columns
        }
        return CGSize(width: Constants.cellSize!, height: Constants.cellSize!)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        Constants.cellSpacing
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        Constants.cellSpacing
    }
}
