// 在開始遊戲時初始化使用者數據
let userData = {
    win_flag: false,
    diff: 0.1,
    sudokuPuzzle: generateEmptyPuzzle(),
    timerInterval: new Date(),
    mistake: 0
};

// let win_flag = false;
// let diff = 0.3;

let puzzle;
let userInput;

let startTime = new Date();
let endTime;
// let timerInterval;


// 使用 URLSearchParams 來解析 URL
var urlParams = new URLSearchParams(window.location.search);
// 使用 get 方法來獲得參數的值
var paramValue = urlParams.get('param');
// 使用 param1Value 進行相應的操作
console.log(paramValue);


document.addEventListener("DOMContentLoaded", function() {
    // startTimer();
    // generateSudoku();
    // document.getElementById("submitButton").addEventListener("click", function() {
    //     if(win_flag){
    //         openModal("遊戲結束，你贏了！\n用時 " + stopTimer());
    //     }
    // });
    document.getElementById("startButton").addEventListener("click", function() {
        startGame();
        userData.sudokuPuzzle = puzzle;
    });
});

function generateSudoku() {
    let sudokuTable = document.getElementById("sudokuTable");
    puzzle = generateEmptyPuzzle();
    userInput = generateEmptyPuzzle(); // 存儲使用者輸入的數字

    // 開始填充數獨盤面
    fillSudoku(puzzle);

    // for(let i = 0; i < 9; i++){
    //     for(let j = 0; j < 9; j++){
    //         userInput[i][j] = puzzle[i][j];
    //     }
    // }

    // 將生成的數獨盤面填入表格中
    for (let i = 0; i < 9; i++) {
        let row = sudokuTable.insertRow(i);
        for (let j = 0; j < 9; j++) {
            let cell = row.insertCell(j);
            if (Math.random() < userData.diff) { // 隨機將一半的格子設為空
                puzzle[i][j] = 0;
                let input = document.createElement("input");
                input.type = "text"; // 使用 text 類型，以允許空白
                input.maxLength = 1; // 限制輸入長度為 1
                input.type = "tel";
                input.inputmode = "tel";
                input.addEventListener("input", function() {
                    // 確保使用者輸入的值為1到9的數字，或者保留為空
                    if (this.value !== "" && (this.value < 1 || this.value > 9 || !Number.isInteger(Number(this.value)))) {
                        this.value = "";
                    }
                    userInput[i][j] = this.value; // 更新使用者輸入的數字
                    // 檢查當前輸入是否合法
                    if (this.value !== "" && !isValidInput(puzzle, userInput, i, j, this.value)) {
                        this.classList.add("error");
                        userData.win_flag = false;
                        userData.mistake = userData.mistake + 1;
                    } else {
                        this.classList.remove("error");
                    }
                    // 檢查勝利條件
                    if (checkWinCondition(puzzle, userInput)) {
                        userData.win_flag = true;
                    }
                });
                cell.appendChild(input);
            } else {
                cell.textContent = puzzle[i][j];
            }
            setCellBackgroundColor(cell, i, j);
        }
    }
}

function generateEmptyPuzzle() {
    // 生成一個9x9的空數獨盤面
    let puzzle = [];
    for (let i = 0; i < 9; i++) {
        puzzle[i] = [];
        for (let j = 0; j < 9; j++) {
            puzzle[i][j] = 0;
        }
    }
    return puzzle;
}

function generateRandomArray() {
    // 生成包含 1 到 9 的數組
    let baseArray = [1, 2, 3, 4, 5, 6, 7, 8, 9];

    // 洗牌算法，將陣列順序打亂
    for (let i = baseArray.length - 1; i > 0; i--) {
        const j = Math.floor(Math.random() * (i + 1));
        [baseArray[i], baseArray[j]] = [baseArray[j], baseArray[i]];
    }

    return baseArray;
}

function fillSudoku(puzzle) {
    numbers = generateRandomArray();
    // 使用遞歸填充數獨盤面
    for (let i = 0; i < 9; i++) {
        for (let j = 0; j < 9; j++) {
            if (puzzle[i][j] === 0) {
                for (let index = 0; index < 9; index++) {
                    if (isValid(puzzle, i, j, numbers[index])) {
                        puzzle[i][j] = numbers[index];
                        if (fillSudoku(puzzle)) {
                            return true;
                        }
                        puzzle[i][j] = 0; // 回溯
                    }
                }
                return false; // 當前位置無法填充
            }
        }
    }
    return true; // 整個盤面都填充完畢
}

function isValid(puzzle, row, col, num) {
    // 檢查在特定位置填充數字是否符合數獨規則
    for (let i = 0; i < 9; i++) {
        if (puzzle[row][i] === num || puzzle[i][col] === num || puzzle[Math.floor(row / 3) * 3 + Math.floor(i / 3)][Math.floor(col / 3) * 3 + i % 3] === num) {
            return false;
        }
    }
    return true;
}

function isValidInput(puzzle, userInput, row, col, value) {
    // 檢查當前輸入是否合法，包括使用者已經輸入的數字
    // 檢查行
    for (let i = 0; i < 9; i++) {
        if (i !== col && (puzzle[row][i] == value || userInput[row][i] == value)) {
            return false;
        }
    }
    // 檢查列
    for (let i = 0; i < 9; i++) {
        if (i !== row && (puzzle[i][col] == value || userInput[i][col] == value)) {
            return false;
        }
    }
    // 檢查3x3區域
    let startRow = Math.floor(row / 3) * 3;
    let startCol = Math.floor(col / 3) * 3;
    for (let i = startRow; i < startRow + 3; i++) {
        for (let j = startCol; j < startCol + 3; j++) {
            if ((i !== row || j !== col) && (puzzle[i][j] == value || userInput[i][j] == value)) {
                return false;
            }
        }
    }
    return true;
}

