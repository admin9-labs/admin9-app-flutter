import 'package:flutter/foundation.dart';

import '../../../../data/repositories/channel_repository.dart';
import '../../../../domain/models/media_channel.dart';

class ChannelViewModel extends ChangeNotifier {
  ChannelViewModel({required this.repository});

  final ChannelRepository repository;

  var _isLoading = true;
  var _myChannels = <MediaChannel>[];

  bool get isLoading => _isLoading;
  List<MediaChannel> get myChannels => List.unmodifiable(_myChannels);
  List<MediaChannel> get moreChannels =>
      repository.availableMoreChannels(_myChannels);

  Future<void> loadChannels() async {
    _isLoading = true;
    notifyListeners();
    _myChannels = await repository.loadMyChannels();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addChannel(MediaChannel channel) async {
    if (_myChannels.any((item) => item.id == channel.id)) return;
    _setMyChannels([..._myChannels, channel]);
    await repository.saveMyChannels(_myChannels);
  }

  Future<void> removeChannel(MediaChannel channel) async {
    if (channel.fixed) return;
    _setMyChannels([
      for (final item in _myChannels)
        if (item.id != channel.id) item,
    ]);
    await repository.saveMyChannels(_myChannels);
  }

  Future<void> moveChannel({
    required String draggedId,
    required String targetId,
  }) async {
    if (draggedId == targetId) return;

    final draggedIndex = _myChannels.indexWhere(
      (channel) => channel.id == draggedId,
    );
    final targetIndex = _myChannels.indexWhere(
      (channel) => channel.id == targetId,
    );
    if (draggedIndex <= 0 || targetIndex <= 0) return;

    final channels = [..._myChannels];
    final dragged = channels.removeAt(draggedIndex);
    final newTargetIndex = channels.indexWhere(
      (channel) => channel.id == targetId,
    );
    channels.insert(newTargetIndex < 1 ? 1 : newTargetIndex, dragged);
    _setMyChannels(channels);
    await repository.saveMyChannels(_myChannels);
  }

  Future<void> resetDefault() async {
    _setMyChannels(await repository.resetDefaultChannels());
  }

  void _setMyChannels(List<MediaChannel> channels) {
    final normalized = <MediaChannel>[];
    for (final channel in channels) {
      if (channel.id == 'recommend') continue;
      if (normalized.any((item) => item.id == channel.id)) continue;
      normalized.add(channel);
    }
    _myChannels = [ChannelRepository.defaultChannels.first, ...normalized];
    notifyListeners();
  }
}
