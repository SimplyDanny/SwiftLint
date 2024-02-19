open class RulesProvider {
    public init() {}
    open func rules() -> [any Rule.Type] {
        queuedFatalError("Implement this function.")
    }
}
