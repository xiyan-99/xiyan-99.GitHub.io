//  mikoto - 修改点歌卡片的封面by夕颜

let body = $response.body;
if (body) {
  try {
    let obj = JSON.parse(body);
    if (obj && obj.data) {
   
      let originalName = obj.data.song_name || "";
      let originalSinger = obj.data.song_singer || "";
      //by夕颜
    
      obj.data.song_name = originalName + "-" + originalSinger;
      // 将歌手改为固定文本“点击播放—>”
      obj.data.song_singer = "夕颜电台      播放 >>>";
      // 修改封面为指定链接
      obj.data.cover = "http://fmc-75014.picgzc.qpic.cn/consult_viewer_pic__f9686da5-d436-4b16-afa3-fd4d0ffe3f5c_1740890135515.jpg";
    }
    $done({body: JSON.stringify(obj)});
  } catch (e) {
    console.log("解析失败by夕颜:", e);
    $done({body});
  }
} else {
  $done({});
}
//by夕颜
