// vip_purchase_service.dart — Cross-platform iOS + Android

import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dovui/pages/ads/widgets/adsService.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VipPurchaseService {
  static final VipPurchaseService _instance = VipPurchaseService._internal();
  factory VipPurchaseService() => _instance;
  VipPurchaseService._internal();

  // ⚠️ Product ID phải khớp chính xác với cả Google Play Console VÀ App Store Connect
  static const String kVipProductId = 'com.thanhhai.dovui.vip';

  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  ProductDetails? _vipProduct;
  ProductDetails? get vipProduct => _vipProduct;

  bool _isAvailable = false;
  bool get isAvailable => _isAvailable;

  String _lastErrorReason = '';
  String get lastErrorReason => _lastErrorReason;

  String get _storeName => Platform.isIOS ? 'App Store' : 'Google Play';

  VoidCallback? onPurchaseSuccess;
  VoidCallback? onPurchaseFailed;
  VoidCallback? onPurchasePending;

  Future<void> init() async {
    // iOS: Set delegate dùng đúng SKPaymentQueueDelegateWrapper
    if (Platform.isIOS) {
      try {
        final iosPlatformAddition =
            _iap.getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
        await iosPlatformAddition.setDelegate(_VipPaymentQueueDelegate());
      } catch (e) {
        debugPrint('⚠️ iOS delegate setup failed (non-fatal): $e');
      }
    }

    try {
      _isAvailable = await _iap.isAvailable();
      debugPrint('🛒 IAP available: $_isAvailable (${Platform.operatingSystem})');
    } catch (e) {
      debugPrint('❌ IAP not available: $e');
      _isAvailable = false;
      _lastErrorReason = '$_storeName không khả dụng trên thiết bị này';
      return;
    }

    if (!_isAvailable) {
      _lastErrorReason = '$_storeName không khả dụng trên thiết bị này';
      return;
    }

    await _subscription?.cancel();
    _subscription = _iap.purchaseStream.listen(
      _onPurchaseUpdate,
      onError: (e) => debugPrint('❌ IAP stream error: $e'),
    );

    await _loadProduct();
  }

  Future<void> _loadProduct() async {
    debugPrint('🔍 Loading product: $kVipProductId on $_storeName');
    try {
      final response = await _iap.queryProductDetails({kVipProductId});

      if (response.error != null) {
        debugPrint('❌ Product query error: ${response.error}');
        _lastErrorReason =
            'Lỗi tải sản phẩm từ $_storeName: ${response.error?.message}';
      }

      if (response.productDetails.isNotEmpty) {
        _vipProduct = response.productDetails.first;
        debugPrint(
            '✅ Product loaded: ${_vipProduct?.title} - ${_vipProduct?.price}');
      } else {
        debugPrint(
            '⚠️ Product not found on $_storeName. Not found IDs: ${response.notFoundIDs}');
        _lastErrorReason =
            'Sản phẩm chưa được tạo trên $_storeName\n'
            'Not found: ${response.notFoundIDs}';
      }
    } catch (e) {
      debugPrint('❌ _loadProduct error: $e');
      _lastErrorReason = 'Không thể tải sản phẩm: $e';
    }
  }

  Future<void> buyVip() async {
    debugPrint(
        '🛒 buyVip called. isAvailable=$_isAvailable, product=$_vipProduct, platform=${Platform.operatingSystem}');

    if (!_isAvailable) {
      _lastErrorReason = '$_storeName không khả dụng';
      onPurchaseFailed?.call();
      return;
    }

    if (_vipProduct == null) {
      debugPrint('❌ Product null — reload thử...');
      await _loadProduct();

      if (_vipProduct == null) {
        _lastErrorReason =
            'Chưa tạo sản phẩm trên $_storeName\n'
            'Vui lòng thử lại sau hoặc liên hệ hỗ trợ.';
        onPurchaseFailed?.call();
        return;
      }
    }

    try {
      final param = PurchaseParam(productDetails: _vipProduct!);
      await _iap.buyNonConsumable(purchaseParam: param);
    } on Exception catch (e) {
      debugPrint('❌ buyNonConsumable error: $e');
      _lastErrorReason = e.toString();
      onPurchaseFailed?.call();
    }
  }

  Future<void> restorePurchases() async {
    await _iap.restorePurchases();
  }

  void _onPurchaseUpdate(List<PurchaseDetails> purchases) {
    for (final purchase in purchases) {
      debugPrint(
          '📦 Purchase update: ${purchase.productID} → ${purchase.status}');
      if (purchase.productID != kVipProductId) continue;

      switch (purchase.status) {
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          _handleSuccess(purchase);
          break;
        case PurchaseStatus.pending:
          onPurchasePending?.call();
          break;
        case PurchaseStatus.error:
          final errMsg = purchase.error?.message ?? 'Lỗi không xác định';
          debugPrint('❌ IAP error: $errMsg');
          if (Platform.isIOS) {
            _lastErrorReason =
                _mapIosError(purchase.error?.code ?? '', errMsg);
          } else {
            _lastErrorReason =
                _mapAndroidError(purchase.error?.code ?? '', errMsg);
          }
          onPurchaseFailed?.call();
          if (purchase.pendingCompletePurchase) {
            _iap.completePurchase(purchase);
          }
          break;
        case PurchaseStatus.canceled:
          _lastErrorReason = 'Bạn đã huỷ thanh toán';
          onPurchaseFailed?.call();
          break;
      }
    }
  }

  String _mapIosError(String code, String fallback) {
    switch (code) {
      case 'SKErrorPaymentCancelled':
      case '2':
        return 'Bạn đã huỷ thanh toán';
      case 'SKErrorPaymentNotAllowed':
      case '3':
        return 'Thiết bị không cho phép thanh toán In-App Purchase.\nKiểm tra Screen Time hoặc cài đặt gia đình.';
      case 'SKErrorPaymentInvalid':
      case '4':
        return 'Thông tin thanh toán không hợp lệ. Kiểm tra lại Apple ID.';
      case 'SKErrorStoreProductNotAvailable':
      case '5':
        return 'Sản phẩm chưa có trên App Store tại khu vực của bạn.';
      case 'SKErrorCloudServiceNetworkConnectionFailed':
        return 'Không có kết nối mạng. Vui lòng thử lại.';
      default:
        return fallback.isNotEmpty
            ? fallback
            : 'Thanh toán thất bại. Vui lòng thử lại.';
    }
  }

  String _mapAndroidError(String code, String fallback) {
    switch (code) {
      case '1':
        return 'Bạn đã huỷ thanh toán';
      case '2':
        return 'Dịch vụ Google Play không khả dụng. Vui lòng thử lại.';
      case '3':
        return 'Thanh toán chưa sẵn sàng. Thử lại sau vài phút.';
      case '4':
        return 'Sản phẩm chưa có trên Play Console.\nVui lòng liên hệ hỗ trợ.';
      case '5':
        return 'Lỗi nhà phát triển. Vui lòng liên hệ hỗ trợ.';
      case '6':
        return 'Lỗi kết nối mạng. Kiểm tra internet và thử lại.';
      case '7':
        return 'Bạn đã mua sản phẩm này rồi. Hãy dùng "Khôi phục giao dịch".';
      default:
        return fallback.isNotEmpty
            ? fallback
            : 'Thanh toán thất bại. Vui lòng thử lại.';
    }
  }

  Future<void> _handleSuccess(PurchaseDetails purchase) async {
    if (purchase.pendingCompletePurchase) {
      await _iap.completePurchase(purchase);
    }

    final firebaseUid = FirebaseAuth.instance.currentUser?.uid;
    final prefs = await SharedPreferences.getInstance();
    final userId = firebaseUid ?? prefs.getString('userId') ?? '';

    if (userId.isNotEmpty) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({'isVip': true});
      debugPrint('✅ Firestore isVip updated for $userId');
    }

    AdsService().setVip(true);
    onPurchaseSuccess?.call();
  }

  void dispose() {
    // Xoá delegate iOS khi dispose để tránh memory leak
    if (Platform.isIOS) {
      try {
        _iap
            .getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>()
            .setDelegate(null);
      } catch (_) {}
    }
    _subscription?.cancel();
  }
}

/// iOS Payment Queue Delegate
/// Dùng đúng class: SKPaymentQueueDelegateWrapper (không phải SKPaymentTransactionObserverWrapper)
class _VipPaymentQueueDelegate implements SKPaymentQueueDelegateWrapper {
  /// Cho phép tiếp tục giao dịch trên mọi storefront (kể cả khi đổi quốc gia)
  @override
  bool shouldContinueTransaction(
    SKPaymentTransactionWrapper transaction,
    SKStorefrontWrapper storefront,
  ) =>
      true;

  /// Cho phép hiển thị popup xác nhận thay đổi giá subscription
  @override
  bool shouldShowPriceConsent() => true;
}