// Quantumult X 脚本 by夕颜
// 功能: 拦截原始请求体，发起兑换请求，返回通知

let body = $request.body;
let json;

try {
  json = JSON.parse(body);
} catch (e) {
  console.log("解析失败:", e);
  $done({});
  return;
}

const wxid = json.wxid || "未知wxid";
const rawCode = json.code || "";
const code = rawCode.startsWith("TB") ? rawCode : "TB" + rawCode;

const url = "https://theme.25mao.com/index/redeem";
const headers = {
  "Content-Type": "application/json",
  "User-Agent": "Mozilla/5.0 (iPhone; CPU iPhone OS 16_5 like Mac OS X)"
};

const requestBody = JSON.stringify({ wxid, code });

$task.fetch({ url, method: "POST", headers, body: requestBody }).then(resp => {
  let msg = "无返回信息";
  try {
    const res = JSON.parse(resp.body);
    msg = res.message || msg;
  } catch (e) {
    msg = "响应解析失败";
  }

  $notify("by夕颜", "", `自动抢盒子兑换码通知\nwxid: ${wxid}\ncode: ${code}\n返回: ${msg}`);
  $done({ response: resp });
}).catch(err => {
  $notify("by夕颜", "", `自动抢盒子兑换码通知\nwxid: ${wxid}\ncode: ${code}\n返回: 请求失败`);
  $done({});
});