import Foundation
import RxSwift

protocol GithubRepositoryProtcol {
    func fetch(page: Int) -> Single<[GithubRepositoryResponse.Item]>
}

struct GithubRepository: GithubRepositoryProtcol {
    func fetch(page: Int) -> Single<[GithubRepositoryResponse.Item]> {
        let path = "search/repositories"
        let parameters: [String: Any] = ["q": "swift", "sort": "stars", "page": page]
        return APIClient.shared
            .get(path, parameters: parameters, type: GithubRepositoryResponse.self)
            .map { $0.items }
    }
}
