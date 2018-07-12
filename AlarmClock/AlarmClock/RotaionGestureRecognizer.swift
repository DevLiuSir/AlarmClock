//
//  RotaionGestureRecognizer.swift
//  AlarmClock
//
//  Created by Liu Chuan on 2018/12/27.
//  Copyright © 2018 LC. All rights reserved.
//

import UIKit


/// 旋转手势代理
@objc protocol RotaionGestureRecognizerDelegate: NSObjectProtocol {
    
    /// 手指按下事件
    ///
    /// - Parameters:
    ///   - touches: 触摸
    ///   - event: 事件
    @objc optional func touchesBeg(_ touches: Set<UITouch>, with event: UIEvent)
    
    /// 手指移动事件
    ///
    /// - Parameters:
    ///   - touches: 触摸
    ///   - event: 事件
    @objc optional func touchesMov(_ touches: Set<UITouch>, with event: UIEvent)
    
    /// 手指抬起事件
    ///
    /// - Parameters:
    ///   - touches: 触摸
    ///   - event: 事件
    @objc optional func touchesEnd(_ touches: Set<UITouch>, with event: UIEvent)
    
    /// 意外中断事件（如打电话打扰）
    ///
    /// - Parameters:
    ///   - touches: 触摸
    ///   - event: 事件
    @objc optional func touchesCancell(_ touches: Set<UITouch>, with event: UIEvent)
    
}


/// 旋转手势类
class RotaionGestureRecognizer: UIGestureRecognizer {
    
    /// 当前旋转角度
    var currentRotation: CGFloat = 0.0
    /// 下一个旋转角度
    var previousRotation: CGFloat = 0.0
    /// 起始点
    var startingPoint = CGPoint.zero
    /// 结束点
    var endPoint = CGPoint.zero
    /// 中心点
    var center = CGPoint.zero
    
    /// 旋转偏移值
    var rotation: CGFloat {
        get {
            return currentRotation + previousRotation
        }
    }
    
    /// 起始点
    var beginPoint: CGPoint {
        get {
            return startingPoint
        }
    }

    /// 旋转手势代理
    weak var rotaionGestureRecognizerDelegate: RotaionGestureRecognizerDelegate?
    
    /// 初始化 center：旋转中心点
    ///
    /// - Parameters:
    ///   - center: 中心点
    ///   - target: 目标
    ///   - action: 动作
    init(center: CGPoint, target: Any?, action: Selector?) {
        super.init(target: target, action: action)
        self.center = center
    }
    
//    func resetRotation() {
//        currentRotation = 0
//        previousRotation = 0
//    }
    
    /**** 复位动作 **** (拖动结束后自动重置) */
    //你需要在touchesEnded 之后 touchesBegan 之前调用 reset() 。这可以让手势识别器清除它的状态然后重新开始。
    override func reset() {
        super.reset()
        //    _previousRotation = [self rotation];
        previousRotation = 0
        currentRotation = 0
    }
}



// MARK: - Event Response Method
extension RotaionGestureRecognizer {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesBegan(touches, with: event)

        startingPoint = (touches.first?.location(in: view))!
        state = UIGestureRecognizer.State.began
        rotaionGestureRecognizerDelegate?.touchesBeg!(touches, with: event)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesMoved(touches, with: event)
        
        let point: CGPoint = (touches.first?.location(in: view))!
        currentRotation = UIView.angleBetweenPoint1(startingPoint, point2: point, andCenter: center)
        state = UIGestureRecognizer.State.changed
        rotaionGestureRecognizerDelegate?.touchesMov!(touches, with: event)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesEnded(touches, with: event)
        
        endPoint = (touches.first?.location(in: view))!
        currentRotation = UIView.angleBetweenPoint1(startingPoint, point2: endPoint, andCenter: center)
        state = UIGestureRecognizer.State.ended
        rotaionGestureRecognizerDelegate?.touchesEnd!(touches, with: event)
    }
    
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesCancelled(touches, with: event)
        
        state = UIGestureRecognizer.State.cancelled
        rotaionGestureRecognizerDelegate?.touchesCancell!(touches, with: event)
    }
}
