//
//  AlarmClockView.swift
//  AlarmClock
//
//  Created by Liu Chuan on 2018/12/25.
//  Copyright © 2018 LC. All rights reserved.
//

import UIKit


/// 闹钟视图代理协议
protocol AlarmViewDelegate: NSObjectProtocol {
    
    /// 闹钟视图已更改
    ///
    /// - Parameters:
    ///   - bedTime: 就寝时间
    ///   - wakeTime: 起床时间
    func alarmViewIsChanged(withBedTime bedTime: String?, wakeTime: String?)
    
}


/// 旋转类型
///
/// - StartAngle: 起始角度
/// - EndAngle: 结束角度
/// - CircularingLocation: 圆环位置
/// - None: 无旋转
enum RotationType {
    case StartAngle
    case EndAngle
    case CircularingLocation
    case None
}


/// 图标视图宽度
private let IconViewWidth: CGFloat = 40

/// 当前开始角度
private var currentStartAngle: Float = 0

/// 当前结束角度
private var currentEndAngle: Float = 0

/// 扇形图层颜色
private let fanColor = UIColor(hue:0.12, saturation:0.81, brightness:1.00, alpha:1.00)



/// 将角度转为弧度
///
/// - Parameter x: x值
/// - Returns: CGFloat
func DgreesToRadoans(x: CGFloat) -> CGFloat {
    return .pi * (x) / 180.0
}



@objcMembers class AlarmClockView: UIView {
    
    // MARK: - Lazy Loading View
    
    /// 旋转类型
    private lazy var rotationType: RotationType = .StartAngle
    
    /// 就寝时间
    var bedTime = ""
    
    /// 起床时间
    var wakeTime = ""
    
    /// 开始角度 Default: 0
    var startAngle: CGFloat = 0.0
    
    /// 结束角度 Default: 0
    var endAngle: CGFloat = 0.0
    
    /// 代理
    weak var delegate: AlarmViewDelegate?
    
    /// 闹钟视图
     private lazy var alarmView: UIView = {
        let view = UIView(frame: bounds)
        return view
     }()
    
    /// 圆环父视图
    private lazy var ringSuperView: UIView = {
        let view = UIView(frame: bounds)
        return view
    }()
    
    /// 就寝父视图
    private lazy var sleepSuperView: UIView = {
        let view = UIView(frame: bounds)
        return view
    }()
    
    /// 按铃图片视图
    private lazy var ringView: UIImageView = {
        let ring = UIImageView(frame: CGRect(x: 0, y: 0, width: IconViewWidth, height: IconViewWidth))
        ring.center = CGPoint(x: AlarmViewRadius, y: IconViewWidth / 2)
        ring.image = UIImage(named: "ring")
        return ring
    }()
    
    /// 就寝图片视图
    private lazy var sleepView: UIImageView = {
        let sleep = UIImageView(frame: CGRect(x: 0, y: 0, width: IconViewWidth, height: IconViewWidth))
        sleep.center = CGPoint(x: AlarmViewRadius, y: IconViewWidth / 2)
        sleep.image = UIImage(named: "sleep")
        return sleep
    }()
    
    /// 时间刻度视图
    private lazy var timeScaleView: UIImageView = {
        let timeV = UIImageView(frame: CGRect(x: 0, y: 0, width: (AlarmViewRadius - IconViewWidth) * 2, height: (AlarmViewRadius - IconViewWidth) * 2))
        timeV.center = CGPoint(x: AlarmViewRadius, y: AlarmViewRadius)
        timeV.image = UIImage(named: "clock")
        return timeV
    }()
    
