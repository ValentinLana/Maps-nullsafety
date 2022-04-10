

import 'package:dio/dio.dart';


class PlacesInterceptor extends Interceptor{
@override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
   
const accessToken = 'pk.eyJ1IjoidmFsZW50aW5jdXJzb2ZsdXR0ZXIiLCJhIjoiY2wxbm1vdWlnMDI2ejNicW1sc3JnaXFldiJ9.NyrfbkE0Wfl1ALz-22A_6g';

   options.queryParameters.addAll({
     'access_token': accessToken,
     'language': 'es',
   });



    super.onRequest(options, handler);
  }

}