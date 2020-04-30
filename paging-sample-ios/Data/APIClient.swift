import Alamofire
import RxSwift

struct APIClient {
    static let shared = Session()
    fileprivate static let decoder: JSONDecoder = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-mm-dd'T'HH:mm:ss'Z'"
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
    static var baseURL: URL {
        get {
            URL(string: "https://api.github.com")!
        }
    }
    private init() { }
}

extension Session {

    func get<T: Decodable>(
        _ relativePath: String,
        parameters: Parameters? = nil,
        encoding: ParameterEncoding = URLEncoding.default,
        headers: HTTPHeaders? = nil,
        interceptor: RequestInterceptor? = nil,
        requestModifier: RequestModifier? = nil,
        type: T.Type) -> Single<T> {
        let url = APIClient.baseURL.appendingPathComponent(relativePath)
        return Single<T>.create { observer in
            let calling = self.request(
                url,
                parameters: parameters,
                encoding: encoding,
                headers: headers,
                interceptor: interceptor,
                requestModifier: requestModifier
            ).responseDecodable(of: T.self, decoder: APIClient.decoder) { response in
                switch response.result {
                case let .success(model):
                    observer(.success(model))
                case let .failure(error):
                    observer(.error(error))
                }
            }
            return Disposables.create { calling.cancel() }
        }
    }
}
