let userData = {
    guessTimes: 0
};

var text = document.querySelector("#text");
var count = document.querySelector("#count");
var result = document.querySelector(".result");
var guessBu = document.querySelector("#guess");
var reBu = document.querySelector("#reBu");
var resultDisplay = document.querySelector("#result");
var correctAudio = document.getElementById("correct-audio");

// 彈窗元素
var modal = document.getElementById("myModal");
var modalText = document.getElementById("modalText");

var minRange = 1;
var maxRange = 100;

let startTime, endTime;
let gameStarted = false;

var guessNumber = Math.floor(Math.random() * (maxRange - minRange + 1)) + minRange;
userData.guessTimes = 0;

guessBu.onclick = function() {
    if (text.value == '') {
        text.focus();
        return;
    }

    if (!gameStarted) {
        startTime = new Date(); // 第一次點擊時開始計時
        gameStarted = true;
    }

    userData.guessTimes++;
    count.innerHTML = userData.guessTimes;
    var userGuess = parseInt(text.value);

    if (isNaN(userGuess) || userGuess < 1 || userGuess > 100) {
        result.innerHTML = "請輸入1-100的數字";
        result.style.color = "red";
        resultDisplay.innerHTML = "輸入錯誤！";
    } else if (userGuess > guessNumber) {
        result.innerHTML = "再小一點";
        result.style.color = "red";
        if (userGuess <= maxRange) {
            maxRange = userGuess;
        }

        resultDisplay.innerHTML = `${minRange}-${maxRange}`;
    } else if (userGuess < guessNumber) {
        result.innerHTML = "再大一點！";
        result.style.color = "red";
        if (userGuess >= minRange) {
            minRange = userGuess;
        }
        resultDisplay.innerHTML = `${minRange}-${maxRange}`;
    } else {
        result.className = "c2";
        result.innerHTML = "恭喜猜對了！";
        result.style.color = "green";
        resultDisplay.innerHTML = "恭喜猜對了！";
        playCorrectGuessSound();

        endTime = new Date(); // 記錄結束時間

        gamedata = {
            "game": "Da Vinci Code",
            'guess_times': userData.guessTimes,
            'start_time': startTime.toISOString().split(".")[0],
            'end_time': endTime.toISOString().split(".")[0]
        }
        sendDataToFlutter(gamedata);

        // 顯示結束彈窗
        showEndGameModal();

        return;
    }
    text.value = '';
    text.focus();
}

function playCorrectGuessSound() {
    correctAudio.play();
}

reBu.onclick = function() {
    resetGame();
}

function resetGame() {
    minRange = 1;
    maxRange = 100;
    guessNumber = Math.floor(Math.random() * (maxRange - minRange + 1)) + minRange;
    userData.guessTimes = 0;
    count.innerHTML = userData.guessTimes;
    result.innerHTML = "";
    resultDisplay.innerHTML = "";
    text.value = "";
    gameStarted = false;
}

function sendDataToFlutter(data) {
    console.log(data);
    try {
        FlutterInterface.postMessage(JSON.stringify(data));
    } catch (e) {
        console.log(e);
    }
}

// 顯示彈窗
function showEndGameModal() {
    modal.style.display = "block";
}

// 再玩一次
function playAgain() {
    resetGame();
    modal.style.display = "none";
}
