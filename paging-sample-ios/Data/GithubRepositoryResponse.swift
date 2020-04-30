import Foundation

struct GithubRepositoryResponse: Codable {
    struct Item: Codable {
        struct Owner: Codable {
            let avatarUrl: String
            let login: String
        }
        let name: String
        let owner: Owner
        let description: String?
        let stargazersCount: Int
        let forksCount: Int
        let watchersCount: Int
        let createdAt: Date
        let updatedAt: Date

        // Server response does not contain this property
        var liked: Bool = false

        private enum CodingKeys: String, CodingKey {
            case name, owner, description, stargazersCount, forksCount, watchersCount, createdAt, updatedAt
        }
    }
    let totalCount: Int?
    let items: [Item]
}
