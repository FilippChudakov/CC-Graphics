-- Подключаем библиотеку
local UI = require("UI")

-- Создаем экраны
local mainScreen = UI.createScreen()
local loginScreen = UI.createScreen()
local dataScreen = UI.createScreen()

-- 1. Главный экран
UI.addLabel(mainScreen, UI.createLabel("Main Menu", 3, 2, colors.yellow, colors.blue))

-- Кнопка входа
UI.addButton(mainScreen, UI.createButton("Login", 3, 5, 15, 3, function()
    UI.setScreen(loginScreen)
end))

-- Кнопка данных
UI.addButton(mainScreen, UI.createButton("View Data", 3, 9, 15, 3, function()
    UI.setScreen(dataScreen)
end))

-- Кнопка выхода
UI.addButton(mainScreen, UI.createButton("Exit", 3, 13, 15, 3, function()
    term.clear()
    term.setCursorPos(1,1)
    error("Programm finished", 0)
end))

-- 2. Экран входа
UI.addLabel(loginScreen, UI.createLabel("Authorization", 3, 2, colors.white, colors.blue))

-- Поле ввода логина
local loginInput = UI.createInput(3, 5, 20, 3, "Enter Login")
UI.addInput(loginScreen, loginInput)

-- Поле ввода пароля
local passInput = UI.createInput(3, 9, 20, 3, "Enter Password")
UI.addInput(loginScreen, passInput)

-- Кнопка входа
UI.addButton(loginScreen, UI.createButton("Login", 3, 13, 15, 3, function()
    print("Логин:", loginInput.text)
    print("Пароль:", passInput.text)
    UI.setScreen(mainScreen)
end))

-- Кнопка назад
UI.addButton(loginScreen, UI.createButton("Back", 3, 17, 15, 3, function()
    UI.setScreen(mainScreen)
end))

-- 3. Экран данных
UI.addLabel(dataScreen, UI.createLabel("List of data", 3, 2, colors.white, colors.blue))

-- Создаем файл с данными если его нет
if not fs.exists("data.txt") then
    local file = fs.open("data.txt", "w")
    file.write("Element 1\nElement 2\nElement 3\nElement 4\nElement 5\nElement 6\nElement 7")
    file.close()
end

-- Массив кнопок с данными
local dataArray = UI.createButtonArray(3, 5, 20, 10, "data.txt", 5, function(selected)
    print("Selected:", selected)
end)
UI.addButtonArray(dataScreen, dataArray)

-- Кнопка обновления
UI.addButton(dataScreen, UI.createButton("Update", 3, 16, 15, 3, function()
    -- Пересоздаем массив кнопок для обновления данных
    dataArray = UI.createButtonArray(3, 5, 20, 10, "data.txt", 5, function(selected)
        print("Selected:", selected)
    end)
    UI.screens[dataScreen].buttonArrays = {dataArray}
end))

-- Кнопка назад
UI.addButton(dataScreen, UI.createButton("Back", 25, 16, 15, 3, function()
    UI.setScreen(mainScreen)
end))

-- Запускаем интерфейс с главного экрана
UI.setScreen(mainScreen)
UI.run()