import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:shopperz/app/modules/auth/controller/auth_controler.dart';
import 'package:shopperz/app/modules/auth/views/sign_in.dart';
import 'package:shopperz/app/modules/category/views/category_wise_product_screen.dart';
import 'package:shopperz/app/modules/filter/controller/filter_controller.dart';
import 'package:shopperz/app/modules/home/controller/brand_controller.dart';
import 'package:shopperz/app/modules/home/controller/category_controller.dart';
import 'package:shopperz/app/modules/home/controller/flash_sale_controller.dart';
import 'package:shopperz/app/modules/home/controller/popular_product_controller.dart';
import 'package:shopperz/app/modules/home/controller/product_section_controller.dart';
import 'package:shopperz/app/modules/home/controller/slider_controller.dart';
import 'package:shopperz/app/modules/home/widgets/category.dart';
import 'package:shopperz/app/modules/home/widgets/multi_promotion_banner.dart';
import 'package:shopperz/app/modules/home/widgets/promotion_banner.dart';
import 'package:shopperz/app/modules/home/widgets/slider.dart';
import 'package:shopperz/app/modules/language/controller/language_controller.dart';
import 'package:shopperz/app/modules/product/widgets/product.dart';
import 'package:shopperz/app/modules/product_details/views/product_details.dart';
import 'package:shopperz/app/modules/profile/controller/profile_controller.dart';
import 'package:shopperz/app/modules/shipping/controller/show_address_controller.dart';
import 'package:shopperz/main.dart';
import 'package:shopperz/utils/svg_icon.dart';
import 'package:shopperz/widgets/custom_text.dart';
import 'package:shopperz/widgets/shimmer/categories_shimmer.dart';
import 'package:shopperz/widgets/shimmer/product_shimmer.dart';
import 'package:shopperz/widgets/shimmer/slider_shimmer.dart';
import 'package:shopperz/widgets/title.dart';
import '../../../../config/theme/app_color.dart';
import '../../../../widgets/appbar.dart';
import '../../product/views/product_list_screen.dart';
import '../../wishlist/controller/wishlist_controller.dart';
import '../../search/views/search_screen.dart';
import '../widgets/see_all_btn.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:io';



