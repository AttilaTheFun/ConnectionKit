
public protocol ParsedPageProvider {
    associatedtype ParsedModel
    var parsedPages: [Page<ParsedModel>] { get }
}
