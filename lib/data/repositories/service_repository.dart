import '../../domain/models/service_item.dart';

class ServiceRepository {
  const ServiceRepository();

  List<ServiceSection> get sections => const [
    ServiceSection(
      id: 'government',
      title: '政务服务',
      items: [
        ServiceItem(
          id: 'national-government-service',
          title: '国家政务服务平台',
          description: '微信小程序入口',
          iconKey: 'government',
          iconUrl:
              'https://alifile.i0834.cn/nmip/2024-09-20/66689074/33E49F7D29CEFAC5A9C8FAC3B474DDF1.jpg',
          target: ServiceTarget.miniProgram(
            appId: 'wx2eec5fb00157a603',
            userName: 'gh_0e163ff2ba74',
          ),
        ),
        ServiceItem(
          id: 'liangshan-card',
          title: '凉山一卡通',
          description: '微信小程序入口',
          iconKey: 'government',
          iconUrl:
              'https://alifile.i0834.cn/nmip/2024-09-20/66686258/BACB783EEECC686A4436EAD16D9D1A69.png',
          target: ServiceTarget.miniProgram(
            appId: 'wx518af1540ffb8418',
            userName: 'gh_f0047e7ebac5',
          ),
        ),
        ServiceItem(
          id: 'liangshan-rural-data',
          title: '凉山州三农大数据',
          description: '微信小程序入口',
          iconKey: 'government',
          iconUrl:
              'https://alifile.i0834.cn/nmip/2024-09-20/66689148/1394F8B1C8F4BDEE53D6C3EE18532DE0.jpg',
          target: ServiceTarget.miniProgram(
            appId: 'wxa9c0edeed5d43881',
            userName: 'gh_04d41a9f0e75',
          ),
        ),
        ServiceItem(
          id: 'liangshan-12345',
          title: '凉山12345',
          description: '微信小程序入口',
          iconKey: 'government',
          iconUrl:
              'https://alifile.i0834.cn/nmip/2024-09-20/66689509/2C9BB2332C32F3653AC3895DAA7466B4.png',
          target: ServiceTarget.miniProgram(
            appId: 'wxfa6f8eb6804a12ef',
            userName: 'gh_380f3a579483',
          ),
        ),
        ServiceItem(
          id: 'liangshan-anti-drug-volunteer',
          title: '凉山禁毒志愿者',
          description: '微信小程序入口',
          iconKey: 'government',
          iconUrl:
              'https://alifile.i0834.cn/nmip/2024-09-20/66689816/96C0E197D035BC948BF6C1F8375DB66F.jpg',
          target: ServiceTarget.miniProgram(
            appId: 'wx9757888a20f0ecff',
            userName: 'gh_e300a4eddbec',
          ),
        ),
        ServiceItem(
          id: 'liangshan-police-report',
          title: '凉山公安违法犯罪线索举报',
          description: '微信小程序入口',
          iconKey: 'government',
          iconUrl:
              'https://alifile.i0834.cn/nmip/2024-09-20/66689870/E082246FE4C75C18EE358324808EFF8A.jpg',
          target: ServiceTarget.miniProgram(
            appId: 'wxe99d5a5b094fbd15',
            userName: 'gh_236a25bdb35b',
          ),
        ),
        ServiceItem(
          id: 'liangshan-smart-justice',
          title: '凉山州智慧司法',
          description: '微信小程序入口',
          iconKey: 'government',
          iconUrl:
              'https://alifile.i0834.cn/nmip/2024-09-20/66690127/7451E51356604B6C9C853D536533FEB5.jpg',
          target: ServiceTarget.miniProgram(
            appId: 'wx47887911b297dcad',
            userName: 'gh_c4eab178f5f6',
          ),
        ),
        ServiceItem(
          id: 'suomahua-volunteer',
          title: '索玛花志愿者',
          description: '微信小程序入口',
          iconKey: 'government',
          iconUrl:
              'https://alifile.i0834.cn/nmip/2024-09-20/66690451/876C7987C14EA8F5948F09C6EDDA18B9.jpg',
          target: ServiceTarget.miniProgram(
            appId: 'wxe06ae6593d35ef3f',
            userName: 'gh_658177cc6ed9',
          ),
        ),
        ServiceItem(
          id: 'electronic-business-license',
          title: '电子营业执照',
          description: '微信小程序入口',
          iconKey: 'government',
          iconUrl:
              'https://alifile.i0834.cn/nmip/2024-09-20/66690959/DA95237D1AE77750802B0E7F8F0AE46B.jpg',
          target: ServiceTarget.miniProgram(
            appId: 'wx63a9813a3b8601d2',
            userName: 'gh_ecb804db5fef',
          ),
        ),
        ServiceItem(
          id: 'national-housing-fund',
          title: '全国住房公积金',
          description: '微信小程序入口',
          iconKey: 'government',
          iconUrl:
              'https://alifile.i0834.cn/nmip/2024-09-20/66692145/E816B43F1D191EB7960FB0C93FD40631.jpg',
          target: ServiceTarget.miniProgram(
            appId: 'wx4dea6f132ae99e01',
            userName: 'gh_fc1db4789939',
          ),
        ),
        ServiceItem(
          id: 'liangshan-human-resources',
          title: '凉山人社',
          description: 'H5 服务入口',
          iconKey: 'government',
          iconUrl:
              'https://alifile.i0834.cn/nmip/2024-09-24/66757436/7BBE750C1E0088DD9F89081122DCE3FE.jpg',
          target: ServiceTarget(
            type: ServiceTargetType.h5,
            value: 'https://lszrs.com.cn/lswx/index.html',
            feedback: '已打开凉山人社',
          ),
        ),
        ServiceItem(
          id: 'civil-affairs-service',
          title: '民政通',
          description: '微信小程序入口',
          iconKey: 'government',
          iconUrl:
              'https://alifile.i0834.cn/nmip/2024-09-20/66692311/7B41ECD94A3CDB83877FE818D3151F50.jpg',
          target: ServiceTarget.miniProgram(
            appId: 'wx12f5a00807e3ec6a',
            userName: 'gh_2e039694bf46',
          ),
        ),
        ServiceItem(
          id: 'state-council-client',
          title: '国务院客户端',
          description: '微信小程序入口',
          iconKey: 'government',
          iconUrl:
              'https://alifile.i0834.cn/nmip/2024-09-20/66692355/793F66A8A5A20648F7A6C287887E041D.jpg',
          target: ServiceTarget.miniProgram(
            appId: 'wxbebb3cdd9b331046',
            userName: 'gh_dc5faf6be488',
          ),
        ),
        ServiceItem(
          id: 'social-security-payment',
          title: '社保缴费',
          description: 'H5 服务入口',
          iconKey: 'government',
          iconUrl:
              'https://alifile.i0834.cn/nmip/2024-09-24/66757531/D399DA7C11A099B8B6DC392E9C033D06.jpg',
          target: ServiceTarget(
            type: ServiceTargetType.h5,
            value: 'https://sichuan.chinatax.gov.cn/sbjf/',
            feedback: '已打开社保缴费',
          ),
        ),
        ServiceItem(
          id: 'traffic-12123',
          title: '交管12123',
          description: '微信小程序入口',
          iconKey: 'government',
          iconUrl:
              'https://alifile.i0834.cn/nmip/2024-09-20/66692417/D130229BFBACC1570B996BFE72627B13.png',
          target: ServiceTarget.miniProgram(
            appId: 'wx49a80525eebd2583',
            userName: 'gh_79770c4ab856',
          ),
        ),
        ServiceItem(
          id: 'medical-insurance-certificate',
          title: '医保凭证',
          description: '微信小程序入口',
          iconKey: 'government',
          iconUrl:
              'https://alifile.i0834.cn/nmip/2024-09-29/81285064/FA3BAA8A8B4C1C52E0971A2F6C3AE177.png',
          target: ServiceTarget.miniProgram(
            appId: 'wx7ec43a6a6c80544d',
            userName: 'gh_45334679e384',
          ),
        ),
      ],
    ),
    ServiceSection(
      id: 'life',
      title: '生活服务',
      items: [
        ServiceItem(
          id: 'life-payment',
          title: '生活缴费',
          description: '微信小程序入口',
          iconKey: 'life',
          iconUrl:
              'https://alifile.i0834.cn/nmip/2024-09-20/66692502/0BB8BCEF079901EE16AC4473F8AE3659.png',
          target: ServiceTarget.miniProgram(
            appId: 'wxd2ade0f25a874ee2',
            userName: 'gh_aceb9bd462ab',
          ),
        ),
        ServiceItem(
          id: 'china-telecom',
          title: '中国电信',
          description: '微信小程序入口',
          iconKey: 'life',
          iconUrl:
              'https://alifile.i0834.cn/nmip/2024-09-20/66692504/EC8BCDEEF0E7F73A342339A9B3D55C4F.jpg',
          target: ServiceTarget.miniProgram(
            appId: 'wxd4daf5a66b681275',
            userName: 'gh_77d07394e351',
          ),
        ),
        ServiceItem(
          id: 'china-mobile',
          title: '中国移动',
          description: '微信小程序入口',
          iconKey: 'life',
          iconUrl:
              'https://alifile.i0834.cn/nmip/2024-09-20/66692505/DB24F49750BA8CBCC94245AE307074AC.jpg',
          target: ServiceTarget.miniProgram(
            appId: 'wx43aab19a93a3a6f2',
            userName: 'gh_3400f59b94d0',
          ),
        ),
        ServiceItem(
          id: 'china-unicom',
          title: '中国联通',
          description: '微信小程序入口',
          iconKey: 'life',
          iconUrl:
              'https://alifile.i0834.cn/nmip/2024-09-20/66692530/9D8983942293844542F74C02C2E2C6DF.jpg',
          target: ServiceTarget.miniProgram(
            appId: 'wx56af9763578b9a93',
            userName: 'gh_2bab3e2deed1',
          ),
        ),
        ServiceItem(
          id: 'yonghui-supermarket',
          title: '永辉超市',
          description: '微信小程序入口',
          iconKey: 'life',
          iconUrl:
              'https://alifile.i0834.cn/nmip/2024-09-20/66692599/8D71F7F2BEE58F3E347FCDBE81A9F9B2.jpg',
          target: ServiceTarget.miniProgram(
            appId: 'wxc9cf7c95499ee604',
            userName: 'gh_f5cd32cf3467',
          ),
        ),
        ServiceItem(
          id: 'walmart',
          title: '沃尔玛',
          description: '微信小程序入口',
          iconKey: 'life',
          iconUrl:
              'https://alifile.i0834.cn/nmip/2024-09-20/66692601/1AEBAD1CBF9C19549D20F627FC93BECC.jpg',
          target: ServiceTarget.miniProgram(
            appId: 'wx83231ee9993066b7',
            userName: 'gh_3ebf45485602',
          ),
        ),
        ServiceItem(
          id: 'the-58-city',
          title: '58同城',
          description: '微信小程序入口',
          iconKey: 'life',
          iconUrl:
              'https://alifile.i0834.cn/nmip/2024-09-20/66692695/947D133E2D3647CCD33D3CFB783FAFDE.jpg',
          target: ServiceTarget.miniProgram(
            appId: 'wxc97b21c63d084d92',
            userName: 'gh_c06ae379d219',
          ),
        ),
        ServiceItem(
          id: 'meituan',
          title: '美团',
          description: '微信小程序入口',
          iconKey: 'life',
          iconUrl:
              'https://alifile.i0834.cn/nmip/2024-09-20/66692720/054ED3F3B9BD8450EBCFB6684C5E90DB.jpg',
          target: ServiceTarget.miniProgram(
            appId: 'wx2c348cf579062e56',
            userName: 'gh_72a4eb2d4324',
          ),
        ),
        ServiceItem(
          id: 'pinduoduo',
          title: '拼多多',
          description: '微信小程序入口',
          iconKey: 'life',
          iconUrl:
              'https://alifile.i0834.cn/nmip/2024-09-20/66692747/36541FA1B2CA7E45A4EB0F5F48144942.jpg',
          target: ServiceTarget.miniProgram(
            appId: 'wx32540bd863b27570',
            userName: 'gh_0e7477744313',
          ),
        ),
        ServiceItem(
          id: 'dada-market',
          title: '达达网络商城',
          description: '微信小程序入口',
          iconKey: 'life',
          iconUrl:
              'https://alifile.i0834.cn/nmip/2024-09-20/66692800/544B904B491618ED5F0A0AD2155D1264.jpg',
          target: ServiceTarget.miniProgram(
            appId: 'wx3cce21086587129c',
            userName: 'gh_e00c034dd25e',
          ),
        ),
        ServiceItem(
          id: 'beike-house',
          title: '贝壳找房',
          description: '微信小程序入口',
          iconKey: 'life',
          iconUrl:
              'https://alifile.i0834.cn/nmip/2024-09-20/66692894/6A24922807D8F81F35E41024C298BF05.jpg',
          target: ServiceTarget.miniProgram(
            appId: 'wxcfd8224218167d98',
            userName: 'gh_2dbd87cb164c',
          ),
        ),
        ServiceItem(
          id: 'wanda-plaza',
          title: '万达广场',
          description: '微信小程序入口',
          iconKey: 'life',
          iconUrl:
              'https://alifile.i0834.cn/nmip/2024-09-20/66692901/4F29FDC5C0C829C79F15F6A14B364035.jpg',
          target: ServiceTarget.miniProgram(
            appId: 'wx07dfb5d79541eca9',
            userName: 'gh_53441af22e1c',
          ),
        ),
        ServiceItem(
          id: 'xinhua-winshare',
          title: '新华文轩',
          description: '微信小程序入口',
          iconKey: 'life',
          iconUrl:
              'https://alifile.i0834.cn/nmip/2025-05-20/86030713/248CE8B7270F5E8940BA306BD0F600E5.jpg',
          target: ServiceTarget.miniProgram(
            appId: 'wxe0f131337f6384f0',
            userName: 'gh_8482df2c3c12',
          ),
        ),
      ],
    ),
    ServiceSection(
      id: 'education',
      title: '教育考试',
      items: [
        ServiceItem(
          id: 'lufeng-school-home-education',
          title: '凉山州泸峰中学家校共育',
          description: '微信小程序入口',
          iconKey: 'education',
          iconUrl:
              'https://alifile.i0834.cn/nmip/2024-09-20/66692962/AAE10ECEEB6D149413427E4E474EE268.jpg',
          target: ServiceTarget.miniProgram(
            appId: 'wx36d7f1f13a40ae57',
            userName: 'gh_ed3932618b36',
          ),
        ),
        ServiceItem(
          id: 'china-education-exam',
          title: '中国教育考试网',
          description: '微信小程序入口',
          iconKey: 'education',
          iconUrl:
              'https://alifile.i0834.cn/nmip/2024-09-20/66692984/0E462CBF04EB304BC860D4C66CEC9432.jpg',
          target: ServiceTarget.miniProgram(
            appId: 'wxa56afc785454c86b',
            userName: 'gh_9bc87509b26b',
          ),
        ),
        ServiceItem(
          id: 'sichuan-vocational-admission',
          title: '四川职业技术学院招生平台',
          description: '微信小程序入口',
          iconKey: 'education',
          iconUrl:
              'https://alifile.i0834.cn/nmip/2024-09-20/66693021/7B8A897132BD414441E4CB49001DDEF6.jpg',
          target: ServiceTarget.miniProgram(
            appId: 'wx539a943cca4cbfd3',
            userName: 'gh_1259b088358e',
          ),
        ),
        ServiceItem(
          id: 'mianning-second-school',
          title: '冕宁县第二中学校',
          description: '微信小程序入口',
          iconKey: 'education',
          iconUrl:
              'https://alifile.i0834.cn/nmip/2024-09-20/66693109/D697075D5BFDBE0D6124ECC200971691.jpg',
          target: ServiceTarget.miniProgram(
            appId: 'wx679dc783ea7658ec',
            userName: 'gh_c805ef1fa727',
          ),
        ),
        ServiceItem(
          id: 'xichang-smart-education',
          title: '西昌智慧教育',
          description: '微信小程序入口',
          iconKey: 'education',
          iconUrl:
              'https://alifile.i0834.cn/nmip/2024-09-20/66693370/ADD7415F04E32C53584915CD96BDD8CF.jpg',
          target: ServiceTarget.miniProgram(
            appId: 'wx73fced5a4b013055',
            userName: 'gh_355616fa1f96',
          ),
        ),
        ServiceItem(
          id: 'exam-id-photo-pro',
          title: '考试证件照Pro',
          description: '微信小程序入口',
          iconKey: 'education',
          iconUrl:
              'https://alifile.i0834.cn/nmip/2024-09-20/66693443/E11C9D4ECB13DCA78BA7A4309B5FAAB2.jpg',
          target: ServiceTarget.miniProgram(
            appId: 'wx850d74e64e45e9f0',
            userName: 'gh_e31dddec4259',
          ),
        ),
        ServiceItem(
          id: 'driving-test-guide',
          title: '驾考宝典',
          description: '微信小程序入口',
          iconKey: 'education',
          iconUrl:
              'https://alifile.i0834.cn/nmip/2024-09-20/66693504/2463B1AA5AC935AB40B7E193BA514223.jpg',
          target: ServiceTarget.miniProgram(
            appId: 'wx36fbd76c4c8c8dbf',
            userName: 'gh_b7d804fd3bb4',
          ),
        ),
        ServiceItem(
          id: 'national-medical-exam',
          title: '国家医学考试中心',
          description: '微信小程序入口',
          iconKey: 'education',
          iconUrl:
              'https://alifile.i0834.cn/nmip/2024-09-20/66693566/A41B7BB08674B4A3EFA62E9A8ECF73F1.jpg',
          target: ServiceTarget.miniProgram(
            appId: 'wx81e247e32e6e988d',
            userName: 'gh_3ddc78fdc1ce',
          ),
        ),
      ],
    ),
    ServiceSection(
      id: 'medical',
      title: '医疗健康',
      items: [
        ServiceItem(
          id: 'sichuan-internet-hospital-liangshan',
          title: '四川省互联网总医院凉山分院',
          description: '微信小程序入口',
          iconKey: 'medical',
          iconUrl:
              'https://alifile.i0834.cn/nmip/2024-09-20/66693650/A88C5945885D04A16F1E32283C225259.jpg',
          target: ServiceTarget.miniProgram(
            appId: 'wx49f53bf258caf06c',
            userName: 'gh_430135e69031',
          ),
        ),
        ServiceItem(
          id: 'liangshan-first-hospital',
          title: '凉山州第一人民医院',
          description: 'H5 服务入口',
          iconKey: 'medical',
          iconUrl:
              'https://alifile.i0834.cn/nmip/2024-09-24/66757462/A3B243957E9914F91BA6958A2B6ECEAB.jpg',
          target: ServiceTarget(
            type: ServiceTargetType.h5,
            value: 'https://m.lsz120.cn/',
            feedback: '已打开凉山州第一人民医院',
          ),
        ),
        ServiceItem(
          id: 'liangshan-seventh-hospital',
          title: '凉山州第七人民医院',
          description: '微信小程序入口',
          iconKey: 'medical',
          iconUrl:
              'https://alifile.i0834.cn/nmip/2024-09-20/66693756/A370936A7BE26AC7B1702BF17E1587E5.jpg',
          target: ServiceTarget.miniProgram(
            appId: 'wxbec68df200cd536e',
            userName: 'gh_3f902e3d60db',
          ),
        ),
        ServiceItem(
          id: 'liangshan-tiered-medical-care',
          title: '凉山分级诊疗居民端',
          description: '微信小程序入口',
          iconKey: 'medical',
          iconUrl:
              'https://alifile.i0834.cn/nmip/2024-09-20/66693842/AF88CA12440E364E14C53672932B2296.jpg',
          target: ServiceTarget.miniProgram(
            appId: 'wxd23973100a6ba0cf',
            userName: 'gh_f846df529c72',
          ),
        ),
        ServiceItem(
          id: 'ctg-xichang-hospital',
          title: '川投西昌医院',
          description: '微信小程序入口',
          iconKey: 'medical',
          iconUrl:
              'https://alifile.i0834.cn/nmip/2024-09-20/66693870/4ECED819DD50709883261339491B24DA.jpg',
          target: ServiceTarget.miniProgram(
            appId: 'wxa4203699cb514ea9',
            userName: 'gh_9f46d6a0cd78',
          ),
        ),
        ServiceItem(
          id: 'meinain-health',
          title: '美年大健康',
          description: '微信小程序入口',
          iconKey: 'medical',
          iconUrl:
              'https://alifile.i0834.cn/nmip/2024-09-20/66693906/486F074229FB7D488ED743ABCC564C00.jpg',
          target: ServiceTarget.miniProgram(
            appId: 'wx8276abe77f1b1b61',
            userName: 'gh_b854b2d5ab28',
          ),
        ),
      ],
    ),
    ServiceSection(
      id: 'travel',
      title: '旅游出行',
      items: [
        ServiceItem(
          id: 'panda-youtu',
          title: '熊猫优途',
          description: '微信小程序入口',
          iconKey: 'travel',
          iconUrl:
              'https://alifile.i0834.cn/nmip/2024-09-20/66693925/C975C3B5ECC91CBC072B0C8498063EDA.jpg',
          target: ServiceTarget.miniProgram(
            appId: 'wxe3f2cf47dc7a4226',
            userName: 'gh_1cff45718265',
          ),
        ),
        ServiceItem(
          id: 'colorful-yunxia-art',
          title: '五彩云霞新文艺',
          description: '微信小程序入口',
          iconKey: 'travel',
          iconUrl:
              'https://alifile.i0834.cn/nmip/2024-09-20/66693929/4AC6601B97A3338FEA69599D801ACA9D.jpg',
          target: ServiceTarget.miniProgram(
            appId: 'wx8592761cc8f9b098',
            userName: 'gh_b59cd98343a2',
          ),
        ),
        ServiceItem(
          id: 'liangshan-cultural-center',
          title: '凉山彝族自治州文化馆',
          description: '微信小程序入口',
          iconKey: 'travel',
          iconUrl:
              'https://alifile.i0834.cn/nmip/2024-09-20/66693946/8A381CCE3A55C7E5129702DE5196BF9D.jpg',
          target: ServiceTarget.miniProgram(
            appId: 'wxb0e490ea11af4a8c',
            userName: 'gh_3ed3e75cdad9',
          ),
        ),
        ServiceItem(
          id: 'liangshan-asiniuniu-agriculture',
          title: '凉山阿斯牛牛农业',
          description: '微信小程序入口',
          iconKey: 'travel',
          iconUrl:
              'https://alifile.i0834.cn/nmip/2024-09-20/66694030/DA87BB24D8B5C1493514304BF9164CBD.jpg',
          target: ServiceTarget.miniProgram(
            appId: 'wxeedad512dae7aa08',
            userName: 'gh_62bc5f11055d',
          ),
        ),
        ServiceItem(
          id: 'qionghai-wetland',
          title: '邛海湿地',
          description: '微信小程序入口',
          iconKey: 'travel',
          iconUrl:
              'https://alifile.i0834.cn/nmip/2024-09-20/66694107/61D3F9291D081EEC8213DDFED323B405.jpg',
          target: ServiceTarget.miniProgram(
            appId: 'wx1145ffadcdc29b0f',
            userName: 'gh_2d74fbb2cfe3',
          ),
        ),
      ],
    ),
    ServiceSection(
      id: 'transport',
      title: '交通出行',
      items: [
        ServiceItem(
          id: 'railway-12306',
          title: '铁路12306',
          description: '微信小程序入口',
          iconKey: 'traffic',
          iconUrl:
              'https://alifile.i0834.cn/nmip/2024-09-20/66694142/228C7A28749D22EAE8B31E6FAA9329AD.jpg',
          target: ServiceTarget.miniProgram(
            appId: 'wxa51f55ab3b2655b9',
            userName: 'gh_83afe0555afa',
          ),
        ),
        ServiceItem(
          id: 'bus-ride-code',
          title: '公交乘车码',
          description: '微信小程序入口',
          iconKey: 'traffic',
          iconUrl:
              'https://alifile.i0834.cn/nmip/2024-09-20/66694216/1C61405B28330AFD527C5F338C03CB63.png',
          target: ServiceTarget.miniProgram(
            appId: 'wxbb58374cdce267a6',
            userName: 'gh_3cf62f4f1d52',
          ),
        ),
        ServiceItem(
          id: 'taxi-driving-service',
          title: '打车代驾',
          description: '微信小程序入口',
          iconKey: 'traffic',
          iconUrl:
              'https://alifile.i0834.cn/nmip/2024-09-20/66694528/398737F30DF43A6F6218C86655C63413.jpg',
          target: ServiceTarget.miniProgram(
            appId: 'wx65cc950f42e8fff1',
            userName: 'gh_ad64296dc8bd',
          ),
        ),
        ServiceItem(
          id: 'coach-ticket',
          title: '汽车票',
          description: '微信小程序入口',
          iconKey: 'traffic',
          iconUrl:
              'https://alifile.i0834.cn/nmip/2024-09-20/66694626/3AD7F1057ECF02193EA84368E08991E6.jpg',
          target: ServiceTarget.miniProgram(
            appId: 'wx2e89c10d00858ce5',
            userName: 'gh_89f503342c08',
          ),
        ),
        ServiceItem(
          id: 'flight-check-in',
          title: '航班值机',
          description: '微信小程序入口',
          iconKey: 'traffic',
          iconUrl:
              'https://alifile.i0834.cn/nmip/2024-09-20/66694315/007437EA43382095E78880DEB350822E.jpg',
          target: ServiceTarget.miniProgram(
            appId: 'wxcf62686dc9d61f90',
            userName: 'gh_266737106011',
          ),
        ),
        ServiceItem(
          id: 'tongtongxing',
          title: '通通行',
          description: '微信小程序入口',
          iconKey: 'traffic',
          iconUrl:
              'https://alifile.i0834.cn/nmip/2024-09-20/66694391/8DEA2A95CE90E1233D61C131F9CD4313.jpg',
          target: ServiceTarget.miniProgram(
            appId: 'wx5ef4c798253fd35b',
            userName: 'gh_212063604fea',
          ),
        ),
        ServiceItem(
          id: 'tencent-map',
          title: '腾讯地图',
          description: '微信小程序入口',
          iconKey: 'traffic',
          iconUrl:
              'https://alifile.i0834.cn/nmip/2024-09-20/66694392/09306ED0AFCEC85DDC43929457AB8FA8.jpg',
          target: ServiceTarget.miniProgram(
            appId: 'wx7643d5f831302ab0',
            userName: 'gh_ff25a9b4394d',
          ),
        ),
        ServiceItem(
          id: 'star-charge',
          title: '星星充电',
          description: '微信小程序入口',
          iconKey: 'traffic',
          iconUrl:
              'https://alifile.i0834.cn/nmip/2024-09-20/66694436/0D11A900EACD753AB27EA436529C7315.jpg',
          target: ServiceTarget.miniProgram(
            appId: 'wxb8e2ba3a621b447d',
            userName: 'gh_0fa1541a5849',
          ),
        ),
      ],
    ),
    ServiceSection(
      id: 'news',
      title: '新闻服务',
      items: [
        ServiceItem(
          id: 'read-newspaper',
          title: '读报纸',
          description: '站内页面入口',
          iconKey: 'news',
          iconUrl:
              'https://alifile.i0834.cn/nmip/2024-09-25/66768487/DBF8ED9F2D8CF26297318BF17F368FD4.png',
          target: ServiceTarget.page(pageId: 84572),
        ),
        ServiceItem(
          id: 'watch-tv',
          title: '看电视',
          description: '站内页面入口',
          iconKey: 'news',
          iconUrl:
              'https://alifile.i0834.cn/nmip/2024-09-25/66768517/E059B88BD790F91DA91616712D6FDC32.png',
          target: ServiceTarget.page(pageId: 83365),
        ),
        ServiceItem(
          id: 'listen-radio',
          title: '听广播',
          description: '站内页面入口',
          iconKey: 'news',
          iconUrl:
              'https://alifile.i0834.cn/nmip/2024-09-25/66768609/BE9BF0A577EAADA6922908D4971DCFDC.png',
          target: ServiceTarget.page(pageId: 84029),
        ),
        ServiceItem(
          id: 'slow-live',
          title: '慢直播',
          description: 'H5 服务入口',
          iconKey: 'news',
          iconUrl:
              'https://alifile.i0834.cn/nmip/2024-09-25/66768691/9FC0EA5C98333E29FD3C88B7CC8768BD.png',
          target: ServiceTarget(
            type: ServiceTargetType.h5,
            value: 'http://app.lsiptv.cn/5g/index.html',
            feedback: '已打开慢直播',
          ),
        ),
        ServiceItem(
          id: 'learn-yi-language',
          title: '学彝语',
          description: '站内页面入口',
          iconKey: 'news',
          iconUrl:
              'https://alifile.i0834.cn/nmip/2024-09-25/66768732/2B1E94DC97D4BBA96D6D80453370B180.png',
          target: ServiceTarget.page(pageId: 87242),
        ),
      ],
    ),
  ];

