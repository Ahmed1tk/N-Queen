local isrand = false

function Create_board(Qs) 
    local tempboard = {}
    for i = 1, n, 1 do
        tempboard[i] = {}
        for j = 1, n, 1 do
            tempboard[i][j] = "empty"
        end
    end
    for k,v in pairs(Qs) do 
        if type(v) == "table" then
            tempboard[v.c][v.r] = k
        else
            tempboard[k][v] = k
        end
    end
    return tempboard
end

function getrandomQs(N)
    Qs = {}
    for i = 1, N, 1 do
        Qs[i] = math.random(1, N)
    end
    return Qs
end

function sleep (a) 
    local sec = tonumber(os.clock() + a); 
    while (os.clock() < sec) do end 
end

function print_Board(Qs, force)
    if Visual or force then 
        local board = Create_board(Qs)
        local ss = {}
        for i = 1, n, 1 do
            local s = "" 
            for j = 1, n, 1 do 
                local f = ""
                if Qs[1] then
                    if board[j][i] ~= "empty" then f = "    " end 
                else
                    if board[j][i] ~= "empty" then f = "   " end 
                end
                s = s ..board[j][i]..f.." | "
            end
            table.insert(ss, s)
        end
        if Visual then 
            os.execute("cls")
        end
        for k,s in pairs(ss) do 
            print(s)
        end
        sleep(0.06)
        print("-----------------------------------------------------")
    end
end

function GetFirstSquare(c, r)
    local lc, lr = nil, nil
    if c == r then 
        lc, lr = 1, 1
    elseif c > r then 
        lc, lr = c - r + 1, 1
    elseif c < r then 
        lc, lr = 1, r - c + 1
    end
    return lc, lr
end

local cc, cr = nil, nil

function is_Safe(c, r, board, Qs, continue)
    local lc, lr = nil, nil
    lc, lr = GetFirstSquare(c, r)
    local k ,sum = 1, c + r 
    local qus = {}
    for i = 1, n, 1 do 
        --if i ~= r and board[c][i] ~= "empty" then cc = c cr = i if not continue then return false end table.insert(qus, cc)  end
        if i ~= c and board[i][r] ~= "empty" then cc = i cr = r if not continue then return false end table.insert(qus, cc)  end
        if lc < (n+1) and lr < (n+1) and lc ~= c and lr ~= r and (board[lc] and board[lc][lr] ~= "empty") then cc = lc cr = lr  if not continue then return false end table.insert(qus, cc) end
        lc = lc + 1
        lr = lr + 1
        sum = c + r 
        if (i + Qs[i] == sum) and (i ~= c and Qs[i] ~= r) then cc = i cr = Qs[i] if not continue then return false end table.insert(qus, cc)  end 
    end
    returner = true 
    if continue and #qus > 0 then returner = false end 
    return returner, qus
end 

function Goal_Test(node)
    local bord = Create_board(node.Qs)
    for k,v in pairs(node.Qs) do
        resultr, _ = is_Safe(k, v, bord, node.Qs)
        if not resultr then 
            return false 
        end
    end
    return true 
end

function copy_Qs(oldQs)
    local newqs = {}

    for i = 1, n, 1 do
        newqs[i] = oldQs[i]
    end

    return newqs 
end

function GetCost(Qs)
    local cost, bord, Conflicts = 0, Create_board(Qs), {}
    for k, v in pairs(Qs) do
        local bool, qus = is_Safe(k, v, bord, Qs, true) 
        if not bool then
            for kk, vv in pairs(qus) do 
                if k ~= vv then
                    local can = true 
                    for i,j in pairs(Conflicts[k] or {}) do 
                        if j == vv then can = false end 
                    end
                    for i,j in pairs(Conflicts[vv] or {}) do 
                        if j == k then can = false end 
                    end
                    if can then 
                        if not Conflicts[k] then Conflicts[k] = {} end 
                        table.insert(Conflicts[k], vv)
                    end 
                end
            end
            cost = cost + 1
        end
    end
    local sum = 0
    for k,v in pairs(Conflicts) do 
        local countt = 0
        for kk, vv in pairs(v) do 
            countt = countt + 1
        end
        sum = sum + countt
    end
    --print(sum, "Conflicts")
    return sum
end

local steps = 0
local Nnodes = 0

function Safely_Expand(node)
    if not isrand and node.Qs then 
        local successors = {}
        local bord = Create_board(node.Qs)
        for k,v in pairs(node.Qs) do 
            if not is_Safe(k, v, bord, node.Qs) then
                for i = 1 , n , 1 do 
                    if is_Safe(k, i, bord, node.Qs) then 
                        newqs = copy_Qs(node.Qs)
                        -- safe column postion 
                        newqs[k] = i                    
                        table.insert(successors, {parent = "left", cost = node.cost and GetCost(newqs), depth = node.depth and node.depth + 1 ,Qs = newqs})
                        print_Board(newqs) 
                        Nnodes = Nnodes + 1
                        break
                    end
                end
            end
        end
        if #successors > 0 then return successors else return Expand(node) end 
    else return Expand(node) end 
end

