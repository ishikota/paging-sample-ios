import Foundation
import RxSwift

struct RepoListPagingData {
    var items: [GithubRepositoryResponse.Item]
    var reachedLast: Bool

    static let empty = RepoListPagingData(items: [], reachedLast: false)
}

struct RepoListUseCase {
    private let repo: GithubRepository

    init(repo: GithubRepository) {
        self.repo = repo
    }

    func fetchItems(page: Int) -> Single<RepoListPagingData> {
        if Bool.random() {
            return Single.error(NSError(domain: "dummy", code: 0, userInfo: nil)).delay(.seconds(1), scheduler: MainScheduler.instance)
        }
        return repo.fetch(page: page).map { response in
            RepoListPagingData(items: response.items, reachedLast: page == 10)
        }
    }
}
