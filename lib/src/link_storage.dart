/**
 * Interface storage adapters should implement.
 *
 * Storage adapters are responsible for persisting [[LinkSession]]'s and can optionally be
 * passed to the [[Link]] constructor to auto-persist sessions.
 */
abstract class LinkStorage {
  /** Write string to storage at key. Should overwrite existing values without error. */
  Future<void> write(String key, String data);

  /** Read key from storage. Should return `null` if key can not be found. */
  Future<String> read(String key);

  /** Delete key from storage. Should not error if deleting non-existing key. */
  Future<void> remove(String key);
}
