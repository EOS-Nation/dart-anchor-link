/**
 * Exception codes. Accessible using the `code` property on Exceptions thrown by [[Link]] and [[LinkSession]].
 * - `E_DELIVERY`: Unable to request message to wallet.
 * - `E_TIMEOUT`: Request was delivered but user/wallet didn't respond in time.
 * - `E_CANCEL`: The [[LinkTransport]] canceled the request.
 * - `E_IDENTITY`: Identity proof failed to verify.
 */
enum LinkExceptionCode { E_DELIVERY, E_TIMEOUT, E_CANCEL, E_IDENTITY }

/**
 * Exception that is thrown if a [[LinkTransport]] cancels a request.
 * @internal
 */
class CancelException implements Exception {
  final code = LinkExceptionCode.E_CANCEL;
  final String reason;

  CancelException(this.reason);

  String toString() =>
      'User canceled request ${reason == null || reason.isEmpty ? '' : '(' + reason + ')'}';
}

/**
 * Exception that is thrown if an identity request fails to verify.
 * @internal
 */
class IdentityException implements Exception {
  final code = LinkExceptionCode.E_IDENTITY;
  final String reason;

  IdentityException(this.reason);

  String toString() =>
      'Unable to verify identity ${reason == null || reason.isEmpty ? '' : '(' + reason + ')'}';
}

/**
 * Exception originating from a [[LinkSession]].
 * @internal
 */
class SessionException implements Exception {
  final LinkExceptionCode code;
  final String reason;

  SessionException(this.reason, this.code);

  String toString() => reason;
}
