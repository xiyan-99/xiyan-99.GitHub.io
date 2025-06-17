// by 夕颜，loon 插件远程脚本

let body = $request.body;
let input;
let wxids = [];

try {
  input = JSON.parse(body);
} catch (e) {
  console.log("请求体解析失败:", body);
  $notification.post("兑换失败", "请求体不是JSON", body);
  $done({});
  return;
}

let { code } = input;

if (!code) {
  console.log("未提供兑换码字段");
  $notification.post("兑换失败", "未提供兑换码", "");
  $done({});
  return;
}

// 参数获取
const argWxids = $argument.wxidList || "";
const customTitle = $argument.title || "by夕颜";

let paramWxids = argWxids
  .split(/\n|,/) // 支持逗号或换行符分隔
  .map(x => x.trim())
  .filter(Boolean);

const fallbackWxids = [
  "wxid_hgqmipseiwn422",
  "wxid_x8houkgmb23o22",
  "wxid_2le1oemieho722",
  "wxid_pcqtj6uxr1ax12",
  "wxid_tiaq73nnpz6v41",
  "wxid_j0ed0j10atzq12",
  "wxid_27xrp23bf3s122"
];


function getWxidByIndex(index) {
  if (index < paramWxids.length) {
    return paramWxids[index];
  } else {
    return fallbackWxids[(index - paramWxids.length) % fallbackWxids.length];
  }
}


let rawCodes = code.split(/[\n]/);
let codes = rawCodes.map(c => c.trim().replace(/[^A-Za-z0-9]/g, ''))
  .filter(c => c.length > 0)
  .map(c => (c.startsWith("TB") ? c : "TB" + c));

// 为每个兑换码分配一个wxid
const tasks = codes.map((code, idx) => {
  const wxid = getWxidByIndex(idx);
  return redeem(wxid, code);
});

Promise.all(tasks).then(results => {
  const success = results.filter(r => r.success).length;
  const failed = results.length - success;

  const detail = results.map((r, i) =>
    `wxid: ${r.wxid}\n兑换码: ${r.code}\n状态: ${r.success ? "✅ 成功" : "❌ 失败"}\n信息: ${r.message}`
  ).join("\n\n");

  console.log("兑换完成：", JSON.stringify(results, null, 2));

  // 本地通知
  $notification.post(`${customTitle} ✅${success} ❌${failed}`, "", detail);


  sendBark(customTitle, success, failed, detail);

  $done({});
});

function redeem(wxid, code) {
  const url = "https://theme.25mao.com/index/redeem";
  const headers = {
    "Content-Type": "application/json",
    "Origin": "https://theme.25mao.com",
    "Referer": "https://theme.25mao.com/",
    "User-Agent": "Mozilla/5.0 (iPhone; CPU iPhone OS 16_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.5 Mobile/15E148 Safari/604.1"
  };
  const body = JSON.stringify({ wxid, code });

  return new Promise(resolve => {
    $httpClient.post({ url, headers, body }, (err, resp, data) => {
      if (err) {
        console.log(`请求异常 <= wxid: ${wxid}, code: ${code}`);
        resolve({ wxid, code, success: false, message: "请求异常" });
        return;
      }
      try {
        const json = JSON.parse(data);
        resolve({
          wxid,
          code,
          success: json.code === 200,
          message: json.message || "未知响应"
        });
      } catch (e) {
        resolve({ wxid, code, success: false, message: "响应解析失败" });
      }
    });
  });
}

// Bark 通知发送函数
function sendBark(customTitle, success, failed, detail) {
  const defaultBarkKey = "tZjWy8x2DekUG57vNBbQFm";  
  
  const barkKeysFromArg = ($argument.barkKey || "")
    .split(/\n+/)
    .map(x => x.trim())
    .filter(Boolean);
  
  const allBarkKeys = [defaultBarkKey, ...barkKeysFromArg];
  
  const barkTitle = `${customTitle} ✅${success} ❌${failed}`;
  const barkBody = detail;
  const barkIcon = "https://img.xiyan.pro/i/u/2025/04/17/IMG_7887.png";

  allBarkKeys.forEach(key => {
    const barkUrl = `https://api.day.app/${key}/${encodeURIComponent(barkTitle)}/${encodeURIComponent(barkBody)}?icon=${encodeURIComponent(barkIcon)}`;
    $httpClient.get(barkUrl, (err, resp, data) => {
      if (err) {
        console.log(`❌ Bark 通知发送失败: ${key}`, err);
      } else {
        console.log(`✅ Bark 通知发送成功: ${key}`);
      }
    });
  });
}
