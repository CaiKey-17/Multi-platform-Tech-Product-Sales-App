import 'package:app/globals/ip.dart';
import 'package:app/models/category_info.dart';
import 'package:app/models/coupon_info.dart';
import 'package:app/models/product_info.dart';
import 'package:app/models/product_info_detail.dart';
import 'package:app/models/rating_info.dart';
import 'package:app/models/resend_otp_request.dart';
import 'package:app/models/resend_otp_response.dart';
import 'package:app/models/sentiment_request.dart';
import 'package:app/models/sentiment_response.dart';
import 'package:app/models/valid_response.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:retrofit/http.dart';
import '../models/login_request.dart';
import '../models/login_response.dart';

import '../models/register_request.dart';
import '../models/valid_request.dart';
import '../models/register_response.dart';
import '../models/user_info.dart';
import '../models/cart_info.dart';

part 'api_service_sentiment.g.dart';

@RestApi(baseUrl: ApiConfig.baseUrlSentiment)
abstract class ApiServiceSentiment {
  factory ApiServiceSentiment(Dio dio, {String baseUrl}) = _ApiServiceSentiment;

  @POST("/predict")
  Future<SentimentResponse> getSentiment(@Body() SentimentRequest request);
}
