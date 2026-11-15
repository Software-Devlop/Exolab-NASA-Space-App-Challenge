import 'package:exolab/features/aiModel/data/datasources/standardizer.dart';
import 'package:exolab/features/aiModel/data/repositories/stress_model_source.dart';
import 'package:exolab/features/aiModel/domain/abstractRepos/stressRepo.dart';
import 'package:exolab/features/aiModel/domain/entities/stressFeatures.dart';
import 'package:exolab/features/aiModel/domain/entities/stressPrediction.dart';

class StressRepositoryImpl implements StressRepository {
  final Standardizer _scaler;
  final StressModelSource _model;

  StressRepositoryImpl(this._scaler, this._model);

  @override
  Future<StressPrediction> predict(StressFeatures features) async {
    final scaled = _scaler.transform(features.toList());
    final p = _model.run(scaled);
    return StressPrediction(
      label: p >= 0.5 ? StressLabel.stress : StressLabel.baseline,
      stressProbability: p,
    );
  }
}
