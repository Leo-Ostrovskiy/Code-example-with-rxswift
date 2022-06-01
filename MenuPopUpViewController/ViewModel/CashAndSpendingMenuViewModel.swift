import RxCocoa
import RxSwift
import RxFlow

public class CashAndSpendingMenuViewModel: RxViewModelProtocol, Stepper {
  struct Input {
    let onCloseButtonTap: PublishRelay<Void>
  }

  struct Output {
    let menuItems: Driver<[MenuOptionModel]>
  }

  private(set) var input: Input!
  private(set) var output: Output!

  // Input
  private let onCloseButtonTap = PublishRelay<Void>()

  // Output
  private let menuItems = BehaviorSubject<[MenuOptionModel]>(
    value: [
      MenuOptionModel(
        imageName: IcNames.IcCash,
        title: "CashAndSpendingMenuViewModel.UpdateAccountBalance.Title".localizationString,
        step: AppStep.updateAccountBalanceRequired
      )
    ]
  )

  private let disposeBag = DisposeBag()
  public var steps = PublishRelay<Step>()

  init() {
    input = Input(onCloseButtonTap: onCloseButtonTap)
    output = Output(menuItems: menuItems.asDriver(onErrorJustReturn: []))

    bindOnCloseButtonTap()
  }

  private func bindOnCloseButtonTap() {
    onCloseButtonTap
      .map {
        AppStep.goBack
      }
      .bind(to: steps)
      .disposed(by: disposeBag)
  }
}
