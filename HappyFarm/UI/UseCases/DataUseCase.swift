import UIKit

private struct DashbordManagerModel: Decodable {
    let serverData1: String
    let serverData2: String
    
    private enum CodingKeys: String, CodingKey {
        case serverData1 = "serverData1"
        case serverData2 = "serverData2"
    }
}

class DataUseCase {
    func makeRequest(url: URL, coreConfigData: CoreConfigData) async throws -> URL {
        let rawQueryString = """
                appsflyer_id=\(coreConfigData.appsFlyerID ?? "")\
                &app_instance_id=\(coreConfigData.appInstanceID ?? "")\
                &uid=\(coreConfigData.uuid)\
                &osVersion=\(coreConfigData.osVersion)\
                &devModel=\(coreConfigData.devModel)\
                &bundle=\(coreConfigData.bundleID)\
                &fcm_token=\(coreConfigData.fcmToken ?? "")\
                &att_token=\(coreConfigData.attToken ?? "")
                """
                        
        guard let dataToEncode = rawQueryString.data(using: .utf8) else {
            throw DataServiceError.encodingFailed
        }
        
        let base64EncodedString = dataToEncode.base64EncodedString()
                
        guard let baseImageStr = URL(string: url.absoluteString + "?data=" + base64EncodedString) else {
            throw DataServiceError.invalidParametrs(url.absoluteString + "?data=...")
        }
                        
        var request = URLRequest(url: baseImageStr)
        request.httpMethod = "POST"
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw DataServiceError.badServerResponse
        }
                
        let configResponseTestB = try JSONDecoder().decode(DashbordManagerModel.self, from: data)
        
        if configResponseTestB.serverData1.isEmpty || configResponseTestB.serverData2.isEmpty {
            BaseUseCase.shared.finalDataImageString = ""
            throw DataServiceError.invalidURL
        }
        
        let imageStringMain = "https://\(configResponseTestB.serverData1)\(configResponseTestB.serverData2)"
        
        guard let dataImageURL = URL(string: imageStringMain) else {
            throw DataServiceError.invalidParametrs(imageStringMain)
        }
                
        UserDefaults.standard.set(imageStringMain, forKey: "mainPropertyKeyKey")
        BaseUseCase.shared.finalDataImageString = imageStringMain

        return dataImageURL
    }
}

// MARK: - Обработка Ошибок
enum DataServiceError: Error, LocalizedError {
    case invalidURL
    case badServerResponse
    case encodingFailed
    case invalidParametrs(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "invalidURL"
        case .badServerResponse:
            return "badServerResponse"
        case .invalidParametrs(let url):
            return "invalidURL \(url)"
        case .encodingFailed:
            return "encodingFailed"
        }
    }
}
