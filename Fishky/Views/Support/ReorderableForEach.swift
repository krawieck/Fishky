import SwiftUI

public typealias Reorderable = Identifiable & Equatable

// https://danielsaidi.com/blog/2023/08/30/enabling-drag-reordering-in-swiftui-lazy-grids-and-stacks
public struct ReorderableForEach<Item: Reorderable, Content: View, Preview: View>: View {
    
    public init(
        _ items: [Item],
        active: Binding<Item?>,
        reorderingEnabled: Bool = true,
        @ViewBuilder content: @escaping (Item) -> Content,
        @ViewBuilder preview: @escaping (Item) -> Preview,
        moveAction: @escaping (IndexSet, Int) -> Void
    ) {
        self.items = items
        self._active = active
        self.content = content
        self.preview = preview
        self.moveAction = moveAction
        self.reorderingEnabled = reorderingEnabled
    }
    
    public init(
        _ items: [Item],
        active: Binding<Item?>,
        reorderingEnabled: Bool = true,
        @ViewBuilder content: @escaping (Item) -> Content,
        moveAction: @escaping (IndexSet, Int) -> Void
    ) where Preview == EmptyView {
        self.items = items
        self._active = active
        self.content = content
        self.preview = nil
        self.moveAction = moveAction
        self.reorderingEnabled = reorderingEnabled
    }
    
    @Binding
    private var active: Item?
    
    @State
    private var hasChangedLocation = false
    
    private let items: [Item]
    private let content: (Item) -> Content
    private let preview: ((Item) -> Preview)?
    private let moveAction: (IndexSet, Int) -> Void
    
    var reorderingEnabled: Bool
    
    
    public var body: some View {
        ForEach(items) { item in
            if !reorderingEnabled {
                content(item)
            } else {        
                if let preview {
                    contentView(for: item)
                        .onDrag {
                            dragData(for: item)
                        } preview: {
                            preview(item)
                        }
                    
                } else {
                    contentView(for: item)
                        .onDrag {
                            dragData(for: item)
                        }
                }
            }
        }
    }
    
    private func contentView(for item: Item) -> some View {
        content(item)
            .opacity(active == item && hasChangedLocation ? 0.5 : 1)
            .onDrop(
                of: [.text],
                delegate: ReorderableDragRelocateDelegate(
                    item: item,
                    items: items,
                    active: $active,
                    hasChangedLocation: $hasChangedLocation
                ) { from, to in
                    withAnimation {
                        moveAction(from, to)
                    }
                }
            )
    }
    
    private func dragData(for item: Item) -> NSItemProvider {
        active = item
        return NSItemProvider(object: "\(item.id)" as NSString)
    }
}


struct ReorderableDragRelocateDelegate<Item: Reorderable>: DropDelegate {
    
    let item: Item
    var items: [Item]
    
    @Binding var active: Item?
    @Binding var hasChangedLocation: Bool
    
    var moveAction: (IndexSet, Int) -> Void
    
    func dropEntered(info: DropInfo) {
        guard item != active, let current = active else { return }
        guard let from = items.firstIndex(of: current) else { return }
        guard let to = items.firstIndex(of: item) else { return }
        hasChangedLocation = true
        if items[to] != current {
            moveAction(IndexSet(integer: from), to > from ? to + 1 : to)
        }
    }
    
    func dropUpdated(info: DropInfo) -> DropProposal? {
        DropProposal(operation: .move)
    }
    
    func performDrop(info: DropInfo) -> Bool {
        hasChangedLocation = false
        active = nil
        return true
    }
}



struct ReorderableDropOutsideDelegate<Item: Reorderable>: DropDelegate {
    @Binding
    var active: Item?
    
    func dropUpdated(info: DropInfo) -> DropProposal? {
        DropProposal(operation: .move)
    }
    
    func performDrop(info: DropInfo) -> Bool {
        active = nil
        return true
    }
}



public extension View {
    func reorderableForEachContainer<Item: Reorderable>(
        active: Binding<Item?>
    ) -> some View {
        onDrop(of: [.text], delegate: ReorderableDropOutsideDelegate(active: active))
    }
}
