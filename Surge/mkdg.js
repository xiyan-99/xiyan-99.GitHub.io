const url = $request.url;
const obj = JSON.parse($response.body);

// 合并歌名和歌手
obj.data.song_name = `${obj.data.song_name}-${obj.data.song_singer}`;

// 固定歌手显示
obj.data.song_singer = "夕颜电台      播放 ▶▶"; 

// 更换封面
obj.data.cover = "http://fmc-75014.picgzc.qpic.cn/consult_viewer_pic__f9686da5-d436-4b16-afa3-fd4d0ffe3f5c_1740890135515.jpg"; 

$done({ body: JSON.stringify(obj) });
