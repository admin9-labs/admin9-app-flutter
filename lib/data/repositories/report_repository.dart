import '../../domain/models/report_item.dart';

class ReportRepository {
  const ReportRepository();

  List<ReportItem> get reports => const [
    ReportItem(
      id: 'road-light',
      title: '小区门口路灯连续三晚不亮',
      location: '锦江区',
      status: '处理中',
      time: '2小时前',
      content: '居民反馈小区门口连续三晚路灯不亮，夜间通行存在安全隐患。',
    ),
    ReportItem(
      id: 'bus-stop',
      title: '公交站牌信息更新不及时',
      location: '高新区',
      status: '已受理',
      time: '昨天 18:20',
      content: '公交站牌线路调整后没有及时更新，老人乘车容易看错站点。',
    ),
    ReportItem(
      id: 'river-clean',
      title: '河道步道杂物堆放影响通行',
      location: '青羊区',
      status: '已办结',
      time: '昨天 09:12',
      content: '河道步道旁堆放杂物，影响市民散步和骑行通行。',
    ),
    ReportItem(
      id: 'crosswalk-signal',
      title: '路口行人信号灯等待时间过长',
      location: '武侯区',
      status: '已受理',
      time: '昨天 21:05',
      content: '居民反映路口行人信号灯等待时间过长，高峰期容易出现抢行。',
    ),
    ReportItem(
      id: 'market-noise',
      title: '早市摊位噪声影响周边居民',
      location: '成华区',
      status: '处理中',
      time: '昨天 07:40',
      content: '临街早市装卸和叫卖声较大，影响周边居民清晨休息。',
    ),
    ReportItem(
      id: 'bike-lane',
      title: '非机动车道被临停车辆占用',
      location: '金牛区',
      status: '已受理',
      time: '前天 19:30',
      content: '非机动车道长期有车辆临停，骑行市民需要绕入机动车道。',
    ),
    ReportItem(
      id: 'trash-point',
      title: '垃圾投放点清运不及时',
      location: '双流区',
      status: '处理中',
      time: '前天 14:18',
      content: '小区外垃圾投放点满溢，异味明显，希望增加清运频次。',
    ),
    ReportItem(
      id: 'school-gate',
      title: '学校门口接送秩序拥堵',
      location: '郫都区',
      status: '已办结',
      time: '3天前',
      content: '放学时段车辆聚集较多，现场已增设临时引导和分流提示。',
    ),
    ReportItem(
      id: 'park-facility',
      title: '公园健身器材螺丝松动',
      location: '温江区',
      status: '处理中',
      time: '3天前',
      content: '市民发现公园健身器材连接处松动，存在使用风险。',
    ),
  ];
}
