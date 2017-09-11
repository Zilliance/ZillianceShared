//
//  AppDelegate.swift
//  Balance Pie
//
//  Created by Philip Dow on 1/8/17.
//  Copyright © 2017 Phil Dow. All rights reserved.
//

import UIKit

private let OnboardingScreenMargin = CGFloat(5)

public class OnboardingPopover: UIView {
    public enum Direction {
        case above
        case below
        case left
        case right
    }

    public enum Transition {
        case none
        case presenting
        case dismissing
    }

    public enum ArrowLocation {
        case centeredOnPopover
        case centeredOnTarget
    }

    fileprivate let roundedRectView = UIView()
    fileprivate let arrowView = UIView()
    
    fileprivate var rectLeftConstraint: NSLayoutConstraint!
    fileprivate var rectRightConstraint: NSLayoutConstraint!
    fileprivate var rectTopConstraint: NSLayoutConstraint!
    fileprivate var rectBottomConstraint: NSLayoutConstraint!
    
    fileprivate var fromDirection = Direction.below
    fileprivate var label = UILabel()
    
    // Values should be set before presenting popover
    
    public var arrowLocation = ArrowLocation.centeredOnPopover
    public var margins = UIEdgeInsets(top: 16, left: 20, bottom: 16, right: 20)
    public var arrowSize = CGSize(width: 12, height: 8)
    public var maxWidth = CGFloat(280)
    public var offset = CGFloat(6)
    
    fileprivate(set) var currentTransition = Transition.none
    public var fitToSuperview = true
    
    public var userInfo: [String: Any]?
    
    public var hasShadow: Bool = false {
        didSet {
            self.roundedRectView.layer.shadowOpacity = hasShadow ? 1 : 0
        }
    }
    
    public var title: String? {
        didSet {
            self.label.text = self.title
        }
    }
    
    override public var backgroundColor: UIColor? {
        set {
            self.roundedRectView.backgroundColor = newValue
            self.arrowView.backgroundColor = newValue
        }
        get {
            return self.roundedRectView.backgroundColor
        }
    }
    
    public var shadowColor: UIColor? {
        didSet {
            self.roundedRectView.layer.shadowColor = shadowColor?.cgColor
        }
    }
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    fileprivate func commonInit() {
        self.isUserInteractionEnabled = false
        
        // Rounded Rect
        
        self.roundedRectView.translatesAutoresizingMaskIntoConstraints = false
        self.roundedRectView.backgroundColor = .lightBlue
        self.roundedRectView.layer.cornerRadius = 4
        
        self.roundedRectView.layer.shadowColor = UIColor.white.cgColor
        self.roundedRectView.layer.shadowOffset = CGSize(width: 0, height: 1)
        self.roundedRectView.layer.shadowRadius = 2
        self.roundedRectView.layer.shadowOpacity = 0
        
        self.addSubview(self.roundedRectView)
        
        self.rectLeftConstraint = self.roundedRectView.leftAnchor.constraint(equalTo: self.leftAnchor)
        self.rectLeftConstraint.isActive = true
        self.rectRightConstraint = self.roundedRectView.rightAnchor.constraint(equalTo: self.rightAnchor)
        self.rectRightConstraint.isActive = true
        self.rectTopConstraint = self.roundedRectView.topAnchor.constraint(equalTo: self.topAnchor)
        self.rectTopConstraint.isActive = true
        self.rectBottomConstraint = self.roundedRectView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        self.rectBottomConstraint.isActive = true
        
        // Arrow
        
        self.arrowView.translatesAutoresizingMaskIntoConstraints = false
        self.arrowView.backgroundColor = .lightBlue
        
        let mask = CAShapeLayer()
        let arrow = UIBezierPath()
        
        arrow.move(to: CGPoint(x: self.arrowSize.width/2, y: 0))
        arrow.addLine(to: CGPoint(x: self.arrowSize.width, y: self.arrowSize.height))
        arrow.addLine(to: CGPoint(x: 0, y: self.arrowSize.height))
        
        arrow.close()
        mask.path = arrow.cgPath
        self.arrowView.layer.mask = mask
        
        self.addSubview(self.arrowView)
        
        self.arrowView.widthAnchor.constraint(equalToConstant: self.arrowSize.width).isActive = true
        self.arrowView.heightAnchor.constraint(equalToConstant: self.arrowSize.height).isActive = true
        self.arrowView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        self.arrowView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        
        // Label
        
        self.label.translatesAutoresizingMaskIntoConstraints = false
        self.label.font = UIFont.muliRegular(size: 14)
        self.label.textColor = UIColor.white
        self.label.textAlignment = .center
        self.label.numberOfLines = 0
        
        self.roundedRectView.addSubview(self.label)
        
        self.label.centerXAnchor.constraint(equalTo: self.roundedRectView.centerXAnchor).isActive = true
        self.label.centerYAnchor.constraint(equalTo: self.roundedRectView.centerYAnchor).isActive = true
        
        self.label.leftAnchor.constraint(equalTo: self.roundedRectView.leftAnchor, constant: self.margins.left).isActive = true
        self.label.rightAnchor.constraint(equalTo: self.roundedRectView.rightAnchor, constant: -self.margins.right).isActive = true
        self.label.topAnchor.constraint(equalTo: self.roundedRectView.topAnchor, constant: self.margins.top).isActive = true
        self.label.bottomAnchor.constraint(equalTo: self.roundedRectView.bottomAnchor, constant: -self.margins.bottom).isActive = true
    }
    
