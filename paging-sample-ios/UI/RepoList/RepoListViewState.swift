import Foundation

struct RepoListViewState {
    enum MutatingContext {
        case initialized
        case fetchItems(RepoListPagingData)
        case refreshItems(RepoListPagingData)
        case updateLike(UpdateLikeResult)
    }
    var items: [GithubRepositoryResponse.Item]
    var mutatingContext: MutatingContext
    var pagingNetworkState: PagingNetworkState

    static let empty = RepoListViewState(items: [], mutatingContext: .initialized, pagingNetworkState: .idle)
}
