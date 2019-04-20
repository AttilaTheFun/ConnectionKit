
public struct ConnectionState<Parser> where Parser: ModelParser {
    public let pages: [Page<Parser.Model>]
}
