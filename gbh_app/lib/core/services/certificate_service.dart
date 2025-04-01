// lib/core/services/certificate_service.dart
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:asn1lib/asn1lib.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pointycastle/api.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:pointycastle/asymmetric/rsa.dart';
import 'package:pointycastle/key_generators/api.dart';
import 'package:pointycastle/key_generators/rsa_key_generator.dart';
import 'package:pointycastle/random/fortuna_random.dart';
import 'package:pointycastle/signers/rsa_signer.dart';
import 'package:pointycastle/digests/sha256.dart';

class CertificateService {
  final FlutterSecureStorage _secureStorage;
  static const String _privateKeyKey = 'private_key'; // 개인키를 열기 위한 키
  static const String _publicKeyKey = 'public_key'; // 공개키를 열기 위한 키

  CertificateService(this._secureStorage);

  // RSA 키 페어 생성 (pointycastle 패키지 사용)
  Future<AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey>> generateRSAKeyPair() async {
    // 보안 랜덤 생성기
    final secureRandom = FortunaRandom();
    final random = Random.secure();
    final seeds = List<int>.generate(32, (_) => random.nextInt(256));
    secureRandom.seed(KeyParameter(Uint8List.fromList(seeds)));

    // RSA 키 생성기
    final keyGen = RSAKeyGenerator();
    final keyParams = RSAKeyGeneratorParameters(
        BigInt.from(65537), 2048, 64);
    
    keyGen.init(ParametersWithRandom(keyParams, secureRandom));

    // 키 페어 생성
    return keyGen.generateKeyPair() as AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey>;
  }

  // 키 페어 저장
  Future<void> storeKeyPair(AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey> keyPair) async {
    // 개인키를 PEM 형식으로 인코딩하여 TEE/SE에 저장
    final privateKeyPem = _encodeRSAPrivateKeyToPem(keyPair.privateKey);
    await _secureStorage.write(key: _privateKeyKey, value: privateKeyPem);

    // 공개키도 저장 (선택사항인데 이거 저장할까요?)
    final publicKeyPem = _encodeRSAPublicKeyToPem(keyPair.publicKey);
    await _secureStorage.write(key: _publicKeyKey, value: publicKeyPem);
  }

  // 개인키를 PEM 형식으로 인코딩
  String _encodeRSAPrivateKeyToPem(RSAPrivateKey privateKey) {
    // ASN.1 형식으로 인코딩
    final privateKeySequence = ASN1Sequence();
    privateKeySequence.add(ASN1Integer(BigInt.from(0))); // 버전
    privateKeySequence.add(ASN1Integer(privateKey.n!)); // Modulus
    privateKeySequence.add(ASN1Integer(privateKey.publicExponent!)); // Public Exponent
    privateKeySequence.add(ASN1Integer(privateKey.privateExponent!)); // Private Exponent
    privateKeySequence.add(ASN1Integer(privateKey.p!)); // Prime 1
    privateKeySequence.add(ASN1Integer(privateKey.q!)); // Prime 2
    privateKeySequence.add(ASN1Integer(privateKey.privateExponent! % (privateKey.p! - BigInt.from(1)))); // Exponent 1
    privateKeySequence.add(ASN1Integer(privateKey.privateExponent! % (privateKey.q! - BigInt.from(1)))); // Exponent 2
    privateKeySequence.add(ASN1Integer(privateKey.q!.modInverse(privateKey.p!))); // Coefficient

    final bytes = privateKeySequence.encodedBytes;
    final base64PrivateKey = base64.encode(bytes);
    
    return '-----BEGIN RSA PRIVATE KEY-----\n' +
        base64PrivateKey.replaceAllMapped(RegExp('.{64}'), (match) => '${match.group(0)}\n') +
        (base64PrivateKey.length % 64 == 0 ? '' : '\n') +
        '-----END RSA PRIVATE KEY-----';
  }

  // 공개키를 PEM 형식으로 인코딩
  String _encodeRSAPublicKeyToPem(RSAPublicKey publicKey) {
    final publicKeySequence = _encodePublicKey(publicKey);
    final bytes = publicKeySequence.encodedBytes;
    final base64PublicKey = base64.encode(bytes);
    
    return '-----BEGIN PUBLIC KEY-----\n' +
        base64PublicKey.replaceAllMapped(RegExp('.{64}'), (match) => '${match.group(0)}\n') +
        (base64PublicKey.length % 64 == 0 ? '' : '\n') +
        '-----END PUBLIC KEY-----';
  }

