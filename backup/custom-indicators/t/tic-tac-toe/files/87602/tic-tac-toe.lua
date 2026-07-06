-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=58440
-- Id: 9580

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

-- initializes the indicator profile
function Init()
    indicator:name("Tic-Tac-Toe 3x3");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Game");
    indicator.parameters:addBoolean("FirstPlayerHuman", "First player is human?", "", true);
    indicator.parameters:addBoolean("SecondPlayerHuman", "Second player is human?", "", false);
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("color", "Color", "", core.rgb(0, 128, 128));
    indicator.parameters:addInteger("size", "Size of text in points", "", 10, 6, 32);
end

local FirstPlayerHuman, SecondPlayerHuman;

local field = {};                   -- play field - 9 cells
                                    -- 1 2 3
                                    -- 4 5 6
                                    -- 7 8 9
                                    -- 0 is empty
                                    -- 1 - player 1 (X)
                                    -- 2 - player 2 (O)

local restartParameters = nil;      -- parameter set kept for restart command
local waitTurnOf = 0;               -- the number of player waited to turn

local color, size;                  -- color and size of the font
local timerID;


-- initializes the instance of the indicator
function Prepare(onlyName)
    local name = profile:id();
    instance:name(name);

    if onlyName then
        return ;
    end

    color = instance.parameters.color;
    size = instance.parameters.size;
    FirstPlayerHuman = instance.parameters.FirstPlayerHuman;
    SecondPlayerHuman = instance.parameters.SecondPlayerHuman;



    instance:setLabelColor(color);
    instance:ownerDrawn(true);

    core.host:execute("addCommand", 1, "Reset the game");
    core.host:execute("addCommand", 2, "Toggle the first player");
    core.host:execute("addCommand", 3, "Toggle the second player");
    core.host:execute("addCommand", 4, "Make a turn");

    timerID = core.host:execute("setTimer", 5, 1);

    ResetGame();

end

function Update(period)
end

local initDraw = false;
local cellSize;

-- draw the indicator content
function Draw(stage, context)
    if stage ~= 2 then
        return ;
    end

    -- initialize GDI objects
    if not initDraw then
        local fontSize = context:pointsToPixels(size);
        cellSize = math.floor(fontSize * 1.5 + 0.5);
        context:createFont(1, "Arial", fontSize, fontSize, context.NORMAL);
        context:createFont(2, "Arial", 0, -fontSize, context.NORMAL);
        context:createPen(3, context.SOLID, 1, color);
        initDraw = true;
    end

    local i, j, x1, y1, x2, y2;

    -- draw cells
    for i = 1, 2, 1 do
        -- vertical line
        x1 = 50 + i * cellSize;
        y1 = 50;
        y2 = 50 + 3 * cellSize;

        context:drawLine(3, x1, y1, x1, y2);
        -- horiz line
        y1 = 50 + i * cellSize;
        x1 = 50;
        x2 = 50 + 3 * cellSize;

        context:drawLine(3, x1, y1, x2, y1);
    end

    local c, style;
    -- draw field
    c = 1;
    style = context.SINGLELINE + context.CENTER + context.VCENTER;
    for i = 1, 3, 1 do
        y2 = 50 + i * cellSize;
        y1 = y2 - cellSize;
        for j = 1, 3, 1 do
            x2 = 50 + j * cellSize;
            x1 = x2 - cellSize;
            if field[c] == 1 then
                context:drawText(1, "X", color, -1, x1, y1, x2, y2, style);
            elseif field[c] == 2 then
                context:drawText(1, "O", color, -1, x1, y1, x2, y2, style);
            end
            c = c + 1;
        end
    end

    -- draw parameters
    local params = "";
    params = params .. "Player 1 (X):\t"
    if FirstPlayerHuman then
        params = params .. "Human";
    else
        params = params .. "Computer";
    end
    params = params .. "\r\nPlayer 2 (O):\t"
    if SecondPlayerHuman then
        params = params .. "Human";
    else
        params = params .. "Computer";
    end
    params = params .. "\r\nWait for turn:\t"
    if waitTurnOf == 1 then
        params = params .. "First Player";
    elseif waitTurnOf == 2 then
        params = params .. "Second Player";
    else
        params = params .. "Game is finished!";
    end
    context:drawText(2, params, color, -1, 100 + 3 * cellSize, 50, context:right(), context:bottom(), context.LEFT + context.TOP);
end


