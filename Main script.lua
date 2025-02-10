local mainFolderPath = "/storage/emulated/0/ScriptData/"
local scriptFolderPath = mainFolderPath .. "Script/"
local nameMUfolderPath = mainFolderPath .. "System/settings/menu_name.dat"
local cmdFilepath = mainFolderPath .. "System/cmd/cmd.lua"
local allExtensionFiles = {}
dofile("/storage/emulated/0/ScriptData/var/usr/lib/Loader.dylib")
dofile("/storage/emulated/0/ScriptData/var/usr/lib/DemonLoader.dylib")
print(prints)
for i = 1, Asset do
    table.insert(allExtensionFiles, {fileName = "file" .. i .. ".lua", displayName = "スクリプト " .. i})
end

local extensionFiles = {}
local logFilePath = mainFolderPath .. "System/ErrorLog/error_log_.log"
-----[ログ]-----
local function logError(errorMessage)
    local logEntry = {
        timestamp = os.date("%Y-%m-%d %H:%M:%S"),
        error = errorMessage
    }
    local logStr = "[" .. logEntry.timestamp .. "] " .. logEntry.error

    local file = io.open(logFilePath, "a")
    if file then
        file:write(logStr .. "\n")
        file:close()
    else
        gg.alert("ログファイルの作成に失敗しました。" ..errorMessage)
    end

    gg.alert(errorMessage)
end

local function folderExists(path)
    local exists = os.rename(path, path) ~= nil
    return exists
end

local function fileExists(path)
    local file = io.open(path, "r")
    if file then
        file:close()
        return true
    else
        return false
    end
end

-----[確認]-----
local function checkMainFolder()
    if not folderExists(mainFolderPath) then
        local errorMessage = "メイン フォルダが見つかりません。スクリプトを終了します。"
        logError(errorMessage)
        os.exit()
    end
end

local function checkScriptFolder()
    if not folderExists(scriptFolderPath) then
        local errorMessage = "スプリクトフォルダが見つかりません。スクリプトを終了します。"
        logError(errorMessage)
        os.exit()
    end
end

-----[読み込み]-----
local function loadExistingFiles()
    for _, file in ipairs(allExtensionFiles) do
        local filePath = scriptFolderPath .. file.fileName
        if fileExists(filePath) then
            table.insert(extensionFiles, file)
        end
    end
end

local function loadMenuNames()
    if fileExists(nameMUfolderPath) then
        local file = io.open(nameMUfolderPath, "r")
        local lineNum = 1
        for line in file:lines() do
            if extensionFiles[lineNum] then
                extensionFiles[lineNum].displayName = line
            end
            lineNum = lineNum + 1
        end
        file:close()
    end
end

local function saveMenuNames()
    local file = io.open(nameMUfolderPath, "w")
    for _, fileEntry in ipairs(extensionFiles) do
        file:write(fileEntry.displayName .. "\n")
    end
    file:close()
end
-----[実行]-----
local function executeScript(fileName)
    local filePath = scriptFolderPath .. fileName
    local file = io.open(filePath, "r")
    if not file then
        local errorMessage = "ファイルを開けません: " .. fileName
        logError(errorMessage)
        return
    end
    local scriptContent = file:read("a")
    file:close()
    local func, err = load(scriptContent)
    if func then
        local status, result = pcall(func)
        if not status then
            local errorMessage = "エラー: " .. result
            logError(errorMessage)
        end
    else
        local errorMessage = "スクリプトの読み込みエラー: " .. err
        logError(errorMessage)
    end
end

local function changeMenuItemName()
    local currentNames = {}
    for i, file in ipairs(extensionFiles) do
        table.insert(currentNames, file.displayName)
    end

    local selectedItem = gg.choice(currentNames, nil, "変更したい項目を選んでください")
    if selectedItem then
        local newName = gg.prompt({"新しい名前を入力してください:"}, {""}, {"text"})
        if newName and newName[1] ~= "" then
            extensionFiles[selectedItem].displayName = newName[1]
            saveMenuNames()
            gg.alert("名前が変更されました。")
        else
            
        end
    else
        
    end
end

--−−−−−−−−−−−−−−−−−−−--
local function Main()
-----[プリインストール]-----
    local choices = {}
    table.insert(choices, "スプリクト設定")
    for _, file in ipairs(extensionFiles) do
        table.insert(choices, file.displayName)
    end
    table.insert(choices, "終了")

    gg.processResume()
    local memoryUsageMB = collectgarbage("count") / 1024
    local Ax = gg.multiChoice(choices, nil, SpringBoard1,memoryUsageMB)

    if Ax ~= nil then
        for i = 1, #choices do
            if Ax[i] then
                if i == #choices then
                local _0x4D3F = gg.alert("本当に終了しますか？",              "はい", "いいえ")
                  if _0x4D3F == 1 then
                   gg.toast("スクリプトを終了します...")
                    os.exit()
                     end
                elseif choices[i] == "スプリクト設定" then
                    local Ax = gg.multiChoice({
                        "ログファイルを初期化",
                        "名前変更",
                        "何もなし",
                        "戻る",
                    }, nil, "設定")

                    if Ax ~= nil then

                        if Ax[1] then
                            local filePath = logFilePath
                            local file = io.open(filePath, "r")
                            if file then
                                file:close()
                                file = io.open(filePath, "w")
                                if file then
                                    local logEntry = {
                                        timestamp = os.date("%Y-%m-%d %H:%M:%S"),
                                        message = "ログファイルが初期化されました",
                                        status = "success"
                                    }
                                    file:write("{\n  \"timestamp\": \"" .. logEntry.timestamp .. "\",\n  \"message\"}")
                                    file:close()
                                    gg.alert("ファイルは正常に初期化されました。")
                                else
                                    gg.alert("ファイルの初期化に失敗しました。")
                                end
                            else
                    local bin = gg.alert("ファイルが存在しません。作成しますか？","いいえ", "はい")
                  if bin == 1 then
                    local filePath = logFilePath
                      local file, err = io.open(filePath, "w")
                        if not file then
                          gg.toast("ファイルを作成できません: " .. err)
                             return
                                end

             file:write("")
             file:close()

                        gg.toast("ファイルが正常に作成されました: " .. filePath)
                              end
                            end
                        end

                         if Ax[2] then
                            changeMenuItemName()
                        end
                    end
                else
                    executeScript(extensionFiles[i - 1].fileName)
                end
            end
        end
        
         if Ax[3] then
         gg.alert("ファイルの初期化に失敗しました。")
end
         if Ax[4] then
end
end
end
-----[]-----
checkMainFolder()
checkScriptFolder()
loadExistingFiles()
loadMenuNames()

while true do
    if gg.isVisible(true) then
        Lext = 1
        gg.setVisible(false)
    end

    if Lext == 1 then
        Lext = -1
        Main()
    end
end