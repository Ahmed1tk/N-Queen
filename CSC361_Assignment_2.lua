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
        tempboard[v.c][v.r] = k
    end
    return tempboard
end

function getrandomQs(N)
    isrand = true 
    Qs = {}
    for i = 1, N, 1 do
        local can = true 
        local rand
        while can do 
            rand = {c = math.random(1, N), r = math.random(1, N)}
            can = false 
            for k,v in pairs(Qs) do 
                if v.c == rand.c and v.r == rand.r then 
                    can = true 
                end
            end
        end
        Qs["Q"..i] = {c = rand.c, r = rand.r}
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
                if board[j][i] ~= "empty" then f = "   " end 
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

function is_Safe(c, r, board, Qs)
    -- no queens on same column
    for i = 1, n, 1 do 
         if i ~= r then 
             if board[c][i] ~= "empty" then 
                 return false    
             end
         end
     end
     -- no queens on same row 
     for i = 1, n, 1 do 
         if i ~= c then 
             if board[i][r] ~= "empty" then 
                 return false    
             end
         end
     end
     -- no queens left diagonal 
     local lc = c 
     local lr = r
     while lc ~= 1 and lr ~= 1 do 
         lc = lc - 1 
         lr = lr - 1 
     end
     for i = 1, n, 1 do 
         if not board[lc] or not board[lc][lr] then break end 
         if lc ~= c and lr ~= r then 
             if board[lc][lr] ~= "empty" then 
                 return false    
             end
         end
         lc = lc + 1
         lr = lr + 1
     end
     -- no queens right diagonal 
     local sum = c + r 
     for k, v in pairs(Qs) do 
        if (v.c + v.r == sum) then 
            if (v.c ~= c and v.r ~= r) then return false end 
        end
     end
     return true 
end 

function Goal_Test(node)
    local bord = Create_board(node.Qs)
    for k,v in pairs(node.Qs) do
        if not is_Safe(v.c, v.r, bord, node.Qs) then 
            return false 
        end
    end
    return true 
end

function copy_Qs(oldQs)
    local newqs = {}

    for i = 1, n, 1 do
        newqs["Q"..i] = {c = oldQs["Q"..i].c, r = oldQs["Q"..i].r}
    end

    return newqs 
end

function GetCost(Qs) 
    local cost = 0
    local bord = Create_board(Qs)
    for k, v in pairs(Qs) do 
        if not is_Safe(v.c, v.r, bord, Qs) then 
            cost = cost + 1
        end
    end
    return cost
end

local steps = 0
local Nnodes = 0

function Safely_Expand(node)
    if not isrand then 
        local successors = {}
        local bord = Create_board(node.Qs)
        for k,v in pairs(node.Qs) do 
            if not is_Safe(v.c, v.r, bord, node.Qs) then
                local c = true  
                for i = 1 , n , 1 do 
                    if is_Safe(v.c, i, bord, node.Qs) then 
                        newqs = copy_Qs(node.Qs)
                        -- safe column postion 
                        newqs[k].r = i                    
                        table.insert(successors, {parent = "left", cost = node.cost and GetCost(newqs), depth = node.depth and node.depth + 1 ,Qs = newqs})
                        print_Board(newqs) 
                        Nnodes = Nnodes + 1
                        c = false
                        break
                    end
                end
                if c then 
                    for i = 1 , n , 1 do 
                        if bord[i][v.r] ~= "empty" and i ~= v.c then 
                            newqs = copy_Qs(node.Qs)
                            -- safe row postion
                            if v.r < n then 
                                newqs[bord[i][v.r]].r = newqs[bord[i][v.r]].r + 1
                            else
                                newqs[bord[i][v.r]].r = newqs[bord[i][v.r]].r - 1
                            end
                            table.insert(successors, {parent = "left", cost = node.cost and GetCost(newqs), depth = node.depth and node.depth + 1 ,Qs = newqs})
                            print_Board(newqs) 
                            Nnodes = Nnodes + 1
                        end
                    end
                end
            end
        end
        if #successors > 0 then return successors else return Expand(node) end 
    else return Expand(node) end 
end

