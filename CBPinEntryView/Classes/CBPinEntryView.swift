//
//  CBPinEntryView.swift
//  Pods
//
//  Created by Chris Byatt on 18/03/2017.
//
//

import UIKit

public protocol CBPinEntryViewDelegate: class {
    func entryChanged(_ completed: Bool)
}

@IBDesignable open class CBPinEntryView: UIView {

    @IBInspectable open var length: Int = CBPinEntryViewDefaults.length
    
    @IBInspectable open var spacing: CGFloat = CBPinEntryViewDefaults.spacing

    @IBInspectable open var entryCornerRadius: CGFloat = CBPinEntryViewDefaults.entryCornerRadius {
        didSet {
            if oldValue != entryCornerRadius {
                updateButtonStyles()
            }
        }
    }

    @IBInspectable open var entryBorderWidth: CGFloat = CBPinEntryViewDefaults.entryBorderWidth {
        didSet {
            if oldValue != entryBorderWidth {
                updateButtonStyles()
            }
        }
    }

    @IBInspectable open var entryDefaultBorderColour: UIColor = CBPinEntryViewDefaults.entryDefaultBorderColour {
        didSet {
            if oldValue != entryDefaultBorderColour {
                updateButtonStyles()
            }
        }
    }

    @IBInspectable open var entryBorderColour: UIColor = CBPinEntryViewDefaults.entryBorderColour {
        didSet {
            if oldValue != entryBorderColour {
                updateButtonStyles()
            }
        }
    }

    @IBInspectable open var entryErrorBorderColour: UIColor = CBPinEntryViewDefaults.entryErrorColour

    @IBInspectable open var entryBackgroundColour: UIColor = CBPinEntryViewDefaults.entryBackgroundColour {
        didSet {
            if oldValue != entryBackgroundColour {
                updateButtonStyles()
            }
        }
    }

    @IBInspectable open var entryTextColour: UIColor = CBPinEntryViewDefaults.entryTextColour {
        didSet {
            if oldValue != entryTextColour {
                updateButtonStyles()
            }
        }
    }

    @IBInspectable open var entryFont: UIFont = CBPinEntryViewDefaults.entryFont {
        didSet {
            if oldValue != entryFont {
                updateButtonStyles()
            }
        }
    }

    @IBInspectable open var isSecure: Bool = CBPinEntryViewDefaults.isSecure

    @IBInspectable open var secureCharacter: String = CBPinEntryViewDefaults.secureCharacter

    @IBInspectable open var keyboardType: Int = CBPinEntryViewDefaults.keyboardType

    private var stackView: UIStackView!
    private var textField: UITextField!

    fileprivate var errorMode: Bool = false

    fileprivate var entryLabels: [UILabel] = []

    public weak var delegate: CBPinEntryViewDelegate?

