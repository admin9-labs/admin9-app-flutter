enum PointTransactionKind {
  earn('获取'),
  spend('使用'),
  expire('过期');

  const PointTransactionKind(this.label);

  final String label;

  static PointTransactionKind parse(String value) {
    return PointTransactionKind.values.firstWhere(
      (kind) => kind.name == value,
      orElse: () => PointTransactionKind.earn,
    );
  }
}

enum PointProductCategory {
  coupon('优惠券'),
  souvenir('文创好物'),
  service('便民服务'),
  event('活动权益');

  const PointProductCategory(this.label);

  final String label;

  static PointProductCategory parse(String value) {
    return PointProductCategory.values.firstWhere(
      (category) => category.name == value,
      orElse: () => PointProductCategory.coupon,
    );
  }
}

enum PointOrderStatus {
  pendingUse('待使用'),
  used('已使用'),
  expired('已过期'),
  canceled('已取消');

  const PointOrderStatus(this.label);

  final String label;

  static PointOrderStatus parse(String value) {
    return PointOrderStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => PointOrderStatus.pendingUse,
    );
  }
}

class PointTask {
  const PointTask({
    required this.id,
    required this.title,
    required this.description,
    required this.points,
    required this.iconKey,
    this.daily = false,
  });

  final String id;
  final String title;
  final String description;
  final int points;
  final String iconKey;
  final bool daily;
}

class PointProduct {
  const PointProduct({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.pointsPrice,
    required this.stock,
    required this.coverKey,
    required this.exchangeNote,
    required this.rules,
    this.limitPerUser = 1,
    this.badge,
  });

  final String id;
  final String title;
  final String description;
  final PointProductCategory category;
  final int pointsPrice;
  final int stock;
  final String coverKey;
  final String exchangeNote;
  final List<String> rules;
  final int limitPerUser;
  final String? badge;

  bool get inStock => stock > 0;
}

class PointTransaction {
  const PointTransaction({
    required this.id,
    required this.kind,
    required this.title,
    required this.time,
    required this.points,
    this.remark,
  });

  final String id;
  final PointTransactionKind kind;
  final String title;
  final String time;
  final int points;
  final String? remark;
}

class PointExchangeOrder {
  const PointExchangeOrder({
    required this.id,
    required this.product,
    required this.status,
    required this.code,
    required this.time,
    this.usedTime,
  });

  final String id;
  final PointProduct product;
  final PointOrderStatus status;
  final String code;
  final String time;
  final String? usedTime;

  PointExchangeOrder copyWith({PointOrderStatus? status, String? usedTime}) {
    return PointExchangeOrder(
      id: id,
      product: product,
      status: status ?? this.status,
      code: code,
      time: time,
      usedTime: usedTime ?? this.usedTime,
    );
  }
}