function AsyncOperationFinished(cookie, success, message)
    if cookie == 1 then
        -- restart game command
        RestartGame("Game is restarted");
    elseif cookie == 2 then
        -- change the kind of the first player
        FirstPlayerHuman = not FirstPlayerHuman;
    elseif cookie == 3 then
        -- change the kind of the second player
        SecondPlayerHuman = not SecondPlayerHuman;
    elseif cookie == 4 then
        -- make a turn command
        local t, c, sx, sy, x, y, cell;
        t, c = core.parseCsv(message, ";");
        if c >= 4 then
            x = tonumber(t[2]);
            y = tonumber(t[3]);
            -- calc cell by coordinates
            if x >= 50 and x < 50 + cellSize * 3 and
               y >= 50 and y < 50 + cellSize * 3 then
                x = math.floor((x - 50) / cellSize);
                y = math.floor((y - 50) / cellSize);
                cell = y * 3 + x + 1;
                -- make a turn if we wait it!
                if field[cell] == 0 then
                    if waitTurnOf == 1 and FirstPlayerHuman then
                        Turn(1, cell);
                    elseif waitTurnOf == 2 and SecondPlayerHuman then
                        Turn(2, cell);
                    else
                        if waitTurnOf == 0 then
                            core.host:execute("prompt", 1000, "Error", "The game is ended. Please restart the game", nil);
                        else
                            core.host:execute("prompt", 1000, "Error", "Please wait for human turn", nil);
                        end
                    end
                else
                    core.host:execute("prompt", 1000, "Error", "Please use this command on an empty field cell", nil);
                end
            else
                core.host:execute("prompt", 1000, "Error", "Please use this command on a field cell", nil);
            end
        end
    elseif cookie == 5 then
        -- timer
        if waitTurnOf == 1 and not FirstPlayerHuman then
            AITurn(1);
        elseif waitTurnOf == 2 and not SecondPlayerHuman then
            AITurn(2);
        end
        elseif cookie == 6 and success then
        FirstPlayerHuman = restartParameters.FirstPlayerHuman;
        SecondPlayerHuman = restartParameters.SecondPlayerHuman;
        ResetGame();
    end
end

-- called when the instance is about to be removed
function ReleaseInstance()
    core.host:execute("killTimer", timerID);
end


-- resets the game
function ResetGame()
    local i;
    for i = 1, 9, 1 do
        field[i] = 0;
    end
    waitTurnOf = 1;
end

-- the number of checks for each field
-- 1 2 3
-- 4 5 6
-- 7 8 9
-- winning combinations for each cell
local checks = { {{2, 3}, {4, 7}, {5, 9}},        -- cell 1 - row 1: 1, 2, 3; col 1: 1, 4, 7; down diagonal: 1, 5, 9
                 {{1, 3}, {5, 8}},                -- cell 2 - row 1: 1, 2, 3; col 2: 2, 5, 8... and so on for next cells
                 {{1, 2}, {6, 9}, {5, 7}},        -- 3
                 {{5, 6}, {1, 7}},                -- 4
                 {{4, 6}, {2, 8}, {1, 9}},        -- 5
                 {{4, 5}, {3, 9}},                -- 6
                 {{8, 9}, {1, 4}, {3, 5}},        -- 7
                 {{7, 9}, {2, 5}},                -- 8
                 {{7, 8}, {1, 5}, {3, 6}}};       -- 9


-- checks the field for win/tie game
function CheckField()
    local i, j;
    -- check winning combinations
    for i = 1, 9, 1 do
        for j = 1, #(checks[i]), 1 do
            local check = checks[i][j];
            if field[i] == field[check[1]] and field[i] == field[check[2]] and field[i] ~= 0 then
                return field[i];
            end
        end
    end

    -- check whether we can play more
    for i = 1, 9, 1 do
        if field[i] == 0 then
            return 0;   -- can play
        end
    end

    return -1;          -- tie game
end

-- register a turn
function Turn(player, cell)
    field[cell] = player;
    local r = CheckField();
    if r == 1 then
        RestartGame("Player 1 win!");
    elseif r == 2 then
        RestartGame("Player 2 win!");
    elseif r == -1 then
        RestartGame("Tie game!");
    elseif r == 0 then
        if player == 1 then
            waitTurnOf = 2;
        else
            waitTurnOf = 1;
        end
    end
end

-- restart the game
function RestartGame(message)
    waitTurnOf = 0;
    restartParameters = parameters.new();
    restartParameters:addBoolean("FirstPlayerHuman", "First player is human?", "", FirstPlayerHuman);
    restartParameters:addBoolean("SecondPlayerHuman", "Second player is human?", "", SecondPlayerHuman);
    core.host:execute("prompt", 6, "Tic-tac-toe", message, restartParameters);
end




-- make AI turn for a player specified
function AITurn(player)
    local i, w, mw, mi, mw1;
    local opposite;

    if player == 1 then
        opposite = 2;
    else
        opposite = 1;
    end

    mw = -1;
    mi = -1;
    mw1 = -1;

    -- calculate weight of each cell and find a cell with maximum weight

    for i = 1, 9, 1 do
        if field[i] == 0 then
            w = 0;
            for j = 1, #(checks[i]), 1 do
                local check = checks[i][j];
                if (field[check[1]] == player and field[check[2]] == player) or
                   (field[check[1]] == opposite and field[check[2]] == opposite) then
                    -- this turn is win
                    -- or next opposite turn is win
                    w = w + 3;
                    mw1 = 3;
                elseif (field[check[1]] == player and field[check[2]] == 0) or
                       (field[check[1]] == 0 and field[check[2]] == player) then
                    -- win in one turns
                    w = w + 2;
                    mw1 = 2;
                elseif field[check[1]] == 0 and field[check[2]] == 0 then
                    -- win in two turns
                    w = w + 1;
                    mw1 = 1;
                end
            end
            if w > mw then
                mw = w;
                mi = i;
            end
        end
    end

    if mw1 == 1 and field[5] == 0 then
        mi = 5;
    end

    if mi > 0 then
        Turn(player, mi);
    else
        assert(false, "Logical error!!!");
    end
end