    // MARK: - Layout
    
    override public func sizeThatFits(_ size: CGSize) -> CGSize {
        let maxLabelWidth = self.maxWidth - self.margins.left - self.margins.right
        let labelSize = self.label.sizeThatFits(CGSize(width: maxLabelWidth, height: CGFloat.greatestFiniteMagnitude))
        
        var width = labelSize.width + self.margins.left + self.margins.right
        var height = labelSize.height + self.margins.top + self.margins.bottom
        
        switch self.fromDirection {
        case .above: fallthrough
        case .below:
            height += self.arrowSize.height
        case .left: fallthrough
        case .right:
            width += self.arrowSize.height
        }
        
        return CGSize(width: width, height: height)
    }
    
    // MARK: -
    
    /// Custom presenters should apply any pre-animation transformations in the prePresenter code block
    
    public func present(in view: UIView, at point: CGPoint, from direction: Direction, prePresenter: (()->Void)?=nil, animator: (()->Void)?=nil) {
        view.addSubview(self)
        self.setFrame(in: view, at: point, from: direction)
        
        // Custom animator
        
        if let prePresenter = prePresenter, let animator = animator {
            prePresenter()
            UIView.animate(withDuration: 0.25, animations: {
                self.currentTransition = .presenting
                animator()
            }, completion: { _ in
                self.currentTransition = .none
            })
            return
        }
        
        // Default animator
        
        self.alpha = 0
        
        switch direction {
        case .above:
            self.transform = CGAffineTransform.identity.scaledBy(x: 0.9, y: 0.9).translatedBy(x: 0, y: -50)
        case .below:
            self.transform = CGAffineTransform.identity.scaledBy(x: 0.9, y: 0.9).translatedBy(x: 0, y: 50)
        case .left:
            self.transform = CGAffineTransform.identity.scaledBy(x: 0.9, y: 0.9).translatedBy(x: -50, y: 0)
        case .right:
            self.transform = CGAffineTransform.identity.scaledBy(x: 0.9, y: 0.9).translatedBy(x: 50, y: 0)
        }
        
        UIView.animate(withDuration: 0.25, animations: {
            self.currentTransition = .presenting
            self.transform = CGAffineTransform.identity
            self.alpha = 1
        }, completion: { _ in
            self.currentTransition = .none
        })
    }
    
    public func dismiss(_ animator: (()->Void)?=nil) {
        guard self.superview != nil else {
            return
        }
        
        // Custom animator
        
        if let animator = animator {
            UIView.animate(withDuration: 0.25, animations: {
                self.currentTransition = .dismissing
                animator()
            }, completion: { _ in
                self.currentTransition = .none
                self.removeFromSuperview()
            })
            return
        }
        
        // Default animator
        
        UIView.animate(withDuration: 0.25, animations: {
            self.currentTransition = .dismissing
            self.transform = CGAffineTransform.identity.scaledBy(x: 0.9, y: 0.9)
            self.alpha = 0
        }, completion: { _ in
            self.currentTransition = .none
            self.removeFromSuperview()
        }) 
    }
    
