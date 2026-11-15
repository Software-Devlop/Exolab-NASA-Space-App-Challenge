import 'package:exolab/features/aiModel/domain/abstractRepos/stressRepo.dart';
import 'package:exolab/features/aiModel/domain/entities/stressFeatures.dart';
import 'package:exolab/features/aiModel/domain/entities/stressPrediction.dart';

class PredictStress {
  final StressRepository _repo;
  const PredictStress(this._repo);

  Future<StressPrediction> call(StressFeatures features) =>
      _repo.predict(features);
}