function checkWinCondition(puzzle, userInput) {
    // 檢查是否符合結束條件
    for (let i = 0; i < 9; i++) {
        for (let j = 0; j < 9; j++) {
            if (userInput[i][j] != 0) {
                return isValidInput(puzzle, userInput, i, j, userInput[i][j]);
            }
        }
    }
    return false;
}

function setCellBackgroundColor(cell, row, col) {
    var color_table = [ //定義二維陣列
        [1, 1, 1, 0, 0, 0, 1, 1, 1],
        [1, 1, 1, 0, 0, 0, 1, 1, 1],
        [1, 1, 1, 0, 0, 0, 1, 1, 1],
        [0, 0, 0, 1, 1, 1, 0, 0, 0],
        [0, 0, 0, 1, 1, 1, 0, 0, 0],
        [0, 0, 0, 1, 1, 1, 0, 0, 0],
        [1, 1, 1, 0, 0, 0, 1, 1, 1],
        [1, 1, 1, 0, 0, 0, 1, 1, 1],
        [1, 1, 1, 0, 0, 0, 1, 1, 1]
    ];
    if (color_table[row][col] === 1) {
        cell.style.backgroundColor = "#f3f6fa";
    } else {
        cell.style.backgroundColor = "#cce5ff"; //"#99c2ff";
    }
}

function openModal(message) {
    let modal = document.getElementById("myModal");
    let modalText = document.getElementById("modalText");
    let playAgainButton = document.getElementById("playAgainButton");
    modalText.textContent = message;
    modal.style.display = "block";
    playAgainButton.style.display = "block";
}

function closemyModal() {
    let modal = document.getElementById("myModal");
    modal.style.display = "none";
}


// timer
function startTimer() {
    userData.timerInterval = setInterval(updateTimer, 1000);
}

function updateTimer() {
    let currentTime = new Date();
    let elapsedTime = Math.floor((currentTime - startTime) / 1000); // 以秒為單位
    let minutes = Math.floor(elapsedTime / 60);
    let seconds = elapsedTime % 60;
    document.getElementById("timer").textContent = padZero(minutes) + ":" + padZero(seconds);
}

function padZero(number) {
    return (number < 10) ? "0" + number : number;
}

function stopTimer() {
    endTime = new Date();
    clearInterval(userData.timerInterval);
    let elapsedTime = Math.floor((endTime - startTime) / 1000); // 以秒為單位
    let minutes = Math.floor(elapsedTime / 60);
    let seconds = elapsedTime % 60;
    userData.timerInterval = elapsedTime;
    return padZero(minutes) + ":" + padZero(seconds);
}

// 遊戲說明
document.addEventListener("DOMContentLoaded", function() {
    // 其他原有的 JavaScript 代碼

    document.getElementById("instructionsButton").addEventListener("click", function() {
        openInstructionsModal();
    });
});

function openInstructionsModal() {
    let modal = document.getElementById("game-info");
    modal.style.display = "block";
}

function closeModal() {
    let modal = document.getElementById("game-info");
    modal.style.display = "none";
    console.log("close");
}



// 初始化遊戲
function startGame() {
    // 重置計時器
    resetTimer();
    // 生成新的數獨盤面
    generateSudoku();
    // 隱藏開始遊戲按鈕
    hideSudoku();
    // 顯示提交按鈕和盤面
    showSudoku();

    startTimer();
    document.getElementById("submitButton").addEventListener("click", function() {
        if (userData.win_flag) {
            let time_used = stopTimer();
            openModal(`遊戲結束，你贏了！ 用時 ${time_used}`);
            time_used_sp = time_used.split(":");
            second_used = Number(time_used_sp[0] * 60) + Number(time_used_sp[1]);
            startTime.setHours(startTime.getHours() + 8)
            endTime.setHours(endTime.getHours() + 8)
            gamedata = {
                "game": "sudoku",
                "level": 1,
                "start_time": startTime.toISOString().split(".")[0],
                "end_time": endTime.toISOString().split(".")[0],
            }
            sendDataToFlutter(gamedata);
        }
    });
}

function resetTimer() {
    // 重置計時器相關變數
    startTime = new Date();;
    clearInterval(userData.timerInterval);
    document.getElementById("timer").textContent = "00:00";
}

function hideSudoku() {
    // 隱藏開始遊戲按鈕
    document.getElementById("startButton").style.display = "none";
    // 隱藏開始遊戲按鈕
    document.getElementById("instructionsButton").style.display = "none";
}

function showSudoku() {
    // 顯示提交按鈕
    document.getElementById("submitButton").style.display = "inline-block";
    // 顯示提交按鈕
    document.getElementById("sudokuTable").style.display = "table";
}

function playAgain() {
    let url = "index.html";
    location.assign(url)
}

// 數據傳送函數
function sendDataToFlutter(data) {
    console.log(data);
    try {
        FlutterInterface.postMessage(JSON.stringify(data));
    } catch (e) {
        console.log(e);
    }
}