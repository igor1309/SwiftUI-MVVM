// SwiftUI MVVM

// This is not a template, at least not universal, because we might need some pre-middleware (like debouncing text input), or post-, depending on the case
// (That's why we don't go with generic `Model<State, Action>`)
// This is rather a skeleton that could be adapted for particular tasks, or not used at all

import Combine
// import CombineSchedulers
import SwiftUI

protocol Reducer<State, Action> {
    
    associatedtype State
    associatedtype Action
    
    func reduce(_ state: State, action: Action) -> State
}

// Feature is a module

public struct /* or enum */ FeatureState: Equatable {
    
    // fields
}

public enum FeatureAction: Equatable {
    
    // cases
    case buttonTapped
}

// Te responsibility of this component is to react to UI events via FeatureAction, or external state updates, and to provide observable state
public final class FeatureModel: ObservableObject {
    
    @Published public private(set) var state: FeatureState
    
    private let actionSubject = PassthroughSubject<FeatureAction, Never>()
    
    init(
        initialState: FeatureState,
        reducer: any Reducer<FeatureState, FeatureAction>
        // scheduler:...
    ) {
        self.state = initialState
        
        actionSubject
            .scan(initialState, reducer.reduce)
        // .receive(on: scheduler)
            .receive(on: DispatchQueue.main)
            .assign(to: &$state)
    }
    
    // or
    init(
        initialState: FeatureState,
        // it is up to the client/caller/composition to provide exactly what this model needs, all mappining, API calls, caching, loading m, etc should happen outside
        stateUpdater: AnyPublisher<FeatureState, Never>
        // scheduler:...
    ) {
        self.state = initialState
        
        stateUpdater
        // .receive(on: scheduler)
            .receive(on: DispatchQueue.main)
            .assign(to: &$state)
    }
    
    public func send(_ action: FeatureAction) {
        actionSubject.send(action)
    }
    
    // for convenience a single `send` endpoint could be accompanied by functions
    func buttonTapped() {
        actionSubject.send(.buttonTapped)
    }
}

public struct FeatureContainerView: View {
    
    @ObservedObject private var model: FeatureModel
    
    public init(model: FeatureModel) {
        self.model = model
    }
    
    public var body: some View {
        
        FeatureStateView(
            state: model.state,
            send: model.send
        )
        .animation(.default, value: model.state)
    }
}

// Note: not public!!
// Could be used
// - in Xcode previews with actionable/interactive views - just need to wire `send` endpoint. For example, the preview could create a top or bottom overlay to render reactions to 'send' calls
// - for snapshotting with different state values and traits (color scheme, dynamic type, locale, orientation, etc)
// this component is decoupled from any model, thus could be connected any model or component with suitable interface (within the module)
internal struct FeatureStateView: View {
    
    let state: FeatureState
    
    // a bunch of endpoint callbacks could be used instead of one closure,
    // but that would be less succinct and expressive
    let send: (FeatureAction) -> Void
    
    var body: some View {
        
        Text("\(String(describing: state)) rendering here")
    }
}
