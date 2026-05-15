import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// In-app strings for English, Hindi, Nepali, and Russian.
class AppLocalizations {
  AppLocalizations._(this._code);
  final String _code;

  static const Set<String> supportedCodes = {'en', 'hi', 'ne', 'ru'};

  static String normalizeCode(String raw) {
    final c = raw.toLowerCase();
    if (c.startsWith('hi')) return 'hi';
    if (c.startsWith('ne')) return 'ne';
    if (c.startsWith('ru')) return 'ru';
    return 'en';
  }

  static AppLocalizations of(BuildContext context) {
    final l = Localizations.of<AppLocalizations>(context, AppLocalizations);
    assert(l != null, 'Missing AppLocalizations.delegate on MaterialApp');
    return l!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  String _t(String k) => _strings[_code]?[k] ?? _strings['en']![k]!;

  String homeHello(String name) => _t('homeHello').replaceAll('{name}', name);

  String shopAppBarTitle(String categoryEnglish) {
    switch (categoryEnglish) {
      case 'All':
        return _t('shopTitleAll');
      case 'Seeds':
        return _t('catSeeds');
      case 'Fertilizers':
        return _t('catFertilizers');
      case 'Pesticides':
        return _t('catPesticides');
      case 'Tools':
        return _t('catTools');
      default:
        return categoryEnglish;
    }
  }

  // —— Navigation & shell ——
  String get navHome => _t('navHome');
  String get navLiveScan => _t('navLiveScan');
  String get navShop => _t('navShop');
  String get navAssistant => _t('navAssistant');
  String get navAccount => _t('navAccount');

  // —— Language UI ——
  String get languageTitle => _t('languageTitle');
  String get langEnglish => _t('langEnglish');
  String get langHindi => _t('langHindi');
  String get langNepali => _t('langNepali');
  String get langRussian => _t('langRussian');
  String get languageUpdated => _t('languageUpdated');

  // —— Home ——
  String get homeAppBarTitle => _t('homeAppBarTitle');
  String get homeToolsHeadline => _t('homeToolsHeadline');
  String get homeToolsBlurb => _t('homeToolsBlurb');
  String get featLiveScanT => _t('featLiveScanT');
  String get featLiveScanS => _t('featLiveScanS');
  String get featDiseaseT => _t('featDiseaseT');
  String get featDiseaseS => _t('featDiseaseS');
  String get featShopT => _t('featShopT');
  String get featShopS => _t('featShopS');
  String get featAssistantT => _t('featAssistantT');
  String get featAssistantS => _t('featAssistantS');
  String get featRegisterT => _t('featRegisterT');
  String get featRegisterS => _t('featRegisterS');
  String get featAccountT => _t('featAccountT');
  String get featAccountS => _t('featAccountS');

  // —— Screens ——
  String get liveScanTitle => _t('liveScanTitle');
  String get assistantTitle => _t('assistantTitle');
  String get diseaseTitle => _t('diseaseTitle');
  String get accountMy => _t('accountMy');
  String get accountAdmin => _t('accountAdmin');
  String get edit => _t('edit');
  String get editProfile => _t('editProfile');
  String get register => _t('register');
  String get signOut => _t('signOut');
  String get shopMyAccount => _t('shopMyAccount');
  String get adminDashboardTitle => _t('adminDashboardTitle');
  String get adminDashButton => _t('adminDashButton');
  String get adminBannerTitle => _t('adminBannerTitle');
  String adminBannerBodyFor(String email) =>
      _t('adminBannerBody').replaceAll('{email}', email);
  String get cropIntel => _t('cropIntel');
  String get cropIntelBody => _t('cropIntelBody');
  String get liveScanToolT => _t('liveScanToolT');
  String get liveScanToolS => _t('liveScanToolS');
  String get diseaseToolT => _t('diseaseToolT');
  String get diseaseToolS => _t('diseaseToolS');
  String get profileDelivery => _t('profileDelivery');
  String get completeProfileTitle => _t('completeProfileTitle');
  String get completeProfileBody => _t('completeProfileBody');
  String get registerButton => _t('registerButton');
  String get usedCheckout => _t('usedCheckout');
  String get adminTools => _t('adminTools');
  String get adminToolsBody => _t('adminToolsBody');
  String get languageListTile => _t('languageListTile');
  String get languageListSubtitle => _t('languageListSubtitle');

  // —— Landing / auth ——
  String get landingBrand => _t('landingBrand');
  String get landingWelcome => _t('landingWelcome');
  String get landingFarmerSignIn => _t('landingFarmerSignIn');
  String get landingFarmerSignInHint => _t('landingFarmerSignInHint');
  String get landingGmail => _t('landingGmail');
  String get landingOrEmail => _t('landingOrEmail');
  String get landingEmail => _t('landingEmail');
  String get landingEmailHint => _t('landingEmailHint');
  String get landingPassword => _t('landingPassword');
  String get landingPasswordHint => _t('landingPasswordHint');
  String get landingLogin => _t('landingLogin');
  String get landingCreateAccount => _t('landingCreateAccount');
  String get landingNewUserHint => _t('landingNewUserHint');
  String get landingAdminLogin => _t('landingAdminLogin');
  String get landingGoogleSnack => _t('landingGoogleSnack');
  String get landingAdminDemoHint => _t('landingAdminDemoHint');
  String get showPassword => _t('showPassword');
  String get hidePassword => _t('hidePassword');

  static final Map<String, Map<String, String>> _strings = {
    'en': _en,
    'hi': _hi,
    'ne': _ne,
    'ru': _ru,
  };
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      AppLocalizations.supportedCodes.contains(AppLocalizations.normalizeCode(locale.languageCode));

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return SynchronousFuture(AppLocalizations._(AppLocalizations.normalizeCode(locale.languageCode)));
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) => false;
}

