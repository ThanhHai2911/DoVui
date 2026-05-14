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

  // ── Force Speaker (gọi nhiều lần để chống Android override) ──────────────

  Future<void> _forceSpeaker() async {
    try {
      await Hardware.instance.setSpeakerphoneOn(true);
      debugPrint('[Voice] forceSpeaker called');
    } catch (e) {
      debugPrint('[Voice] forceSpeaker error: $e');
    }
  }

  // ── Connect ───────────────────────────────────────────────────────────────

  Future<void> connect({
    required String roomId,
    required String userId,
    required String displayName,
    bool enableMic = false,
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

      // Lần 1: set speaker trước khi bật mic
      await _forceSpeaker();
      await Future.delayed(const Duration(milliseconds: 200));

      // Set mic theo yêu cầu (mặc định tắt)
      await _room!.localParticipant?.setMicrophoneEnabled(
        enableMic,
        audioCaptureOptions: const AudioCaptureOptions(
          echoCancellation: true,
          noiseSuppression: true,
          autoGainControl: true,
          typingNoiseDetection: true,
        ),
      );
      _isMicOn = enableMic;

      // Lần 2: Android thường reset speaker sau khi audio session thay đổi
      await Future.delayed(const Duration(milliseconds: 300));
      await _forceSpeaker();

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
    _remoteAudioTracks.clear();

    notifyListeners();
    debugPrint('[Voice] Disconnected');
  }

  // ── Mic ───────────────────────────────────────────────────────────────────

  Future<void> toggleMic() async {
    try {
      if (_isMicOn) {
        await _room?.localParticipant?.setMicrophoneEnabled(false);
        _isMicOn = false;
      } else {
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

        // Android reset speaker sau khi bật mic → force lại
        if (_isSpeakerOn) {
          await Future.delayed(const Duration(milliseconds: 200));
          await _forceSpeaker();
        }
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
        await Hardware.instance.setSpeakerphoneOn(true);
        await Future.delayed(const Duration(milliseconds: 100));
        await _forceSpeaker();
        for (final track in _remoteAudioTracks) {
          track.enable();
        }
      } else {
        await Hardware.instance.setSpeakerphoneOn(false);
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

  // ── Token ─────────────────────────────────────────────────────────────────

  String _generateToken({
    required String roomId,
    required String userId,
    required String displayName,
  }) {
    final now = DateTime.now();
    final exp = now.add(const Duration(hours: 2));

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
            // Force speaker mỗi khi nhận track mới (Android hay reset ở đây)
            _forceSpeaker();
          } else {
            track.disable();
          }
        }

        _upsertRemote(e.participant);
        notifyListeners();
      })
      ..on<TrackUnsubscribedEvent>((e) {
        if (e.track is RemoteAudioTrack) {
          _remoteAudioTracks.remove(e.track);
        }
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
          _participants[e.participant.identity] =
              existing.copyWith(isMuted: true);
        }
        notifyListeners();
      })
      ..on<TrackUnmutedEvent>((e) {
        final existing = _participants[e.participant.identity];
        if (existing != null) {
          _participants[e.participant.identity] =
              existing.copyWith(isMuted: false);
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
        _remoteAudioTracks.clear();
        notifyListeners();
      });
  }

  // ── Participants ──────────────────────────────────────────────────────────

  void _syncExistingParticipants() {
    final local = _room?.localParticipant;
    if (local != null) {
      _participants[local.identity] = VoiceParticipant(
        userId: local.identity,
        name: local.name,
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
      name: p.name,
      isSpeaking: p.isSpeaking,
      isMuted: isMuted,
    );
  }
}