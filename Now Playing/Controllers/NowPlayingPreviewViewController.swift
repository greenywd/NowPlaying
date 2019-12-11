//
//  NowPlayingPreviewControllerViewController.swift
//  Now Playing
//
//  Created by Thomas Greenwood on 11/12/19.
//  Copyright © 2019 Thomas Greenwood. All rights reserved.
//

import UIKit

class NowPlayingPreviewViewController: UIViewController {
    let song: Song
    private let imageView = UIImageView()
    
    override func loadView() {
        self.view = imageView
        
        let gradient = CAGradientLayer()
        gradient.frame = CGRect(x: 0, y: 0, width: song.artwork!.size.width, height: song.artwork!.size.height)
        gradient.colors = [UIColor.clear, UIColor.black]
        imageView.layer.addSublayer(gradient)
    }
    
    init(song: Song) {
        self.song = song
        super.init(nibName: nil, bundle: nil)
        
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.image = song.artwork
        
        let gradient = CAGradientLayer()
        gradient.frame = CGRect(x: 0, y: 0, width: song.artwork!.size.width, height: song.artwork!.size.height)
        gradient.colors = [UIColor.clear, UIColor.black]
        imageView.layer.insertSublayer(gradient, at: 0)

        // By setting the preferredContentSize to the image size,
        // the preview will have the same aspect ratio as the image
        preferredContentSize = song.artwork!.size
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
