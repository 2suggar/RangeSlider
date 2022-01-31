import UIKit

private enum Const {
    static let tintColor: UIColor = .lightBlue
    static let backgroundColor: UIColor = .rangeSliderTrackBackground
}

class RangeSliderTrack: CALayer {

    // MARK: - Public properties

    weak var rangeSlider: RangeSlider?

    // MARK: - Lifecycle

    override func draw(in context: CGContext) {
        guard let slider = rangeSlider else { return }

        let path = UIBezierPath(roundedRect: bounds, cornerRadius: bounds.height / 2.0)
        context.setFillColor(Const.backgroundColor.cgColor)
        context.addPath(path.cgPath)
        context.fillPath()

        context.setFillColor(Const.tintColor.cgColor)
        let lowerValuePosition = slider.positionForValue(slider.lowerValue).x
        let upperValuePosition = slider.positionForValue(slider.upperValue).x
        let rect = CGRect(x: lowerValuePosition, y: 0.0, width: upperValuePosition - lowerValuePosition, height: bounds.height)
        context.fill(rect)
  }
}
