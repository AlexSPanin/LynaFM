//
//  LynaFMApp.swift
//  Shared
//
//  Created by Александр Панин on 18.01.2023.
//
import SwiftUI
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()

    return true
  }
}
// активность приложения
class AppState: ObservableObject {
    @Published var isActive = true

    private var observers = [NSObjectProtocol]()

    init() {
        observers.append(
            NotificationCenter.default.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: .main) { _ in
                self.isActive = true
            }
        )
        observers.append(
            NotificationCenter.default.addObserver(forName: UIApplication.willResignActiveNotification, object: nil, queue: .main) { _ in
                self.isActive = false
            }
        )
    }
    
    deinit {
        observers.forEach(NotificationCenter.default.removeObserver)
    }
}

@main
struct LynaFMApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(AppState())
                .onAppear {
                    print("System Parameters:")
                    print(Bundle.main.displayName)
                    print(Bundle.main.appVersion)
                    print(Bundle.main.appBuild)
                    print(UIDevice.current.systemVersion)
                    print(UIDevice.current.modelName)
                    print(UIScreen.main.scale)
                    print(UIScreen.main.nativeScale)
                    print(UIScreen.main.bounds)
                }
        }
    }
}
