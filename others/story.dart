// import 'package:get/get.dart';

// class Story extends GetxController {
//   // static Future<InstaProfile> storyFromUrl(String userUrl) async {
//   //   InstaProfile _profileParsed = InstaProfile();
//   //   String _temporaryData = '';
//   //   int _startInx = 0, _endInx = 1;
//   //   Client _client = Client();
//   //   Response _response;
//   //   var _document, jsonData;
//   //   List<InstaStory> _storyData = [];

//   //   _profileParsed = await InstaData.userProfileData(userUrl);
//   //   if (_profileParsed != null) {
//   //     if (_profileParsed.isPrivate == false) {
//   //       String _patternStart = "{\"pageProps\":";
//   //       String _patternEnd = ",\"__N_SSP\":tru";

//   //       try {
//   //         String username =
//   //             userUrl.replaceAll('https://www.instagram.com/', '');
//   //         username = username.replaceAll('https://instagram.com/', '');
//   //         username = username.replaceAll('/', '');
//   //         _response =
//   //             await _client.get('https://storiesig.com/stories/$username');
//   //         _document = parse(_response.body);
//   //         _document = _document.querySelectorAll('body');
//   //         _temporaryData = _document[0].text;

//   //         _temporaryData = _temporaryData.trim();
//   //         _startInx =
//   //             _temporaryData.indexOf(_patternStart) + _patternStart.length;
//   //         _endInx = _temporaryData.indexOf(_patternEnd);
//   //         _temporaryData = _temporaryData.substring(_startInx, _endInx);
//   //         jsonData = json.decode(_temporaryData);

//   //         // print(jsonData);
//   //         _profileParsed.storyCount =
//   //             int.parse(jsonData['stories']['media_count'].toString());
//   //         for (var item in jsonData['stories']['items']) {
//   //           var date =
//   //               DateTime.fromMillisecondsSinceEpoch(item['taken_at'] * 1000);
//   //           _storyData.add(InstaStory(
//   //             storyDate: date.toString(),
//   //             storyType:
//   //                 item['media_type'].toString() == '1' ? 'photo' : 'video',
//   //             storyHeight: item['original_height'].toString(),
//   //             storyWidth: item['original_width'].toString(),
//   //             storyThumbnail:
//   //                 item['image_versions2']['candidates'][0]['url'].toString(),
//   //             downloadUrl: item['media_type'].toString() == '1'
//   //                 ? item['image_versions2']['candidates'][0]['url'].toString()
//   //                 : item['video_versions'][0]['url'].toString(),
//   //           ));
//   //         }
//   //         _profileParsed.storyData = _storyData;
//   //       } catch (error) {
//   //         print('[InstaData][storyFromUrl]: $error');
//   //       }
//   //     } else {
//   //       // Private Acc
//   //       return _profileParsed;
//   //     }
//   //   } else {
//   //     // Invaild URL
//   //     return null;
//   //   }
//   //   return _profileParsed;
//   // }
// }