  // 저장된 개인키 가져오기
  Future<RSAPrivateKey?> getPrivateKey() async {
    final privateKeyPem = await _secureStorage.read(key: _privateKeyKey);
    if (privateKeyPem == null) return null;
    return _decodeRSAPrivateKeyFromPem(privateKeyPem);
  }

  // 저장된 공개키 가져오기
  Future<RSAPublicKey?> getPublicKey() async {
    final publicKeyPem = await _secureStorage.read(key: _publicKeyKey);
    if (publicKeyPem == null) return null;
    return _decodeRSAPublicKeyFromPem(publicKeyPem);
  }

  // PEM 형식의 개인키 디코딩
  RSAPrivateKey _decodeRSAPrivateKeyFromPem(String pemString) {
    // PEM에서 base64 추출
    final pemContent = pemString
        .replaceAll('-----BEGIN RSA PRIVATE KEY-----', '')
        .replaceAll('-----END RSA PRIVATE KEY-----', '')
        .replaceAll('\n', '');
    
    final bytes = base64.decode(pemContent);
    final asn1Parser = ASN1Parser(Uint8List.fromList(bytes));
    final topLevelSeq = asn1Parser.nextObject() as ASN1Sequence;
    
    // ASN.1 구조에서 개인키 파라미터 추출
    // 버전은 무시 (index 0)
    final modulus = (topLevelSeq.elements[1] as ASN1Integer).valueAsBigInteger;
    final publicExponent = (topLevelSeq.elements[2] as ASN1Integer).valueAsBigInteger;
    final privateExponent = (topLevelSeq.elements[3] as ASN1Integer).valueAsBigInteger;
    final p = (topLevelSeq.elements[4] as ASN1Integer).valueAsBigInteger;
    final q = (topLevelSeq.elements[5] as ASN1Integer).valueAsBigInteger;
    
    return RSAPrivateKey(modulus!, privateExponent!, p, q);
  }

  // PEM 형식의 공개키 디코딩
  RSAPublicKey _decodeRSAPublicKeyFromPem(String pemString) {
    // PEM에서 base64 추출
    final pemContent = pemString
        .replaceAll('-----BEGIN PUBLIC KEY-----', '')
        .replaceAll('-----END PUBLIC KEY-----', '')
        .replaceAll('\n', '');
    
    final bytes = base64.decode(pemContent);
    final asn1Parser = ASN1Parser(Uint8List.fromList(bytes));
    final topLevelSeq = asn1Parser.nextObject() as ASN1Sequence;
    
    final bitString = topLevelSeq.elements[1] as ASN1BitString;
    final publicKeyParser = ASN1Parser(bitString.contentBytes()!);
    final publicKeySeq = publicKeyParser.nextObject() as ASN1Sequence;
    
    final modulus = (publicKeySeq.elements[0] as ASN1Integer).valueAsBigInteger;
    final exponent = (publicKeySeq.elements[1] as ASN1Integer).valueAsBigInteger;
    
    return RSAPublicKey(modulus!, exponent!);
  }

  // 키 페어 존재 여부 확인
  Future<bool> hasKeyPair() async {
    final publicKey = await getPublicKey();
    return publicKey != null;
  }

