//
//  IndicatorView.swift
//  Ride
//
//  Created by Mac on 18/08/2022.
//

import Foundation
import UIKit

class Indicator:UIView{
    var imageView: UIImageView!
    var titleLabel: UILabel!
    var rotationAnimation = CABasicAnimation(keyPath: "transform.rotation")
    
    public init() {
        super.init(frame: .zero)
        create()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        create()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        create()
    }
    
    private func create(){
        
        titleLabel = UILabel.init(frame: CGRect.zero)
        titleLabel.font = .boldSystemFont(ofSize: 21)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        addSubview(titleLabel)
        
        imageView = UIImageView()
        imageView.image = UIImage.init(named: "loader")
        imageView.contentMode = .scaleAspectFit
        addSubview(imageView)
        
        
        let stack = UIStackView.init(arrangedSubviews: [imageView, titleLabel]);
        stack.distribution = .fillProportionally
        stack.axis = .vertical
        stack.spacing = 5
        addSubview(stack)
        stack.addParentFullLayout()
        titleLabel.setFixedLayoutAttribute(attribute: .height, constant: 20)
    }
    
    public  func show(text:String?=nil){
        titleLabel.text = text
        
       
        rotationAnimation.fromValue = 0.0
        rotationAnimation.toValue = Double.pi * 2
        rotationAnimation.duration = 1.5
        rotationAnimation.repeatCount = Float.infinity
        rotationAnimation.isRemovedOnCompletion = false
        imageView.layer.add(rotationAnimation, forKey: "rotate")
    }
    public  func pauseLoader(){
        imageView.layer.pause()
    }
    public  func restartLoader(){
       
        imageView.layer.resume()
    imageView.layer.name = "rotate"
        if let sublayers = imageView.layer.sublayers {
            for layer in sublayers {
                // ...
                if layer.name == "rotate"{
                    print("we are here")
                }
            }
        }
//        rotationAnimation.fromValue = 0.0
//        rotationAnimation.toValue = Double.pi * 2
//        rotationAnimation.duration = 1.5
//        rotationAnimation.repeatCount = Float.infinity
//        imageView.layer.add(rotationAnimation, forKey: "rotate")
    }
    
}