    /// 最终时间标签
    private lazy var finallyTimeLabel: UILabel = {
        let timeLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 40))
        timeLabel.center = CGPoint(x: AlarmViewRadius, y: AlarmViewRadius)
        timeLabel.text = "0小时0分"
        timeLabel.font = UIFont.boldSystemFont(ofSize: 20)
        timeLabel.numberOfLines = 1
        timeLabel.textColor = .white
        timeLabel.textAlignment = .center
        return timeLabel
    }()
    
    /// 最底部图层(在坐标系内绘制贝塞尔曲线)
    private lazy var lowestLayer: CAShapeLayer = {
        let lowestLayer = CAShapeLayer()
        lowestLayer.bounds = CGRect(x: 0, y: 0, width: bounds.size.width, height: bounds.size.height)
        /// 要呈现的形状的路径
        lowestLayer.path = drawAlarmPath(withStartAngle: 0, endAngle: 360)?.cgPath
        /// 填充路径的颜色
        lowestLayer.fillColor = UIColor(red: 0.07, green: 0.07, blue: 0.07, alpha: 1).cgColor
        return lowestLayer
    }()
    
    
    /// 渐变图层
    private lazy var gradientLayer: CAGradientLayer = {
        let gradient = CAGradientLayer()
        gradient.frame = fanLayer.bounds
        gradient.colors = [cgColorFor(red: 254, green: 149, blue: 40),
                           cgColorFor(red: 254, green: 193, blue: 47),
                           cgColorFor(red: 254, green: 200, blue: 49)]

        
//        gradient.colors = [cgColorFor(red: 254, green: 149, blue: 40), cgColorFor(red: 255, green: 255, blue: 0)]
//        gradient.locations = [0.0, 0.5, 1.0]
        gradient.startPoint = CGPoint(x: 0.5, y: 1)
        gradient.endPoint = CGPoint(x: 0.5, y: 0)
        return gradient
    }()
    
    /// 扇形遮罩图层(绘制贝塞尔曲线)
    private lazy var fanLayer: CAShapeLayer = {
        let fan = CAShapeLayer()
        fan.bounds = CGRect(x: 0, y: 0, width: bounds.size.width, height: bounds.size.height)
        // 要呈现的形状的路径
        fan.path = drawAlarmPath(withStartAngle: startAngle, endAngle: endAngle)?.cgPath
        // 要呈现的颜色
        fan.fillColor = fanViewColor
        // 设置描边色
        fan.strokeColor = UIColor.clear.cgColor
        return fan
    }()
    
    /// 扇形视图颜色
    public var fanViewColor: CGColor = UIColor.orange.cgColor {
        didSet{     // 监听数值 `fanViewColor` 的改变, 从而修改 `fanLayer` 的背景色
            if fanViewColor != oldValue {
                fanLayer.fillColor = fanViewColor
            }
        }
    }
    
    /// 旋转手势
    private lazy var gestureRecognizer: RotaionGestureRecognizer = {
        let ges = RotaionGestureRecognizer(center: alarmView.center, target: self, action: #selector(rotationAction(_:)))
        ges.rotaionGestureRecognizerDelegate = self
        return ges
    }()
    
    
    // MARK: - Initialization method
    
    /// 根据视图的尺寸位置\起始角度\结束角度创建视图
    ///
    /// - Parameters:
    ///   - frame: 视图尺寸位置
    ///   - startAngle: 起始角度
    ///   - endAngle: 结束角度
    init(frame: CGRect, startAngle: CGFloat, endAngle: CGFloat) {
        super.init(frame: frame)
        self.startAngle = startAngle
        self.endAngle = endAngle
        currentStartAngle = Float(startAngle)
        currentEndAngle = Float(endAngle)

        configUI()
        configGesture()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    
    /// 旋转手势相应事件
    @objc private func rotationAction(_ gestureRec: RotaionGestureRecognizer) {
        print("旋转角度 == \(-gestureRec.rotation * 180 / .pi)")
        beginRotation(withAngle: (-gestureRec.rotation * 180 / .pi), beiginPiont: gestureRec.beginPoint)
    }
    
    /// 开始旋转
    ///
    /// - Parameters:
    ///   - angle: 角度
    ///   - point: 点
    func beginRotation(withAngle angle: CGFloat, beiginPiont point: CGPoint) {
        switch rotationType {
        case RotationType.StartAngle:
            changeStartAngle(angle)
        case RotationType.EndAngle:
            changeEndAngle(angle)
        case RotationType.CircularingLocation:
            changeCircularingLocation(angle)
        default:
            break
        }
    }
    
    
    /// 改变起始时间
    ///
    /// - Parameter startAngle: 开始角度
    func changeStartAngle(_ startAngle: CGFloat) {
        
        var start = startAngle
        
        print("角度差 = \(abs(endAngle - self.startAngle - startAngle))")
        
        if abs(endAngle - self.startAngle - startAngle) > 360 {
            //修复BUG
//            if startAngle > 0 {
//                startAngle = startAngle - 360
//            } else {
//                startAngle = startAngle + 360
//            }
            
            
            if startAngle > 0 {
                start = startAngle - 360
            }else{
                start = startAngle + 360
            }
        }
        print("角度差2 = \(abs(endAngle - self.startAngle - start))")
        sleepSuperView.transform = CGAffineTransform(rotationAngle: DgreesToRadoans(x: self.startAngle + start))   //公转
        sleepView.transform = CGAffineTransform(rotationAngle: -DgreesToRadoans(x: self.startAngle + start))       //自转
        self.fanLayer.path = drawAlarmPath(withStartAngle: start + self.startAngle, endAngle: endAngle)?.cgPath
        
    }
    
    /// 改变结束时间
    ///
    /// - Parameter endAngle: 结束角度
    func changeEndAngle(_ endAngle: CGFloat) {
        
        var end = endAngle
        
        if abs(Float(startAngle - self.endAngle - endAngle)) > 360 {
            
//            if endAngle > 0 {
//                endAngle = endAngle - 360
//            } else {
//                endAngle = endAngle + 360
//            }
            
            
            if endAngle > 0 {
                end = endAngle - 360
            }else{
                end = endAngle + 360
            }
        }
        print("角度差 = \(abs(Float(self.endAngle - startAngle - endAngle)))")
        ringSuperView.transform = CGAffineTransform(rotationAngle: DgreesToRadoans(x: self.endAngle + end))
        ringView.transform = CGAffineTransform(rotationAngle: -DgreesToRadoans(x: self.endAngle + end))
        fanLayer.path = drawAlarmPath(withStartAngle: startAngle, endAngle: self.endAngle + end)?.cgPath
    }
    
    /// 改变圆环位置
    ///
    /// - Parameter angle: 角度
    func changeCircularingLocation(_ angle: CGFloat) {
        sleepSuperView.transform = CGAffineTransform(rotationAngle: DgreesToRadoans(x: startAngle + angle)) //公转
        sleepView.transform = CGAffineTransform(rotationAngle: -DgreesToRadoans(x: startAngle + angle)) //自转
        ringSuperView.transform = CGAffineTransform(rotationAngle: DgreesToRadoans(x: endAngle + angle))
        ringView.transform = CGAffineTransform(rotationAngle: -DgreesToRadoans(x: endAngle + angle))
        fanLayer.path = drawAlarmPath(withStartAngle: startAngle + angle, endAngle: endAngle + angle)?.cgPath
    }
    
}


// MARK: - Custom Method
extension AlarmClockView {
    
    
    /// 配置UI
    private func configUI() {
        
        self.layer.addSublayer(lowestLayer)
        //self.alarmView.layer.addSublayer(fanLayer)
        
        // 添加渐变层
        self.alarmView.layer.addSublayer(gradientLayer)
        // 设置遮罩
        gradientLayer.mask = fanLayer
        
        alarmView.transform = CGAffineTransform(rotationAngle: -.pi / 2)
        
        addSubview(alarmView)
        addSubview(ringSuperView)
        addSubview(sleepSuperView)
        addSubview(timeScaleView)
        addSubview(finallyTimeLabel)
        
        ringSuperView.addSubview(ringView)
        sleepSuperView.addSubview(sleepView)
        
    }
    /// 配置手势
    private func configGesture() {
        addGestureRecognizer(gestureRecognizer)
        changeStartAngle(0)
        changeEndAngle(0)
    }

    /// 绘制BezierPath
    ///
    /// - Parameters:
    ///   - startAngle: 起始角度
    ///   - endAngle: 结束角度
    /// - Returns: UIBezierPath
    func drawAlarmPath(withStartAngle startAngle: CGFloat, endAngle: CGFloat) -> UIBezierPath? {
        
        let circleRect = CGRect(x: AlarmViewRadius, y: AlarmViewRadius, width: bounds.size.width, height: bounds.size.height)
        let circlePath = UIBezierPath()
        
/*
        可以画出一段弧线。
        看下各个参数的意义：
            center：圆心的坐标
            radius：半径
            startAngle：起始的弧度
            endAngle：圆弧结束的弧度
            clockwise：true为顺时针，false为逆时针
*/
        
        circlePath.addArc(withCenter: CGPoint(x: circleRect.midX, y: circleRect.midY), radius: circleRect.size.width / 2, startAngle: DgreesToRadoans(x: startAngle), endAngle: DgreesToRadoans(x: endAngle), clockwise: true)
        circlePath.addLine(to: CGPoint(x: circleRect.midX, y: circleRect.midY))
        circlePath.close()
        currentStartAngle = fmodf(Float(startAngle), 360)
        currentEndAngle = fmodf(Float(endAngle), 360)
        finallyTimeLabel.attributedText = timeBlock(withAngle: Float(currentEndAngle - currentStartAngle))
        bedTime = bedTime(withAngle: CGFloat(currentStartAngle)) ?? ""
        wakeTime = wakeTime(withAngle: CGFloat(currentEndAngle)) ?? ""
        self.delegate?.alarmViewIsChanged(withBedTime: bedTime, wakeTime: wakeTime)
        return circlePath
    }
    
    /// 旋转类型
    ///
    /// - Parameter piont: 点
    /// - Returns: RotationType
    func rotationType(withPiont piont: CGPoint) -> RotationType {
        /// 时钟视图中心点
        let alarmViewCenter = CGPoint(x: AlarmViewRadius, y: AlarmViewRadius)
        /// 起始中心点
        let startCenter = CGPoint(x: cos( CGFloat((currentStartAngle - 90) / 180) * .pi) * (AlarmViewRadius - IconViewWidth / 2) + AlarmViewRadius, y: sin( CGFloat((currentStartAngle - 90) / 180) * .pi) * (AlarmViewRadius - IconViewWidth / 2) + AlarmViewRadius)
        /// 结束中心点
        let endCenter = CGPoint(x: cos( CGFloat((currentEndAngle - 90) / 180) * .pi) * (AlarmViewRadius - IconViewWidth / 2) + AlarmViewRadius, y: sin( CGFloat((currentEndAngle - 90) / 180) * .pi) * (AlarmViewRadius - IconViewWidth / 2) + AlarmViewRadius)

        if UIView.distanceBetweenPointA(alarmViewCenter, andPiontB: piont) >= AlarmViewRadius - IconViewWidth && UIView.distanceBetweenPointA(alarmViewCenter, andPiontB: piont) <= AlarmViewRadius {
            if UIView.distanceBetweenPointA(startCenter, andPiontB: piont) < IconViewWidth / 2 {
                return RotationType.StartAngle
            }else if UIView.distanceBetweenPointA(endCenter, andPiontB: piont) < IconViewWidth / 2 {
                return RotationType.EndAngle
            }else {
                return RotationType.None
            }
        }
        return RotationType.None
    }
    
    
    /// 根据弧度(角度)转换成字符串
    ///
    /// - Parameter angle: 角度
    /// - Returns: 字符串
    func timeBlock(withAngle angle: Float) -> NSAttributedString? {
        var angle = angle
        angle = angle < 0 ? fmodf(720 + angle, 360) : fmodf(angle, 360)
        var hour: Int
        var minute: Int
        if abs(angle) < 30 {
            hour = 0
            minute = Int(angle / 30 * 60)
        } else {
            hour = Int(angle / 30)
            minute = Int(fmodf(angle, 30) / 30 * 60)
        }
        hour = hour % 12 < 0 ? (48 + hour) % 12 : hour % 12
        minute = minute % 60 < 0 ? (120 + minute) % 60 : minute % 60
        print("\(hour)小时\(minute)分钟")
        print("\(hour)HR\(minute)MIN")
        return attributeString(withHour: hour, minute: minute)
    }

    
    /// 根据角度(弧度)转换就寝时间
    ///
    /// - Parameter angle: 角度
    /// - Returns: 字符串
    func bedTime(withAngle angle: CGFloat) -> String? {
        
        var angle = angle
       // fmodf: 获得浮点数除法操作的余数
        angle = angle < 0 ? CGFloat(fmodf(Float(720 + angle), 360)) : CGFloat(fmodf(Float(angle), 360))
        /// 小时
        var hour: Int
        /// 分钟
        var minute: Int

        ///返回给定数字的绝对值。
        ///
        ///  - 参数x：带符号的数字。
        ///  - 返回：`x`的绝对值。

        if abs(Float(angle)) < 30 {

            hour = 0
            minute = Int(angle / 30 * 60)
        } else {
            hour = Int(angle / 30)
            minute = Int(fmodf(Float(angle), 30) / 30 * 60)
        }
        hour = hour % 12 < 0 ? (48 + hour) % 12 : hour % 12
        minute = minute % 60 < 0 ? (120 + minute) % 60 : minute % 60
        return String(format: "%02d:%02d", hour, minute)
    }
    
    /// 根据角度(弧度)转换起床时间
    ///
    /// - Parameter angle: 角度
    /// - Returns: 字符串
    func wakeTime(withAngle angle: CGFloat) -> String? {
        
        var angle = angle
        angle = angle < 0 ? CGFloat(fmodf(Float(720 + angle), 360)) : CGFloat(fmodf(Float(angle), 360))
        var hour: Int
        var minute: Int
        
        if abs(Float(angle)) < 30 {
            hour = 0
            minute = Int(angle / 30 * 60)
        } else {
            hour = Int(angle / 30)
            minute = Int(fmodf(Float(angle), 30) / 30 * 60)
        }
        hour = hour % 12 < 0 ? (48 + hour) % 12 : hour % 12
        minute = minute % 60 < 0 ? (120 + minute) % 60 : minute % 60
        return String(format: "%02d:%02d", hour, minute)
    }
    
    
    /// 根据时间(小时\分钟)转换成字符串
    ///
    /// - Parameters:
    ///   - hour: 小时
    ///   - minute: 分钟
    /// - Returns: 字符串
    func attributeString(withHour hour: Int, minute: Int) -> NSAttributedString {
        
        /// 初始化NSMutableAttributedString
        let attributedString = NSMutableAttributedString()
        // 设置字体格式和大小
        let dictAttr0 = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.white]
        let dictAttr1 = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 25), NSAttributedString.Key.foregroundColor: UIColor.white]
        let attr0 = NSAttributedString(string: String(format: " %2d", hour), attributes: dictAttr1)
