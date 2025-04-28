const url = $request.url;
const query = url.match(/\?(.*)/)?.[1] || '';
const params = {};
query.split('&').forEach(kv => {
  const [k, v] = kv.split('=');
  params[k] = decodeURIComponent(v || '');
});

// 支持两个接口参数名：msg 和 gm
const msg = params.msg || params.gm || '';
const n = params.n || '1';

if (!msg) {
  console.log("关键词为空，退出请求");
  $done({});
}

const newApi = `https://api.dragonlongzhu.cn/api/joox/juhe_music.php?msg=${encodeURIComponent(msg)}&n=${n}&type=json`;

$httpClient.get(newApi, function (error, response, data) {
  if (error || !data) {
    console.log("新接口请求失败: " + error);
    return $done({});
  }

  try {
    const res = JSON.parse(data).data;

    const final = {
      code: 200,
      title: res.title || "",
      singer: res.singer || "",
      id: "标准音质",
      link: res.link || "",
      cover: res.cover || "",
      music_url: res.url || "",
      lrc: res.lyric || "",
      lyric: res.lyric || "",
      data: {
        music_url: $argument.music_url || $persistentStore.read("music_url") || res.url || "",
        title: $argument.song_name || res.title || "",
        singer: $argument.song_singer || res.singer || "",
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