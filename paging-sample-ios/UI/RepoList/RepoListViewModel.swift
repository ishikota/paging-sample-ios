import Foundation
import RxCocoa
import RxSwift

class RepoListViewModel {
    private weak var view: RepoListViewController!
    private let useCase: RepoListUseCase
    private(set) var viewState: Driver<RepoListViewState>!

    init(view: RepoListViewController, useCase: RepoListUseCase) {
        self.view = view
        self.useCase = useCase

        var page = 1
        let pagingNetworkState  =  BehaviorRelay<PagingNetworkState>(value: .idle)

        let loadMoreTrigger = view.duplicatableLoadMoreTrigger.asObservable()
            .withLatestFrom(pagingNetworkState)
            .filter { $0.isIdle }  // Ignore event while isLoading
            .map { _ in }

        let loadItems = Observable.merge(view.fetchTrigger.asObservable(), loadMoreTrigger.asObservable(), view.retryTrigger.asObservable())
            .flatMap { _ -> Observable<RepoListPagingData> in
                pagingNetworkState.accept(.loading)
                return useCase.fetchItems(page: page).asObservable().catchError { error in
                    pagingNetworkState.accept(.error)
                    print("catch error so return empty")
                    return .empty()
                }
        }.map(RepoListViewState.MutatingContext.fetchItems)

        let refreshItems = view.refreshTrigger.asObservable()
            .do(onNext: { _ in
                page = 1
            }, onError: { _ in
                pagingNetworkState.accept(.error)
            })
            .flatMap { _ -> Observable<RepoListPagingData> in
                return useCase.fetchItems(page: page).asObservable().catchErrorJustReturn(RepoListPagingData.empty)
        }.map(RepoListViewState.MutatingContext.refreshItems)

        let viewStateWithoutPagingNetworkState = Observable.merge(loadItems, refreshItems)
            .scan(into: RepoListViewState.empty) { viewState, mutatingContext in
                viewState.mutatingContext = mutatingContext
                switch mutatingContext {
                case .initialized:
                    assertionFailure("never called")
                case let .fetchItems(pagingData):
                    viewState.items += pagingData.items
                    page += 1
                    if pagingData.reachedLast {
                        pagingNetworkState.accept(.reachedLast)
                    } else {
                        pagingNetworkState.accept(.idle)
                    }
                case let .refreshItems(pagingData):
                    viewState.items = pagingData.items
                    page += 1
                    pagingNetworkState.accept(.idle)
                }
        }.startWith(RepoListViewState.empty)

        viewState = Observable.combineLatest(pagingNetworkState, viewStateWithoutPagingNetworkState) { pagingNetworkState, viewState in
            var viewState = viewState
            viewState.pagingNetworkState = pagingNetworkState
            return viewState
        }.asDriver(onErrorDriveWith: .empty())
    }
}
