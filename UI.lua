local UI = {}

-- Настройки экрана
UI.screenWidth, UI.screenHeight = term.getSize()
UI.selected = 1

-- Создание кнопки
function UI.createButton(text, x, y, w, h, onClick)
    return {
        type = "button",
        text = text,
        x = x,
        y = y,
        width = w or (#text + 4),
        height = h or 3,
        onClick = onClick,
        selected = false
    }
end

-- Создание поля ввода
function UI.createInput(x, y, w, h, default)
    return {
        type = "input",
        text = default or "",
        x = x,
        y = y,
        width = w or 20,
        height = h or 3,
        active = false,
        selected = false
    }
end

-- Отрисовка интерфейса
function UI.draw(buttons, inputs)
    term.setBackgroundColor(colors.blue)
    term.clear()
    
    -- Отрисовка кнопок
    for i, btn in ipairs(buttons) do
        local bg = btn.selected and colors.lime or colors.green
        term.setBackgroundColor(bg)
        
        for dy = 0, btn.height - 1 do
            term.setCursorPos(btn.x, btn.y + dy)
            term.write((" "):rep(btn.width))
        end
        
        term.setBackgroundColor(colors.green)
        term.setTextColor(colors.black)
        term.setCursorPos(
            btn.x + math.floor((btn.width - #btn.text)/2),
            btn.y + math.floor(btn.height/2)
        )
        term.write(btn.text)
    end
    
    -- Отрисовка полей ввода
    for i, inp in ipairs(inputs) do
        local border = inp.selected and colors.orange or colors.gray
        term.setBackgroundColor(border)
        
        for dy = 0, inp.height - 1 do
            term.setCursorPos(inp.x, inp.y + dy)
            term.write((" "):rep(inp.width))
        end
        
        term.setBackgroundColor(colors.white)
        for dy = 1, inp.height - 2 do
            term.setCursorPos(inp.x + 1, inp.y + dy)
            term.write((" "):rep(inp.width - 2))
        end
        
        term.setCursorPos(inp.x + 2, inp.y + 1)
        term.setTextColor(colors.black)
        term.write(inp.text)
        
        if inp.active then
            term.setCursorPos(inp.x + 2 + #inp.text, inp.y + 1)
            term.setBackgroundColor(colors.red)
            term.write(" ")
        end
    end
end

-- Обработка текстового ввода
function UI.handleTextInput(input, buttons, inputs)
    local cursorPos = #input.text
    
    while true do
        UI.draw(buttons, inputs)
        term.setCursorPos(input.x + 2 + cursorPos, input.y + 1)
        term.setBackgroundColor(colors.red)
        term.write(" ")
        
        local event, key = os.pullEvent()
        
        if event == "char" then
            if #input.text < input.width - 4 then
                input.text = input.text .. key
                cursorPos = #input.text
            end
        elseif event == "key" then
            if key == 257 then -- Enter
                break
            elseif key == 259 then -- Backspace
                if cursorPos > 0 then
                    input.text = input.text:sub(1, -2)
                    cursorPos = #input.text
                end
            end
        elseif event == "mouse_click" then
            break
        end
    end
    
    input.active = false
end

-- Основной цикл обработки событий
function UI.run(buttons, inputs)
    -- Начальное выделение
    if #buttons > 0 then
        buttons[1].selected = true
    end
    
    UI.draw(buttons, inputs)
    
    while true do
        local event, key, x, y = os.pullEvent()
        
        -- Обработка кликов мышкой
        if event == "mouse_click" then
            -- Проверка кнопок
            for i, btn in ipairs(buttons) do
                if x >= btn.x and x < btn.x + btn.width and
                   y >= btn.y and y < btn.y + btn.height then
                    UI.selected = i
                    if btn.onClick then btn.onClick() end
                end
            end
            
            -- Проверка полей ввода
            for i, inp in ipairs(inputs) do
                if x >= inp.x and x < inp.x + inp.width and
                   y >= inp.y and y < inp.y + inp.height then
                    UI.selected = #buttons + i
                    inp.active = true
                    UI.handleTextInput(inp, buttons, inputs)
                end
            end
        
        -- Обработка клавиатуры
        elseif event == "key" then
            -- Навигация вниз
            if key == 264 or key == 83 then -- Down/S
                UI.selected = math.min(UI.selected + 1, #buttons + #inputs)
            
            -- Навигация вверх
            elseif key == 265 or key == 87 then -- Up/W
                UI.selected = math.max(UI.selected - 1, 1)
            
            -- Активация элемента
            elseif key == 257 then -- Enter
                if UI.selected <= #buttons then
                    if buttons[UI.selected].onClick then 
                        buttons[UI.selected].onClick() 
                    end
                else
                    local inp = inputs[UI.selected - #buttons]
                    inp.active = true
                    UI.handleTextInput(inp, buttons, inputs)
                end
            end
        end
        
        -- Обновление выделения
        for i, btn in ipairs(buttons) do
            btn.selected = (i == UI.selected)
        end
        for i, inp in ipairs(inputs) do
            inp.selected = (#buttons + i == UI.selected)
            inp.active = false -- Сбрасываем активность при навигации
        end
        
        UI.draw(buttons, inputs)
    end
end

-- Пример использования
local buttons = {
    UI.createButton("Enter", 10, 5, 10, 3, function() 
        print("Entered") 
    end),
    UI.createButton("Cancel", 10, 10, 10, 3, function() 
        print("Canceled!") 
    end)
}

local inputs = {
    UI.createInput(10, 15, 20, 3, "Login"),
    UI.createInput(10, 20, 20, 3, "Pass")
}

-- Запуск интерфейса
UI.run(buttons, inputs)