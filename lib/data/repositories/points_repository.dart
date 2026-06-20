import '../../domain/models/points.dart';

class PointsRepository {
  const PointsRepository();

  int get initialBalance => 1280;

  List<PointTask> get tasks => const [
    PointTask(
      id: 'daily-checkin',
      title: '每日签到',
      description: '每天首次签到可领取积分',
      points: 10,
      iconKey: 'checkin',
      daily: true,
    ),
    PointTask(
      id: 'read-news',
      title: '阅读新闻',
      description: '浏览一篇本地新闻后领取',
      points: 20,
      iconKey: 'read',
    ),
    PointTask(
      id: 'favorite-content',
      title: '收藏内容',
      description: '收藏感兴趣的新闻或视频',
      points: 15,
      iconKey: 'favorite',
    ),
    PointTask(
      id: 'comment-content',
      title: '评论互动',
      description: '发表一条文明评论',
      points: 25,
      iconKey: 'comment',
    ),
    PointTask(
      id: 'reserve-live',
      title: '预约直播',
      description: '预约一场本地直播节目',
      points: 30,
      iconKey: 'live',
    ),
    PointTask(
      id: 'submit-report',
      title: '提交爆料',
      description: '提交一条有效民生线索',
      points: 50,
      iconKey: 'report',
    ),
    PointTask(
      id: 'apply-service',
      title: '办理服务',
      description: '提交一次便民服务申请',
      points: 40,
      iconKey: 'service',
    ),
  ];

  List<PointProduct> get products => const [
    PointProduct(
      id: 'coffee-coupon',
      title: '本地咖啡满减券',
      description: '合作门店消费满 30 元可抵 10 元',
      category: PointProductCategory.coupon,
      pointsPrice: 180,
      stock: 18,
      coverKey: 'coffee',
      exchangeNote: '兑换后在合作门店出示核销码使用。',
      rules: ['有效期 30 天', '每人限兑 1 次', '不与其他活动叠加'],
      badge: '热门',
    ),
    PointProduct(
      id: 'bus-pass',
      title: '公交出行权益',
      description: '本地公交单次出行权益券',
      category: PointProductCategory.service,
      pointsPrice: 260,
      stock: 9,
      coverKey: 'bus',
      exchangeNote: '兑换后在出行服务窗口出示权益码。',
      rules: ['有效期 15 天', '仅限本地公交权益场景', '过期自动失效'],
    ),
    PointProduct(
      id: 'movie-coupon',
      title: '社区影票优惠券',
      description: '社区公益放映活动优惠名额',
      category: PointProductCategory.event,
      pointsPrice: 320,
      stock: 6,
      coverKey: 'movie',
      exchangeNote: '兑换成功后按短信或现场提示核销。',
      rules: ['活动当天有效', '名额不可转赠', '请提前 15 分钟到场'],
    ),
    PointProduct(
      id: 'cultural-bag',
      title: '城市文创帆布袋',
      description: '融媒联名城市文创纪念品',
      category: PointProductCategory.souvenir,
      pointsPrice: 680,
      stock: 4,
      coverKey: 'bag',
      exchangeNote: '兑换后到融媒服务台凭码领取。',
      rules: ['不提供物流配送', '领取时请出示手机号', '每人限兑 1 次'],
    ),
    PointProduct(
      id: 'library-seat',
      title: '图书馆预约权益',
      description: '周末阅读区优先预约名额',
      category: PointProductCategory.service,
      pointsPrice: 420,
      stock: 0,
      coverKey: 'library',
      exchangeNote: '兑换后在图书馆服务台核验使用。',
      rules: ['周末有效', '库存有限', '请按预约时段到场'],
      badge: '已兑完',
    ),
    PointProduct(
      id: 'festival-ticket',
      title: '文旅节活动名额',
      description: '本地文旅节互动体验预约资格',
      category: PointProductCategory.event,
      pointsPrice: 960,
      stock: 3,
      coverKey: 'festival',
      exchangeNote: '兑换后凭权益码进入活动候补名单。',
      rules: ['名额确认以现场通知为准', '每人限兑 1 次', '活动开始后不可核销'],
    ),
  ];

  PointTask? taskById(String id) {
    for (final task in tasks) {
      if (task.id == id) return task;
    }
    return null;
  }

  PointProduct? productById(String id) {
    for (final product in products) {
      if (product.id == id) return product;
    }
    return null;
  }
}
