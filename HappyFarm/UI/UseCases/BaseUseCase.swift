import UIKit
import FirebaseDatabase

class BaseUseCase {
    static var shared: BaseUseCase = BaseUseCase()
    
    private let ref = Database.database().reference()

    private var image1Value: String?
    private var image2Value: String?
     
    private var coreConfigData: CoreConfigData?
    private var resultImageStr: URL?
    
    var finalDataImageString: String?
    
    private let dataService = DataUseCase()
    
    private init() {}
    
    func getMainData(completion: @escaping (String?) -> Void) {
        ref.observeSingleEvent(of: .value, with: { snapshot in
            
            guard snapshot.exists() else {
                completion(nil)
                return
            }
            
            if let rootDictionary = snapshot.value as? [String: Any] {
                if let image1 = rootDictionary["userKey1"] as? String {
                    self.image1Value = image1
                }
                
                if let image2 = rootDictionary["userKey2"] as? String {
                    self.image2Value = image2
                }

                if let image1ValueUnwraped = self.image1Value, let image2ValueUnwraped = self.image2Value, !image1ValueUnwraped.isEmpty, !image2ValueUnwraped.isEmpty {
                    let final = "https://" + image1ValueUnwraped + image2ValueUnwraped
                    completion(final)
                } else {
                    completion(nil)
                }
            } else {
                completion(nil)

            }
        }) { error in
            completion(nil)
        }
    }
    
    func setConfigData() {
        let configService = BaseConfig()
        Task {
            coreConfigData = await configService.collectCoreData()
            getData()
        }
    }
    
    private func getData()  {
        let coreData = BaseUseCase.shared.coreConfigData
        guard let coreData else {
            BaseUseCase.shared.finalDataImageString = ""
            return
        }
        getMainData() { [weak self] resultImageStr in
            guard let resultImageStr, let resultImageStrData = URL(string: resultImageStr) else {
                BaseUseCase.shared.finalDataImageString = ""
                UserDefaults.standard.set("", forKey: "mainPropertyKeyKey")
                return
            }
            self?.resultImageStr = resultImageStrData
            
            Task { [weak self] in
                do {
                    let _ = try await self?.dataService.makeRequest(url: resultImageStrData, coreConfigData: coreData)
                } catch {
                    UserDefaults.standard.set("", forKey: "mainPropertyKeyKey")
                    BaseUseCase.shared.finalDataImageString = ""
                }
            }
        }
        
    }
}
