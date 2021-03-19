//
//  PostCell.swift
//  Parstagram
//
//  Created by Daniel Astudillo on 3/19/21.
//

import UIKit

class PostCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    @IBOutlet var photoView: UIImageView!
    
    @IBOutlet var usernameLabel: UILabel!
    @IBOutlet var captionLabel: UILabel!
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
