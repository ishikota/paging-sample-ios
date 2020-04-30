import Foundation
import RxSwift

protocol GithubRepositoryProtcol {
    func fetch(page: Int) -> Single<GithubRepositoryResponse>
}

struct UpdateLikeResult {
    var id: String
    var newState: Bool
}

struct GithubRepository: GithubRepositoryProtcol {
    func fetch(page: Int) -> Single<GithubRepositoryResponse> {
        let path = "search/repositories"
        let parameters: [String: Any] = ["q": "swift", "sort": "stars", "page": page]
        return APIClient.shared
            .get(path, parameters: parameters, type: GithubRepositoryResponse.self)
    }

    func updateLike(id: String) -> Single<UpdateLikeResult> {
        return Single<UpdateLikeResult>.create { observer in
            observer(.success(UpdateLikeResult(id: id, newState: Bool.random())))
            return Disposables.create()
        }.delay(.milliseconds(3000), scheduler: MainScheduler.instance)
    }
}
