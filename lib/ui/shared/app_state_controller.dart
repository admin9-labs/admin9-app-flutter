import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../data/services/local_storage_service.dart';
import '../../data/repositories/points_repository.dart';
import '../../domain/models/article.dart';
import '../../domain/models/live_program.dart';
import '../../domain/models/points.dart';
import '../../domain/models/report_item.dart';
import '../../domain/models/service_item.dart';
import '../../domain/models/user_activity.dart';

class AppStateController extends ChangeNotifier {
  AppStateController({
    required LocalStorageService storage,
    PointsRepository? pointsRepository,
    String? pointsUserKey,
    DateTime Function()? now,
  }) : _storage = storage,
       _pointsRepository = pointsRepository ?? const PointsRepository(),
       _pointsUserKey = _normalizePointsUserKey(pointsUserKey),
       _now = now ?? DateTime.now,
       _pushEnabled = storage.loadPushEnabled() {
    _recentServiceIds.addAll(storage.loadRecentServiceIds());
    _loadPointsState();
  }

  final LocalStorageService _storage;
  final PointsRepository _pointsRepository;
  final DateTime Function() _now;
  String? _pointsUserKey;

  final _favoriteArticleIds = <String>{};
  final _likedArticleIds = <String>{};
  final _followedSources = <String>{};
  final _favoriteServiceIds = <String>{};
  final _reservedLiveIds = <String>{};
  final _readMessageIds = <String>{};
  final _recentServiceIds = <String>[];
  final _claimedPointTaskIds = <String>{};
  final _pendingPointTaskIds = <String>{};

  final _favoriteArticles = <Article>[];
  final _history = <Article>[];
  final _comments = <UserComment>[];
  final _reports = <ReportSubmission>[];
  final _reservations = <LiveReservation>[];
  final _serviceRecords = <ServiceApplicationRecord>[];
  final _favoriteServices = <ServiceItem>[];
  final _feedbacks = <FeedbackRecord>[];
  final _searchHistory = <String>[];
  final _pointTransactions = <PointTransaction>[];
  final _pointOrders = <PointExchangeOrder>[];

  bool _pushEnabled;
  late int _pointsBalance;
  late bool _checkedInToday;

  bool get pushEnabled => _pushEnabled;
  int get pointsBalance => _pointsBalance;
  bool get checkedInToday {
    _syncCheckInToday();
    return _checkedInToday;
  }

  int get expiringPoints => 80;
  int get checkInStreak => checkedInToday ? 4 : 3;
  String get pointsLevel {
    if (_pointsBalance >= 2400) return '热心市民';
    if (_pointsBalance >= 1200) return '活跃用户';
    return '普通用户';
  }

  List<Article> get favoriteArticles => List.unmodifiable(_favoriteArticles);
  List<Article> get history => List.unmodifiable(_history);
  List<UserComment> get comments => List.unmodifiable(_comments);
  List<ReportSubmission> get reports => List.unmodifiable(_reports);
  List<LiveReservation> get reservations => List.unmodifiable(_reservations);
  List<ServiceApplicationRecord> get serviceRecords =>
      List.unmodifiable(_serviceRecords);
  List<ServiceItem> get favoriteServices =>
      List.unmodifiable(_favoriteServices);
  List<FeedbackRecord> get feedbacks => List.unmodifiable(_feedbacks);
  List<String> get searchHistory => List.unmodifiable(_searchHistory);
  List<String> get followedSources => List.unmodifiable(_followedSources);
  List<String> get recentServiceIds => List.unmodifiable(_recentServiceIds);
  List<PointTransaction> get pointTransactions =>
      List.unmodifiable(_pointTransactions);
  List<PointExchangeOrder> get pointOrders => List.unmodifiable(_pointOrders);

  bool isFavoriteArticle(String id) => _favoriteArticleIds.contains(id);
  bool isLikedArticle(String id) => _likedArticleIds.contains(id);
  bool isFollowingSource(String source) => _followedSources.contains(source);
  bool isFavoriteService(String id) => _favoriteServiceIds.contains(id);
  bool isReservedLive(String id) => _reservedLiveIds.contains(id);
  bool isMessageRead(String id) => _readMessageIds.contains(id);
  bool isPointTaskClaimed(String id) => _claimedPointTaskIds.contains(id);
  bool isPointTaskPending(String id) => _pendingPointTaskIds.contains(id);
  bool hasRedeemedProduct(String productId) {
    return _pointOrders.any((order) => order.product.id == productId);
  }

  List<UserComment> commentsForArticle(String articleId) {
    return _comments
        .where((comment) => comment.article.id == articleId)
        .toList(growable: false);
  }

