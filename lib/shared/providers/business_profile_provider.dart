import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/enums/business_type.dart';
import 'settings_provider.dart';

class BusinessProfile {
  final BusinessType businessType;
  final String businessName;
  final String ownerName;
  final String phone;
  final String address;
  final double defaultCommissionRate; // e.g. 50.0 for 50%
  final String receiptFooter;
  final String? logoPath;

  const BusinessProfile({
    this.businessType = BusinessType.general,
    this.businessName = 'Mi Negocio',
    this.ownerName = 'Comerciante',
    this.phone = '',
    this.address = '',
    this.defaultCommissionRate = 10.0,
    this.receiptFooter = '¡Gracias por su preferencia!',
    this.logoPath,
  });

  BusinessProfile copyWith({
    BusinessType? businessType,
    String? businessName,
    String? ownerName,
    String? phone,
    String? address,
    double? defaultCommissionRate,
    String? receiptFooter,
    String? logoPath,
  }) {
    return BusinessProfile(
      businessType: businessType ?? this.businessType,
      businessName: businessName ?? this.businessName,
      ownerName: ownerName ?? this.ownerName,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      defaultCommissionRate:
          defaultCommissionRate ?? this.defaultCommissionRate,
      receiptFooter: receiptFooter ?? this.receiptFooter,
      logoPath: logoPath ?? this.logoPath,
    );
  }
}

class BusinessProfileNotifier extends StateNotifier<BusinessProfile> {
  final FlutterSecureStorage _storage;

  BusinessProfileNotifier(this._storage) : super(const BusinessProfile()) {
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final typeId = await _storage.read(key: 'business_type_id');
    final name = await _storage.read(key: 'business_name');
    final owner = await _storage.read(key: 'owner_name');
    final phone = await _storage.read(key: 'business_phone');
    final address = await _storage.read(key: 'business_address');
    final commStr = await _storage.read(key: 'default_commission_rate');
    final footer = await _storage.read(key: 'receipt_footer');
    final logo = await _storage.read(key: 'business_logo_path');

    state = BusinessProfile(
      businessType: BusinessType.fromId(typeId),
      businessName: name ?? 'Mi Negocio',
      ownerName: owner ?? 'Comerciante',
      phone: phone ?? '',
      address: address ?? '',
      defaultCommissionRate: double.tryParse(commStr ?? '10.0') ?? 10.0,
      receiptFooter: footer ?? '¡Gracias por su preferencia!',
      logoPath: logo,
    );
  }

  Future<void> updateBusinessType(BusinessType type) async {
    await _storage.write(key: 'business_type_id', value: type.id);
    state = state.copyWith(businessType: type);
  }

  Future<void> updateDetails({
    required String businessName,
    required String ownerName,
    required String phone,
    required String address,
    required double commissionRate,
    required String receiptFooter,
    String? logoPath,
  }) async {
    await _storage.write(key: 'business_name', value: businessName);
    await _storage.write(key: 'owner_name', value: ownerName);
    await _storage.write(key: 'business_phone', value: phone);
    await _storage.write(key: 'business_address', value: address);
    await _storage.write(
        key: 'default_commission_rate', value: commissionRate.toString());
    await _storage.write(key: 'receipt_footer', value: receiptFooter);
    if (logoPath != null) {
      await _storage.write(key: 'business_logo_path', value: logoPath);
    }

    state = state.copyWith(
      businessName: businessName,
      ownerName: ownerName,
      phone: phone,
      address: address,
      defaultCommissionRate: commissionRate,
      receiptFooter: receiptFooter,
      logoPath: logoPath,
    );
  }
}

final businessProfileProvider =
    StateNotifierProvider<BusinessProfileNotifier, BusinessProfile>((ref) {
  return BusinessProfileNotifier(ref.watch(secureStorageProvider));
});
