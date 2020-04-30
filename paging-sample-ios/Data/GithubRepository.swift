import Foundation
import RxSwift

protocol GithubRepositoryProtcol {
    func fetch(page: Int) -> Single<GithubRepositoryResponse>
}

struct GithubRepository: GithubRepositoryProtcol {
    func fetch(page: Int) -> Single<GithubRepositoryResponse> {
        let path = "search/repositories"
        let parameters: [String: Any] = ["q": "swift", "sort": "stars", "page": page]
        return APIClient.shared
            .get(path, parameters: parameters, type: GithubRepositoryResponse.self)
    }
}
