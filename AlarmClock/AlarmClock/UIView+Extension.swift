//
//  UIView+Extension.swift
//  AlarmClock
//
//  Created by Liu Chuan on 2018/12/27.
//  Copyright © 2018 LC. All rights reserved.
//

import UIKit

extension UIView {
    
    /// 时钟视图的半径
    var AlarmViewRadius: CGFloat {
        get {
            return bounds.width / 2
        }
    }
    
    /// 时钟视图的高度
    var AlarmViewWH: CGFloat {
        get {
            return bounds.width
        }
    }
    
    /// 两个坐标点的角度
    ///
    /// - Parameters:
    ///   - first: 第一个点
    ///   - second: 第二个点
    ///   - center: 中心点
    /// - Returns: CGFloat
    class func angleBetweenPoint1(_ first: CGPoint, point2 second: CGPoint, andCenter center: CGPoint) -> CGFloat {
        
        let centeredPoint1 = CGPoint(x: first.x - center.x, y: first.y - center.y)
        let centeredPoint2 = CGPoint(x: second.x - center.x, y: second.y - center.y)
        let firstAngle: CGFloat = angleBetweenOriginAndPointA(centeredPoint1)
        let secondAngle: CGFloat = angleBetweenOriginAndPointA(centeredPoint2)
        let rads: CGFloat = secondAngle - firstAngle
        return rads
    }
    
    /// 两点的距离
    ///
    /// - Parameters:
    ///   - pointA: 第一个点A
    ///   - pointB: 第二个点B
    /// - Returns: CGFloat
    class func distanceBetweenPointA(_ pointA: CGPoint, andPiontB pointB: CGPoint) -> CGFloat {
        
        let a: CGFloat = pow(pointB.x - pointA.x, 2)
        let b: CGFloat = pow(pointB.y - pointA.y, 2)
        return sqrt(a + b)
    }
    
    //* 某点和原点间的角度
    class func angleBetweenOriginAndPointA(_ p: CGPoint) -> CGFloat {
        
        if p.x == 0 {
            return CGFloat(signA(num: p.y)) * .pi
        }
        
        // '-' because negative ordinates are positive in UIKit
        var angle = atan(-p.y / p.x)
        
        // atan() is defined in [-pi/2, pi/2], but we want a value in [0, 2*pi]
        // so we deal with these special cases accordingly
        switch quadrantForPointA(p: p) {
        case 1, 2:
            angle += .pi
        case 3:
            angle += 2 * .pi
        default:
            break
        }
        return angle
    }
    
    //* 点的象限
    class func quadrantForPointA(p: CGPoint) -> Int {
        if p.x > 0 && p.y < 0 {
            return 0
        } else if p.x < 0 && p.y < 0 {
            return 1
        } else if p.x < 0 && p.y > 0 {
            return 2
        } else if p.x > 0 && p.y > 0 {
            return 3
        }
        return 0
    }
    
    class func signA(num: CGFloat) -> Int {
        if num == 0 {
            return 0
        } else if num > 0 {
            return 1
        } else {
            return -1
        }
    }

}