const Map<String, String> _en = {
  'navHome': 'Home',
  'navLiveScan': 'Live scan',
  'navShop': 'Shop',
  'navAssistant': 'Assistant',
  'navAccount': 'Account',
  'languageTitle': 'App language',
  'langEnglish': 'English',
  'langHindi': 'Hindi',
  'langNepali': 'Nepali',
  'langRussian': 'Russian',
  'languageUpdated': 'Language updated.',
  'homeAppBarTitle': 'AgriSmart',
  'homeHello': 'Hello, {name}',
  'homeToolsHeadline': 'Your farming tools',
  'homeToolsBlurb':
      'Live pest checks, disease screening, inputs, and help — all in this app.',
  'featLiveScanT': 'Live crop & insect scan',
  'featLiveScanS': 'Camera scan with alerts when an insect may harm your crop.',
  'featDiseaseT': 'Crop disease check (photo)',
  'featDiseaseS': 'Capture or choose a leaf photo for disease screening.',
  'featShopT': 'Agri inputs shop',
  'featShopS': 'Seeds, fertilizer, and crop protection products.',
  'featAssistantT': 'AI farming assistant',
  'featAssistantS': 'Questions on crops, pests, and practices.',
  'featRegisterT': 'Farmer registration',
  'featRegisterS': 'Save your profile for checkout and personalized help.',
  'featAccountT': 'My account',
  'featAccountS': 'View or edit your saved profile.',
  'liveScanTitle': 'Live crop & insect scan',
  'assistantTitle': 'AI Farming Assistant',
  'diseaseTitle': 'Crop disease check',
  'accountMy': 'My account',
  'accountAdmin': 'Account',
  'edit': 'Edit',
  'editProfile': 'Edit profile',
  'register': 'Register',
  'signOut': 'Sign out',
  'shopMyAccount': 'My account',
  'shopTitleAll': 'Agri inputs shop',
  'catSeeds': 'Seeds',
  'catFertilizers': 'Fertilizers',
  'catPesticides': 'Pesticides',
  'catTools': 'Tools',
  'adminDashboardTitle': 'AgriSmart Admin',
  'adminDashButton': 'Admin dashboard',
  'adminBannerTitle': 'Administrator',
  'adminBannerBody':
      'Signed in as {email}. Open the admin dashboard to manage products, farmers, and crop-tool notes.',
  'cropIntel': 'Crop intelligence',
  'cropIntelBody':
      'Run detection from your account — same tools as the Home and Live scan tabs.',
  'liveScanToolT': 'Live crop & insect scan',
  'liveScanToolS': 'Real-time camera scan with crop-specific harm alerts.',
  'diseaseToolT': 'Crop disease check (photo)',
  'diseaseToolS': 'Analyze a leaf or canopy photo for disease signals.',
  'profileDelivery': 'Profile & delivery',
  'completeProfileTitle': 'Complete your farmer profile',
  'completeProfileBody':
      'Add your name, phone, email, and delivery address for checkout and personalized help.',
  'registerButton': 'Register',
  'usedCheckout': 'Used on checkout, assistant, and anywhere your account appears.',
  'adminTools': 'Admin tools',
  'adminToolsBody':
      'Farmer profiles and crop shortcuts are hidden here. Use the main tabs (Home, Live scan) for crop tools.',
  'languageListTile': 'Language',
  'languageListSubtitle': 'English, Hindi, Nepali, Russian',
  'landingBrand': 'AgriSmart',
  'landingWelcome': 'Welcome back. Let’s grow together.',
  'landingFarmerSignIn': 'Farmer sign-in',
  'landingFarmerSignInHint': 'Use the email and password from your registration.',
  'landingGmail': 'Sign in with Gmail',
  'landingOrEmail': 'or use email and password',
  'landingEmail': 'Email',
  'landingEmailHint': 'you@example.com',
  'landingPassword': 'Password',
  'landingPasswordHint': 'Your account password',
  'landingLogin': 'Login',
  'landingCreateAccount': 'Create new account',
  'landingNewUserHint': 'New to AgriSmart? Tap to create a free farmer account.',
  'landingAdminLogin': 'Login as Admin',
  'landingGoogleSnack':
      'Google Sign-In is not wired in this demo build. Use email and password, or register a new account.',
  'landingAdminDemoHint':
      'Demo admin: admin@agrismart.com / admin123 — manage products under Account → Admin panel after sign-in.',
  'showPassword': 'Show',
  'hidePassword': 'Hide',
};

