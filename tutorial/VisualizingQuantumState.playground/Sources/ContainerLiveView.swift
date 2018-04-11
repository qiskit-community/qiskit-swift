import qiskit
import PlaygroundSupport

#if os(OSX)

    import Cocoa

#elseif os(iOS)

    import UIKit

#endif

// MARK: - Main body

public class ContainerLiveView {

    // MARK: - Private properties

    private let height: CGFloat
    private var containedViews: [Int : VisualizationTypes.View]

    // MARK: - Init methods

    public init(height: CGFloat) {
        self.height = height
        self.containedViews = [:]
    }

    // MARK: - Public methods

    public func insertSubview(_ subview: VisualizationTypes.View, at index: Int) {
        containedViews[index] = subview
    }
}

// MARK: - PlaygroundLiveViewable methods

extension ContainerLiveView: PlaygroundLiveViewable {
    public var playgroundLiveViewRepresentation: PlaygroundSupport.PlaygroundLiveViewRepresentation {
        return .view(makeContainerView())
    }
}

// MARK: - Private body


private extension ContainerLiveView {

    // MARK: - Constants

    enum Constants {
        static let borderSize = CGFloat(40)
    }

    // MARK: - Private methods

    func makeContainerView() -> VisualizationTypes.View {
        let views = Array(containedViews.values)
        let contentHeight = views.reduce(0) { $0 + $1.frame.size.height }
        let maxWidth = views.reduce(0) { max($0, $1.frame.size.width) }
        let contentWidth = (maxWidth + CGFloat(2) * Constants.borderSize)

        #if os(OSX)

            let frame = NSMakeRect(0, 0, contentWidth, contentHeight)
            let container = NSView(frame: frame)

        #elseif os(iOS)

            let frame = CGRect(x: 0, y: 0, width: contentWidth, height: self.height)
            let container = UIScrollView(frame: frame)

            let contentSize = CGSize(width: contentWidth, height: contentHeight)
            container.contentSize = contentSize

        #endif

        var sortedContainedIndexes = Array(containedViews.keys).sorted()
        if isCoordinateSystemOriginDown() {
            sortedContainedIndexes = sortedContainedIndexes.reversed()
        }

        var y = CGFloat(0)
        for containedIndex in sortedContainedIndexes {
            let containedView = containedViews[containedIndex]!
            containedView.frame.origin.x = Constants.borderSize
            containedView.frame.origin.y = y

            container.addSubview(containedView)

            y += containedView.frame.size.height
        }

        #if os(OSX)

            let scrollFrame = NSMakeRect(0, 0, contentWidth, self.height)
            let scrollView = NSScrollView(frame: scrollFrame)
            scrollView.backgroundColor = NSColor.black
            scrollView.documentView = container

            return scrollView

        #elseif os(iOS)

            return container

        #endif
    }

    func isCoordinateSystemOriginDown() -> Bool {
        #if os(OSX)

            return true

        #elseif os(iOS)

            return false

        #endif
    }

}
