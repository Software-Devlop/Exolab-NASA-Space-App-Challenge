import 'package:exolab/features/aiModel/data/datasources/standardizer.dart';
import 'package:exolab/features/aiModel/data/repositories/stress_model_source.dart';
import 'package:exolab/features/aiModel/data/repositories/stress_repo_impl.dart';
import 'package:exolab/features/aiModel/domain/usecases/predictHealthUC.dart';

class AiModelModule {
  AiModelModule._(this.predictStress);

  final PredictStress predictStress;

  static Future<AiModelModule> init() async {
    final scaler = await Standardizer.load();
    final model = await StressModelSource.load();
    final repo = StressRepositoryImpl(scaler, model);
    return AiModelModule._(PredictStress(repo));
  }
}
