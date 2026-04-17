// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get language => '语言';

  @override
  String get selectLanguage => '选择语言';

  @override
  String get profileSettings => '个人资料设置';

  @override
  String get onboardingWelcome => '欢迎来到 Pinnacle';

  @override
  String get continueButton => '继续';

  @override
  String get appTitle => '游客安全';

  @override
  String get appTagline => '保护每一次旅行';

  @override
  String get govBadge => '官方政府安全系统';

  @override
  String get signIn => '登录';

  @override
  String get loginWelcome => '欢迎回到游客安全系统';

  @override
  String get emailAddress => '邮箱地址';

  @override
  String get enterEmail => '请输入您的邮箱';

  @override
  String get password => '密码';

  @override
  String get enterPassword => '请输入您的密码';

  @override
  String get forgotPassword => '忘记密码？';

  @override
  String get noAccount => '没有账户？ ';

  @override
  String get createAccount => '创建账户';

  @override
  String get errorEmptyEmail => '请输入您的邮箱。';

  @override
  String get errorInvalidEmail => '请输入有效的邮箱地址。';

  @override
  String get errorEmptyPassword => '请输入您的密码。';

  @override
  String get errorLoginFailed => '登录失败，请重试。';

  @override
  String get registerWelcome => '注册以访问游客安全系统';

  @override
  String get fullName => '全名';

  @override
  String get enterFullName => '请输入您的全名';

  @override
  String get confirmPassword => '确认密码';

  @override
  String get enterConfirmPassword => '请确认您的密码';

  @override
  String get alreadyHaveAccount => '已有账户？ ';

  @override
  String get errorEmptyName => '请输入您的全名。';

  @override
  String get errorCreatePassword => '请创建密码。';

  @override
  String get errorShortPassword => '密码必须至少为8个字符。';

  @override
  String get errorPasswordMismatch => '密码不匹配。';

  @override
  String get errorRegisterFailed => '注册失败，请重试。';

  @override
  String get resetPassword => '重置密码';

  @override
  String get resetPasswordCaption => '输入您的邮箱，我们将发送重置链接';

  @override
  String get sendResetLink => '发送重置链接';

  @override
  String get rememberPassword => '记得密码？ ';

  @override
  String get protectedStatus => '受保护';

  @override
  String get currentLocation => '当前位置';

  @override
  String get lastUpdatedNow => '最后更新：刚刚';

  @override
  String get quickActions => '快速操作';

  @override
  String get reportIncident => '报告\n事件';

  @override
  String get shareLocation => '分享\n位置';

  @override
  String get emergencyContacts => '紧急\n联系人';

  @override
  String get safetyMap => '安全\n地图';

  @override
  String get sosText => 'SOS';

  @override
  String get recentAlerts => '近期警报';

  @override
  String get viewAll => '查看全部';

  @override
  String get navHome => '首页';

  @override
  String get navMap => '地图';

  @override
  String get navChat => '聊天';

  @override
  String get navAlerts => '警报';

  @override
  String get navProfile => '个人资料';

  @override
  String get errorMapSearch => '无法打开地图搜索';

  @override
  String get searchLocation => '搜索位置...';

  @override
  String get nearbyHospitals => '附近医院';

  @override
  String get policeStations => '警察局';

  @override
  String get pharmacies => '药店';

  @override
  String get embassies => '大使馆';

  @override
  String get atms => '自动取款机';

  @override
  String get publicTransit => '公共交通';

  @override
  String get publicRestrooms => '公共厕所';

  @override
  String get touristAttractions => '旅游景点';

  @override
  String get mapLegend => '地图图例';

  @override
  String get legendYourLocation => '您的位置';

  @override
  String get legendIncidentReports => '事件报告';

  @override
  String get legendCautionZones => '警示区域';

  @override
  String get legendHighRiskZones => '高风险区域';

  @override
  String get legendSafeZones => '安全区域';

  @override
  String get activeBadge => '活跃';

  @override
  String get alertBadge => '警报';

  @override
  String get warningBadge => '警告';

  @override
  String get dangerBadge => '危险';

  @override
  String get safeBadge => '安全';

  @override
  String get mapCopyright => '地图数据 © OpenStreetMap 贡献者';

  @override
  String get activeAlerts => '活跃警报';

  @override
  String get callHelpline => '呼叫旅游热线';

  @override
  String get cancelSosTitle => '取消SOS？';

  @override
  String get cancelSosMessage => '您确定要取消紧急警报吗？';

  @override
  String get keepActive => '保持启用';

  @override
  String get cancelSosButton => '取消SOS';

  @override
  String get sosActivated => 'SOS已激活';

  @override
  String get sosNotified => '已通知紧急服务。\n救援正在路上。';

  @override
  String get sosNameLabel => '姓名';

  @override
  String get sosLocationLabel => '位置';

  @override
  String get sosTimestampLabel => '时间戳';

  @override
  String cancellationAvailableFor(Object countdown) {
    return '取消有效倒计时：${countdown}s';
  }

  @override
  String get mockLocation => '16th Road, Bandra West';

  @override
  String get reportIncidentTitle => '报告事件';

  @override
  String get incidentTheft => '盗窃 / 扒窃';

  @override
  String get incidentMedical => '医疗突发事件';

  @override
  String get incidentAssault => '骚扰 / 袭击';

  @override
  String get incidentLostItem => '丢失物品';

  @override
  String get incidentSuspicious => '可疑活动';

  @override
  String get incidentAccident => '事故 / 碰撞';

  @override
  String get incidentOther => '其他';

  @override
  String get takePhoto => '拍照';

  @override
  String get chooseGallery => '从相册选择';

  @override
  String get errorSelectIncidentType => '请选择事件类型。';

  @override
  String get reportSubmittedTitle => '报告已提交';

  @override
  String get reportSubmittedMessage => '您的报告已安全提交至地方当局。如果需要，救援正在路上。';

  @override
  String get returnToHome => '返回主页';

  @override
  String get incidentTypeLabel => '事件类型';

  @override
  String get dateLabel => '日期';

  @override
  String get timeLabel => '时间';

  @override
  String get currentGpsLocation => '当前GPS位置';

  @override
  String get mapViewButton => '地图视图';

  @override
  String get descriptionLabel => '描述';

  @override
  String get attachmentsLabel => '附件';

  @override
  String get recordingAudio => '录音中...';

  @override
  String get voiceNote => '语音备忘录';

  @override
  String get mediaAdded => '已添加媒体';

  @override
  String get addMedia => '添加媒体';

  @override
  String get submitReportButton => '提交报告';

  @override
  String get govHelplines => '政府求助热线';

  @override
  String get touristHelpline => '旅游求助热线';

  @override
  String get policeHelpline => '警察';

  @override
  String get ambulanceHelpline => '救护车';

  @override
  String get fireBrigadeHelpline => '消防队';

  @override
  String get womensHelpline => '妇女求助热线';

  @override
  String get cyberCrimeHelpline => '网络犯罪求助热线';

  @override
  String get yourEmergencyContacts => '您的紧急联系人';

  @override
  String get noContactsAdded => '尚未添加任何个人联系人。';

  @override
  String get addContactsOnboarding => '在引导过程中添加联系人以在此处查看。';

  @override
  String get personalIdentity => '个人身份';

  @override
  String get firstName => '名';

  @override
  String get lastName => '姓';

  @override
  String get dob => '出生日期';

  @override
  String get nationality => '国籍';

  @override
  String get passportNum => '护照/ID 编号';

  @override
  String get passportExpiry => '护照有效期至';

  @override
  String get phoneTitle => '电话验证';

  @override
  String get phoneNumberLabel => '电话号码';

  @override
  String get verifyCode => '输入验证码';

  @override
  String get travelTimeline => '旅行时间表';

  @override
  String get arrivalDate => '抵达日期';

  @override
  String get departureDate => '离开日期';

  @override
  String get purposeOfVisit => '访问目的';

  @override
  String get placesToVisit => '计划访问的地点';

  @override
  String get contact1 => '联系人 1';

  @override
  String get contact2 => '联系人 2';

  @override
  String get relationship => '关系';

  @override
  String get stayDetailsTitle => '住宿详情';

  @override
  String get accommodationType => '住宿类型';

  @override
  String get propertyName => '酒店/物业名称';

  @override
  String get fullAddress => '详细地址';

  @override
  String get roomUnit => '房间/单元号';

  @override
  String get accommodationPhone => '住宿电话';

  @override
  String get medicalSafety => '医疗安全';

  @override
  String get bloodType => '血型';

  @override
  String get allergiesLabel => '有过敏史？';

  @override
  String get allergyDetails => '过敏详情';

  @override
  String get conditionsLabel => '有慢性疾病？';

  @override
  String get conditionDetails => '病情详情';

  @override
  String get medicationsLabel => '需要定期服药？';

  @override
  String get medicationDetails => '用药详情';

  @override
  String get insurancePolicy => '保险单号';

  @override
  String get consentPrivacy => '同意与隐私';

  @override
  String get consentTerms => '我同意服务条款和隐私政策';

  @override
  String get consentLocation => '我同意进行位置跟踪以进行安全监控';

  @override
  String get consentData => '我同意与紧急服务部门共享我的数据';

  @override
  String get consentAlerts => '我同意接收安全警报和通知';

  @override
  String get reqLabel => '必填';

  @override
  String get optLabel => '选填';

  @override
  String get editBtn => '编辑';

  @override
  String get doneBtn => '完成';

  @override
  String get signOutBtn => '退出';

  @override
  String get deleteAccBtn => '删除账号';

  @override
  String get deleteAccPrompt => '您确定要永久删除您的帐户吗？此操作无法撤消。';

  @override
  String get deleteBtn => '删除';

  @override
  String get cancelBtn => '取消';
}
