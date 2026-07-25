import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/company_profile_table.dart';

part 'company_profile_dao.g.dart';

/// DAO para operaciones CRUD del perfil de empresa y membrete de facturas.
@DriftAccessor(tables: [CompanyProfile])
class CompanyProfileDao extends DatabaseAccessor<AppDatabase> with _$CompanyProfileDaoMixin {
  CompanyProfileDao(super.db);

  /// Obtiene el perfil del negocio único. Si no existe, crea una entrada inicial por defecto.
  Future<CompanyProfileData> getCompanyProfile() async {
    final list = await select(companyProfile).get();
    if (list.isNotEmpty) {
      return list.first;
    }

    // Insertar registro inicial por defecto
    final id = await into(companyProfile).insert(
      const CompanyProfileCompanion(
        name: Value('Mi Negocio Comercial'),
        taxId: Value('J-12345678-9'),
        phone: Value('+58 412 1234567'),
        email: Value('contacto@minegocio.com'),
        address: Value('Av. Principal, Caracas, Venezuela'),
        invoiceHeader: Value('¡Gracias por su compra!'),
        invoiceFooter: Value('Comprobante emitido sin tachaduras ni enmiendas.'),
      ),
    );

    return (select(companyProfile)..where((t) => t.id.equals(id))).getSingle();
  }

  /// Stream reactivo del perfil de empresa.
  Stream<CompanyProfileData> watchCompanyProfile() async* {
    final initial = await getCompanyProfile();
    yield initial;

    yield* (select(companyProfile)..where((t) => t.id.equals(initial.id))).watchSingle();
  }

  /// Actualiza los datos del perfil de empresa.
  Future<bool> updateCompanyProfile(CompanyProfileCompanion entry) async {
    final profile = await getCompanyProfile();
    return (update(companyProfile)..where((t) => t.id.equals(profile.id)))
        .write(entry.copyWith(updatedAt: Value(DateTime.now())))
        .then((rows) => rows > 0);
  }
}
