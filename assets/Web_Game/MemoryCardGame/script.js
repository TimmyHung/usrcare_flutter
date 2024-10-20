var gameListing = document.getElementById("diff-list");

// 使用 URLSearchParams 來解析 URL
var urlParams = new URLSearchParams(window.location.search);
// 使用 get 方法來獲得參數的值
var paramValue = urlParams.get('param');
// 使用 param1Value 進行相應的操作
console.log(paramValue);

games().then(function(gamePaths) {
    gamePaths.forEach(function(gamePath) {
        const imgElement = document.createElement('img');
        imgElement.src = "level_img/" + gamePath.file + ".png";

        var gameLink = document.createElement("a");
        gameLink.classList.add("game");
        gameLink.href = "./" + gamePath.folder + "/index.html?param=" + encodeURIComponent(paramValue);
        gameLink.textContent = gamePath.name;

        gameLink.insertBefore(imgElement, gameLink.firstChild);

        var gameElement = document.createElement("div");
        gameElement.classList.add("game-dox");
        gameElement.appendChild(gameLink);

        gameListing.appendChild(gameElement);
    });
});

async function games() {
    return [
        { name: "簡單模式", file: "easy_mode", folder: "easy_mode" },
        { name: "普通模式", file: "normal_mode", folder: "normal_mode" },
        { name: "困難模式", file: "hard_mode", folder: "hard_mode" },
        { name: "超難模式", file: "extreme_mode", folder: "extreme_mode" }
    ];
}
