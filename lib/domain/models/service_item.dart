enum ServiceTargetType {
  h5,
  internalPage,
  phone,
  email,
  externalApp,
  miniProgram,
  page,
  placeholder,
}

class ServiceTarget {
  const ServiceTarget({
    this.type = ServiceTargetType.placeholder,
    this.value = '',
    this.feedback = '服务暂不可用',
    this.appId = '',
    this.userName = '',
    this.path = '',
    this.pageId,
  });

  const ServiceTarget.miniProgram({
    required this.appId,
    required this.userName,
    this.path = '',
    this.feedback = '微信小程序跳转待接入',
  }) : type = ServiceTargetType.miniProgram,
       value = '',
       pageId = null;

  const ServiceTarget.page({required this.pageId, this.feedback = '页面跳转待接入'})
    : type = ServiceTargetType.page,
      value = '',
      appId = '',
      userName = '',
      path = '';

  final ServiceTargetType type;
  final String value;
  final String feedback;
  final String appId;
  final String userName;
  final String path;
  final int? pageId;
}

class ServiceSection {
  const ServiceSection({
    required this.id,
    required this.title,
    required this.items,
    this.showMore = true,
    this.moreLabel = '更多',
    this.displayLimit = 8,
  });

  final String id;
  final String title;
  final List<ServiceItem> items;
  final bool showMore;
  final String moreLabel;
  final int? displayLimit;
}

class ServiceItem {
  const ServiceItem({
    required this.id,
    required this.title,
    required this.description,
    required this.iconKey,
    this.iconUrl = '',
    this.target = const ServiceTarget(),
    this.guide = '请填写办理信息',
  });

  final String id;
  final String title;
  final String description;
  final String iconKey;
  final String iconUrl;
  final ServiceTarget target;
  final String guide;

  String get searchableText =>
      '$title $description ${target.value} ${target.appId} '
      '${target.userName} ${target.path} ${target.pageId ?? ''}';
}
