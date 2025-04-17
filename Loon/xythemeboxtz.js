// 夕颜编写主题多并发兑换-loon通知版
// 功能: 仅通知最终结果，不修改请求体

let body = $request.body;
let json;
try {
  json = JSON.parse(body);
} catch (e) {
  $notification.post("兑换失败", "请求体不是JSON", "");
  $done({});
  return;
}

const rawCodes = json.code?.split(/\n|,/).map(c => c.trim()).filter(Boolean) || [];

if (rawCodes.length === 0) {
  $notification.post("兑换失败", "未获取到兑换码", "");
  $done({});
  return;
}

const codes = rawCodes.map(code => (code.startsWith("TB") ? code : "TB" + code));
const wxidList = ($argument.wxidList || "").split(",").map(w => w.trim()).filter(Boolean);

if (wxidList.length === 0) {
  $notification.post("兑换失败", "未设置wxidList参数", "");
  $done({});
  return;
}

// 并发发起请求，但不影响原请求
const tasks = codes.slice(0, wxidList.length).map((code, idx) => {
  const wxid = wxidList[idx];
  return redeem(wxid, code);
});

Promise.all(tasks).then(results => {
  const successList = results.filter(r => r.success);
  const failedList = results.filter(r => !r.success);

  let msg = results.map((r, i) => 
    `第 ${i + 1} 个任务 by 夕颜\nwxid: ${r.wxid}\n兑换码: ${r.code}\n状态: ${r.success ? "✅成功" : "❌失败"}\n信息: ${r.message}`
  ).join("\n\n");

  $notification.post(
    `主题兑换完成 ✅${successList.length} ❌${failedList.length}`,
    `共 ${results.length} 个任务`,
    msg.length > 300 ? msg.slice(0, 300) + "\n...内容过长已截断" : msg
  );

  $done({}); // 让原始请求继续，不修改任何内容
});

function redeem(wxid, code) {
  const url = "https://theme.25mao.com/index/redeem";
  const headers = {
    "Content-Type": "application/json",
    "User-Agent": "Mozilla/5.0 (iPhone; CPU iPhone OS 16_5 like Mac OS X)"
  };
  const body = JSON.stringify({ wxid, code });

  return new Promise(resolve => {
    $httpClient.post({ url, headers, body }, (err, resp, data) => {
      if (err) {
        resolve({ wxid, code, success: false, message: "请求失败" });
        return;
      }

      try {
        const res = JSON.parse(data);
        resolve({
          wxid,
          code,
          success: res.code === 200,
          message: res.message || "无返回信息"
        });
      } catch (e) {
        resolve({ wxid, code, success: false, message: "响应解析失败" });
      }
    });
  });
}