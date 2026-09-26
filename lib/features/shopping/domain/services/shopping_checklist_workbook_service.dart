import '../entities/shopping_checklist.dart';

abstract interface class ShoppingChecklistWorkbookService {
  Future<void> export(ShoppingChecklist checklist);
  Future<ShoppingChecklistImportResult> importChecklist(String tripId);
}
