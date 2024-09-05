const modifiedRequest = {
  url: 'https://api.fish.audio/model',  // 目标请求 URL
  headers: $request.headers
};

// 设置新的 Authorization 请求头
modifiedRequest.headers['Authorization'] = 'Bearer ab5743267ba84d419a1b2a9a2ff02e98';

// 发出修改后的请求
$done({url: modifiedRequest.url, headers: modifiedRequest.headers});
