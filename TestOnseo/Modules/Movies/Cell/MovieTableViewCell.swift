//
//  MovieTableViewCell.swift
//  TestOnseo
//
//  Created by Artem Tkachenko on 04.07.2021.
//  Copyright © 2020 Artem Tkachenko. All rights reserved.
//

import UIKit
import SDWebImage

protocol MovieTableViewCellProtocol {
    func display(title: String?)
    func display(posterImageUrl: String?)
    func display(date: String?)
    func display(description: String?)
    func display(rating: String?)
    func display(model: Movie)
}

class MovieTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        resetContent()
        setupView()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        resetContent()
    }
     
    private func resetContent() {
        titleLabel.text = nil
        posterImageView.image = nil
        dateLabel.text = nil
        descriptionLabel.text = nil
    }
    
    private func setupView() {
        
    }
    
}

extension MovieTableViewCell: MovieTableViewCellProtocol {
    func display(model: Movie) {
        
    }
    
    func display(title: String?) {
        titleLabel.text = title
    }
    
    func display(date: String?) {
        dateLabel.text = date
    }
    
    func display(description: String?) {
        descriptionLabel.text = description
    }
    
    func display(rating: String?) {
        ratingLabel.text = rating
    }
    
    func display(posterImageUrl: String?) {
        if let stringUrl = posterImageUrl, let url = URL(string: stringUrl) {
            posterImageView.sd_setImage(with: url, completed: nil)
        }
    }
}
