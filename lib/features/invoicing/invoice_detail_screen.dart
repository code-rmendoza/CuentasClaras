import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/providers/database_provider.dart';
import '../../core/utils/currency_utils.dart';

/// Pantalla de detalle / vista previa del comprobante emitido con membrete de la empresa.
class InvoiceDetailScreen extends ConsumerWidget {
  final int invoiceId;

  const InvoiceDetailScreen({super.key, required this.invoiceId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dao = ref.watch(invoicesDaoProvider);
    final companyAsync = ref.watch(companyProfileStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de Comprobante'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Compartir Comprobante',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Generando versión PDF para compartir...')),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder(
        future: dao.getInvoiceById(invoiceId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final invoice = snapshot.data;
          if (invoice == null) {
            return const Center(child: Text('Comprobante no encontrado'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Membrete de la Empresa ────────────────────────
                    companyAsync.when(
                      data: (comp) {
                        final taxId = comp.taxId;
                        final address = comp.address;
                        final header = comp.invoiceHeader;

                        return Center(
                          child: Column(
                            children: [
                              const Icon(Icons.business, size: 40, color: Colors.blue),
                              const SizedBox(height: 6),
                              Text(
                                comp.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (taxId != null && taxId.isNotEmpty)
                                Text(
                                  'RIF/NIT: $taxId',
                                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                              if (address != null && address.isNotEmpty)
                                Text(
                                  address,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                                ),
                              if (header != null && header.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  '"$header"',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontStyle: FontStyle.italic,
                                    color: Colors.blueGrey,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        );
                      },
                      loading: () => const SizedBox.shrink(),
                      error: (err, stack) => const SizedBox.shrink(),
                    ),
                    const Divider(height: 24),

                    // Número y fecha de factura
                    Center(
                      child: Column(
                        children: [
                          Text(
                            invoice.invoiceNumber,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Fecha: ${invoice.issueDate.day}/${invoice.issueDate.month}/${invoice.issueDate.year}',
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 24),

                    // Datos del Cliente
                    Text(
                      'Cliente / Receptor',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    Text(
                      invoice.partyName,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),

                    // Detalles Financieros
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Método de Pago:'),
                        Text(
                          invoice.paymentMethod,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Estado:'),
                        Text(
                          invoice.status == 'paid' ? 'PAGADA' : 'PENDIENTE',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: invoice.status == 'paid' ? Colors.green : Colors.orange,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),

                    // Desglose de totales
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Subtotal:'),
                        Text(CurrencyUtils.formatCents(invoice.subtotalCents, invoice.currency)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Impuestos / IVA:'),
                        Text(CurrencyUtils.formatCents(invoice.taxCents, invoice.currency)),
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'TOTAL:',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          CurrencyUtils.formatCents(invoice.totalCents, invoice.currency),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),

                    // Pie de Página del Comprobante
                    companyAsync.maybeWhen(
                      data: (comp) {
                        final footer = comp.invoiceFooter;
                        if (footer != null && footer.isNotEmpty) {
                          return Column(
                            children: [
                              const Divider(height: 32),
                              Center(
                                child: Text(
                                  footer,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                            ],
                          );
                        }
                        return const SizedBox.shrink();
                      },
                      orElse: () => const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