//        let attr1 = NSAttributedString(string: " 小时", attributes: dictAttr0)
        let attr1 = NSAttributedString(string: " HR", attributes: dictAttr0)
        let attr2 = NSAttributedString(string: String(format: " %2d", minute), attributes: dictAttr1)
//        let attr3 = NSAttributedString(string: " 分钟", attributes: dictAttr0)
         let attr3 = NSAttributedString(string: " MIN", attributes: dictAttr0)
        
        attributedString.append(attr0)
        attributedString.append(attr1)
        attributedString.append(attr2)
        attributedString.append(attr3)
        return attributedString
    }
    
    // 扩展CGColor
    func cgColorFor(red: CGFloat, green: CGFloat, blue: CGFloat) -> CGColor {
        return UIColor(red: red/255.0, green: green/255.0, blue: blue/255.0, alpha: 1).cgColor
    }

}


// MARK: - RotaionGestureRecognizerDelegate
extension AlarmClockView : RotaionGestureRecognizerDelegate {
    
    
    func touchesBeg(_ touches: Set<UITouch>, with event: UIEvent) {
      
        let startPiont: CGPoint? = touches.first?.location(in: self)
        
        print("\(startPiont?.x ?? 0.0)--\(startPiont?.y ?? 0.0)")
        
        rotationType = rotationType(withPiont: startPiont!)
    }
    
    func touchesMov(_ touches: Set<UITouch>, with event: UIEvent) {
        
    }
    
    func touchesCancell(_ touches: Set<UITouch>, with event: UIEvent) {
        rotationType = .None
        startAngle = CGFloat(currentStartAngle)
        endAngle = CGFloat(currentEndAngle)
    }
    
    
    func touchesEnd(_ touches: Set<UITouch>, with event: UIEvent) {
        rotationType = .None
        startAngle = CGFloat(currentStartAngle)
        endAngle = CGFloat(currentEndAngle)
    }
    
}
