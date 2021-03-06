//
//  TinyConsoleController.swift
//  TinyConsole
//
//  Created by Devran Uenal on 28.11.16.
//
//

import UIKit

open class TinyConsoleController: UIViewController {
    
    /// the kind of window modes that are supported by TinyConsole
    ///
    /// - collapsed: the console is hidden
    /// - expanded: the console is shown
    public enum WindowMode: Int, CustomStringConvertible {
        case collapsed = 0
        case expanded
        
        public var description: String {
            switch self {
            case .collapsed:
                return "Collapsed"
            case .expanded:
                return "Expanded"
            }
        }
    }
    
    // MARK: - Private Properties -
    public var rootViewController: UIViewController
    
    private var consoleViewController: TinyConsoleViewController = {
        return TinyConsoleViewController()
    }()
    
    private lazy var consoleViewHeightConstraint: NSLayoutConstraint? = {
        if #available(iOS 9, *) {
            return self.consoleViewController.view.heightAnchor.constraint(equalToConstant: 0)
        } else {
            return NSLayoutConstraint(item: self.consoleViewController.view, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 0)
        }
    }()
    
    private let consoleFrameHeight: CGFloat = 120
    private let expandedHeight: CGFloat = 140
    
    private lazy var consoleFrame: CGRect = {
        
        var consoleFrame = self.view.bounds
        consoleFrame.size.height -= self.consoleFrameHeight
        
        return consoleFrame
    }()
    
    // MARK: - Initializer -
    public init(rootViewController: UIViewController) {
        self.rootViewController = rootViewController
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        assertionFailure("Interface Builder is not supported")
        self.rootViewController = UIViewController()
        super.init(coder: aDecoder)
    }
    
    // MARK: - Public Methods -
    public var shakeEnabled: Bool = true
    
    public var consoleWindowMode: WindowMode = .collapsed {
        didSet {
            consoleViewHeightConstraint?.isActive = false
            consoleViewHeightConstraint?.constant = consoleWindowMode == .collapsed ? 0 : self.expandedHeight
            consoleViewHeightConstraint?.isActive = true
        }
    }
    
    public func update(windowMode: WindowMode, animated: Bool) {
        consoleWindowMode = windowMode
        if animated == true {
            UIView.animate(withDuration: 0.25) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        addChild(consoleViewController)
        consoleViewController.view.frame = consoleFrame
        view.addSubview(consoleViewController.view)
        consoleViewController.didMove(toParent: self)
        
        addChild(rootViewController)
        rootViewController.view.frame = CGRect(x: consoleFrame.minX, y: consoleFrame.maxY, width: view.bounds.width, height: 120)
        view.addSubview(rootViewController.view)
        rootViewController.didMove(toParent: self)
        
        setupConstraints()
    }
    
    open override func motionBegan(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if (motion == UIEvent.EventSubtype.motionShake && shakeEnabled == true) {
            self.update(windowMode: (consoleWindowMode == .collapsed ? .expanded : .collapsed), animated: true)
        }
    }
    
    open override var childForStatusBarHidden: UIViewController? {
        get {
            return self.rootViewController
        }
    }
    
    open override var childForStatusBarStyle: UIViewController? {
        get {
            return self.rootViewController
        }
    }
    
    open override var prefersStatusBarHidden: Bool {
        get {
            return self.rootViewController.prefersStatusBarHidden
        }
    }
    
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        get {
            return self.rootViewController.preferredStatusBarStyle
        }
    }
    
    // MARK: - Private Methods -
    private func setupConstraints() {
        
        rootViewController.view.attach(anchor: .top, to: view)
        
        consoleViewController.view.attach(anchor: .bottom, to: view)
        consoleViewHeightConstraint?.isActive = true
        
        if #available(iOS 9, *) {
            
            rootViewController.view.bottomAnchor.constraint(equalTo: consoleViewController.view.topAnchor).isActive = true
        } else {
            
            NSLayoutConstraint(item: (rootViewController.view)!,
                               attribute: .bottom,
                               relatedBy: .equal,
                               toItem: consoleViewController.view,
                               attribute: .top,
                               multiplier: 1.0,
                               constant: 0)
                .isActive = true
        }
    }
}

fileprivate extension UIView {
    
    enum Anchor {
        case top
        case bottom
    }
    
    func attach(anchor: Anchor, to view: UIView) {
        
        translatesAutoresizingMaskIntoConstraints = false
        
        if #available(iOS 9, *) {
            
            switch anchor {
            case .top:
                topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            case .bottom:
                bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            }
            
            leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
            rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
            
        } else {
            
            switch anchor {
            case .top:
                NSLayoutConstraint(item: self,
                                   attribute: .top,
                                   relatedBy: .equal,
                                   toItem: view,
                                   attribute: .top,
                                   multiplier: 1.0,
                                   constant: 0)
                    .isActive = true
            case .bottom:
                NSLayoutConstraint(item: self,
                                   attribute: .bottom,
                                   relatedBy: .equal,
                                   toItem: view,
                                   attribute: .bottom,
                                   multiplier: 1.0,
                                   constant: 0)
                    .isActive = true
            }
            
            // left anchor
            NSLayoutConstraint(item: self,
                               attribute: .left,
                               relatedBy: .equal,
                               toItem: view,
                               attribute: .left,
                               multiplier: 1.0,
                               constant: 0)
                .isActive = true
            // right anchor
            NSLayoutConstraint(item: self,
                               attribute: .right,
                               relatedBy: .equal,
                               toItem: view,
                               attribute: .right,
                               multiplier: 1.0,
                               constant: 0)
                .isActive = true
        }
    }
}