const Map<String, String> _hi = {
  'navHome': 'होम',
  'navLiveScan': 'लाइव स्कैन',
  'navShop': 'दुकान',
  'navAssistant': 'सहायक',
  'navAccount': 'खाता',
  'languageTitle': 'ऐप की भाषा',
  'langEnglish': 'अंग्रेज़ी',
  'langHindi': 'हिन्दी',
  'langNepali': 'नेपाली',
  'langRussian': 'रूसी',
  'languageUpdated': 'भाषा अपडेट हो गई।',
  'homeAppBarTitle': 'AgriSmart',
  'homeHello': 'नमस्ते, {name}',
  'homeToolsHeadline': 'आपके खेती के उपकरण',
  'homeToolsBlurb':
      'लाइव कीट जाँच, रोग जाँच, इनपुट और मदद — सब इसी ऐप में।',
  'featLiveScanT': 'लाइव फसल और कीट स्कैन',
  'featLiveScanS': 'कैमरा स्कैन जब कीट आपकी फसल को नुकसान पहुँचा सकता है तो चेतावनी।',
  'featDiseaseT': 'फसल रोग जाँच (फोटो)',
  'featDiseaseS': 'रोग जाँच के लिए पत्ती की फोटो लें या चुनें।',
  'featShopT': 'कृषि इनपुट दुकान',
  'featShopS': 'बीज, उर्वरक और फसल सुरक्षा उत्पाद।',
  'featAssistantT': 'AI कृषि सहायक',
  'featAssistantS': 'फसल, कीट और खेती के बारे में प्रश्न।',
  'featRegisterT': 'किसान पंजीकरण',
  'featRegisterS': 'चेकआउट और व्यक्तिगत सहायता के लिए प्रोफ़ाइल सहेजें।',
  'featAccountT': 'मेरा खाता',
  'featAccountS': 'अपनी सहेजी प्रोफ़ाइल देखें या बदलें।',
  'liveScanTitle': 'लाइव फसल और कीट स्कैन',
  'assistantTitle': 'AI कृषि सहायक',
  'diseaseTitle': 'फसल रोग जाँच',
  'accountMy': 'मेरा खाता',
  'accountAdmin': 'खाता',
  'edit': 'संपादन',
  'editProfile': 'प्रोफ़ाइल संपादित करें',
  'register': 'पंजीकरण',
  'signOut': 'साइन आउट',
  'shopMyAccount': 'मेरा खाता',
  'shopTitleAll': 'कृषि इनपुट दुकान',
  'catSeeds': 'बीज',
  'catFertilizers': 'उर्वरक',
  'catPesticides': 'कीटनाशक',
  'catTools': 'उपकरण',
  'adminDashboardTitle': 'AgriSmart व्यवस्थापक',
  'adminDashButton': 'व्यवस्थापक डैशबोर्ड',
  'adminBannerTitle': 'व्यवस्थापक',
  'adminBannerBody':
      '{email} के रूप में साइन इन। उत्पाद, किसान और नोट प्रबंधन के लिए डैशबोर्ड खोलें।',
  'cropIntel': 'फसल बुद्धिमत्ता',
  'cropIntelBody':
      'अपने खाते से जाँच चलाएँ — होम और लाइव स्कैन टैब जैसे ही उपकरण।',
  'liveScanToolT': 'लाइव फसल और कीट स्कैन',
  'liveScanToolS': 'फसल-विशिष्ट नुकसान चेतावणी के साथ रियल-टाइम कैमरा स्कैन।',
  'diseaseToolT': 'फसल रोग जाँच (फोटो)',
  'diseaseToolS': 'रोग संकेतों के लिए पत्ती या छत का फोटो विश्लेषण।',
  'profileDelivery': 'प्रोफ़ाइल और डिलीवरी',
  'completeProfileTitle': 'अपनी किसान प्रोफ़ाइल पूरी करें',
  'completeProfileBody':
      'चेकआउट और सहायता के लिए नाम, फोन, ईमेल और पता जोड़ें।',
  'registerButton': 'पंजीकरण',
  'usedCheckout': 'चेकआउट, सहायक और खाते में दिखने वाला नाम।',
  'adminTools': 'व्यवस्थापक उपकरण',
  'adminToolsBody':
      'किसान प्रोफ़ाइल यहाँ छिपी हैं। फसल उपकरणों के लिए होम और लाइव स्कैन टैब उपयोग करें।',
  'languageListTile': 'भाषा',
  'languageListSubtitle': 'अंग्रेज़ी, हिन्दी, नेपाली, रूसी',
  'landingBrand': 'AgriSmart',
  'landingWelcome': 'वापसी पर स्वागत है। साथ मिलकर बढ़ें।',
  'landingFarmerSignIn': 'किसान साइन-इन',
  'landingFarmerSignInHint': 'अपने पंजीकरण का ईमेल और पासवर्ड उपयोग करें।',
  'landingGmail': 'Gmail से साइन इन',
  'landingOrEmail': 'या ईमेल और पासवर्ड',
  'landingEmail': 'ईमेल',
  'landingEmailHint': 'you@example.com',
  'landingPassword': 'पासवर्ड',
  'landingPasswordHint': 'आपका खाता पासवर्ड',
  'landingLogin': 'लॉग इन',
  'landingCreateAccount': 'नया खाता बनाएँ',
  'landingNewUserHint': 'नए हैं? मुफ़्त किसान खाता बनाने के लिए टैप करें।',
  'landingAdminLogin': 'व्यवस्थापक के रूप में लॉग इन',
  'landingGoogleSnack':
      'इस डेमो में Google साइन-इन नहीं है। ईमेल/पासवर्ड या नया खाता बनाएँ।',
  'landingAdminDemoHint':
      'डेमो व्यवस्थापक: admin@agrismart.com / admin123 — साइन इन के बाद खाता → व्यवस्थापक पैनल से उत्पाद प्रबंधित करें।',
  'showPassword': 'दिखाएँ',
  'hidePassword': 'छिपाएँ',
};