  void setPushEnabled(bool value) {
    if (_pushEnabled == value) return;
    _pushEnabled = value;
    _storage.savePushEnabled(value);
    notifyListeners();
  }

  void addSearchQuery(String query) {
    final normalized = query.trim();
    if (normalized.isEmpty) return;
    _searchHistory.remove(normalized);
    _searchHistory.insert(0, normalized);
    if (_searchHistory.length > 8) {
      _searchHistory.removeRange(8, _searchHistory.length);
    }
    notifyListeners();
  }

  void clearSearchHistory() {
    if (_searchHistory.isEmpty) return;
    _searchHistory.clear();
    notifyListeners();
  }

  void addHistory(Article article) {
    _history.removeWhere((item) => item.id == article.id);
    _history.insert(0, article);
    if (_history.length > 30) {
      _history.removeRange(30, _history.length);
    }
    markPointTaskReady('read-news');
    notifyListeners();
  }

  void toggleFavoriteArticle(Article article) {
    if (_favoriteArticleIds.remove(article.id)) {
      _favoriteArticles.removeWhere((item) => item.id == article.id);
    } else {
      _favoriteArticleIds.add(article.id);
      _favoriteArticles.insert(0, article);
      markPointTaskReady('favorite-content');
    }
    notifyListeners();
  }

  void toggleLikeArticle(Article article) {
    if (!_likedArticleIds.remove(article.id)) {
      _likedArticleIds.add(article.id);
    }
    notifyListeners();
  }

  void toggleFollowSource(String source) {
    if (!_followedSources.remove(source)) {
      _followedSources.add(source);
    }
    notifyListeners();
  }

  void addComment(Article article, String content) {
    final normalized = content.trim();
    if (normalized.isEmpty) return;
    _comments.insert(
      0,
      UserComment(
        id: 'comment-${DateTime.now().microsecondsSinceEpoch}',
        article: article,
        content: normalized,
        time: '刚刚',
      ),
    );
    markPointTaskReady('comment-content');
    notifyListeners();
  }

  void toggleCommentLike(String id) {
    final index = _comments.indexWhere((comment) => comment.id == id);
    if (index < 0) return;
    _comments[index] = _comments[index].copyWith(
      liked: !_comments[index].liked,
    );
    notifyListeners();
  }

  void toggleLiveReservation(LiveProgram program) {
    if (_reservedLiveIds.remove(program.id)) {
      _reservations.removeWhere((item) => item.program.id == program.id);
    } else {
      _reservedLiveIds.add(program.id);
      _reservations.insert(0, LiveReservation(program: program, time: '刚刚预约'));
      markPointTaskReady('reserve-live');
    }
    notifyListeners();
  }

  void submitReport({
    required String title,
    required String location,
    required String content,
    List<ReportAttachment> attachments = const [],
  }) {
    final item = ReportItem(
      id: 'report-${DateTime.now().microsecondsSinceEpoch}',
      title: title,
      location: location,
      status: '已提交',
      time: '刚刚',
      content: content,
    );
    _reports.insert(
      0,
      ReportSubmission(item: item, content: content, attachments: attachments),
    );
    markPointTaskReady('submit-report');
    notifyListeners();
  }

  void toggleFavoriteService(ServiceItem service) {
    if (_favoriteServiceIds.remove(service.id)) {
      _favoriteServices.removeWhere((item) => item.id == service.id);
    } else {
      _favoriteServiceIds.add(service.id);
      _favoriteServices.insert(0, service);
    }
    notifyListeners();
  }

  void applyService({
    required ServiceItem service,
    required String applicant,
    required String phone,
  }) {
    _serviceRecords.insert(
      0,
      ServiceApplicationRecord(
        id: 'service-${DateTime.now().microsecondsSinceEpoch}',
        service: service,
        applicant: applicant,
        phone: phone,
        time: '刚刚',
        status: '已提交',
        progress: const ['已提交', '材料预审中', '等待部门受理', '办理完成'],
      ),
    );
    markPointTaskReady('apply-service');
    notifyListeners();
  }

  void recordServiceUse(ServiceItem service) {
    _recentServiceIds.remove(service.id);
    _recentServiceIds.insert(0, service.id);
    if (_recentServiceIds.length > 8) {
      _recentServiceIds.removeRange(8, _recentServiceIds.length);
    }
    _storage.saveRecentServiceIds(_recentServiceIds);
    notifyListeners();
  }

  void addFeedback(String content) {
    final normalized = content.trim();
    if (normalized.isEmpty) return;
    _feedbacks.insert(
      0,
      FeedbackRecord(
        id: 'feedback-${DateTime.now().microsecondsSinceEpoch}',
        content: normalized,
        time: '刚刚',
        status: '已提交',
        reply: '工作人员已收到反馈。',
      ),
    );
    notifyListeners();
  }

