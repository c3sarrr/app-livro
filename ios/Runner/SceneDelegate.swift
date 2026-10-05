import Flutter
import UIKit

// G09 (D-87): "Abrir com" de EPUB e PDF no iOS. O arquivo chega como URL (cópia no Inbox do app, porque
// LSSupportsOpeningDocumentsInPlace = NO); ele é movido do Inbox (que entra no backup do iCloud) para
// tmp/recebidos — de outro lugar, copiado — e o Dart pega a lista ("pendentes") quando abre e a cada aviso
// ("chegaram"). URL que não é arquivo (o retorno do login) segue para os plugins.
// Sem Mac nesta máquina: escrito e não compilado — pendência de ambiente (G27).
class SceneDelegate: FlutterSceneDelegate {
  private var prontos: [[String: String]] = []
  private var canal: FlutterMethodChannel?

  override func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    super.scene(scene, willConnectTo: session, options: connectionOptions)
    receber(connectionOptions.urlContexts)
    prepararCanal()
  }

  override func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
    super.scene(scene, openURLContexts: URLContexts)
    if receber(URLContexts) > 0 {
      prepararCanal()
      canal?.invokeMethod("chegaram", arguments: nil)
    }
  }

  private func prepararCanal() {
    guard canal == nil, let controller = window?.rootViewController as? FlutterViewController else {
      return
    }
    let c = FlutterMethodChannel(name: "booknest/arquivos", binaryMessenger: controller.binaryMessenger)
    c.setMethodCallHandler { [weak self] call, result in
      guard let self = self else {
        result([])
        return
      }
      if call.method == "pendentes" {
        result(self.prontos)
        self.prontos.removeAll()
      } else {
        result(FlutterMethodNotImplemented)
      }
    }
    canal = c
  }

  @discardableResult
  private func receber(_ contexts: Set<UIOpenURLContext>) -> Int {
    let fm = FileManager.default
    let dir = fm.temporaryDirectory.appendingPathComponent("recebidos", isDirectory: true)
    try? fm.createDirectory(at: dir, withIntermediateDirectories: true)
    let inbox = fm.urls(for: .documentDirectory, in: .userDomainMask).first?
      .appendingPathComponent("Inbox", isDirectory: true)
      .resolvingSymlinksInPath().path
    var n = 0
    for ctx in contexts where ctx.url.isFileURL {
      let url = ctx.url
      let acesso = url.startAccessingSecurityScopedResource()
      defer {
        if acesso { url.stopAccessingSecurityScopedResource() }
      }
      let destino = dir.appendingPathComponent(UUID().uuidString)
      do {
        if let inbox = inbox, url.resolvingSymlinksInPath().path.hasPrefix(inbox + "/") {
          try fm.moveItem(at: url, to: destino)
        } else {
          try fm.copyItem(at: url, to: destino)
        }
        prontos.append(["path": destino.path, "name": url.lastPathComponent])
        n += 1
      } catch {
        continue
      }
    }
    return n
  }
}
