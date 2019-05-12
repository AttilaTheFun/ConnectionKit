
public protocol EdgeStorable {
    associatedtype Model

    /**
     Initializes the storer with an initial array of edges.
     */
    init(initialEdges: [Edge<Model>])

    /**
     Retrieve the cursor for the given end.
     */
    func cursor(for end: End) -> String?

    /**
     Ingest a page of data into the manager.
     */
    func ingest(edges: [Edge<Model>], from end: End)

    /**
     Reset the pages back to a known set of edges.
     */
    func reset(to initialEdges: [Edge<Model>])
}