  // CSR 생성
  Future<String> generateCSR({
    required String commonName, 
    String country = 'KR', 
    String organization = 'GBH'
  }) async {
    // 저장된 키 페어 불러오기
    final privateKey = await getPrivateKey();
    final publicKey = await getPublicKey();
    
    if (privateKey == null || publicKey == null) {
      throw Exception('키 페어가 존재하지 않습니다. 먼저 키 페어를 생성하세요.');
    }

    // CSR을 위한 Subject 정보 구성
    final subject = {
      'CN': ASN1PrintableString(commonName),
      'O': ASN1PrintableString(organization),
      'C': ASN1PrintableString(country),
    };

    // CSR 생성 로직 (ASN.1 형식으로 인코딩)
    final subjectSequence = ASN1Sequence();
    subject.forEach((key, value) {
      final rdnSet = ASN1Set();
      // OID를 Uint8List로 변환
      final attributeType = ASN1ObjectIdentifier(Uint8List.fromList(_getOIDForName(key)));
      final attributeValue = ASN1Sequence()
        ..add(attributeType)
        ..add(value);
      rdnSet.add(attributeValue);
      subjectSequence.add(rdnSet);
    });

    // 공개키 정보 (SubjectPublicKeyInfo)
    final publicKeyInfo = _encodePublicKey(publicKey);

    // CSR 메인 시퀀스
    final csrInfoSeq = ASN1Sequence()
      ..add(ASN1Integer(BigInt.from(0))) // 버전
      ..add(subjectSequence) // Subject
      ..add(publicKeyInfo) // 공개키 정보
      ..add(ASN1Null()); // 속성은 비워둠

    // CSR 정보 인코딩
    final csrInfoBytes = csrInfoSeq.encodedBytes;

    // 서명 알고리즘
    final signer = RSASigner(SHA256Digest(), '1.2.840.113549.1.1.11');
    final params = PrivateKeyParameter<RSAPrivateKey>(privateKey);
    signer.init(true, params);

    // CSR 정보에 서명
    final signature = signer.generateSignature(Uint8List.fromList(csrInfoBytes));
    final signatureBytes = (signature as RSASignature).bytes;

    // 최종 CSR 구성
    final csrSequence = ASN1Sequence()
      ..add(csrInfoSeq)
      ..add(ASN1Sequence()
        ..add(ASN1ObjectIdentifier(Uint8List.fromList([42, 134, 72, 134, 247, 13, 1, 1, 11]))) // SHA-256 with RSA 
        ..add(ASN1Null()))
      ..add(ASN1BitString(signatureBytes));

    // PEM 형식으로 인코딩하여 반환
    final csrBytes = csrSequence.encodedBytes;
    final csrBase64 = base64.encode(csrBytes);
    final csrPem = '-----BEGIN CERTIFICATE REQUEST-----\n' +
        csrBase64.replaceAllMapped(RegExp('.{64}'), (match) => '${match.group(0)}\n') +
        (csrBase64.length % 64 == 0 ? '' : '\n') +
        '-----END CERTIFICATE REQUEST-----';

    return csrPem;
  }

  // PublicKey를 ASN.1 Sequence로 인코딩
  ASN1Sequence _encodePublicKey(RSAPublicKey publicKey) {
    final algorithmSeq = ASN1Sequence();
    // OID를 Uint8List로 변환
    final algorithmAsn1Obj = ASN1ObjectIdentifier(Uint8List.fromList([42, 134, 72, 134, 247, 13, 1, 1, 1])); // RSA
    final paramsAsn1 = ASN1Null();
    algorithmSeq.add(algorithmAsn1Obj);
    algorithmSeq.add(paramsAsn1);

    final publicKeyAsn1Seq = ASN1Sequence();
    publicKeyAsn1Seq.add(ASN1Integer(publicKey.modulus!));
    publicKeyAsn1Seq.add(ASN1Integer(publicKey.exponent!));
    final publicKeySeqBytes = publicKeyAsn1Seq.encodedBytes;
    final publicKeyBitString = ASN1BitString(Uint8List.fromList(publicKeySeqBytes));

    final publicKeySeq = ASN1Sequence();
    publicKeySeq.add(algorithmSeq);
    publicKeySeq.add(publicKeyBitString);
    
    return publicKeySeq;
  }

  // OID 매핑 함수 (String이 아닌 List<int> 반환)
  List<int> _getOIDForName(String name) {
    // OID 매핑
    final Map<String, List<int>> oidMap = {
      'C': [85, 4, 6],     // 2.5.4.6 (국가)
      'O': [85, 4, 10],    // 2.5.4.10 (조직명)
      'OU': [85, 4, 11],   // 2.5.4.11 (조직 단위)
      'CN': [85, 4, 3],    // 2.5.4.3 (공통명)
    };
    
    return oidMap[name] ?? [85, 4, 3]; // 기본값은 CN
  }
}