import '../financial_engine.dart';

int? findTippingPointYear(List<GrowthProjection> results) {
  for (var r in results) {
    if ((r.corpusValue - r.totalInvested) >= r.totalInvested) return r.year;
  }
  return null;
}

void exportStrategyCsv(List<GrowthProjection> results) {}
