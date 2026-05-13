// ignore: depend_on_referenced_packages
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:flutter/foundation.dart';
import 'package:livekit_client/livekit_client.dart';

class VoiceParticipant {
  final String userId;
  final String name;
  final bool isSpeaking;
  final bool isMuted;

  const VoiceParticipant({
    required this.userId,
    required this.name,
    required this.isSpeaking,
    required this.isMuted,
  });

  VoiceParticipant copyWith({bool? isSpeaking, bool? isMuted}) =>
      VoiceParticipant(
        userId: userId,
        name: name,
        isSpeaking: isSpeaking ?? this.isSpeaking,
        isMuted: isMuted ?? this.isMuted,
      );
}

class VoiceService extends ChangeNotifier {
  static const _livekitUrl = 'wss://do-vui-quizapp-m40yu3v4.livekit.cloud';
  static const _apiKey = 'APIXTk2UottBMtY';
  static const _apiSecret = 'OB4er5yx8c3IJkyxtg5kT6tyFZ2BuavChx4xxQ86OYc';

  Room? _room;
  EventsListener<RoomEvent>? _listener;

  bool _isConnected = false;
  bool _isMicOn = false;
  bool _isSpeakerOn = true;
  final Map<String, VoiceParticipant> _participants = {};
  final List<RemoteAudioTrack> _remoteAudioTracks = [];

  bool get isConnected => _isConnected;
  bool get isMicOn => _isMicOn;
  bool get isSpeakerOn => _isSpeakerOn;
  List<VoiceParticipant> get participants => _participants.values.toList();

  // ── Connect ───────────────────────────────────────────────────────────────

  Future<void> connect({
    required String roomId,
    required String userId,
    required String displayName,
  }) async {
    if (_isConnected) return;
    try {
      final token = _generateToken(
        roomId: roomId,
        userId: userId,
        displayName: displayName,
      );

      _room = Room(
        roomOptions: const RoomOptions(
          adaptiveStream: true,
          dynacast: true,
          defaultAudioPublishOptions: AudioPublishOptions(dtx: true),
          defaultAudioOutputOptions: AudioOutputOptions(speakerOn: true),
        ),
      );

      _listener = _room!.createListener();
      _setupEvents();

      await _room!.connect(_livekitUrl, token);

      _isConnected = true;
      await Hardware.instance.setSpeakerphoneOn(true);

      await Future.delayed(const Duration(milliseconds: 200));

      /// MICROPHONE
      await _room!.localParticipant?.setMicrophoneEnabled(
        true,
        audioCaptureOptions: const AudioCaptureOptions(
          echoCancellation: true,
          noiseSuppression: true,
          autoGainControl: true,
          typingNoiseDetection: true,
        ),
      );

      _isMicOn = true;

      _syncExistingParticipants();
      notifyListeners();
      debugPrint('[Voice] Connected → $roomId');
    } catch (e) {
      debugPrint('[Voice] Connect error: $e');
      rethrow;
    }
  }

  // ── Disconnect ────────────────────────────────────────────────────────────

  Future<void> disconnect() async {
    if (!_isConnected) return;

    _listener?.dispose();

    await _room?.disconnect();
    _room?.dispose();

    _room = null;
    _listener = null;

    _isConnected = false;
    _isMicOn = false;
    _isSpeakerOn = false;

    _participants.clear();

    notifyListeners();

    debugPrint('[Voice] Disconnected');
  }

  // ── Mic ───────────────────────────────────────────────────────────────────

  Future<void> toggleMic() async {
    try {
      if (_isMicOn) {
        /// TẮT MIC
        await _room?.localParticipant?.setMicrophoneEnabled(false);

        _isMicOn = false;
      } else {
        /// BẬT MIC LẠI
        await _room?.localParticipant?.setMicrophoneEnabled(
          true,
          audioCaptureOptions: const AudioCaptureOptions(
            echoCancellation: true,
            noiseSuppression: true,
            autoGainControl: true,
            typingNoiseDetection: true,
          ),
        );

        _isMicOn = true;
      }

      notifyListeners();

      debugPrint('MIC STATE: $_isMicOn');
    } catch (e) {
      debugPrint('TOGGLE MIC ERROR: $e');
    }
  }

  // ── Speaker ───────────────────────────────────────────────────────────────

