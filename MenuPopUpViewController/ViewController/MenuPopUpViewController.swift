import UIKit
import RxSwift
import RxCocoa

class MenuPopUpViewController: UIViewController {
  override var preferredStatusBarStyle: UIStatusBarStyle {
    .lightContent
  }

  var viewModel: CashAndSpendingMenuViewModel!
  private var optionViewsCollection: [MenuOptionView] = []
  private let disposeBag = DisposeBag()

  @IBOutlet private var closeButton: UIButton!

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }

  init() {
    super
      .init(
        nibName: String(
          describing: MenuPopUpViewController.self
        ),
        bundle: Bundle(for: MenuPopUpViewController.self)
      )
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    setup()
    setupBindings()
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)

    startAppearingAnimation()
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)

    animateDismissingAnimation()
  }

  private func setup() {
    setupMainView()
    setupCloseButton()
  }

  private func setupMainView() {
    view.backgroundColor = Constants.mainViewBackgroundColor
    let tapGesture = UITapGestureRecognizer()
    view.addGestureRecognizer(tapGesture)
    tapGesture.rx.event
      .map { _ in AppStep.goBack }
      .bind(to: viewModel.steps)
      .disposed(by: disposeBag)
  }

  private func setupCloseButton() {
    closeButton.isUserInteractionEnabled = true
    closeButton.backgroundColor = Constants.closeButtonBackgroundColor
    closeButton.tintColor = Constants.closeButtonTintColor
    closeButton.layer.cornerRadius = closeButton.bounds.height / 2
    closeButton.layer.shadowOpacity = Constants.shadowOpacity
    closeButton.layer.shadowRadius = Constants.shadowRadius
    closeButton.layer.shadowOffset = Constants.shadowOffset
    closeButton.layer.shadowColor = Constants.closeButtonShadowColor
    closeButton.setImage(
      UIImage(
        named: IcNames.IcClose,
        in: Bundle(for: MenuPopUpViewController.self),
        compatibleWith: nil
      ),
      for: .normal
    )

    closeButton.transform = CGAffineTransform(rotationAngle: Constants.startRotationAngle)
  }

  private func setupBindings() {
    bindCloseButton()
    bindMenuItems()
  }

  private func bindCloseButton() {
    closeButton.rx.tap
      .bind(to: viewModel.input.onCloseButtonTap)
      .disposed(by: disposeBag)
  }

  private func bindMenuItems() {
    viewModel.output.menuItems
      .drive { [weak self] cellModelArray in
        guard let self = self else { return }

        cellModelArray.forEach {
          self.optionViewsCollection.append(self.setupCell(with: $0))
        }
      }
      .disposed(by: disposeBag)

    optionViewsCollection.forEach {
      view.addSubview($0)
      $0.layoutIfNeeded()
    }
  }

  private func setupCell(with model: MenuOptionModel) -> MenuOptionView {
    let optionView = MenuOptionView(
      frame: CGRect(
        x: 0,
        y: UIScreen.main.bounds.height - Constants.bottomSpace,
        width: UIScreen.main.bounds.width,
        height: Constants.optionViewHeight
      )
    )
    optionView.setupView(model: model, steps: viewModel.steps)
    optionView.setDisapperedState(needIdentity: true)
    optionView.isUserInteractionEnabled = true
    return optionView
  }

  private func startAppearingAnimation() {
    animateMainView(finishMainViewBackgroundColor: Constants.endMainViewBackgroundColor)
    animateCloseButton(finishAngle: CGAffineTransform(rotationAngle: Constants.endRotationAngle))
    animateOptionViews(stepLength: -Constants.optionViewHeight)
  }

  private func animateDismissingAnimation() {
    animateMainView(finishMainViewBackgroundColor: Constants.mainViewBackgroundColor)
    animateCloseButton(finishAngle: CGAffineTransform(rotationAngle: Constants.startRotationAngle))
    animateOptionViews(stepLength: Constants.optionViewHeight)
  }

  private func animateMainView(finishMainViewBackgroundColor: UIColor) {
    UIView.animate(withDuration: Constants.viewAppearingDuration) { [weak self] in
      guard let self = self else { return }

      self.view.backgroundColor = finishMainViewBackgroundColor
    }
  }

  private func animateOptionViews(stepLength: CGFloat) {
    var yViewPosition = closeButton.frame.minY + stepLength
    optionViewsCollection.forEach { view in
      UIView.animate(withDuration: Constants.viewAppearingDuration) {
        view.frame = CGRect(x: view.frame.minX, y: yViewPosition, width: view.frame.width, height: view.frame.height)
        view.layoutIfNeeded()
      }

      stepLength < 0
      ? view.setAppearedStateAnimated(with: Constants.viewAppearingDuration)
      : view.setDisappearedStateAnimated(with: Constants.viewAppearingDuration)
      yViewPosition += stepLength
    }
  }

  private func animateCloseButton(finishAngle: CGAffineTransform) {
    UIView.animate(withDuration: Constants.viewAppearingDuration) { [weak self] in
      guard let self = self else { return }

      self.closeButton.transform = finishAngle
    }
  }
}

private enum Constants {
  // Colors
  static let closeButtonBackgroundColor = UIColor.Blue.Dark2
  static let closeButtonTintColor = UIColor.white
  static let closeButtonShadowColor = UIColor.black.withAlphaComponent(0.4).cgColor
  static let mainViewBackgroundColor = UIColor.black.withAlphaComponent(0)
  static let endMainViewBackgroundColor = UIColor.black.withAlphaComponent(0.4)

  // Values
  static let shadowRadius: CGFloat = 4
  static let shadowOpacity: Float = 1
  static let shadowOffset = CGSize(width: 0, height: 2)
  static let optionViewHeight: CGFloat = 64
  static let viewAppearingDuration = 0.3
  static let startRotationAngle: CGFloat = -.pi / 4
  static let endRotationAngle: CGFloat = .pi / 2
  static let bottomSpace: CGFloat = 148
}