function Expand(node, u)
    local successors = {}
    local bord = Create_board(node.Qs)
    for k,v in pairs(node.Qs) do 
        if not is_Safe(v.c, v.r, bord, node.Qs) then 
            for i = 1 , 8, 1 do
                local newqs = {}
                if isrand and i == 1 and (v.c > 1 and bord[v.c-1][v.r] == "empty") and (node.parent and node.parent ~= "right") then 
                    newqs = copy_Qs(node.Qs)
                    -- go left 
                    newqs[k].c = v.c - 1                    
                    table.insert(successors, {parent = "left", cost = node.cost and GetCost(newqs), depth = node.depth and node.depth + 1 ,Qs = newqs})
                    print_Board(newqs) 
                    Nnodes = Nnodes + 1
                elseif isrand and i == 2 and (v.c < n and bord[v.c+1][v.r] == "empty") and (node.parent and node.parent ~= "left") then 
                    newqs = copy_Qs(node.Qs)
                    -- go right 
                    newqs[k].c = v.c + 1
                    table.insert(successors, {parent = "right", cost = node.cost and GetCost(newqs), depth = node.depth and node.depth + 1 ,Qs = newqs})
                    print_Board(newqs) 
                    Nnodes = Nnodes + 1
                elseif (isrand or u) and i == 3 and (v.r > 1 and bord[v.c][v.r-1] == "empty") and (node.parent and node.parent ~= "down") then 
                    newqs = copy_Qs(node.Qs)
                    -- go up 
                    newqs[k].r = v.r - 1
                    table.insert(successors, {parent = "up", cost = node.cost and GetCost(newqs), depth = node.depth and node.depth + 1 ,Qs = newqs})
                    print_Board(newqs)
                    Nnodes = Nnodes + 1
                elseif i == 4 and (v.r < n and bord[v.c][v.r+1] == "empty") and (node.parent and node.parent ~= "up") then 
                    newqs = copy_Qs(node.Qs)
                    -- go down 
                    newqs[k].r = v.r + 1
                    table.insert(successors, {parent = "down", cost = node.cost and GetCost(newqs), depth = node.depth and node.depth + 1 ,Qs = newqs})
                    print_Board(newqs)
                    Nnodes = Nnodes + 1
                elseif isrand and i == 5 and ((v.c > 1 and v.r > 1) and bord[v.c-1][v.r-1] == "empty") and (node.parent and node.parent ~= "downright") then 
                    newqs = copy_Qs(node.Qs)
                    -- go upleft 
                    newqs[k].r = v.r - 1
                    newqs[k].c = v.c - 1                    
                    table.insert(successors, {parent = "upleft", cost = node.cost and GetCost(newqs), depth = node.depth and node.depth + 1 ,Qs = newqs})
                    print_Board(newqs)
                    Nnodes = Nnodes + 1
                elseif isrand and i == 6 and ((v.c < n and v.r > 1) and bord[v.c+1][v.r-1] == "empty") and (node.parent and node.parent ~= "downleft") then 
                    newqs = copy_Qs(node.Qs)
                    -- go upright 
                    newqs[k].r = v.r - 1
                    newqs[k].c = v.c + 1                    
                    table.insert(successors, {parent = "upright", cost = node.cost and GetCost(newqs), depth = node.depth and node.depth + 1 ,Qs = newqs})
                    print_Board(newqs)
                    Nnodes = Nnodes + 1
                elseif isrand and i == 7 and ((v.c > 1 and v.r < n) and bord[v.c-1][v.r+1] == "empty") and (node.parent and node.parent ~= "upright") then 
                    newqs = copy_Qs(node.Qs)
                    -- go downleft 
                    newqs[k].r = v.r + 1
                    newqs[k].c = v.c - 1                    
                    table.insert(successors, {parent = "downleft", cost = node.cost and GetCost(newqs), depth = node.depth and node.depth + 1 ,Qs = newqs})
                    print_Board(newqs)
                    Nnodes = Nnodes + 1
                elseif isrand and i == 8 and ((v.c < n and v.r < n) and bord[v.c+1][v.r+1] == "empty") and (node.parent and node.parent ~= "upleft") then 
                    newqs = copy_Qs(node.Qs)
                    -- go downright 
                    newqs[k].r = v.r + 1
                    newqs[k].c = v.c + 1                    
                    table.insert(successors, {parent = "downright", cost = node.cost and GetCost(newqs), depth = node.depth and node.depth + 1 ,Qs = newqs})
                    print_Board(newqs)
                    Nnodes = Nnodes + 1
                end
            end
        end
    end
    if #successors > 0 then 
        return successors
    else
        if not u then 
            return Expand(node, true)
        else return {} end
    end
end

