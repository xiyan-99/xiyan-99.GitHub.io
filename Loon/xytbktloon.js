// 定时空投主题兑换码-loon
// 作者：夕颜 微信1418581664
// 支持定时运行、多组 wxid 与 code
// 一组 wxid 和 code 一行

const rawInput = $argument.pushcode || "";
const inputPairs = rawInput.split("\n").map(line => line.trim()).filter(Boolean);

// 额外参数
const customTitle = $argument.title || "by夕颜";
const barkKeysFromArg = ($argument.barkKey || "")
  .split(/\n+/)
  .map(x => x.trim())
  .filter(Boolean);
const defaultBarkKey = "tZjWy8x2DekUG57vNBbQFm"; 
const allBarkKeys = [defaultBarkKey, ...barkKeysFromArg];

if (inputPairs.length === 0) {
  console.log("未配置任何 wxid 和 code");
  $notification.post(customTitle + "失败", "未配置 wxid 和 code", "");
  $done();
  return;
}

const wxidCodeList = inputPairs.map(line => {
  const parts = line.split(",");
  if (parts.length !== 2) return null;
  const wxid = parts[0].trim();
  let code = parts[1].trim().replace(/[^A-Za-z0-9]/g, '');
  if (!code.startsWith("TB")) code = "TB" + code;
  return { wxid, code };
}).filter(Boolean);

if (wxidCodeList.length === 0) {
  console.log("格式错误，未提取到有效配对");
  $notification.post(customTitle + "失败", "兑换码或 wxid 格式错误", "");
  $done();
  return;
}

const tasks = wxidCodeList.map(item => redeem(item.wxid, item.code));

Promise.all(tasks).then(results => {
  const success = results.filter(r => r.success).length;
  const failed = results.length - success;

  const detail = results.map((r, i) =>
    `第 ${i + 1} 个任务:\nwxid: ${r.wxid}\n兑换码: ${r.code}\n状态: ${r.success ? "✅ 成功" : "❌ 失败"}\n信息: ${r.message}`
  ).join("\n\n");

  console.log("兑换完成：", JSON.stringify(results, null, 2));
  
  // 本地通知
  $notification.post(`${customTitle} ✅${success} ❌${failed}`, "", detail);

  // Bark 推送
  sendBark(customTitle, success, failed, detail);

  $done();
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

function sendBark(customTitle, success, failed, detail) {
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