    public func setFrame(in view: UIView, at point: CGPoint, from direction: Direction) {
        self.fromDirection = direction
        
        // Calculate the frame
        
        let size = self.sizeThatFits(CGSize.zero)
        
        var y: CGFloat!
        var x: CGFloat!
        
        switch direction {
        case .above:
            y = point.y - size.height - self.offset
            x = point.x - size.width/2
            break
        case .below:
            y = point.y + self.offset
            x = point.x - size.width/2
        case .left:
            y = point.y - size.height/2
            x = point.x - size.width - self.offset
        case .right:
            y = point.y - size.height/2
            x = point.x + self.offset
        }
        
        let origin = CGPoint(x: x, y: y)
        var frame = CGRect(origin: origin, size: size)
        
        if self.fitToSuperview {
            
            // Adjust frame to keep us off screen edges by the screen margin
            
            if frame.minX < view.bounds.minX {
                frame.origin.x = view.bounds.minX + OnboardingScreenMargin
            }
            if frame.maxX > view.bounds.maxX {
                frame.origin.x = view.bounds.maxX - frame.size.width - OnboardingScreenMargin
            }
            if frame.minY < view.bounds.minY {
                frame.origin.y = view.bounds.minY + OnboardingScreenMargin
            }
            if frame.maxY > view.bounds.maxY {
                frame.origin.y = view.bounds.maxY - frame.size.height - OnboardingScreenMargin
            }
        }
            
        // Update rounded rect constraint constants
        
        self.rectLeftConstraint.constant = 0
        self.rectRightConstraint.constant = 0
        self.rectTopConstraint.constant = 0
        self.rectBottomConstraint.constant = 0
        
        switch direction {
        case .above: self.rectBottomConstraint.constant = -self.arrowSize.height
        case .below: self.rectTopConstraint.constant = self.arrowSize.height
        case .left:  self.rectRightConstraint.constant = -self.arrowSize.height
        case .right: self.rectLeftConstraint.constant = self.arrowSize.height
        }
        
        self.frame = frame
        
        // Move the arrow into place and rotate it with a transform
        
        var rotation: CGFloat!
        var transX: CGFloat!
        var transY: CGFloat!
        
        switch (direction, self.arrowLocation) {
            
        case (.above, .centeredOnPopover):
            transX = 0
            transY = frame.size.height/2 - self.arrowSize.height/2 - 1
            
        case (.above, .centeredOnTarget):
            transX = point.x - frame.midX
            transY = frame.size.height/2 - self.arrowSize.height/2 - 1
            
        case (.below, .centeredOnPopover):
            transX = 0
            transY = -frame.size.height/2 + self.arrowSize.height/2 + 1
            
        case (.below, .centeredOnTarget):
            transX = point.x - frame.midX
            transY = -frame.size.height/2 + self.arrowSize.height/2 + 1
            
        case (.left, .centeredOnPopover):
            transX = frame.size.width/2 - self.arrowSize.height/2 - 1
            transY = 0
            
        case (.left, .centeredOnTarget):
            transX = frame.size.width/2 - self.arrowSize.height/2 - 1
            transY = point.y - frame.midY
            
        case (.right, .centeredOnPopover):
            transX = -frame.size.width/2 + self.arrowSize.height/2 + 1
            transY = 0
            
        case (.right, .centeredOnTarget):
            transX = -frame.size.width/2 + self.arrowSize.height/2 + 1
            transY = point.y - frame.midY
        }
        
        switch direction {
        case .above: rotation = CGFloat.pi
        case .below: rotation = CGFloat(0)
        case .left:  rotation = CGFloat.pi/2
        case .right: rotation = CGFloat.pi*3/2
        }
        
        self.arrowView.transform = CGAffineTransform.identity.translatedBy(x: transX, y: transY).rotated(by: rotation)
    }
}
