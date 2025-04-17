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

-- Создание поля ввода (обновленная версия)
function UI.createInput(x, y, w, h, default)
    return {
        type = "input",
        text = default or "",
        x = x,
        y = y,
        width = w or 20,
        height = h or 3,
        active = false,
        selected = false,
        cursorPos = 1  -- Начинаем с начала поля
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
    
    -- Отрисовка полей ввода (обновленная)
    for i, inp in ipairs(inputs) do
        local border = inp.active and colors.orange or inp.selected and colors.lime or colors.gray
        term.setBackgroundColor(border)
        
        -- Рамка поля
        for dy = 0, inp.height - 1 do
            term.setCursorPos(inp.x, inp.y + dy)
            term.write((" "):rep(inp.width))
        end
        
        -- Внутренняя область
        term.setBackgroundColor(colors.white)
        for dy = 1, inp.height - 2 do
            term.setCursorPos(inp.x + 1, inp.y + dy)
            term.write((" "):rep(inp.width - 2))
        end
        
        -- Отображение текста с учетом позиции курсора
        local displayText = inp.text
        local textOffset = 0
        
        -- Если текст не помещается, обрезаем его
        if #displayText > inp.width - 4 then
            if inp.cursorPos > inp.width - 4 then
                textOffset = inp.cursorPos - (inp.width - 4)
                displayText = displayText:sub(textOffset + 1, textOffset + inp.width - 4)
            else
                displayText = displayText:sub(1, inp.width - 4)
            end
        end
        
        term.setCursorPos(inp.x + 2, inp.y + 1)
        term.setBackgroundColor(colors.white)
        term.setTextColor(colors.black)
        term.write(displayText)
        
        -- Курсор (если поле активно)
        if inp.active then
            local cursorX = inp.x + 2 + (inp.cursorPos - textOffset - 1)
            if cursorX >= inp.x + 2 and cursorX < inp.x + inp.width - 2 then
                term.setCursorPos(cursorX, inp.y + 1)
                term.setBackgroundColor(colors.red)
                term.write(" ")
            end
        end
    end
end

-- Обработка текстового ввода (обновленная версия)
function UI.handleTextInput(input, buttons, inputs)
    input.active = true
    input.cursorPos = 1  -- Курсор в начале текста
    
    while input.active do
        UI.draw(buttons, inputs)
        
        local event, key, x, y = os.pullEvent()
        
        if event == "char" then
            -- Вставка символа на текущей позиции курсора
            input.text = input.text:sub(1, input.cursorPos - 1) .. key .. input.text:sub(input.cursorPos + 1)
            input.cursorPos = input.cursorPos + 1
            
        elseif event == "key" then
            if key == 257 then -- Enter
                input.active = false
            elseif key == 259 then -- Backspace
                if input.cursorPos > 1 then
                    -- Удаление символа перед курсором
                    input.text = input.text:sub(1, input.cursorPos - 2) .. input.text:sub(input.cursorPos)
                    input.cursorPos = input.cursorPos - 1
                end
            elseif key == 263 then -- Left arrow
                if input.cursorPos > 1 then
                    input.cursorPos = input.cursorPos - 1
                end
            elseif key == 262 then -- Right arrow
                if input.cursorPos <= #input.text then
                    input.cursorPos = input.cursorPos + 1
                end
            end
            
        elseif event == "mouse_click" then
            -- Проверяем, был ли клик вне поля ввода
            if x < input.x or x >= input.x + input.width or
               y < input.y or y >= input.y + input.height then
                input.active = false
            else
                -- Устанавливаем курсор в позицию клика
                local clickPos = x - input.x - 1
                input.cursorPos = math.max(1, math.min(clickPos, #input.text + 1))
            end
        end
    end
end

-- Основной цикл обработки событий
function UI.run(buttons, inputs)
    -- Начальное выделение
    if #buttons > 0 then
        buttons[1].selected = true
    elseif #inputs > 0 then
        inputs[1].selected = true
        UI.selected = #buttons + 1
    end
    
    UI.draw(buttons, inputs)
    
    while true do
        local event, key, x, y = os.pullEvent()
        
        if event == "mouse_click" then
            -- Обработка кликов по кнопкам
            for i, btn in ipairs(buttons) do
                if x >= btn.x and x < btn.x + btn.width and
                   y >= btn.y and y < btn.y + btn.height then
                    UI.selected = i
                    if btn.onClick then btn.onClick() end
                end
            end
            
            -- Обработка кликов по полям ввода
            for i, inp in ipairs(inputs) do
                if x >= inp.x and x < inp.x + inp.width and
                   y >= inp.y and y < inp.y + inp.height then
                    UI.selected = #buttons + i
                    UI.handleTextInput(inp, buttons, inputs)
                end
            end
        
        elseif event == "key" then
            -- Навигация стрелками или WSAD
            if key == 264 or key == 83 then -- Down/S
                UI.selected = math.min(UI.selected + 1, #buttons + #inputs)
            elseif key == 265 or key == 87 then -- Up/W
                UI.selected = math.max(UI.selected - 1, 1)
            elseif key == 257 then -- Enter
                if UI.selected <= #buttons then
                    if buttons[UI.selected].onClick then 
                        buttons[UI.selected].onClick() 
                    end
                else
                    local inp = inputs[UI.selected - #buttons]
                    UI.handleTextInput(inp, buttons, inputs)
                end
            end
            
            -- Обновление выделения
            for i, btn in ipairs(buttons) do
                btn.selected = (i == UI.selected)
            end
            for i, inp in ipairs(inputs) do
                inp.selected = (#buttons + i == UI.selected)
            end
        end
        
        UI.draw(buttons, inputs)
    end
end

-- Пример использования
local buttons = {
    UI.createButton("Сохранить", 10, 5, 12, 3, function() 
        print("Текст сохранен!")
    end)
}

local inputs = {
    UI.createInput(10, 10, 25, 3, "Введите текст")
}

-- Запуск интерфейса
UI.run(buttons, inputs)
