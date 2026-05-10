class DtlsConfig {
  DtlsConfig._();

  static const bool enforceDtls = true;
  static const String minDtlsVersion = '1.3';

  static Map<String, dynamic> get webRtcConstraints => {
    'mandatory': {
      'OfferToReceiveAudio': false,
      'OfferToReceiveVideo': false,
    },
    'optional': [],
  };
}
