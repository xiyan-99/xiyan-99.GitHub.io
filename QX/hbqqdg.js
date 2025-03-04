// Quantumult X 脚本 - 合并修改响应体中歌名、歌手、封面和音乐 URL
// 当 music_url 为 "维护中" 时，调用新 API 获取实际歌曲 URL

(async () => {
  let body = $response.body;
  try {
    let obj = JSON.parse(body);
    if (obj && obj.data) {
      // 保存原始变量
      let originalName = obj.data.song_name || "";
      let originalSinger = obj.data.song_singer || "";
      let originalMusicUrl = obj.data.music_url || "";
      
      // 修改歌名为 "原歌名-原歌手"
      obj.data.song_name = originalName + "-" + originalSinger;
      // 修改歌手为固定文本
      obj.data.song_singer = "夕颜电台      播放 >>>";
      // 修改封面为指定链接（请根据需要修改链接）
      obj.data.cover = "http://fmc-75014.picgzc.qpic.cn/consult_viewer_pic__f9686da5-d436-4b16-afa3-fd4d0ffe3f5c_1740890135515.jpg";
      
      // 如果 music_url 为 "维护中"，则尝试调用新 API 更新歌曲 URL
      if (originalMusicUrl === "维护中") {
        // 构造新 API 的 URL，使用原歌名作为参数（注意：参数需 encodeURIComponent 处理）
        let newAPI = "https://api.dragonlongzhu.cn/api/dg_shenmiMusic_SQ.php?msg=" +
                     encodeURIComponent(originalName) + "&n=1&type=json";
        let res = await $task.fetch({ url: newAPI });
        if (res.statusCode === 200) {
          try {
            let newObj = JSON.parse(res.body);
            if (newObj && newObj.data && newObj.data.music_url && newObj.data.music_url !== "维护中") {
              obj.data.music_url = newObj.data.music_url;
            } else {
              console.log("新 API 返回数据异常: " + res.body);
              // 保留原来的 music_url（"维护中"）
            }
          } catch (e) {
            console.log("解析新 API 返回 JSON 失败: " + e);
          }
        } else {
          console.log("新 API 请求失败，状态码：" + res.statusCode);
        }
      }
    }
    $done({ body: JSON.stringify(obj) });
  } catch (e) {
    console.log("解析原响应 JSON 失败: " + e);
    $done({ body });
  }
})();
