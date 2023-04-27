//
//  ImageCell.swift
//  miniBootcampChallenge
//

import UIKit

class ImageCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    // Prepare the cell for reuse
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }
    
    // Display the image
    func display(_ image: UIImage?) {
        imageView.image = image
    }

    // Configure the cell with the image URL for asynchronous downloading
    func configure(with imageURL: URL) {
        // Create a URLSession data task to download the image
        URLSession.shared.dataTask(with: imageURL) { data, _, _ in
            if let data = data, let image = UIImage(data: data) {
                // Update the UI on the main thread
                DispatchQueue.main.async {
                    self.display(image)
                }
            }
        }.resume() // Start the data task
    }
}


