class GitHubNode {
    # The database ID of the node. Is aliased to 'DatabaseID'.
    # All function that take ID should also take the alias.
    # Example: 42
    [System.Nullable[UInt64]] $ID

    # The node ID of the node.
    # Example: MDQ6VXNlcjE=
    [string] $NodeID
}