const Map<String, String> _ne = {
  'navHome': 'गृह',
  'navLiveScan': 'लाइभ स्क्यान',
  'navShop': 'पसल',
  'navAssistant': 'सहायक',
  'navAccount': 'खाता',
  'languageTitle': 'एप भाषा',
  'langEnglish': 'अङ्ग्रेजी',
  'langHindi': 'हिन्दी',
  'langNepali': 'नेपाली',
  'langRussian': 'रसियन',
  'languageUpdated': 'भाषा अद्यावधिक भयो।',
  'homeAppBarTitle': 'AgriSmart',
  'homeHello': 'नमस्ते, {name}',
  'homeToolsHeadline': 'तपाईंको कृषि उपकरणहरू',
  'homeToolsBlurb':
      'लाइभ कीरा जाँच, रोग जाँच, इनपुट र सहायता — यही एपमा।',
  'featLiveScanT': 'लाइभ बाली र कीरा स्क्यान',
  'featLiveScanS': 'क्यामेरा स्क्यान जब कीराले बालीलाई हानी पुर्‍याउन सक्छ।',
  'featDiseaseT': 'बाली रोग जाँच (फोटो)',
  'featDiseaseS': 'रोग जाँचका लागि पातको फोटो लिनुhos वा छान्नुhos।',
  'featShopT': 'कृषि इनपुट पसल',
  'featShopS': 'बीउ, मल र बाली संरक्षण सामग्री।',
  'featAssistantT': 'AI कृषि सहायक',
  'featAssistantS': 'बाली, कीरा र अभ्यास बारे प्रश्न।',
  'featRegisterT': 'किसान दर्ता',
  'featRegisterS': 'चेकआउट र व्यक्तिगत सहायताका लागि प्रोफाइल बचत गर्नुhos।',
  'featAccountT': 'मेरो खाता',
  'featAccountS': 'बचत गरिएको प्रोफाइल हेर्नुhos वा सम्पादन गर्नुhos।',
  'liveScanTitle': 'लाइभ बाली र कीरा स्क्यान',
  'assistantTitle': 'AI कृषि सहायक',
  'diseaseTitle': 'बाली रोग जाँच',
  'accountMy': 'मेरो खाता',
  'accountAdmin': 'खाता',
  'edit': 'सम्पादन',
  'editProfile': 'प्रोफाइल सम्पादन',
  'register': 'दर्ता',
  'signOut': 'साइन आउट',
  'shopMyAccount': 'मेरो खाता',
  'shopTitleAll': 'कृषि इनपुट पसल',
  'catSeeds': 'बीउ',
  'catFertilizers': 'मल',
  'catPesticides': 'कीटनाशक',
  'catTools': 'उपकरण',
  'adminDashboardTitle': 'AgriSmart प्रशासक',
  'adminDashButton': 'प्रशासक ड्यासबोर्ड',
  'adminBannerTitle': 'प्रशासक',
  'adminBannerBody':
      '{email} मा साइन इन। उत्पादन, किसान र नोट प्रबन्धनका लागि ड्यासबोर्ड खोल्नुhos।',
  'cropIntel': 'बाली बुद्धिमत्ता',
  'cropIntelBody':
      'आफ्नो खाताबाट जाँच चलाउनुhos — गृह र लाइभ स्क्यान ट्याब जस्तै उपकरण।',
  'liveScanToolT': 'लाइभ बाली र कीरा स्क्यान',
  'liveScanToolS': 'बाली-आधारित चेतावनी सहित वास्तविक-समय क्यामेरा स्क्यान।',
  'diseaseToolT': 'बाली रोग जाँच (फोटो)',
  'diseaseToolS': 'रोग संकेतका लागि पात वा छहराको फोटो विश्लेषण।',
  'profileDelivery': 'प्रोफाइल र डेलिभरी',
  'completeProfileTitle': 'किसान प्रोफाइल पूरा गर्नुhos',
  'completeProfileBody':
      'चेकआउट र सहायताका लागि नाम, फोन, इमेल र ठेगाना थप्नुhos।',
  'registerButton': 'दर्ता',
  'usedCheckout': 'चेकआउट, सहायक र खातामा देखिने नाम।',
  'adminTools': 'प्रशासक उपकरण',
  'adminToolsBody':
      'किसान प्रोफाइल यहाँ लुकेका छन्। बाली उपकरणका लागि गृह र लाइभ स्क्यान ट्याब प्रयोग गर्नुhos।',
  'languageListTile': 'भाषा',
  'languageListSubtitle': 'अङ्ग्रेजी, हिन्दी, नेपाली, रसियन',
  'landingBrand': 'AgriSmart',
  'landingWelcome': 'फेरि स्वागत छ। सँगै बढौँ।',
  'landingFarmerSignIn': 'किसान साइन-इन',
  'landingFarmerSignInHint': 'दर्तामा भएको इमेल र पासवर्ड प्रयोग गर्नुhos।',
  'landingGmail': 'Gmail बाट साइन इन',
  'landingOrEmail': 'वा इमेल र पासवर्ड',
  'landingEmail': 'इमेल',
  'landingEmailHint': 'you@example.com',
  'landingPassword': 'पासवर्ड',
  'landingPasswordHint': 'तपाईंको खाता पासवर्ड',
  'landingLogin': 'लगइन',
  'landingCreateAccount': 'नयाँ खाता बनाउनुhos',
  'landingNewUserHint': 'नयाँ हुनुहुन्छ? निःशुल्क किसान खाता बनाउन ट्याप गर्नुhos।',
  'landingAdminLogin': 'प्रशासकको रूपमा लगइन',
  'landingGoogleSnack':
      'यो डेमोमा Google साइन-इन छैन। इमेल/पासवर्ड वा नयाँ खाता प्रयोग गर्नुhos।',
  'landingAdminDemoHint':
      'डेमो प्रशासक: admin@agrismart.com / admin123 — साइन इन पछि खाता → प्रशासक प्यानलबाट उत्पादन व्यवस्थापन।',
  'showPassword': 'देखाउनुhos',
  'hidePassword': 'लुकाउनुhos',
};

