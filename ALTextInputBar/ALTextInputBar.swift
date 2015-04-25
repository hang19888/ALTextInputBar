//
//  ALTextInputBar.swift
//  ALTextInputBar
//
//  Created by Alex Littlejohn on 2015/04/24.
//  Copyright (c) 2015 zero. All rights reserved.
//

import UIKit

public typealias ALSubmitTextAction = (text: String) -> Void
public typealias ALButtonAction = () -> Void

func defaultNumberOfLines() -> CGFloat {
    return 6
}

public class ALTextInputBar: UIView, ALTextViewDelegate {
    
    /// Used for the intrinsic content size for autolayout
    public var defaultHeight: CGFloat = 44
    
    /// If true the right button will always be visible else it will only show when there is text in the text view
    public var alwaysShowRightButton = false
    
    /// The horizontal padding between the view edges and its subviews
    public var horizontalPadding: CGFloat = 0
    
    /// The horizontal spacing between subviews
    public var horizontalSpacing: CGFloat = 5
    
    /// Set and retrieve the text view text
    public var text: String! {
        get {
            return textView.text
        }
        set(newValue) {
            textView.text = newValue
        }
    }
    
    /** 
    This view will be displayed on the left of the text view.
    
    If this view is nil nothing will be displayed, and the text view will fill the space
    
    */
    public var leftView: UIView? {
        willSet(newValue) {
            if newValue == nil {
                if let view = leftView {
                    view.removeFromSuperview()
                }
            }
        }
        didSet {
            if let view = leftView {
                addSubview(view)
            }
        }
    }
    
    public var rightView: UIView? {
        willSet(newValue) {
            if newValue == nil {
                if let view = rightView {
                    view.removeFromSuperview()
                }
            }
        }
        didSet {
            if let view = rightView {
                addSubview(view)
            }
        }
    }
    
    public let textView: ALTextView = {
        
        let _textView = ALTextView()
        
        _textView.textContainerInset = UIEdgeInsetsMake(1, 0, 1, 0);
        _textView.textContainer.lineFragmentPadding = 0
        
        _textView.maxNumberOfLines = defaultNumberOfLines()
        
        _textView.placeholder = "Type here"
        _textView.placeholderColor = UIColor.lightGrayColor()
        
        _textView.font = UIFont.systemFontOfSize(14)
        _textView.textColor = UIColor.darkGrayColor()

        _textView.backgroundColor = UIColor.clearColor()
        
        // This changes the caret color
        _textView.tintColor = UIColor.lightGrayColor()
        
        return _textView
        }()
    
    private var showRightButton = false
    private var showLeftButton = false
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        addSubview(textView)
        
        textView.textViewDelegate = self
        
        backgroundColor = UIColor.groupTableViewBackgroundColor()
    }
    
    // MARK: - View positioning and layout -

    override public func intrinsicContentSize() -> CGSize {
        return CGSizeMake(UIViewNoIntrinsicMetric, defaultHeight)
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        let size = frame.size
        
        var leftViewSize = CGSizeZero
        var rightViewSize = CGSizeZero
        
        if let view = leftView {
            leftViewSize = view.bounds.size
            
            let leftViewX: CGFloat = horizontalPadding
            let leftViewVerticalPadding = (defaultHeight - leftViewSize.height) / 2
            let leftViewY: CGFloat = size.height - (leftViewSize.height + leftViewVerticalPadding)
            view.frame = CGRectMake(leftViewX, leftViewY, leftViewSize.width, leftViewSize.height)
        }

        if let view = rightView {
            rightViewSize = view.bounds.size
            
            let rightViewVerticalPadding = (defaultHeight - rightViewSize.height) / 2
            var rightViewX = size.width
            let rightViewY = size.height - (rightViewSize.height + rightViewVerticalPadding)
            
            if showRightButton || alwaysShowRightButton {
                rightViewX -= (rightViewSize.width + horizontalPadding)
            }
            
            view.frame = CGRectMake(rightViewX, rightViewY, rightViewSize.width, rightViewSize.height)
        }
        
        let textViewPadding = fabs(defaultHeight - (textView.font.lineHeight + textView.textContainerInset.top + textView.textContainerInset.bottom)) / 2
        var textViewX = horizontalPadding
        let textViewY = textViewPadding
        let textViewHeight = size.height - (textViewPadding * 2)
        var textViewWidth = size.width - (horizontalPadding + horizontalPadding)
        
        if leftViewSize.width > 0 {
            textViewX += leftViewSize.width + horizontalSpacing
            textViewWidth -= leftViewSize.width + horizontalSpacing
        }
        
        if (showRightButton || alwaysShowRightButton) && rightViewSize.width > 0 {
            textViewWidth -= (horizontalSpacing + rightViewSize.width)
        }
        
        textView.frame = CGRectMake(textViewX, textViewY, textViewWidth, textViewHeight)
     
        println(frame)
    }
    
    public func updateViews(animated: Bool) {
        if animated {
            // :discussion: Honestly not sure about the best way to calculated the ideal spring animation duration
            // however these values seem to work for Slack
            // possibly replace with facebook/pop but that opens another can of worms
            UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.7, options: .CurveEaseInOut, animations: {
                self.setNeedsLayout()
                self.layoutIfNeeded()
                }, completion: nil)
            
        } else {
            setNeedsLayout()
            layoutIfNeeded()
        }
    }
    
    // MARK: - ALTextViewDelegate -
    
    public final func textViewHeightChanged(textView: UITextView, newHeight: CGFloat) {
        let height = (defaultHeight - (textView.font.lineHeight + textView.textContainerInset.top + textView.textContainerInset.bottom)) + newHeight
        
        frame.size.height = height
        
        setNeedsLayout()
        layoutIfNeeded()
        
        for c in constraints() {
            var constraint = c as! NSLayoutConstraint
            if constraint.firstAttribute == NSLayoutAttribute.Height {
                constraint.constant = height < defaultHeight ? defaultHeight : height
            }
        }
    }
    
    public final func textViewDidChange(textView: UITextView) {
        setNeedsLayout()
        layoutIfNeeded()
        
        var shouldShowButton = textView.text.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0
        
        if showRightButton != shouldShowButton && !alwaysShowRightButton {
            showRightButton = shouldShowButton
            updateViews(true)
        }
    }
}