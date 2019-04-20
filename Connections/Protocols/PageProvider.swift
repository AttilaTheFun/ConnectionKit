import RxSwift

protocol PageProvider {
    associatedtype Model: Hashable

    /**
     Array of tuples of the page index and page of data.
     */
    var pages: [Page<Model>] { get }

    /**
     Observable for the pages.
     */
    var pagesObservable: Observable<[Page<Model>]> { get }
}
