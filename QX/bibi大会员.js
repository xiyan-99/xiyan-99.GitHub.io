/*

新版需要自己抓包找域名

[rewrite_local]

#哔哩哔哩解锁大会员
^https?:\/\/app\.bilibili\.com/bilibili\.app\.playurl\.v1\.PlayURL/PlayView$ url script-request-header bibi.js

[mitm]
hostname = *.biliapi.*, *.bilibili.*

*/

var modifiedHeaders = $request.headers;

modifiedHeaders['Cookie'] = '_uuid=3FD2DC8D-83B10-210E7-D10109-CB23DA107D5ED19162infoc; b_nut=1714998119; buvid3=2F3BDA33-2D0A-53FB-5F04-022ECDF0548119359infoc; buvid4=7A1A92E9-74ED-B315-839B-5FCC794A936019359-124050612-dS/6Tr0EBFyLpEUlLKTkwA%3D%3D; buvid_fp=b8d811880c2feb618f332d8d25dac0e1; Buvid=YD4DCEDD0A00B9134C6AB6373FDB351A8C21; DedeUserID=3546559201413941; DedeUserID__ckMd5=86d2937300731cc4; SESSDATA=8ce5e62a%2C1730550078%2C28596351CjCL0HS0ZTG_oZX5R3FvRrLHM7p1kuzLPOCFeYCzW1X4AVbnpjQeuzWdugRIccNd2qISVmxkTXJJUzdiblB5MDJBTUlpU3lVRTc4QTB0R1lIU2dYTEFhdl82dmoyd1FHRTNCZ3NpTFlVdTZScVVqSHVCUTRJSDVoaGlYclNiWXFLLV8yd3ZWS2tBIIEC; bili_jct=f0118aa14e36f241fa3e40136f14c9ec; sid=dmjtn5j7';

modifiedHeaders['Authorization'] = 'identify_v1 34be130b079e6c811b3a64f07de30f51CjCL0HS0ZTG_oZX5R3FvRrLHM7p1kuzLPOCFeYCzW1X4AVbnpjQeuzWdugRIccNd2qISVmxkTXJJUzdiblB5MDJBTUlpU3lVRTc4QTB0R1lIU2dYTEFhdl82dmoyd1FHRTNCZ3NpTFlVdTZScVVqSHVCUTRJSDVoaGlYclNiWXFLLV8yd3ZWS2tBIIEC';

modifiedHeaders['User-Agent'] = 'bili-universal/77600100 os/ios model/iPhone 15 Pro Max mobi_app/iphone osVer/17.1.1 network/2';

$done({headers : modifiedHeaders});