    override public init(frame: CGRect) {
        super.init(frame: frame)

        commonInit()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override open func awakeFromNib() {
        super.awakeFromNib()

        commonInit()
    }

    override open func prepareForInterfaceBuilder() {
        commonInit()
    }


    private func commonInit() {
        setupStackView()
        setupTextField()
        setupGestures()
        
        createLabels()
    }

    private func setupStackView() {
        stackView = UIStackView(frame: bounds)
        stackView.alignment = .fill
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = spacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(stackView)
        
        stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0).isActive = true
        stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0).isActive = true
        stackView.topAnchor.constraint(equalTo: topAnchor, constant: 0).isActive = true
        stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0).isActive = true
    }

    private func setupTextField() {
        textField = UITextField(frame: bounds)
        textField.delegate = self
        textField.keyboardType = UIKeyboardType(rawValue: keyboardType) ?? .numberPad
        textField.addTarget(self, action: #selector(textfieldChanged(_:)), for: .editingChanged)

        addSubview(textField)

        textField.isHidden = true
    }
    
    private func setupGestures() {
        isUserInteractionEnabled = true
        setupTap()
        setupLongPress()
    }
    
    private func setupTap() {
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture))
        addGestureRecognizer(gestureRecognizer)
    }
    
    @objc
    private func handleTapGesture() {
        textField.becomeFirstResponder()
    }
    
    private func setupLongPress() {
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressGesture(recognizer:)))
        addGestureRecognizer(gestureRecognizer)
    }
    
    @objc
    private func handleLongPressGesture(recognizer: UIGestureRecognizer) {
        guard recognizer.state == .began else { return }
        
        if let recognizerView = recognizer.view,
           let recognizerSuperView = recognizerView.superview,
           recognizerView.becomeFirstResponder() {
            let menuController = UIMenuController.shared
            menuController.setTargetRect(recognizerView.frame, in: recognizerSuperView)
            menuController.setMenuVisible(true, animated: true)
        }
    }

    private func createLabels() {
        for i in 0..<length {
            let label = UILabel()
            label.backgroundColor = entryBackgroundColour
            label.textColor = entryTextColour
            label.font = entryFont
            label.textAlignment = .center
            
            label.tag = i + 1

            label.layer.cornerRadius = entryCornerRadius
            label.layer.borderColor = entryDefaultBorderColour.cgColor
            label.layer.borderWidth = entryBorderWidth

            entryLabels.append(label)
            stackView.addArrangedSubview(label)
        }
    }

    private func updateButtonStyles() {
        for label in entryLabels {
            label.backgroundColor = entryBackgroundColour
            label.textColor = entryTextColour
            label.font = entryFont

            label.layer.cornerRadius = entryCornerRadius
            label.layer.borderColor = entryDefaultBorderColour.cgColor
            label.layer.borderWidth = entryBorderWidth
        }
    }

    open func toggleError() {
        if !errorMode {
            for label in entryLabels {
                label.layer.borderColor = entryErrorBorderColour.cgColor
                label.layer.borderWidth = entryBorderWidth
            }
        } else {
            for label in entryLabels {
                label.layer.borderColor = entryBorderColour.cgColor
            }
        }

        errorMode = !errorMode
    }

    open func getPinAsInt() -> Int? {
        if let intOutput = Int(textField.text!) {
            return intOutput
        }

        return nil
    }

    open func getPinAsString() -> String {
        return textField.text!
    }
    
    @discardableResult open override func resignFirstResponder() -> Bool {
        super.resignFirstResponder()
        
        entryLabels.forEach {
            $0.layer.borderColor = entryDefaultBorderColour.cgColor
        }
        
        return textField.resignFirstResponder()
    }
}

extension CBPinEntryView: UITextFieldDelegate {
    @objc func textfieldChanged(_ textField: UITextField) {
        let complete: Bool = textField.text!.count == length
        delegate?.entryChanged(complete)
    }

    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        errorMode = false
        for label in entryLabels {
            label.layer.borderColor = entryBorderColour.cgColor
        }

        let deleting = (range.location == textField.text!.count - 1 && range.length == 1 && string == "")

        if string.count > 0 && !Scanner(string: string).scanInt(nil) {
            return false
        }

        let oldLength = textField.text!.count
        let replacementLength = string.count
        let rangeLength = range.length

        let newLength = oldLength - rangeLength + replacementLength

        if !deleting {
            for label in entryLabels {
                if label.tag == newLength {
                    label.layer.borderColor = entryDefaultBorderColour.cgColor
                    if !isSecure {
                        label.text = string
                    } else {
                        label.text = secureCharacter
                    }
                } else if label.tag == newLength + 1 {
                    label.layer.borderColor = entryBorderColour.cgColor
                } else {
                    label.layer.borderColor = entryDefaultBorderColour.cgColor
                }
            }
        } else {
            for label in entryLabels {
                if label.tag == oldLength {
                    label.layer.borderColor = entryBorderColour.cgColor
                    label.text = ""
                } else {
                    label.layer.borderColor = entryDefaultBorderColour.cgColor
                }
            }
        }

        return newLength <= length
    }
}

// Paste support
extension CBPinEntryView {
    open override var canBecomeFirstResponder: Bool {
        return true
    }
    
    open override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return action == #selector(UIResponderStandardEditActions.paste(_:)) && validPasteboardContent() != nil
    }
    
    private func validPasteboardContent() -> String? {
        guard let content = UIPasteboard.general.string, validate(content: content) else {
            return nil
        }
        
        return content
    }
    
    private func validate(content: String) -> Bool {
        return Int(content) != nil
    }
    
    open override func paste(_ sender: Any?) {
        if let content = validPasteboardContent() {
            paste(newContent: content)
        }
    }
    
    private func paste(newContent: String) {
        var i = 0
        for c in newContent {
            if i >= entryLabels.count {
                break
            }
            
            let label = entryLabels[i]
            label.text = String(c)
            
            i += 1
        }
        
        textField.text = newContent
        textfieldChanged(textField)
    }
}