function Expand(node, u)
    local successors = {}
    if not node.Qs then return {} end 
    local bord = Create_board(node.Qs)
    for k,v in pairs(node.Qs) do 
        if not is_Safe(k, v, bord, node.Qs) then 
            for i = 1 , 2, 1 do
                local newqs = {}
                if i == 1 and (k > 1 and bord[k][v-1] == "empty") and (node.parent and node.parent ~= "down") then 
                    newqs = copy_Qs(node.Qs)
                    -- go up 
                    newqs[k] = v - 1
                    table.insert(successors, {parent = "up", cost = node.cost and GetCost(newqs), depth = node.depth and node.depth + 1 ,Qs = newqs})
                    print_Board(newqs)
                    Nnodes = Nnodes + 1
                elseif i == 2 and (v < n and bord[k][v+1] == "empty") and (node.parent and node.parent ~= "up") then 
                    newqs = copy_Qs(node.Qs)
                    -- go down 
                    newqs[k] = v + 1
                    table.insert(successors, {parent = "down", cost = node.cost and GetCost(newqs), depth = node.depth and node.depth + 1 ,Qs = newqs})
                    print_Board(newqs)
                    Nnodes = Nnodes + 1
                end
            end
        end
    end
    return successors
end

function HillClimbing(problem)
    local current, neighbor = nil, nil
    current = {Qs = problem, cost = GetCost(problem), parent = "nil"}
    print("starting conflicts : "..current.cost)
    while true do
        for k, v in pairs(Safely_Expand(current)) do
            if not neighbor or not neighbor.Qs then 
                neighbor = v 
            elseif neighbor.cost >= v.cost then 
                neighbor = v 
            end
        end
        if current.cost == 0 then print("Global Maximuim Found!.") end 
        if current.cost == 0 or (neighbor.cost > current.cost) then local_maxima = current break end 
        current = neighbor
        neighbor = {cost = 0}
    end

    return local_maxima
end

function GetRandomByColumn(n)
    local ByColumn = {}
    for i = 1, n, 1 do
        ByColumn[i] = math.random(1, n)
    end
    return ByColumn
end

function Merge(select, first, second)
    local newmerge1 = {}
    local newmerge2 = {}
    for i = 1, n, 1 do 
        if i <= select then 
            newmerge1[i] = first[i]
            newmerge2[i] = second[i]
        else
            newmerge1[i] = second[i]
            newmerge2[i] = first[i]
        end
    end
   --[[  print_Board(newmerge1, true)
    print_Board(newmerge2, true) ]]
    return {newmerge1, newmerge2}
end

function Mutate(Qs)
    Qs[math.random(1, n)] = math.random(1, n)
    return Qs
end


PriorityQueue = dofile("priority_queue.lua")
local FitnessSize = 16
function GeneticAlgorithm(problem)
    local current, boards = nil, {}
    pq = PriorityQueue()

    --Initial Population
    local coest = 0
    for i = 1, FitnessSize, 1 do 
        local temp = {Qs = GetRandomByColumn(problem)}
        temp.cost = GetCost(temp.Qs)
        pq:put(temp, temp.cost)
        coest = coest + temp.cost
    end

    print("starting conflicts : "..math.floor(coest/FitnessSize))
    while true do 
        --Selection
        local selected = {}
        for i = 1, ((FitnessSize/2) + 1), 1 do 
            boards[i] = pq:pop()
            if i > 1 then
                selected[i-1] = {[1] = boards[1].Qs, [2] = boards[i].Qs, select = math.random(1, n-1)}
            end
        end
        pq:clear()
        --Crossover
        local CrossOver = {}
        for k, v in pairs(selected) do 
            local temp = Merge(v.select, v[1], v[2])
            for k, v in pairs(temp) do 
                table.insert(CrossOver, {Qs = Mutate(v),cost = GetCost(v)})
            end
        end
        --Mutation
        for k, v in pairs(CrossOver) do 
            if Goal_Test(v) then return v end
            pq:put(v, v.cost)
        end
        for k, v in pairs(boards) do 
            pq:put(v, v.cost)
        end
    end
end

local nTime

function main()
    while true do 
        local strat, temp = nil, nil 
        print("Choose strategy")
        print("1 - Hill Climbing")
        print("2 - Genetic Algorithm")
        print("0 - exit")
        temp = tonumber(io.read())
        while type(temp) ~= "number" or (temp > 2 or temp < -1 ) do temp = tonumber(io.read()) end
        if temp == 0 then return end
        strat = temp
        print("input N size or input 0 for maximum solvable N within 1 minute of search time")
        temp = tonumber(io.read())
        while type(temp) ~= "number" or (temp < -1 ) do temp = tonumber(io.read()) end
        Visual = false
        local ismax = false 
        if temp == 0 then n = 4 ismax = true else n = temp ismax = false end
        local stratText
        if ismax then 
            nTime = os.clock()
            local result
            local timetook
            local play = true 
            while play do 
                time_counter = os.clock()
                if strat == 1 then result = HillClimbing(getrandomQs(n)) stratText = "Hill Climbing" elseif strat == 2 then result = GeneticAlgorithm(n) stratText = "Genetic Algorithm" end
                timetook = os.clock() - time_counter
                if timetook > 60 then 
                    play = false
                end
                print("N :"..n..", Conflicts = "..result.cost..", time took: "..timetook)
                if play then n = n + 1 else n = n - 1 end
            end
            print("The maximum solvable N within 1 minute of search time is: "..n..". Strategy used is : "..stratText)
        else
            time_spent = os.clock()
            local rQs = getrandomQs(n)
            if strat == 1 then result = HillClimbing(rQs) stratText = "Hill Climbing" elseif strat == 2 then result = GeneticAlgorithm(n) stratText = "Genetic Algorithm" end
            time_spent = os.clock() - time_spent
            --print_Board(result.Qs, true)
            print("Time spent to reach solution N: "..n.." using "..stratText.." strategy, is: "..time_spent..". Conflicts = "..result.cost)
        end
    end
end

main()