//TODO: Move to dart_esr create signing_request
class SigningRequest {
  Map<String, dynamic> data = {};
  void pushInfo(Map<String, String> info) {
    if (!data.containsKey('info')) {
      data['info'] = [];
    }
    (data['info'] as List).add(info);
  }
}

class CallbackPayload {}

class SigningRequestCreateArguments {}

class SigningRequestEncodingOptions {}
