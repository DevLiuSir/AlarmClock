//
//  ViewController.swift
//  AlarmClock
//
//  Created by Liu Chuan on 2018/12/25.
//  Copyright © 2018 LC. All rights reserved.
//

import UIKit


/// 屏幕的宽度
private let screenW: CGFloat = UIScreen.main.bounds.width
/// 屏幕的高度
private let screenH: CGFloat = UIScreen.main.bounds.height
/// 屏幕宽度的一半
private let screenWidthHalf: CGFloat = screenW / 2
/// 屏幕高度的一半
private let screenHeightHalf: CGFloat = screenH / 2
/// 标签的宽度
private let labelWidth: CGFloat = 120
/// 标签的高度
private let labelHeight: CGFloat = 30
/// 闹钟视图的高度
private let alarmClockViewHeight: CGFloat = 350
/// 闹钟视图的X值
let alarmViewX: CGFloat = screenW - alarmClockViewHeight / 2
/// 闹钟视图的Y值
let alarmViewY: CGFloat = screenH - alarmClockViewHeight / 2


class ViewController: UIViewController {
    
    
    // MARK: - Lazy Loading
    /// 就寝标签
//    private lazy var bedLabel: UILabel = {
//        let label = UILabel(frame: CGRect(x: (screenWidthHalf - labelWidth)/2, y: 140, width: labelWidth, height: labelHeight))
//        label.text = "Bedtime"
//        label.textColor = .white
//        label.font = UIFont.boldSystemFont(ofSize: 22)
//        label.textAlignment = .center
//        label.numberOfLines = 1
//        return label
//    }()
    
    /// 就寝图片
    private lazy var bedImage: UIImageView = {
        let imag = UIImageView(frame: CGRect(x: (screenWidthHalf - labelWidth)/2, y: 140, width: labelWidth, height: 30))
        imag.image = UIImage(named: "Bedtime")
        imag.contentMode = .scaleAspectFill
        imag.clipsToBounds = true       // 图像是否裁切
        return imag
    }()
    
    /// 就寝时间标签
    private lazy var bedTimeLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: (screenWidthHalf - labelWidth)/2, y: 180, width: labelWidth, height: labelHeight))
        label.text = alarmClockView.bedTime
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 35)
        label.textAlignment = .center
        label.numberOfLines = 1
        return label
    }()
    
//    /// 起床标签
//    private lazy var wakeLabel: UILabel = {
//        let label = UILabel(frame: CGRect(x: screenWidthHalf + (screenWidthHalf - labelWidth)/2, y: 140, width: labelWidth, height: labelHeight))
//        label.text = "Wake"
//        label.textColor = .white
//        label.font = UIFont.boldSystemFont(ofSize: 22)
//        label.textAlignment = .center
//        label.numberOfLines = 1
//        return label
//    }()
    
    
    /// 起床图片
    private lazy var wakeImage: UIImageView = {
        let imag = UIImageView(frame: CGRect(x: screenWidthHalf + (screenWidthHalf - labelWidth)/2, y: 140, width: labelWidth, height: 30))
        imag.image = UIImage(named: "Wake")
        imag.contentMode = .scaleAspectFill
        imag.clipsToBounds = true       // 图像是否裁切
        return imag
    }()
    
    /// 起床时间标签
    private lazy var wakeTimeLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: screenWidthHalf + (screenWidthHalf - labelWidth)/2, y: 180, width: labelWidth, height: labelHeight))
        label.text = alarmClockView.wakeTime
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 35)
        label.textAlignment = .center
        label.numberOfLines = 1
        return label
    }()
    
    /// 闹钟视图
    private lazy var alarmClockView: AlarmClockView = { [unowned self] in
        let alarmClockView = AlarmClockView(frame: CGRect(x: alarmViewX, y: alarmViewY, width: alarmClockViewHeight, height: alarmClockViewHeight), startAngle: 45, endAngle: 90)
        alarmClockView.center = view.center
        alarmClockView.alpha = 1
        alarmClockView.backgroundColor = .clear
        alarmClockView.delegate = self
        return alarmClockView
    }()
    
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.black
        
        view.addSubview(alarmClockView)
//        view.addSubview(bedLabel)
//        view.addSubview(wakeLabel)
        
        
        view.addSubview(bedImage)
        view.addSubview(wakeImage)
        view.addSubview(bedTimeLabel)
        view.addSubview(wakeTimeLabel)
        
        
    }  
}


// MARK: - AlarmViewDelegate
extension ViewController : AlarmViewDelegate {
    
    func alarmViewIsChanged(withBedTime bedTime: String?, wakeTime: String?) {
        bedTimeLabel.text = bedTime
        wakeTimeLabel.text = wakeTime
    }
}
