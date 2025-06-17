// Fineshare 签到并获取积分信息
!(async () => {
  const token = $argument.fineshare_sign_token || "";
  const url = "https://aivoiceover.fineshare.com/api/dailySignin";

  $httpClient.post({
    url,
    headers: {
      Authorization: `Bearer ${token}`,
      "Content-Type": "application/json"
    },
    body: JSON.stringify({ client: "tts" })
  }, function (error, response, data) {
    if (error) {
      $notification.post("🤖 Fineshare 签到失败", "", String(error));
      return $done();
    }

    try {
      const json = JSON.parse(data);
      const message = json?.error?.message || "签到成功";
      const credits = json?.credits ?? "未知";
      const acquired = json?.acquiredCredits ?? "未知";

      $notification.post("🤖 Fineshare 签到", message, `当前积分: ${credits}，获得积分: ${acquired}`);
    } catch (e) {
      $notification.post("🤖 签到响应解析失败", "", String(e));
    }

    $done();
  });
})();