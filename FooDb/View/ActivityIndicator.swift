//
//  ActivityIndicator.swift
//  FooDb
//
//  Created by taralika on 4/2/20.
//  Copyright © 2020 at. All rights reserved.
//

import UIKit

class ActivityIndicator
{
    private let activityIndicator = UIActivityIndicatorView()
    private let blurView = UIView()
    private func setupLoader()
    {
        hide()
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = .white
    }
    
    func show(_ holdingView: UIView)
    {
        setupLoader()
        DispatchQueue.main.async
        {
            self.blurView.frame = holdingView.bounds
            self.blurView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
            self.activityIndicator.center = holdingView.center
            self.activityIndicator.startAnimating()
            self.blurView.addSubview(self.activityIndicator)
            holdingView.addSubview(self.blurView)
        }
    }
    
    func hide()
    {
        DispatchQueue.main.async
        {
            self.blurView.removeFromSuperview()
            self.activityIndicator.stopAnimating()
            self.activityIndicator.removeFromSuperview()
        }
    }
}
