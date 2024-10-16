//
//  StackRouter.swift
//  SpotHopper
//
//  Created by Benjamin Golic on 08.05.24.
//

import Foundation
import SwiftUI

struct StackRouter<Content: View>: View {
  @State var router = Router()
  var content: () -> Content
  
  var body: some View {
    NavigationStack(path: $router.path) {
      content()
        .navigationDestination(for: Router.Destination.self, destination: { dest in
          dest.asView()
        })
        .sheet(item: $router.sheet, content: { sheetDest in
          sheetDest.asStackRouterView(
            onPopRoot: {
              router.dismissSheet()
            },
            parentRouter: router
          )
        })
        .fullScreenCover(item: $router.fullscreenCover, content: { coverDest in
          coverDest.asStackRouterView(
            onPopRoot: {
              router.dismissFullscreenCover()
            },
            parentRouter: router
          )
        })
    }
    .environment(router)
  }
}

@Observable
class Router {
  var path: NavigationPath
  var sheet: Destination?
  var fullscreenCover: Destination?
  
  @ObservationIgnored var onPopRoot: () -> Void
  @ObservationIgnored weak var parentRouter: Router?
  
  init(path: NavigationPath = NavigationPath(), sheet: Destination? = nil, onPopRoot: @escaping () -> Void = {}, parentRouter: Router? = nil) {
    self.path = path
    self.sheet = sheet
    self.onPopRoot = onPopRoot
    self.parentRouter = parentRouter
  }
  
  func push(_ destination: Destination) {
    path.append(destination)
  }
  
  func pop() {
    guard path.count > 0 else {
      onPopRoot()
      return
    }
    
    path.removeLast()
  }
  
  func popAll() {
    self.sheet = nil
    self.fullscreenCover = nil
    
    path.removeLast(path.count)
    onPopRoot()
  }
  
  func showSheet(_ destination: Destination) {
    sheet = destination
  }
  
  func dismissSheet() {
    sheet = nil
  }
  
  func showFullscreenCover(_ destination: Destination) {
    fullscreenCover = destination
  }
  
  func dismissFullscreenCover() {
    fullscreenCover = nil
  }
  
  var rootParentRouter: Router {
    var rootRouter: Router = self
    while let parent = rootRouter.parentRouter {
      rootRouter = parent
    }
    return rootRouter
  }
  
  enum Destination: Equatable, Hashable, Identifiable {
    var id: Self { self }
    case settings
    
    @ViewBuilder
    func asView() -> some View {
      switch self {
      case .settings:
        SettingsView()
        
      }
    }
    
    @ViewBuilder
    func asStackRouterView(onPopRoot: @escaping () -> Void, parentRouter: Router) -> some View {
      StackRouter(router: Router(onPopRoot: onPopRoot, parentRouter: parentRouter)) {
        asView()
      }
    }
  }
}
