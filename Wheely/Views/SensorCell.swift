//
//  SensorCell.swift
//  Wheely
//
//  Created by Student on 2020-04-04.
//  Copyright © 2020 Daniel Abella. All rights reserved.
//

import UIKit
import Charts
import CoreData

class BaseCell: UICollectionViewCell {
    
    var homeController: HomeController?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        
    }
}

class SensorCell: BaseCell {
    
    
    var sensor: SensorModel? {
        didSet {
            print("Did set sensor model")
            self.descriptionLabel.text = self.sensor?.title
            self.chartView.data = self.sensor?.data
            self.chartView.chartDescription?.text = self.sensor?.title
            chartView.data?.notifyDataChanged()
            chartView.notifyDataSetChanged()
            self.reloadInputViews()
        }
    }
    
    var chartView: LineChartView = {
        let view = LineChartView()
        view.backgroundColor = .systemGray5
        return view
    }()
    
    let descriptionLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .systemGray6
        return label
    }()
    
    let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray4
        return view
    }()
    
    override func setupViews() {
        super.setupViews()
        
        print("Graph setup...")
        
        addSubview(chartView)
        addSubview(separatorView)
        addSubview(descriptionLabel)
        
        addConstraintsWithFormat(format: "H:|-16-[v0]-16-|", views: chartView)
        addConstraintsWithFormat(format: "H:|-16-[v0(40)]-16-|", views: descriptionLabel)
        addConstraintsWithFormat(format: "V:|-16-[v0]-16-[v1(40)]-[v2(1)]|", views: chartView, descriptionLabel, separatorView)
        addConstraintsWithFormat(format: "H:|[v0]|", views: separatorView)
        
    }
    
}
