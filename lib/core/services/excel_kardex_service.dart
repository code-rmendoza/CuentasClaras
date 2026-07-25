import 'dart:io';
import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../data/database/app_database.dart';

class ExcelKardexService {
  ExcelKardexService._();
  static final ExcelKardexService instance = ExcelKardexService._();

  /// Genera un archivo CSV/Excel de Kardex e Inventario Valorizado.
  Future<File> generateInventoryKardexCsv({
    required List<Product> products,
    required List<InventoryData> inventoryItems,
  }) async {
    final List<List<dynamic>> rows = [];

    // Cabecera del archivo Excel / CSV
    rows.add([
      'ID Producto',
      'Nombre Producto',
      'Stock Actual',
      'Unidad',
      'Stock Mínimo',
      'Precio Venta (USD)',
      'Costo Unitario (USD)',
      'Valor Total Stock (USD)',
      'Estado Stock',
    ]);

    final Map<int, InventoryData> invMap = {
      for (final item in inventoryItems) item.productId: item
    };

    for (final pItem in products) {
      final inv = invMap[pItem.id];
      final currentStock = inv?.currentStock ?? 0;
      final minStock = inv?.minStock ?? 5;
      final unit = inv?.unit ?? 'units';
      final price = pItem.defaultPrice / 100.0;
      final cost = (inv?.costPerUnit ?? 0) / 100.0;
      final totalValue = currentStock * cost;

      String status = 'Normal';
      if (currentStock <= 0) {
        status = 'AGOTADO';
      } else if (currentStock <= minStock) {
        status = 'STOCK BAJO';
      }

      rows.add([
        pItem.id,
        pItem.name,
        currentStock,
        unit,
        minStock,
        price.toStringAsFixed(2),
        cost.toStringAsFixed(2),
        totalValue.toStringAsFixed(2),
        status,
      ]);
    }

    final csvString = const ListToCsvConverter().convert(rows);
    final tempDir = await getTemporaryDirectory();
    final dateSuffix = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final file = File(p.join(tempDir.path, 'Kardex_Inventario_$dateSuffix.csv'));

    await file.writeAsString(csvString);
    return file;
  }

  /// Genera y comparte directamente el archivo de Kardex e Inventario por WhatsApp / Email / Drive.
  Future<void> exportAndShareKardex({
    required List<Product> products,
    required List<InventoryData> inventoryItems,
  }) async {
    final file = await generateInventoryKardexCsv(
      products: products,
      inventoryItems: inventoryItems,
    );

    final xFile = XFile(file.path, name: p.basename(file.path));
    await Share.shareXFiles(
      [xFile],
      subject: 'Kardex e Inventario Valorizado CuentasClaras',
      text: 'Exportación oficial de Kardex de Inventario en Excel / CSV.',
    );
  }
}
