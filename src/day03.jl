module Day03
"""
Load inputs and solve the [Day 3](https://adventofcode.com/2023/day/3) puzzle.
"""
function run()::Tuple{Int64,Int64}
    inputs = readlines(joinpath(@__DIR__, "../data/day03.txt"))
    return solve(inputs), solve(inputs, true)
end

function solve(schematic::Array{String,1}, part_2=false)::Int64
    if part_2
        return 1
    end

    matrix = string_arr_to_matrix(schematic)
    sum = analyze_matrix(matrix)
    # println(sum)
    return sum
end

function string_arr_to_matrix(str::Array{String,1})::Matrix{Char}
    n = length(str[1]) # number of columns
    m = length(str) # number of rows

    matrix = Matrix{Char}(undef, m, n)
    i = 1
    for line in str
        if length(line) != n
            error("Non-rectangular matrix!")
        end

        j = 1
        for c in collect(line)
            matrix[i, j] = c
            j += 1
        end
        i += 1
    end

    return matrix
end

function get_next_pos(matrix::Matrix{Char}, curr_pos::Tuple{Int64,Int64})::Union{Some{Tuple{Int64,Int64}},Nothing}
    m, n = size(matrix)
    i, j = curr_pos

    if j + 1 <= n
        return Some((i, j + 1))
    elseif i + 1 <= m
        return Some((i + 1, 1))
    end
    return nothing
end

function analyze_matrix(matrix::Matrix{Char}, curr_pos::Tuple{Int64,Int64}=(1, 1), sum::Int64=0)::Int64
    c = matrix[curr_pos[1], curr_pos[2]]
    # println("[$(curr_pos[1]), $(curr_pos[2])] -> $c")

    if !isdigit(c)
        maybe_next_pos = get_next_pos(matrix, curr_pos)
        if isnothing(maybe_next_pos)
            return sum
        end
        return analyze_matrix(matrix, something(maybe_next_pos), sum)
    end

    if has_adjacent_symbol(matrix, curr_pos)
        num = get_adjacent_number(matrix, curr_pos)
        sum += num
        # println("Added $num b/c [$(curr_pos[1]), $(curr_pos[2])] -> $c has a symbol next to it!")

        while true
            maybe_next_pos = get_next_pos(matrix, curr_pos)
            if isnothing(maybe_next_pos)
                return sum
            end
            next_pos = something(maybe_next_pos)
            if next_pos == (curr_pos[1], curr_pos[2] + 1) && isdigit(matrix[curr_pos[1], curr_pos[2]+1])
                curr_pos = next_pos
                continue
            end
            return analyze_matrix(matrix, next_pos, sum)
        end
    end

    maybe_next_pos = get_next_pos(matrix, curr_pos)
    if isnothing(maybe_next_pos)
        return sum
    end
    return analyze_matrix(matrix, something(maybe_next_pos), sum)
end

function has_adjacent_symbol(matrix::Matrix{Char}, home_pos::Tuple{Int64,Int64})::Bool
    m, n = size(matrix)
    for i in -1:1, j in -1:1
        if i == 0 && j == 0
            continue
        end
        ip = i + home_pos[1]
        jp = j + home_pos[2]
        if ip < 1 || ip > n || jp < 1 || jp > m
            continue
        end

        c = matrix[ip, jp]
        if c != '.' && !isdigit(c)
            return true
        end
    end
    return false
end

function get_adjacent_number(matrix::Matrix{Char}, pos::Tuple{Int64,Int64})::Int64
    m, n = size(matrix)
    i, j = pos
    str::Vector{Char} = [matrix[i, j]]
    jp = j - 1
    while jp ≥ 1 && isdigit(matrix[i, jp])
        pushfirst!(str, matrix[i, jp])
        jp -= 1
    end

    jp = j + 1
    while jp ≤ n && isdigit(matrix[i, jp])
        push!(str, matrix[i, jp])
        jp += 1
    end

    return parse(Int64, String(str))
end

end # module
