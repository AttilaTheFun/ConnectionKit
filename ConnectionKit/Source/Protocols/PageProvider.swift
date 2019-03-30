import RxSwift

protocol PageProvider {
    associatedtype Fetcher: ConnectionFetcher

    /**
     Array of tuples of the page index and page of data.
     */
    var pages: [Page<Fetcher>] { get }

    /**
     Observable for the pages.
     */
    var pagesObservable: Observable<[Page<Fetcher>]> { get }
}
