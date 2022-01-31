import UIKit

private enum Const {
    static let shadowColor: UIColor = UIColor(white: 0, alpha: 0.16)
    static let borderColor: UIColor = .init(white: 0, alpha: 0.04)
    static let backgroundColor: UIColor = .white

    static let border: CGFloat = 0.5
    static let shadowOffset: CGFloat = 2.0
}

class RangeSliderKnob: CALayer {

    // MARK: - Public properties

    static var shadowOffset: CGFloat { Const.shadowOffset }

    var isHighlighted: Bool = false {
        didSet {
            opacity = isHighlighted ? 0.88 : 1
            if let superLayer = superlayer, isHighlighted {
                removeFromSuperlayer()
                superLayer.addSublayer(self)
            }
        }
    }

    // MARK: - Lifecycle

    override func draw(in context: CGContext) {
        let knobFrame = bounds.insetBy(dx: RangeSliderKnob.shadowOffset, dy: RangeSliderKnob.shadowOffset)
        let cornerRadius = knobFrame.height / 2
        let knobPath = UIBezierPath(roundedRect: knobFrame, cornerRadius: cornerRadius)

        context.setShadow(offset: CGSize(width: 0.0, height: Const.shadowOffset), blur: 1.0, color: Const.shadowColor.cgColor)
        context.setFillColor(Const.backgroundColor.cgColor)
        context.addPath(knobPath.cgPath)
        context.fillPath()

        context.setStrokeColor(Const.borderColor.cgColor)
        context.setLineWidth(Const.border)
        context.addPath(knobPath.cgPath)
        context.strokePath()
    }
}