  void markMessageRead(String id) {
    if (_readMessageIds.add(id)) {
      notifyListeners();
    }
  }

  bool checkInForPoints() {
    _syncCheckInToday();
    if (_checkedInToday) return false;
    final task = _pointsRepository.taskById('daily-checkin');
    if (task == null) return false;
    _checkedInToday = true;
    _storage.savePointsLastCheckInDate(_pointsUserKey, _todayKey());
    _addPoints(task.points, '每日签到', remark: '连续签到 $checkInStreak 天');
    notifyListeners();
    return true;
  }

  void setPointsUserKey(String? userKey) {
    final normalized = _normalizePointsUserKey(userKey);
    if (_pointsUserKey == normalized) return;
    _pointsUserKey = normalized;
    _loadPointsState();
    notifyListeners();
  }

  void markPointTaskReady(String taskId) {
    if (_claimedPointTaskIds.contains(taskId) || taskId == 'daily-checkin') {
      return;
    }
    if (_pendingPointTaskIds.add(taskId)) {
      _storage.savePendingPointTaskIds(
        _pointsUserKey,
        _pendingPointTaskIds.toList(),
      );
      notifyListeners();
    }
  }

  bool claimPointTask(PointTask task) {
    if (task.id == 'daily-checkin') {
      return checkInForPoints();
    }
    if (_claimedPointTaskIds.contains(task.id)) return false;
    if (!_pendingPointTaskIds.contains(task.id)) return false;
    _claimedPointTaskIds.add(task.id);
    _pendingPointTaskIds.remove(task.id);
    _storage.saveClaimedPointTaskIds(
      _pointsUserKey,
      _claimedPointTaskIds.toList(),
    );
    _storage.savePendingPointTaskIds(
      _pointsUserKey,
      _pendingPointTaskIds.toList(),
    );
    _addPoints(task.points, task.title, remark: task.description);
    notifyListeners();
    return true;
  }

  String? canExchangeProduct(PointProduct product) {
    if (!product.inStock) return '已兑完';
    final redeemedCount = _pointOrders
        .where((order) => order.product.id == product.id)
        .length;
    if (redeemedCount >= product.limitPerUser) {
      return '该权益每人限兑 ${product.limitPerUser} 次';
    }
    if (_pointsBalance < product.pointsPrice) {
      return '还差 ${product.pointsPrice - _pointsBalance} 积分';
    }
    return null;
  }

  PointExchangeOrder? exchangeProduct(PointProduct product) {
    if (canExchangeProduct(product) != null) return null;
    _pointsBalance -= product.pointsPrice;
    _storage.savePointsBalance(_pointsUserKey, _pointsBalance);
    final timestamp = _now().microsecondsSinceEpoch;
    final order = PointExchangeOrder(
      id: 'order-$timestamp',
      product: product,
      status: PointOrderStatus.pendingUse,
      code: 'A9-${timestamp.toString().substring(7, 13)}',
      time: '刚刚',
    );
    _pointOrders.insert(0, order);
    _savePointOrders();
    _pointTransactions.insert(
      0,
      PointTransaction(
        id: 'spend-$timestamp',
        kind: PointTransactionKind.spend,
        title: product.title,
        time: '刚刚',
        points: -product.pointsPrice,
        remark: '积分商城兑换',
      ),
    );
    _savePointTransactions();
    notifyListeners();
    return order;
  }

  void markPointOrderUsed(String id) {
    final index = _pointOrders.indexWhere((order) => order.id == id);
    if (index < 0) return;
    final order = _pointOrders[index];
    if (order.status != PointOrderStatus.pendingUse) return;
    _pointOrders[index] = order.copyWith(
      status: PointOrderStatus.used,
      usedTime: '刚刚核销',
    );
    final usedIds = _pointOrders
        .where((item) => item.status == PointOrderStatus.used)
        .map((item) => item.id)
        .toList();
    _storage.saveUsedPointOrderIds(_pointsUserKey, usedIds);
    _savePointOrders();
    notifyListeners();
  }

  void _addPoints(int points, String title, {String? remark}) {
    _pointsBalance += points;
    _storage.savePointsBalance(_pointsUserKey, _pointsBalance);
    _pointTransactions.insert(
      0,
      PointTransaction(
        id: 'point-${_now().microsecondsSinceEpoch}',
        kind: PointTransactionKind.earn,
        title: title,
        time: '刚刚',
        points: points,
        remark: remark,
      ),
    );
    _savePointTransactions();
  }

  String _todayKey() {
    final now = _now();
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');
    return '${now.year}-$month-$day';
  }

  bool _syncCheckInToday() {
    final checkedInToday =
        _storage.loadPointsLastCheckInDate(_pointsUserKey) == _todayKey();
    if (_checkedInToday == checkedInToday) return false;
    _checkedInToday = checkedInToday;
    return true;
  }

