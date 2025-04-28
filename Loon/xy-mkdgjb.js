const url = $request.url;
const query = url.match(/\?(.*)/)?.[1] || '';
const params = {};
query.split('&').forEach(kv => {
  const [k, v] = kv.split('=');
  params[k] = decodeURIComponent(v || '');
});

const msg = params.msg || '';
const n = params.n || '';
const newApi = `https://api.dragonlongzhu.cn/api/joox/juhe_music.php?msg=${encodeURIComponent(msg)}&n=${n}&type=json&n=1`;

$httpClient.get(newApi, function (error, response, data) {
  if (error || !data) {
    console.log("新接口请求失败: " + error);
    return $done({});
  }

  try {
    const res = JSON.parse(data).data;

    // 构造原接口需要的响应结构
    const final = {
      data: {
        music_url: $argument.music_url || $persistentStore.read("music_url") || res.url || "",
        song_name: $argument.song_name || res.title || "",
        song_singer: $argument.song_singer || res.singer || "",
        cover: $argument.cover || res.cover || "",
        lyric: $argument.lyric || res.lyric || ""
      }
    };

    if ($argument.music_url || $persistentStore.read("music_url")) {
      console.log("使用音频链接: " + final.data.music_url);
      $persistentStore.remove("music_url");
    }

    $done({ body: JSON.stringify(final) });
  } catch (err) {
    console.log("解析 JSON 出错: " + err);
    $done({});
  }
});