  List<ServiceItem> get services => [
    for (final section in sections)
      for (final item in section.items) item,
  ];

  List<ServiceItem> get defaultRecentItems => const [
    ServiceItem(
      id: 'liangshan-human-resources',
      title: '凉山人社',
      description: 'H5 服务入口',
      iconKey: 'government',
      iconUrl:
          'https://alifile.i0834.cn/nmip/2024-09-24/66757436/7BBE750C1E0088DD9F89081122DCE3FE.jpg',
      target: ServiceTarget(
        type: ServiceTargetType.h5,
        value: 'https://lszrs.com.cn/lswx/index.html',
        feedback: '已打开凉山人社',
      ),
    ),
    ServiceItem(
      id: 'liangshan-12345',
      title: '凉山12345',
      description: '微信小程序入口',
      iconKey: 'government',
      iconUrl:
          'https://alifile.i0834.cn/nmip/2024-09-20/66689509/2C9BB2332C32F3653AC3895DAA7466B4.png',
      target: ServiceTarget.miniProgram(
        appId: 'wxfa6f8eb6804a12ef',
        userName: 'gh_380f3a579483',
      ),
    ),
    ServiceItem(
      id: 'railway-12306',
      title: '铁路12306',
      description: '微信小程序入口',
      iconKey: 'traffic',
      iconUrl:
          'https://alifile.i0834.cn/nmip/2024-09-20/66694142/228C7A28749D22EAE8B31E6FAA9329AD.jpg',
      target: ServiceTarget.miniProgram(
        appId: 'wxa51f55ab3b2655b9',
        userName: 'gh_83afe0555afa',
      ),
    ),
  ];

  ServiceItem? findById(String id) {
    for (final item in services) {
      if (item.id == id) return item;
    }
    return null;
  }

  ServiceSection? sectionById(String id) {
    for (final section in sections) {
      if (section.id == id) return section;
    }
    return null;
  }
}
