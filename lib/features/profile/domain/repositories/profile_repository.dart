import 'package:zaika/common/models/response_model.dart';
import 'package:zaika/api/api_client.dart';
import 'package:zaika/features/profile/domain/models/update_profile_response_model.dart';
import 'package:zaika/features/profile/domain/models/update_user_model.dart';
import 'package:zaika/features/profile/domain/models/userinfo_model.dart';
import 'package:zaika/features/profile/domain/repositories/profile_repository_interface.dart';
import 'package:zaika/util/app_constants.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class ProfileRepository implements ProfileRepositoryInterface {
  final ApiClient apiClient;
  ProfileRepository({required this.apiClient});

  @override
  Future<ResponseModel> updateProfile(UpdateUserModel userInfoModel, XFile? data, String tokeni) async {
    ResponseModel responseModel;
    Response response = await apiClient.postMultipartData(AppConstants.updateProfileUri, userInfoModel.toJson(), [MultipartBody('image', data)], [], handleError: false);
    if (response.statusCode == 200) {
      String message = 'profile_updated_successfully'.tr;
      if (response.body != null && response.body is Map && response.body['message'] != null) {
        message = response.body['message'];
      }
      responseModel = ResponseModel(true, message,
        updateProfileResponseModel: (response.body != null && response.body is Map && response.body['verification_on'] != null) ? UpdateProfileResponseModel.fromJson(response.body) : null,
      );
    } else {
      String? errorMessage;
      if (response.body != null && response.body is Map) {
        if (response.body['errors'] != null && (response.body['errors'] is List) && (response.body['errors'] as List).isNotEmpty) {
          errorMessage = response.body['errors'][0]['message'];
        } else if (response.body['message'] != null) {
          errorMessage = response.body['message'];
        }
      }
      errorMessage ??= response.statusText ?? 'something_went_wrong'.tr;
      responseModel = ResponseModel(false, errorMessage,
        updateProfileResponseModel: (response.body != null && response.body is Map && response.body['verification_on'] != null) ? UpdateProfileResponseModel.fromJson(response.body) : null,
      );
    }
    return responseModel;
  }

  @override
  Future<ResponseModel> changePassword(UserInfoModel userInfoModel) async {
    ResponseModel responseModel;
    Map<String, dynamic> data = {
      'name': '${userInfoModel.fName} ${userInfoModel.lName}',
      'email': userInfoModel.email,
      'password': userInfoModel.password,
      'phone': userInfoModel.phone,
      'button_type': 'change_password'
    };
    Response response = await apiClient.postData(AppConstants.updateProfileUri, data, handleError: false);
    if (response.statusCode == 200) {
      String? message = response.body["message"];
      responseModel = ResponseModel(true, message);
    } else {
      responseModel = ResponseModel(false, response.statusText);
    }
    return responseModel;
  }

  @override
  Future add(value) {
    // TODO: implement add
    throw UnimplementedError();
  }

  @override
  Future<Response> delete(int? id) async {
    return await apiClient.postData(AppConstants.customerRemoveUri, {"_method": "delete"});
  }

  @override
  Future<UserInfoModel?> get(String? id) async {
    UserInfoModel? userInfoModel;
    Response response = await apiClient.getData(AppConstants.customerInfoUri);
    if (response.statusCode == 200) {
      userInfoModel = UserInfoModel.fromJson(response.body);
    }
    return userInfoModel;
  }

  @override
  Future getList({int? offset}) {
    // TODO: implement getList
    throw UnimplementedError();
  }

  @override
  Future update(Map<String, dynamic> body, int? id) {
    // TODO: implement update
    throw UnimplementedError();
  }

  
}