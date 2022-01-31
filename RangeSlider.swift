import UIKit

private enum Const {
    static let trackHeight: CGFloat = 2
    static let knobSize: CGFloat = 28

    static let height: CGFloat = 32
}

final class RangeSlider: UIControl {

    // MARK: - Public properties

    var minimumValue: Double = 0.0 {
        didSet { updateTrackLayerFrameAndKnobPositions() }
    }

    var maximumValue: Double = 10.0 {
        didSet { updateTrackLayerFrameAndKnobPositions() }
    }

    /// The current lower value
    var lowerValue: Double = 0.0 {
        didSet { updateTrackLayerFrameAndKnobPositions() }
    }

    /// The current upper value
    var upperValue: Double = 10.0 {
        didSet { updateTrackLayerFrameAndKnobPositions() }
    }

    /// The minimum value a Knob can change
    var stepValue: Double = 0.0 {
        didSet { updateTrackLayerFrameAndKnobPositions() }
    }

    /// The minimum difference in value between the Knobs
    var minimumDistance: Double = 0.0 {
        didSet { updateTrackLayerFrameAndKnobPositions() }
    }

    /// Whether or not you can drag the highlighted area to move both Knobs at the same time.
    var dragTrack: Bool = true

    // MARK: - Private properties

    private var previousLocation: CGPoint = .zero
    private var previouslySelectedKnobIsUpper: Bool = true

    private let track = RangeSliderTrack()
    private let lowerKnob = RangeSliderKnob()
    private let upperKnob = RangeSliderKnob()

    private var range: Double { maximumValue - minimumValue }

    private var knobsAreClose: Bool = false

    override var frame: CGRect {
        didSet { updateLayerFramesAndPositions() }
    }

    // MARK: - Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        track.rangeSlider = self
        track.contentsScale = UIScreen.main.scale
        layer.addSublayer(track)

        lowerKnob.frame = CGRect(x: 0, y: 0, width: Const.knobSize, height: Const.knobSize)
        lowerKnob.contentsScale = UIScreen.main.scale
        layer.addSublayer(lowerKnob)

        upperKnob.frame = CGRect(x: 0, y: 0, width: Const.knobSize, height: Const.knobSize)
        upperKnob.contentsScale = UIScreen.main.scale
        layer.addSublayer(upperKnob)

        snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(Const.height)
        }
    }

    override func layoutIfNeeded() {
        super.layoutIfNeeded()
        updateLayerFramesAndPositions()
    }

    // MARK: - Private methods

    private func updateLayerFramesAndPositions() {
        lowerKnob.frame = CGRect(x: 0, y: 0, width: Const.knobSize, height: Const.knobSize)
        upperKnob.frame = CGRect(x: 0, y: 0, width: Const.knobSize, height: Const.knobSize)
        updateTrackLayerFrameAndKnobPositions()
    }

    /// Updates the tracks layer frame and the knobs positions.
    private func updateTrackLayerFrameAndKnobPositions() {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        let newTrackDy = (frame.height - Const.trackHeight) / 2
        track.frame = CGRect(x: 0, y: newTrackDy, width: frame.width, height: Const.trackHeight)
        track.setNeedsDisplay()

        lowerKnob.position = positionForValue(lowerValue)
        lowerKnob.setNeedsDisplay()

        upperKnob.position = positionForValue(upperValue)
        upperKnob.setNeedsDisplay()

        CATransaction.commit()
    }

    func positionForValue(_ value: Double) -> CGPoint {
        guard maximumValue > minimumValue else { return .zero }

        let percent = (value - minimumValue) / range
        let knobsDeltaWidth = Const.knobSize - (RangeSliderKnob.shadowOffset * 2)
        let knobDeltaX = knobsDeltaWidth / 2

        let x = percent * (bounds.width - knobsDeltaWidth) + knobDeltaX
        let y = track.frame.midY

        return .init(x: x, y: y)
    }

    private func boundValue(_ value: Double, toLowerValue lowerValue: Double, upperValue: Double) -> Double {
        min(max(value, lowerValue), upperValue)
    }

    // MARK: - Override methods

    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        previousLocation = touch.location(in: self)

        if lowerKnob.frame.contains(previousLocation) && upperKnob.frame.contains(previousLocation) {

            knobsAreClose = upperValue - lowerValue <= minimumDistance
            if knobsAreClose {
                upperKnob.isHighlighted = true
                lowerKnob.isHighlighted = true
                return true
            }

            /// changing the knob to control another one this time
            previouslySelectedKnobIsUpper ? (lowerKnob.isHighlighted = true) : (upperKnob.isHighlighted = true)
            previouslySelectedKnobIsUpper.toggle()
            return true
        }

        if lowerKnob.frame.contains(previousLocation) {
            lowerKnob.isHighlighted = true
            previouslySelectedKnobIsUpper = false
            return true
        }

        if upperKnob.frame.contains(previousLocation) {
            upperKnob.isHighlighted = true
            previouslySelectedKnobIsUpper = true
            return true
        }

        if dragTrack {
            upperKnob.isHighlighted = true
            lowerKnob.isHighlighted = true
            return true
        }

        return false
    }

    override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let location = touch.location(in: self)

        let deltaLocation = Double(location.x - previousLocation.x)
        var deltaValue = (maximumValue - minimumValue) * deltaLocation / Double(bounds.width - Const.knobSize)

        guard abs(deltaValue) >= stepValue else { return true }

        if stepValue != 0 {
            let multiplier = (deltaValue / stepValue).rounded()
            deltaValue = stepValue * multiplier
        }

        previousLocation = location

        if knobsAreClose {
            deltaValue > 0 ? (lowerKnob.isHighlighted = false) : (upperKnob.isHighlighted = false)
            knobsAreClose = false
        }

        if lowerKnob.isHighlighted && upperKnob.isHighlighted {
            let gap = upperValue - lowerValue
            if deltaValue > 0 {
                upperValue = boundValue(upperValue + deltaValue, toLowerValue: lowerValue + gap, upperValue: maximumValue)
                lowerValue = boundValue(lowerValue + deltaValue, toLowerValue: minimumValue, upperValue: upperValue - gap)
            } else {
                lowerValue = boundValue(lowerValue + deltaValue, toLowerValue: minimumValue, upperValue: upperValue - gap)
                upperValue = boundValue(upperValue + deltaValue, toLowerValue: lowerValue + gap, upperValue: maximumValue)
            }
        } else if lowerKnob.isHighlighted {
            lowerValue = boundValue(lowerValue + deltaValue, toLowerValue: minimumValue, upperValue: upperValue - minimumDistance)
        } else if upperKnob.isHighlighted {
            upperValue = boundValue(upperValue + deltaValue, toLowerValue: lowerValue + minimumDistance, upperValue: maximumValue)
        }

        sendActions(for: .valueChanged)
        return true
    }

    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        lowerKnob.isHighlighted = false
        upperKnob.isHighlighted = false
    }

}
