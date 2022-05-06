import 'package:instegram/core/usecase/usecase.dart';
import 'package:instegram/data/models/user_personal_info.dart';
import 'package:instegram/domain/repositories/story_repository.dart';

class GetStoriesInfoUseCase
    implements
        UseCase<List<UserPersonalInfo>, List<dynamic>> {
  final FirestoreStoryRepository _getStoryRepository;

  GetStoriesInfoUseCase(this._getStoryRepository);

  @override
  Future<List<UserPersonalInfo>> call(
      {required List<dynamic> params}) {
    return _getStoryRepository.getStoriesInfo(
        usersIds: params);
  }
}