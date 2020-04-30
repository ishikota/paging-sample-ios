import Foundation

struct RepoListViewBuilder {
    static func build() -> RepoListViewController {
        let viewController = RepoListViewController()
        let useCase = RepoListUseCase(repo: GithubRepository())
        let viewModel = RepoListViewModel(view: viewController, useCase: useCase)
        viewController.inject(viewModel: viewModel)
        return viewController
    }
}
