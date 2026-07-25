import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../shared/providers/database_provider.dart';
import '../../core/utils/currency_utils.dart';

/// Pantalla principal del Módulo de Facturación (Historial de comprobantes).
class InvoicesListScreen extends ConsumerWidget {
  const InvoicesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invoicesAsync = ref.watch(allInvoicesProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Facturación & Comprobantes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.receipt_long),
            tooltip: 'Siguiente Correlativo',
            onPressed: () async {
              final dao = ref.read(invoicesDaoProvider);
              final nextNumber = await dao.getNextInvoiceNumber('invoice');
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Próximo Correlativo: $nextNumber')),
                );
              }
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/invoices/new'),
        icon: const Icon(Icons.add_shopping_cart),
        label: const Text('Nueva Factura'),
      ),
      body: invoicesAsync.when(
        data: (invoices) {
          if (invoices.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_sharp, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No hay facturas registradas',
                    style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () => context.push('/invoices/new'),
                    icon: const Icon(Icons.add),
                    label: const Text('Emitir Primera Factura'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: invoices.length,
            itemBuilder: (context, index) {
              final invoice = invoices[index];
              return Card(
                elevation: 1,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: invoice.type == 'credit_note'
                        ? Colors.orange.withValues(alpha: 0.1)
                        : Colors.blue.withValues(alpha: 0.1),
                    child: Icon(
                      invoice.type == 'credit_note' ? Icons.remove_circle_outline : Icons.receipt,
                      color: invoice.type == 'credit_note' ? Colors.orange : Colors.blue,
                    ),
                  ),
                  title: Text(
                    '${invoice.invoiceNumber} • ${invoice.partyName}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '${invoice.issueDate.day}/${invoice.issueDate.month}/${invoice.issueDate.year} • ${invoice.paymentMethod}',
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        CurrencyUtils.formatCents(invoice.totalCents, invoice.currency),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: invoice.status == 'paid'
                              ? Colors.green.withValues(alpha: 0.1)
                              : Colors.amber.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          invoice.status == 'paid' ? 'Pagada' : 'Pendiente',
                          style: TextStyle(
                            fontSize: 10,
                            color: invoice.status == 'paid' ? Colors.green : Colors.orange[800],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  onTap: () => context.push('/invoices/${invoice.id}'),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