  void _loadPointsState() {
    _pointsBalance =
        _storage.loadPointsBalance(_pointsUserKey) ??
        _pointsRepository.initialBalance;
    _checkedInToday =
        _storage.loadPointsLastCheckInDate(_pointsUserKey) == _todayKey();
    _claimedPointTaskIds
      ..clear()
      ..addAll(_storage.loadClaimedPointTaskIds(_pointsUserKey));
    _pendingPointTaskIds
      ..clear()
      ..addAll(_storage.loadPendingPointTaskIds(_pointsUserKey));
    _pointOrders
      ..clear()
      ..addAll(_loadPointOrders());
    final usedOrderIds = _storage.loadUsedPointOrderIds(_pointsUserKey);
    for (final id in usedOrderIds) {
      final index = _pointOrders.indexWhere((order) => order.id == id);
      if (index >= 0) {
        _pointOrders[index] = _pointOrders[index].copyWith(
          status: PointOrderStatus.used,
          usedTime: '刚刚核销',
        );
      }
    }
    _pointTransactions
      ..clear()
      ..addAll(_loadPointTransactions())
      ..addAll(_seedPointTransactions());
  }

  List<PointTransaction> _seedPointTransactions() {
    return const [
      PointTransaction(
        id: 'seed-signin',
        kind: PointTransactionKind.earn,
        title: '每日签到',
        time: '昨天',
        points: 10,
        remark: '连续签到 3 天',
      ),
      PointTransaction(
        id: 'seed-read',
        kind: PointTransactionKind.earn,
        title: '阅读新闻',
        time: '昨天',
        points: 20,
        remark: '浏览本地资讯',
      ),
      PointTransaction(
        id: 'seed-expire',
        kind: PointTransactionKind.expire,
        title: '积分过期',
        time: '上月',
        points: -30,
        remark: '过期积分自动清理',
      ),
    ];
  }

  List<PointExchangeOrder> _loadPointOrders() {
    final orders = <PointExchangeOrder>[];
    for (final payload in _storage.loadPointOrderPayloads(_pointsUserKey)) {
      try {
        final json = jsonDecode(payload);
        if (json is! Map<String, dynamic>) continue;
        final product = _pointsRepository.productById(
          json['product_id']?.toString() ?? '',
        );
        if (product == null) continue;
        orders.add(
          PointExchangeOrder(
            id: json['id']?.toString() ?? '',
            product: product,
            status: PointOrderStatus.parse(json['status']?.toString() ?? ''),
            code: json['code']?.toString() ?? '',
            time: json['time']?.toString() ?? '',
            usedTime: json['used_time']?.toString(),
          ),
        );
      } on FormatException {
        continue;
      }
    }
    return orders.where((order) => order.id.isNotEmpty).toList();
  }

  void _savePointOrders() {
    final payloads = [
      for (final order in _pointOrders)
        jsonEncode({
          'id': order.id,
          'product_id': order.product.id,
          'status': order.status.name,
          'code': order.code,
          'time': order.time,
          'used_time': order.usedTime,
        }),
    ];
    _storage.savePointOrderPayloads(_pointsUserKey, payloads);
  }

  List<PointTransaction> _loadPointTransactions() {
    final transactions = <PointTransaction>[];
    for (final payload in _storage.loadPointTransactionPayloads(
      _pointsUserKey,
    )) {
      try {
        final json = jsonDecode(payload);
        if (json is! Map<String, dynamic>) continue;
        final points = json['points'];
        if (points is! int) continue;
        transactions.add(
          PointTransaction(
            id: json['id']?.toString() ?? '',
            kind: PointTransactionKind.parse(json['kind']?.toString() ?? ''),
            title: json['title']?.toString() ?? '',
            time: json['time']?.toString() ?? '',
            points: points,
            remark: json['remark']?.toString(),
          ),
        );
      } on FormatException {
        continue;
      }
    }
    return transactions
        .where((transaction) => transaction.id.isNotEmpty)
        .toList();
  }

  void _savePointTransactions() {
    final payloads = [
      for (final transaction in _pointTransactions)
        if (!transaction.id.startsWith('seed-'))
          jsonEncode({
            'id': transaction.id,
            'kind': transaction.kind.name,
            'title': transaction.title,
            'time': transaction.time,
            'points': transaction.points,
            'remark': transaction.remark,
          }),
    ];
    _storage.savePointTransactionPayloads(_pointsUserKey, payloads);
  }

  static String? _normalizePointsUserKey(String? userKey) {
    final normalized = userKey?.trim();
    if (normalized == null || normalized.isEmpty) return null;
    return normalized;
  }
}