  Future<void> toggleSpeaker() async {
  try {
    _isSpeakerOn = !_isSpeakerOn;

    if (_isSpeakerOn) {
      /// BẬT LOA NGOÀI
      await Hardware.instance.setSpeakerphoneOn(true);

      for (final track in _remoteAudioTracks) {
        track.enable();
      }
    } else {
      /// TẮT TOÀN BỘ ÂM THANH
      for (final track in _remoteAudioTracks) {
        track.disable();
      }
    }

    notifyListeners();

    debugPrint('SPEAKER: $_isSpeakerOn');
  } catch (e) {
    debugPrint('TOGGLE SPEAKER ERROR: $e');
  }
}

  // ── Token (dart_jsonwebtoken ^3.x) ───────────────────────────────────────

  String _generateToken({
    required String roomId,
    required String userId,
    required String displayName,
  }) {
    final now = DateTime.now();
    final exp = now.add(const Duration(hours: 2));

    // ^3.x: JWT constructor nhận payload trực tiếp, sign dùng JWTKey
    final jwt = JWT(
      {
        'iss': _apiKey,
        'sub': userId,
        'iat': now.millisecondsSinceEpoch ~/ 1000,
        'exp': exp.millisecondsSinceEpoch ~/ 1000,
        'nbf': now.millisecondsSinceEpoch ~/ 1000,
        'name': displayName,
        'video': {
          'roomJoin': true,
          'room': roomId,
          'canPublish': true,
          'canSubscribe': true,
          'canPublishData': false,
        },
      },
      issuer: _apiKey,
      subject: userId,
    );

    // ^3.x dùng SecretKey (HMAC-SHA256) — API không đổi so với ^2.x
    return jwt.sign(
      SecretKey(_apiSecret),
      algorithm: JWTAlgorithm.HS256,
      expiresIn: const Duration(hours: 2),
    );
  }

  // ── Events ────────────────────────────────────────────────────────────────

  void _setupEvents() {
    _listener!
      ..on<TrackSubscribedEvent>((e) {
        if (e.track is RemoteAudioTrack) {
          final track = e.track as RemoteAudioTrack;

          _remoteAudioTracks.add(track);

          if (_isSpeakerOn) {
            track.enable();
          } else {
            track.disable();
          }
        }

        _upsertRemote(e.participant);
        notifyListeners();
      })
      ..on<ParticipantConnectedEvent>((e) {
        _upsertRemote(e.participant);
        notifyListeners();
      })
      ..on<ParticipantDisconnectedEvent>((e) {
        _participants.remove(e.participant.identity);
        notifyListeners();
      })
      ..on<TrackMutedEvent>((e) {
        final existing = _participants[e.participant.identity];
        if (existing != null) {
          _participants[e.participant.identity] = existing.copyWith(
            isMuted: true,
          );
        }
        notifyListeners();
      })
      ..on<TrackUnmutedEvent>((e) {
        final existing = _participants[e.participant.identity];
        if (existing != null) {
          _participants[e.participant.identity] = existing.copyWith(
            isMuted: false,
          );
        }
        notifyListeners();
      })
      ..on<ActiveSpeakersChangedEvent>((e) {
        for (final k in _participants.keys.toList()) {
          _participants[k] = _participants[k]!.copyWith(isSpeaking: false);
        }
        for (final p in e.speakers) {
          final existing = _participants[p.identity];
          if (existing != null) {
            _participants[p.identity] = existing.copyWith(isSpeaking: true);
          }
        }
        notifyListeners();
      })
      ..on<RoomDisconnectedEvent>((_) {
        _isConnected = false;
        _isMicOn = false;
        _isSpeakerOn = true;

        _participants.clear();

        notifyListeners();
      });
  }

  void _syncExistingParticipants() {
    final local = _room?.localParticipant;
    if (local != null) {
      _participants[local.identity] = VoiceParticipant(
        userId: local.identity,
        name: local.name, // ignore: dead_null_aware_expression
        isSpeaking: false,
        isMuted: false,
      );
    }
    _room?.remoteParticipants.forEach((_, p) => _upsertRemote(p));
  }

  void _upsertRemote(RemoteParticipant p) {
    final isMuted = p.audioTrackPublications.every(
      (pub) => pub.muted || pub.track == null,
    );
    _participants[p.identity] = VoiceParticipant(
      userId: p.identity,
      name: p.name, // ignore: dead_null_aware_expression
      isSpeaking: p.isSpeaking,
      isMuted: isMuted,
    );
  }
}
