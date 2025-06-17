// 兼容性检测函数
function compatible(works_min, works_max, tweak_compatibility) {
    // 获取当前 iOS 系统版本（从 UA 中提取）并转换为浮点数
    let currentiOS = parseFloat((
        '' + (/CPU.*OS ([0-9_]{1,})|(CPU like).*AppleWebKit.*Mobile/i.exec(navigator.userAgent) || [0, ''])[1]
    ).replace('undefined', '3_2').replace('_', '.').replace('_', ''));

    // 转换版本字符串为可比较的浮点格式
    works_min = numerize(works_min);
    works_max = numerize(works_max);

    // 获取页面中用于显示兼容性的元素
    let el = document.querySelector(".compatibility");

    // 判断当前系统是否低于、超出或位于兼容范围
    if (currentiOS < works_min) {
        el.innerHTML = "你的 iOS 版本太低，不支持该插件。支持版本：" + tweak_compatibility + "。";
        el.classList.add("red");
    } else if (currentiOS > works_max) {
        el.innerHTML = "你的 iOS 版本过高，不支持该插件。支持版本：" + tweak_compatibility + "。";
        el.classList.add("red");
    } else if (String(currentiOS) !== "NaN") {
        el.innerHTML = "该插件与你的设备兼容！";
        el.classList.add("green");
    }
}

// 将版本号字符串转为浮点格式（如 14.2.1 => 14.21）
function numerize(x) {
    return x.substring(0, x.indexOf(".")) + "." + x.substring(x.indexOf(".") + 1).replace(".", "");
}

// 页面模块显示切换函数（用于导航按钮）
function swap(hide, show) {
    const hideElements = document.querySelectorAll(hide);
    const showElements = document.querySelectorAll(show);

    for (let i = 0; i < hideElements.length; i++) {
        hideElements[i].style.display = "none";
    }
    for (let i = 0; i < showElements.length; i++) {
        showElements[i].style.display = "block";
    }

    // 更新导航按钮激活状态
    document.querySelector(".nav_btn" + show + "_btn")?.classList.add("active");
    document.querySelector(".nav_btn" + hide + "_btn")?.classList.remove("active");
}

// 所有 <a> 链接默认新标签页打开
function externalize() {
    const links = document.querySelectorAll("a");
    for (let i = 0; i < links.length; i++) {
        links[i].setAttribute("target", "_blank");
    }
}

// 黑暗模式切换函数，isOled 为 true 则使用纯黑背景
function darkMode(isOled) {
    const darkColor = isOled ? "black" : "#161616";
    const body = document.querySelector("body");
    body.style.color = "white";
    body.style.background = darkColor;

    const elements = document.querySelectorAll(
        ".subtle_link, .subtle_link > div > div, .subtle_link > div > div > p"
    );
    for (let i = 0; i < elements.length; i++) {
        elements[i].style.color = "white";
    }
}

// 如果 UA 包含 "dark"，启用暗黑模式；如有 oled 或 pure-black 则启用纯黑背景
if (navigator.userAgent.toLowerCase().includes("dark")) {
    const ua = navigator.userAgent.toLowerCase();
    darkMode(ua.includes("oled") || ua.includes("pure-black"));
}