const Map<String, String> _ru = {
  'navHome': 'Главная',
  'navLiveScan': 'Сканер',
  'navShop': 'Магазин',
  'navAssistant': 'Помощник',
  'navAccount': 'Аккаунт',
  'languageTitle': 'Язык приложения',
  'langEnglish': 'Английский',
  'langHindi': 'Хинди',
  'langNepali': 'Непальский',
  'langRussian': 'Русский',
  'languageUpdated': 'Язык обновлён.',
  'homeAppBarTitle': 'AgriSmart',
  'homeHello': 'Здравствуйте, {name}',
  'homeToolsHeadline': 'Ваши инструменты',
  'homeToolsBlurb':
      'Проверка вредителей, болезней, закупка средств и помощь — в одном приложении.',
  'featLiveScanT': 'Скан фермы и насекомых',
  'featLiveScanS': 'Камера с оповещениями, если насекомое может навредить урожаю.',
  'featDiseaseT': 'Болезни культуры (фото)',
  'featDiseaseS': 'Снимите или выберите фото листа для проверки.',
  'featShopT': 'Магазин средств',
  'featShopS': 'Семена, удобрения и средства защиты растений.',
  'featAssistantT': 'ИИ-помощник фермера',
  'featAssistantS': 'Вопросы о культурах, вредителях и практиках.',
  'featRegisterT': 'Регистрация фермера',
  'featRegisterS': 'Сохраните профиль для оформления заказа и советов.',
  'featAccountT': 'Мой аккаунт',
  'featAccountS': 'Просмотр или изменение сохранённого профиля.',
  'liveScanTitle': 'Скан культуры и насекомых',
  'assistantTitle': 'ИИ-помощник по фермерству',
  'diseaseTitle': 'Проверка болезней',
  'accountMy': 'Мой аккаунт',
  'accountAdmin': 'Аккаунт',
  'edit': 'Изменить',
  'editProfile': 'Изменить профиль',
  'register': 'Регистрация',
  'signOut': 'Выйти',
  'shopMyAccount': 'Мой аккаунт',
  'shopTitleAll': 'Магазин средств',
  'catSeeds': 'Семена',
  'catFertilizers': 'Удобрения',
  'catPesticides': 'Пестициды',
  'catTools': 'Инструменты',
  'adminDashboardTitle': 'AgriSmart — админ',
  'adminDashButton': 'Панель администратора',
  'adminBannerTitle': 'Администратор',
  'adminBannerBody':
      'Вход как {email}. Откройте панель для товаров, фермеров и заметок.',
  'cropIntel': 'Аналитика полей',
  'cropIntelBody':
      'Запускайте проверки из аккаунта — те же инструменты, что на главной и в сканере.',
  'liveScanToolT': 'Скан культуры и насекомых',
  'liveScanToolS': 'Камера в реальном времени с предупреждениями по вреду.',
  'diseaseToolT': 'Болезни культуры (фото)',
  'diseaseToolS': 'Анализ листа или полога на признаки болезни.',
  'profileDelivery': 'Профиль и доставка',
  'completeProfileTitle': 'Заполните профиль фермера',
  'completeProfileBody':
      'Добавьте имя, телефон, e-mail и адрес доставки для заказа и помощи.',
  'registerButton': 'Регистрация',
  'usedCheckout': 'Используется при заказе, в помощнике и в профиле.',
  'adminTools': 'Инструменты админа',
  'adminToolsBody':
      'Профили фермеров скрыты здесь. Для инструментов по культурам используйте «Главная» и «Сканер».',
  'languageListTile': 'Язык',
  'languageListSubtitle': 'Английский, хинди, непальский, русский',
  'landingBrand': 'AgriSmart',
  'landingWelcome': 'С возвращением. Растём вместе.',
  'landingFarmerSignIn': 'Вход фермера',
  'landingFarmerSignInHint': 'Используйте e-mail и пароль из регистрации.',
  'landingGmail': 'Войти через Gmail',
  'landingOrEmail': 'или e-mail и пароль',
  'landingEmail': 'E-mail',
  'landingEmailHint': 'you@example.com',
  'landingPassword': 'Пароль',
  'landingPasswordHint': 'Пароль аккаунта',
  'landingLogin': 'Войти',
  'landingCreateAccount': 'Создать аккаунт',
  'landingNewUserHint': 'Новичок? Создайте бесплатный аккаунт фермера.',
  'landingAdminLogin': 'Вход как администратор',
  'landingGoogleSnack':
      'Вход через Google в этой демо не подключён. Используйте e-mail/пароль или регистрацию.',
  'landingAdminDemoHint':
      'Демо-админ: admin@agrismart.com / admin123 — после входа: Аккаунт → панель администратора для товаров.',
  'showPassword': 'Показать',
  'hidePassword': 'Скрыть',
};
