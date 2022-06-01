import UIKit
import Reusable
import RxSwift
import RxCocoa
import RxFlow

class MenuOptionView: UIView, NibOwnerLoadable {
  private let disposeBag = DisposeBag()

  @IBOutlet private var containerView: UIView!
  @IBOutlet private var optionNameLabel: UILabel!
  @IBOutlet private var optionButton: UIButton!

  override init(frame: CGRect) {
    super.init(frame: frame)

    loadNibContent()
    setup()
  }

  required init?(coder: NSCoder) {
    super.init(coder: coder)

    loadNibContent()
    setup()
  }

  func setupView(model: MenuOptionModel, steps: PublishRelay<Step>) {
    optionButton.setImage(
      UIImage(
        named: model.imageName,
        in: Bundle(for: MenuOptionView.self),
        compatibleWith: nil
      ),
      for: .normal
    )
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.lineHeightMultiple = Constants.lineHeightMultiple
    optionNameLabel.attributedText = NSAttributedString(
      string: model.title,
      attributes: [
        .font: Constants.nameOptionFont,
        .kern: Constants.kern,
        .paragraphStyle: paragraphStyle,
        .foregroundColor: Constants.nameOptionTextColor
      ]
    )

    let tapGesture = UITapGestureRecognizer()
    containerView.addGestureRecognizer(tapGesture)

    Observable
      .merge(optionButton.rx.tap.asObservable(), tapGesture.rx.event.map { _ in Void() })
      .map { _ in AppStep.parentNavigationRequired(step: model.step) }
      .debug()
      .bind(to: steps)
      .disposed(by: disposeBag)

    setup()
  }

  private func setup() {
    setupMainView()
    setupOptionButton()
    setupContainerView()
  }

  private func setupMainView() {
    backgroundColor = Constants.mainViewBackgroundColor
  }

  private func setupOptionButton() {
    optionButton.layer.cornerRadius = optionButton.bounds.height / 2
    optionButton.backgroundColor = Constants.buttonBackgroundColor
    optionButton.tintColor = Constants.buttonTintColor
    optionButton.layer.shadowOpacity = Constants.shadowOpacity
    optionButton.layer.shadowRadius = Constants.shadowRadius
    optionButton.layer.shadowOffset = Constants.shadowOffset
    optionButton.layer.shadowColor = Constants.optionButtonShadowColor
    optionButton.setTitle(Constants.emptyString, for: .normal)
  }

  private func setupContainerView() {
    containerView.backgroundColor = Constants.containerBackgroundColor
    containerView.layer.cornerRadius = Constants.containerCornerRadius
  }

  func setDisapperedState(needIdentity: Bool) {
    if needIdentity {
      optionButton.transform = CGAffineTransform.identity
    }

    optionButton.alpha = Constants.startAlpha
    optionButton.transform = Constants.startTransform
    optionNameLabel.alpha = Constants.startAlpha
    containerView.transform = Constants.startTransform
    containerView.alpha = Constants.startAlpha
  }

  func setAppearedState() {
    optionButton.transform = Constants.identityTransform
    optionButton.alpha = Constants.finishAlpha
    containerView.transform = Constants.identityTransform
    containerView.alpha = Constants.finishAlpha
    optionNameLabel.alpha = Constants.finishAlpha
  }

  func setAppearedStateAnimated(with duration: Double) {
    setDisapperedState(needIdentity: true)
    UIView.animate(withDuration: TimeInterval(duration)) { [weak self] in
      guard let self = self else { return }

      self.setAppearedState()
    }
  }

  func setDisappearedStateAnimated(with duration: Double) {
    setAppearedState()
    UIView.animate(withDuration: TimeInterval(duration)) { [weak self] in
      guard let self = self else { return }

      self.setDisapperedState(needIdentity: false)
    }
  }
}

private enum Constants {
  // Strings
  static let emptyString = ""

  // Fonts
  static let nameOptionFont = FontName.roboto.getUIFont(typeFace: .regular, size: 17)

  // Colors
  static let buttonBackgroundColor = UIColor.Blue.Base
  static let nameOptionTextColor = UIColor.Blue.Base
  static let buttonTintColor = UIColor.Blue.Dark1
  static let containerBackgroundColor = UIColor.Blue.Dark2
  static let mainViewBackgroundColor = UIColor.clear
  static let optionButtonShadowColor = UIColor.black.withAlphaComponent(0.4).cgColor

  // Sizes
  static let containerCornerRadius: CGFloat = 18
  static let lineHeightMultiple = 1.1
  static let kern: CGFloat = 0.2

  // Values
  static let shadowRadius: CGFloat = 4
  static let shadowOpacity: Float = 1
  static let shadowOffset = CGSize(width: 0, height: 2)
  static let startTransform = CGAffineTransform(scaleX: 0.01, y: 0.01)
  static let identityTransform = CGAffineTransform.identity
  static let finishAlpha: CGFloat = 1
  static let startAlpha: CGFloat = 0
}
