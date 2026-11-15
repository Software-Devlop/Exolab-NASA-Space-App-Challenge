import 'package:exolab/features/aiModel/domain/entities/stressFeatures.dart';
import 'package:exolab/features/aiModel/domain/entities/stressPrediction.dart';

abstract class StressRepository {
  Future<StressPrediction> predict(StressFeatures features);
}