function BFS(N, inode)
    local Nsteps, Nnodes, Fsize = 0, 0, 0
    local fringe = {}
    local node = {}

    local Qs = inode

    local index, cn = 1, 1 
    fringe[index] = {Qs = Qs, parent = "nil"}
    while true do
        if not fringe[cn] then print("BFS Failed") break end 
        node = fringe[cn]
        cn = cn + 1
        if index > Fsize then Fsize = index end 
        fringe[index] = nil 
        index = index - 1
        if Goal_Test(node) then break end 
        for k, v in pairs(Safely_Expand(node)) do 
            index = index + 1
            fringe[index] = {Qs = copy_Qs(v.Qs), parent = v.parent}
        end
    end

    print_Board(node.Qs, true)

    return {Nsteps = cn, Nnodes = index, Fsize = Fsize} 
end

local curentdepth = 0

local cutoff_occured = false 

function Recursive_DLS(node, N, limit)
    cutoff_occured = false
    if Goal_Test(node) then return node
    elseif node.depth > limit then return "cutoff"
    else
       for k,v in pairs(--[[ Expand(node) ]]Safely_Expand(node)) do 
        steps = steps + 1
        curentdepth = curentdepth + 1
        local result = Recursive_DLS(v, N, limit)
            if result == "cutoff" then cutoff_occured = true 
            elseif result ~= "failure" then return result end
       end
       if cutoff_occured then return "cutoff" else return "failure" end 
    end
end

function DLS(N, depth, inode)
    curentdepth = 0
    return Recursive_DLS({depth = 0, Qs = inode, parent = "nil"}, N, depth)
end

function IDS(N, inode)
    depth = 1
    local result
    steps = 0
    Nnodes = 0
    while true do 
        result = DLS(N, depth, inode)
        if result ~= "cutoff" then break end 
        depth = depth + 1
    end
    print_Board(result.Qs, true)

    print("finished IDS")
    return {Nsteps = steps, Nnodes = Nnodes} 
end

PriorityQueue = dofile("priority_queue.lua")
function A_star(N, inode)
    local Nsteps, Nnodes, Fsize = 0, 0, 0
    local fringe = {}
    local node = {}

    local Qs = inode
    
    pq = PriorityQueue()
    pq:put({Qs = Qs, cost = 0, parent = "nil"}, 0)

    while true do 
        Nsteps = Nsteps + 1
        if pq:empty() then print("A* Failed") break end 
        node =  pq:pop()
        local fhash = pq:size()
        if fhash > Fsize then Fsize = fhash end 
        if Goal_Test(node) then break end 
        for k, v in pairs(Safely_Expand(node)) do
            pq:put(v, v.cost)
        end
    end

    print_Board(node.Qs, true)

    print("finished A*")
    return {Nsteps = Nsteps, Nnodes = pq:size(), Fsize = Fsize} 
end

local nTime

function main()
    local strat, temp = nil, nil 
    print("N size ?: ")
    temp = tonumber(io.read())
    print(type(temp))
    while type(temp) ~= "number" do temp = tonumber(io.read()) print(type(temp)) end 
    n = temp 
    print("Choose strategy")
    print("1 - BFS")
    print("2 - IDS")
    print("3 - A*")
    temp = tonumber(io.read())
    while type(temp) ~= "number" or (temp > 3 or temp < 0 ) do temp = tonumber(io.read()) end
    strat = temp
    print("enable visuals ? (0.06 sec delay foreach step): ")
    print("1 - true")
    print("0 - false")
    temp = tonumber(io.read())
    while type(temp) ~= "number" or (temp > 2 or temp < -1 ) do temp = tonumber(io.read()) end
    if temp == 0 then Visual = false elseif temp == 1 then Visual = true end 
    print("starting node ?: ")
    print("1 - random")
    print("0 - all in first row")
    temp = tonumber(io.read())
    while type(temp) ~= "number" or (temp > 2 or temp < -1 ) do temp = tonumber(io.read()) end
    local sn = {}
    if temp == 1 then sn = getrandomQs(n) else 
        for i = 1, n, 1 do
            sn["Q"..i] = {c =i, r = 1}
        end
    end
    print_Board(sn, true)
    nTime = os.clock()
    local result
    if strat == 1 then result = BFS(n, sn) strat = "BFS" elseif strat == 2 then result = IDS(n, sn) strat = "IDS" elseif strat == 3 then result = A_star(n, sn) strat = "A*" end   
    
    print("1 - Total number of steps to reach a solution (solution cost) : "..result.Nsteps)
    print("2 - Total number of nodes generated before reaching a solution (search cost) : "..result.Nnodes)
    print("3 - Maximum size of the frienge  : "..((result.Fsize ~= nil and result.Fsize) or "no fringe"))

    print("Elapsed time is: " .. os.clock()-nTime)
    print("Strategy used is : "..strat) 
    print("number of nodes : "..n)
end

main()