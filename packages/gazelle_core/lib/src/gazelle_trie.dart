/// Represents the result of a search operation in a Gazelle Trie.
class GazelleTrieSearchResult<T> {
  /// The node associated with the search result.
  final GazelleTrieNode<T>? node;

  /// A map containing values of wildcard nodes encountered during the search.
  final Map<String, String> wildcardValues;

  /// Constructs a GazelleTrieSearchResult instance.
  ///
  /// [node] is the node associated with the search result.
  ///
  /// [wildcardValues] is a map containing values of wildcard nodes encountered during the search.
  const GazelleTrieSearchResult({
    required this.node,
    this.wildcardValues = const {},
  });

  /// The value associated with the search result.
  T? get value => node?.value;
}

/// Represents a node in a Gazelle Trie.
class GazelleTrieNode<T> {
  /// The parent node of this trie node.
  final GazelleTrieNode<T>? parent;

  /// The name associated with this trie node.
  final String name;

  /// The children nodes of this trie node.
  Map<String, GazelleTrieNode<T>> children = {};

  /// The value associated with this trie node.
  T? value;

  /// The name of the wildcard associated with this trie node.
  String? _wildcardName;

  /// Constructs a GazelleTrieNode instance.
  ///
  /// The [name] parameter represents the name associated with this trie node.
  /// The [parent] parameter represents the parent node of this trie node.
  GazelleTrieNode({
    this.name = "",
    this.parent,
  });

  /// Sets the wildcard name associated with this trie node.
  set wildcardName(String name) => _wildcardName = name;

  /// Gets the wildcard name associated with this trie node.
  String get wildcardName =>
      _wildcardName == null ? throw "Wildcard name is null" : _wildcardName!;

  /// Checks if this node is a wildcard node.
  bool get isWildcard => _wildcardName != null;

  /// Checks if this node has any wildcard children.
  bool get hasWildcardChild => children.values.any((e) => e.isWildcard);

  /// Gets the wildcard child node.
  GazelleTrieNode<T> get wildcardChild =>
      children.values.singleWhere((e) => e.isWildcard);
}

/// Represents a Trie data structure used for efficient prefix-based searching.
class GazelleTrie<T> {
  /// The wildcard character used in the trie.
  final String wildcard;

  /// The root node of the trie.
  GazelleTrieNode<T> root = GazelleTrieNode<T>();

  /// Constructs a GazelleTrie instance.
  ///
  /// [wildcard] is the wildcard character used in the trie.
  GazelleTrie({
    required this.wildcard,
  });

  /// Inserts a list of strings into the trie with the specified value.
  void insert(List<String> strings, T value) {
    GazelleTrieNode<T> current = root;

    for (final string in strings) {
      if (string.startsWith(wildcard)) {
        final wildcardName = string.replaceAll(wildcard, "");
        if (!current.children.containsKey(wildcardName)) {
          current.children[wildcardName] = GazelleTrieNode<T>(
            name: wildcardName,
            parent: current,
          );
        }
        current = current.children[wildcardName]!;

        current.wildcardName = wildcardName;
        continue;
      }

      if (!current.children.containsKey(string)) {
        current.children[string] = GazelleTrieNode<T>(
          name: string,
          parent: current,
        );
      }
      current = current.children[string]!;
    }

    current.value = value;
  }

  /// Searches for a list of strings in the trie.
  ///
  /// Returns a GazelleTrieSearchResult containing the value associated with the search result
  /// and any wildcard values encountered during the search.
  GazelleTrieSearchResult<T> search(List<String> strings) {
    GazelleTrieNode<T> current = root;
    Map<String, String> wildcards = {};

    for (final string in strings) {
      if (current.children.containsKey(string)) {
        current = current.children[string]!;
      } else if (current.hasWildcardChild) {
        current = current.wildcardChild;
        wildcards[current.wildcardName] = string;
      } else {
        return GazelleTrieSearchResult(
          node: null,
          wildcardValues: wildcards,
        );
      }
    }

    return GazelleTrieSearchResult(
      node: current,
      wildcardValues: wildcards,
    );
  }
}