class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  BannerAd? _bannerAd;
  bool _isBannerAdLoaded = false;
  AdSize? _adSize;

  NativeAd? _nativeAd1;
  NativeAd? _nativeAd2;
  bool _isNativeAd1Loaded = false;
  bool _isNativeAd2Loaded = false;

  final String bannerAdUnitId = Platform.isAndroid
  ? 'ca-app-pub-5669197550373328/6856336743'
  : 'ca-app-pub-5669197550373328/6856336743';

  final String nativeAdUnitId = Platform.isAndroid
  ? 'ca-app-pub-5669197550373328/3027938225'
  : 'ca-app-pub-5669197550373328/3027938225';

  @override
  void initState() {
    super.initState();
}

    @override
    void didChangeDependencies(){
      super.didChangeDependencies();
      if (_bannerAd == null) {
        _loadAdaptiveBanner();        
      }
      if (_nativeAd1 == null) {
        _loadNativeAds();
      }
      if (_nativeAd2 == null) {
        _loadNativeAds();
      }
    }

    Future<void> _loadNativeAds() async {
  debugPrint('[NativeAd] Loading both native ads...');

    _nativeAd1 = NativeAd(
      adUnitId: nativeAdUnitId,
      factoryId: 'yourNativeAdFactoryId',
      request: const AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          debugPrint('[NativeAd1] Loaded');
          setState(() => _isNativeAd1Loaded = true);
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('[NativeAd1] Failed: $error');
          ad.dispose();
        },
      ),
    )..load();

    _nativeAd2 = NativeAd(
      adUnitId: nativeAdUnitId,
      factoryId: 'yourNativeAdFactoryId',
      request: const AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          debugPrint('[NativeAd2] Loaded');
          setState(() => _isNativeAd2Loaded = true);
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('[NativeAd2] Failed: $error');
          ad.dispose();
        },
      ),
    )..load();

  try {
    await _nativeAd1!.load();
    debugPrint('[NativeAd1] Load call completed.');
  } catch (e) {
    debugPrint('[NativeAd1] Exception while loading native ad: $e');
  }
}


    Future<void> _loadAdaptiveBanner() async {
    debugPrint('Attempting to load adaptive banner...');

    try {
      final size = await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
        MediaQuery.of(context).size.width.truncate(),
      );

      if (size == null) {
        debugPrint('AdSize returned null. Banner will not be displayed.');
        return;
      }

      setState(() {
        _adSize = size;
      });

      debugPrint('AdSize fetched: ${_adSize!.width}x${_adSize!.height}');

      _bannerAd = BannerAd(
        adUnitId: bannerAdUnitId,
        size: _adSize!,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (Ad ad) {
            debugPrint('Banner Ad loaded.');
            setState(() {
              _isBannerAdLoaded = true;
            });
          },
          onAdFailedToLoad: (Ad ad, LoadAdError error) {
            debugPrint('Banner Ad failed to load: $error');
            ad.dispose();
          },
          onAdOpened: (Ad ad) => debugPrint('Ad opened'),
          onAdClosed: (Ad ad) => debugPrint('Ad closed'),
        ),
      );

      await _bannerAd!.load();
      debugPrint('Banner ad load initiated');
    } catch (e) {
      debugPrint('Exception while loading banner ad: $e');
    }
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    _nativeAd1?.dispose();
    _nativeAd2?.dispose();
    super.dispose();
  }

  Widget adBanner() {
    if (_isBannerAdLoaded && _bannerAd != null && _adSize != null) {
      debugPrint('Displaying ad banner...');
      return SafeArea(
        child: SizedBox(
          width: _adSize!.width.toDouble(),
          height: _adSize!.height.toDouble(),
          child: AdWidget(ad: _bannerAd!),
        ),
      );
    } else {
      debugPrint('Ad not ready yet: '
          'isLoaded=$_isBannerAdLoaded, bannerAd=${_bannerAd != null}, size=${_adSize != null}');
      return const SizedBox.shrink();
    }
  }

  Widget nativeAdWidget1() {
  debugPrint('[NativeAd1Widget] Building native ad widget...');
  debugPrint('[NativeAd1Widget] isLoaded=$_isNativeAd1Loaded, ad=${_nativeAd1 != null}');

  if (_isNativeAd1Loaded && _nativeAd1 != null) {
    return LayoutBuilder(
      builder: (context, constraints){
        return Container(
        margin: EdgeInsets.symmetric(vertical: 8.h),      
        constraints: BoxConstraints(
          maxHeight: 250.h
        ),
        child: AdWidget(ad: _nativeAd1!),
      );
      }
    );
  } else {
    debugPrint('[NativeAdWidget] Native ad not ready yet.');
    return const SizedBox.shrink();
  }
}

  Widget nativeAdWidget2() {
  debugPrint('[NativeAd2Widget] Building native ad widget...');
  debugPrint('[NativeAd2Widget] isLoaded=$_isNativeAd2Loaded, ad=${_nativeAd2 != null}');

  if (_isNativeAd1Loaded && _nativeAd1 != null) {
    return LayoutBuilder(
      builder: (context, constraints){
        return Container(
        margin: EdgeInsets.symmetric(vertical: 8.h),      
        constraints: BoxConstraints(
          maxHeight: 250.h
        ),
        child: AdWidget(ad: _nativeAd2!),
      );
      }
    );
  } else {
    debugPrint('[NativeAd2Widget] Native ad not ready yet.');
    return const SizedBox.shrink();
  }
}


 


  



  @override
  Widget build(BuildContext context) {
    final sliderController = Get.put(SliderController());
    final categoryController = Get.put(CategoryController());
    final productSectionController = Get.put(ProductSectionController());
    AuthController authController = Get.put(AuthController());
    ProfileController profile = Get.put(ProfileController());
    LanguageController language = Get.put(LanguageController());
    final filterController = Get.put(FilterController());
    final flashSaleController = Get.put(FlashSaleControlelr());
    final showAddressController = Get.put(ShowAddressController());
    final wishListController = Get.put(WishlistController());
    final brandController = Get.put(BrandController());
    final popularProductController = Get.put(PopularProductController());
    categoryController.fetchCategory();
    productSectionController.fetchProductSection();

    sliderController.fetchSlider();
    profile.getPages();
    authController.getCountryCode();
    language.getLanguageData();

    if (box.read('isLogedIn') != false) {
      profile.getAddress();
      profile.getTotalOrdersCount();
      profile.getTotalCompleteOrdersCount();
      profile.getTotalReturnOrdersCount();
      profile.getTotalWalletBalance();
      showAddressController.showAdresses();
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.dark,
        statusBarColor: Colors.transparent,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppColor.primaryBackgroundColor,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(48.h),
          child: AppBarWidget(
              isSearch: true,
              svgIcon: SvgIcon.search,
              onTap: () {
                Get.to(() => const SearchScreen());
              }),
        ),
        body: RefreshIndicator(
          color: AppColor.primaryColor,
          onRefresh: () async {
            productSectionController.fetchProductSection();
            categoryController.fetchCategory();
            brandController.fetchBrands();
            sliderController.fetchSlider();
            profile.getPages();
            authController.getSetting();
            authController.getCountryCode();
            language.getLanguageData();
            if (box.read('isLogedIn') != false) {
              profile.getAddress();
              profile.getTotalOrdersCount();
              profile.getTotalCompleteOrdersCount();
              profile.getTotalReturnOrdersCount();
              profile.getTotalWalletBalance();
            }
          },
          child: Padding(
            padding: EdgeInsets.only(top: 16.h, left: 16.w),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(right: 16.w),
                        child: Obx(() {
                          return sliderController.sliderData.value.data == null
                              ? const SliderSectionShimmer()
                              : sliderController
                                      .sliderData.value.data!.isNotEmpty
                                  ? const SliderWidget()
                                  : const SizedBox();
                        }),
                      ),
                      SizedBox(height: 24.h),
                      Obx(() {
                        return categoryController
                                    .categoryModel.value.data?.isNotEmpty ??
                                false
                            ? Padding(
                                padding: EdgeInsets.only(right: 16.w),
                                child: TitleWidget(
                                  text: 'CATEGORIES'.tr,
                                ),
                              )
                            : const SizedBox();
                      }),
                      Obx(() {
                        return categoryController.categoryModel.value.data ==
                                null
                            ? Padding(
                                padding: EdgeInsets.only(top: 20.h),
                                child: const CategoriesSectionShimmer(),
                              )
                            : categoryController
                                    .categoryModel.value.data!.isNotEmpty
                                ? const CategoryWidget()
                                : const SizedBox();
                      }),
                      const PromotionBanner()
                    ],
                  ),
                  SizedBox(height: 32.h),
                  adBanner(),
                  SizedBox(
                    child: Obx(() {
                      return productSectionController
                                  .productSection.value.data ==
                              null
                          ? const ProductShimmer()
                          : productSectionController
                                  .productSection.value.data!.isNotEmpty
                              ? ListView.builder(
                                  shrinkWrap: true,
                                  padding: EdgeInsets.zero,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: productSectionController
                                      .productSection.value.data?.length,
                                  itemBuilder: (context, index) {
                                    final section = productSectionController
                                        .productSection.value.data;
                                    return section![index].products!.isNotEmpty
                                        ? Padding(
                                            padding:
                                                EdgeInsets.only(right: 16.w),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                TitleWidget(
                                                    text: section[index]
                                                        .name
                                                        .toString()),
                                                SizedBox(height: 12.h),
                                                StaggeredGrid.count(
                                                  crossAxisCount: 2,
                                                  mainAxisSpacing: 16.h,
                                                  crossAxisSpacing: 16.w,
                                                  children: [
                                                    ...[
                                                    for (var i = 0;
                                                        i <
                                                            section[index]
                                                                .products!
                                                                .length;
                                                        i++) ...[
                                                      Obx(
                                                        () => ProductWidget(
                                                          onTap: () {
                                                            Get.to(
                                                              () => ProductDetailsScreen(
                                                                  sectionModel:
                                                                      section[
                                                                          index],
                                                                  productModel:
                                                                      section[index]
                                                                          .products![i]),
                                                            );
                                                          },
                                                          favTap: () async {
                                                            if (box.read(
                                                                    'isLogedIn') !=
                                                                false) {
                                                              if (section[index]
                                                                      .products![
                                                                          i]
                                                                      .wishlist ==
                                                                  true) {
                                                                await wishListController
                                                                    .toggleFavoriteFalse(section[
                                                                            index]
                                                                        .products![
                                                                            i]
                                                                        .id!);
                                                                wishListController
                                                                    .showFavorite(section[
                                                                            index]
                                                                        .products![
                                                                            i]
                                                                        .id!);
                                                              }
                                                              if (section[index]
                                                                      .products![
                                                                          i]
                                                                      .wishlist ==
                                                                  false) {
                                                                await wishListController
                                                                    .toggleFavoriteTrue(section[
                                                                            index]
                                                                        .products![
                                                                            i]
                                                                        .id!);
                                                                wishListController
                                                                    .showFavorite(section[
                                                                            index]
                                                                        .products![
                                                                            i]
                                                                        .id!);
                                                              }
                                                            } else {
                                                              Get.to(() =>
                                                                  const SignInScreen());
                                                            }
                                                          },
                                                          wishlist: wishListController
                                                                      .favList
                                                                      .contains(section[index]
                                                                          .products![
                                                                              i]
                                                                          .id!) ||
                                                                  productSectionController
                                                                          .productSection
                                                                          .value
                                                                          .data![
                                                                              index]
                                                                          .products![
                                                                              i]
                                                                          .wishlist ==
                                                                      true
                                                              ? true
                                                              : false,
                                                          productImage:
                                                              section[index]
                                                                  .products![i]
                                                                  .cover!,
                                                          title: section[index]
                                                              .products![i]
                                                              .name,
                                                          rating: section[index]
                                                              .products![i]
                                                              .ratingStar,
                                                          currentPrice: section[
                                                                  index]
                                                              .products![i]
                                                              .currencyPrice,
                                                          discountPrice: section[
                                                                  index]
                                                              .products![i]
                                                              .discountedPrice,
                                                          textRating: section[
                                                                  index]
                                                              .products![i]
                                                              .ratingStarCount,
                                                          flashSale:
                                                              section[index]
                                                                  .products![i]
                                                                  .flashSale!,
                                                          isOffer:
                                                              section[index]
                                                                  .products![i]
                                                                  .isOffer!,
                                                        ),
                                                      ),
                                                      if (i == 1)
                                                      nativeAdWidget1(),
                                                      if (i == 4)
                                                      nativeAdWidget2(),

                                                  ],
                                                  ]
                                                  ]
                                                ),
                                                SizedBox(height: 32.h),
                                                MultiPromotionBanner(
                                                  pIndex: index,
                                                ),
                                              ],
                                            ),
                                          )
                                        : const SizedBox();
                                  })
                              : const SizedBox();
                    }),
                  ),
                  Obx(
                    () => popularProductController.popularModel.value.data ==
                            null
                        ? const ProductShimmer()
                        : popularProductController
                                .popularModel.value.data!.isNotEmpty
                            ? Padding(
                                padding: EdgeInsets.only(right: 16.w),
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(right: 16.w),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          TitleWidget(text: "Most Popular".tr),
                                          SeeAllButton(
                                            onTap: () async {
                                              Get.to(
                                                () => const ProductlistScreen(
                                                  id: 5,
                                                  title: "Most Popular",
                                                ),
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 16.h),
                                    StaggeredGrid.count(
                                      crossAxisCount: 2,
                                      mainAxisSpacing: 16.h,
                                      crossAxisSpacing: 16.w,
                                      children: [
                                        for (int index = 0;
                                            index <
                                                popularProductController
                                                    .popularModel
                                                    .value
                                                    .data!
                                                    .length;
                                            index++)
                                          ProductWidget(
                                            onTap: () {
                                              Get.to(() => ProductDetailsScreen(
                                                  individualProduct:
                                                      popularProductController
                                                          .popularModel
                                                          .value
                                                          .data?[index]));
                                            },
                                            wishlist: wishListController.favList
                                                        .contains(
                                                            popularProductController
                                                                .popularModel
                                                                .value
                                                                .data![index]
                                                                .id!) ||
                                                    popularProductController
                                                            .popularModel
                                                            .value
                                                            .data?[index]
                                                            .wishlist ==
                                                        true
                                                ? true
                                                : false,
                                            favTap: () async {
                                              if (box.read('isLogedIn') !=
                                                  false) {
                                                if (popularProductController
                                                        .popularModel
                                                        .value
                                                        .data?[index]
                                                        .wishlist ==
                                                    true) {
                                                  await wishListController
                                                      .toggleFavoriteFalse(
                                                          popularProductController
                                                              .popularModel
                                                              .value
                                                              .data![index]
                                                              .id!);
                              
                                                  wishListController.showFavorite(
                                                      popularProductController
                                                          .popularModel
                                                          .value
                                                          .data![index]
                                                          .id!);
                                                }
                                                if (popularProductController
                                                        .popularModel
                                                        .value
                                                        .data?[index]
                                                        .wishlist ==
                                                    false) {
                                                  await wishListController
                                                      .toggleFavoriteTrue(
                                                          popularProductController
                                                              .popularModel
                                                              .value
                                                              .data![index]
                                                              .id!);
                              
                                                  wishListController.showFavorite(
                                                      popularProductController
                                                          .popularModel
                                                          .value
                                                          .data![index]
                                                          .id!);
                                                }
                                              } else {
                                                Get.to(
                                                    () => const SignInScreen());
                                              }
                                            },
                                            productImage:
                                                popularProductController
                                                    .popularModel
                                                    .value
                                                    .data?[index]
                                                    .cover!,
                                            title: popularProductController
                                                .popularModel
                                                .value
                                                .data?[index]
                                                .name,
                                            rating: popularProductController
                                                .popularModel
                                                .value
                                                .data?[index]
                                                .ratingStar
                                                .toString(),
                                            currentPrice:
                                                popularProductController
                                                    .popularModel
                                                    .value
                                                    .data?[index]
                                                    .currencyPrice,
                                            discountPrice:
                                                popularProductController
                                                    .popularModel
                                                    .value
                                                    .data?[index]
                                                    .discountedPrice,
                                            textRating: popularProductController
                                                .popularModel
                                                .value
                                                .data?[index]
                                                .ratingStarCount,
                                            flashSale: popularProductController
                                                .popularModel
                                                .value
                                                .data?[index]
                                                .flashSale!,
                                            isOffer: popularProductController
                                                .popularModel
                                                .value
                                                .data?[index]
                                                .isOffer!,
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              )
                            : const SizedBox(),
                  ),
                  SizedBox(height: 34.h),
                  Obx(
                    () => flashSaleController.flashSaleModel.value.data == null
                        ? const ProductShimmer()
                        : flashSaleController
                                .flashSaleModel.value.data!.isNotEmpty
                            ? Padding(
                                padding: EdgeInsets.only(right: 16.w),
                                child: Obx(
                                  () => Column(
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(right: 16.w),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            TitleWidget(text: 'Flash Sale'.tr),
                                            SeeAllButton(
                                              onTap: () {
                                                Get.to(
                                                  () => const ProductlistScreen(
                                                    id: 10,
                                                    title: "Flash Sale",
                                                  ),
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 16.h),
                                      StaggeredGrid.count(
                                        crossAxisCount: 2,
                                        mainAxisSpacing: 16.h,
                                        crossAxisSpacing: 16.w,
                                        children: [
                                          for (int index = 0;
                                              index <
                                                  flashSaleController
                                                      .flashSaleModel
                                                      .value
                                                      .data!
                                                      .length;
                                              index++)
                                            Obx(() {
                                              final flashSale =
                                                  flashSaleController
                                                      .flashSaleModel
                                                      .value
                                                      .data![index];
                              
                                              return Obx(
                                                () => ProductWidget(
                                                  onTap: () {
                                                    Get.to(
                                                      () =>
                                                          ProductDetailsScreen(
                                                        individualProduct:
                                                            flashSaleController
                                                                .flashSaleModel
                                                                .value
                                                                .data?[index],
                                                      ),
                                                    );
                                                  },
                                                  wishlist: wishListController
                                                              .favList
                                                              .contains(
                                                                  flashSale
                                                                      .id!) ||
                                                          flashSale.wishlist ==
                                                              true
                                                      ? true
                                                      : false,
                                                  favTap: () async {
                                                    if (box.read('isLogedIn') !=
                                                        false) {
                                                      if (flashSale.wishlist ==
                                                          true) {
                                                        await wishListController
                                                            .toggleFavoriteFalse(
                                                                flashSale.id!);
                                                        wishListController
                                                            .showFavorite(
                                                                flashSale.id!);
                                                      }
                                                      if (flashSale.wishlist ==
                                                          false) {
                                                        await wishListController
                                                            .toggleFavoriteTrue(
                                                                flashSale.id!);
                              
                                                        wishListController
                                                            .showFavorite(
                                                                flashSale.id!);
                                                      }
                                                    } else {
                                                      Get.to(() =>
                                                          const SignInScreen());
                                                    }
                                                  },
                                                  favColor: wishListController
                                                          .favList
                                                          .contains(
                                                              flashSale.id!)
                                                      ? SvgIcon.filledHeart
                                                      : SvgIcon.heart,
                                                  productImage:
                                                      flashSale.cover!,
                                                  title: flashSale.name,
                                                  rating: flashSale.ratingStar
                                                      .toString(),
                                                  currentPrice:
                                                      flashSale.currencyPrice,
                                                  discountPrice:
                                                      flashSale.discountedPrice,
                                                  textRating:
                                                      flashSale.ratingStarCount,
                                                  flashSale:
                                                      flashSale.flashSale!,
                                                  isOffer: flashSale.isOffer!,
                                                ),
                                              );
                                            }),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : const SizedBox(),
                  ),
                  SizedBox(height: 34.h),
                  Obx(
                    () => brandController.brandModel.value.data != null
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TitleWidget(text: "Popular Brands".tr),
                              SizedBox(height: 16.h),
                              SizedBox(
                                height: brandController
                                            .brandModel.value.data?.isEmpty ??
                                        false
                                    ? 0
                                    : 100.h,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  shrinkWrap: true,
                                  itemCount: brandController
                                      .brandModel.value.data?.length,
                                  itemBuilder: (context, index) {
                                    return InkWell(
                                      borderRadius: BorderRadius.circular(16.r),
                                      onTap: () {
                                        filterController.addHomeBrandId(
                                            brandController.brandModel.value
                                                .data![index].id
                                                .toString());
                              
                                        Get.to(() => CategoryWiseProductScreen(
                                              brandName: brandController
                                                  .brandModel
                                                  .value
                                                  .data?[index]
                                                  .name,
                                            ));
                                      },
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 4.w),
                                        child: Obx(
                                          () => brandController.brandModel.value
                                                          .data ==
                                                      null ||
                                                  brandController.brandModel
                                                      .value.data!.isEmpty
                                              ? Shimmer.fromColors(
                                                  baseColor: Colors.grey[200]!,
                                                  highlightColor:
                                                      Colors.grey[300]!,
                                                  child: Container(
                                                    height: 90.h,
                                                    width: 100.w,
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(16.r),
                                                        color: Colors.white),
                                                  ),
                                                )
                                              : Ink(
                                                  height: 90,
                                                  width: 100,
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    border: Border.all(
                                                        color: AppColor
                                                            .borderColor),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            16.r),
                                                  ),
                                                  child: Padding(
                                                    padding:
                                                        EdgeInsets.all(8.sp),
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceAround,
                                                      children: [
                                                        CachedNetworkImage(
                                                            imageUrl:
                                                                brandController
                                                                    .brandModel
                                                                    .value
                                                                    .data![
                                                                        index]
                                                                    .cover
                                                                    .toString(),
                                                            fit: BoxFit.cover,
                                                            imageBuilder: (context,
                                                                    imageProvider) =>
                                                                Container(
                                                                  height: 20.h,
                                                                  width: 60.w,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    image: DecorationImage(
                                                                        image:
                                                                            imageProvider),
                                                                  ),
                                                                )),
                                                        SizedBox(height: 20.h),
                                                        CustomText(
                                                          text: brandController
                                                                  .brandModel
                                                                  .value
                                                                  .data?[index]
                                                                  .name ??
                                                              "",
                                                          color: AppColor
                                                              .textColor,
                                                          weight:
                                                              FontWeight.w600,
                                                          size: 12.sp,
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              SizedBox(
                                height: brandController
                                            .brandModel.value.data?.isEmpty ??
                                        false
                                    ? 0
                                    : 100.h,
                              )
                            ],
                          )
                        : const SizedBox(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

}