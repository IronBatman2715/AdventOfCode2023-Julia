module Day03

using AdventOfCode2023

"""
Load inputs and solve the [Day 3](https://adventofcode.com/2023/day/3) puzzle.
"""
function run()::Tuple{Int,Int}
    inputs::Vector{String} = split(AdventOfCode2023.data[3], '\n')
    return solve(inputs), solve(inputs, true)
end

function solve(schematic::Vector{String}, part_2=false)::Int
    matrix = string_arr_to_matrix(schematic)

    if part_2
        sum = 0
        m, n = size(matrix)
        for i in 1:m, j in 1:n
            c = matrix[i, j]
            if c == '*'
                sum += get_gear_ratio(matrix, (i, j))
            end
        end
        return sum
    else
        return analyze_matrix(matrix)
    end
end

function string_arr_to_matrix(str::Vector{String})::Matrix{Char}
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

function get_next_pos(matrix::Matrix{Char}, curr_pos::Tuple{Int,Int})::Union{Some{Tuple{Int,Int}},Nothing}
    m, n = size(matrix)
    i, j = curr_pos

    if j + 1 <= n
        return Some((i, j + 1))
    elseif i + 1 <= m
        return Some((i + 1, 1))
    end
    return nothing
end

function get_next_adj_pos(matrix::Matrix{Char}, home_pos::Tuple{Int,Int}, curr_pos::Tuple{Int,Int})::Union{Some{Tuple{Int,Int}},Nothing}
    m, n = size(matrix)
    i, j = curr_pos
    Δi, Δj = curr_pos .- home_pos

    # Skip setting curr_pos to home_pos so starting block works 
    if Δi == 0 && Δj == -1
        if j + 2 ≤ n
            return Some((i, j + 2))
        end
        return Some((i + 1, j))
    end
    # If home_pos entered as curr_pos, assume starting
    if Δi == 0 && Δj == 0
        i_start = i - 1
        j_start = j - 1
        if i_start < 1
            i_start = i
        end
        if j_start < 1
            j_start = j
        end
        if i == i_start && j == j_start
            j_start = j + 1
        end
        return Some((i_start, j_start))
    end

    if j + 1 ≤ n && Δj < 1
        return Some((i, j + 1))
    elseif i + 1 ≤ m && Δi < 1
        j_start = home_pos[2] - 1
        if j_start < 1
            j_start = j
        end
        return Some((i + 1, j_start))
    end
    return nothing
end

function analyze_matrix(matrix::Matrix{Char}, curr_pos::Tuple{Int,Int}=(1, 1), sum::Int=0)::Int
    c = matrix[curr_pos[1], curr_pos[2]]

    if !isdigit(c)
        maybe_next_pos = get_next_pos(matrix, curr_pos)
        if isnothing(maybe_next_pos)
            return sum
        end
        return analyze_matrix(matrix, something(maybe_next_pos), sum)
    end

    if has_adjacent_symbol(matrix, curr_pos)
        num = get_full_number(matrix, curr_pos)
        sum += num

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

function get_adjacent_numbers(matrix::Matrix{Char}, home_pos::Tuple{Int,Int})::Vector{Int}
    numbers = []
    curr_pos = home_pos
    while true
        maybe_curr_pos = get_next_adj_pos(matrix, home_pos, curr_pos)
        if isnothing(maybe_curr_pos)
            return numbers
        end
        curr_pos = something(maybe_curr_pos)
        curr_val = matrix[curr_pos[1], curr_pos[2]]

        if isdigit(curr_val)
            number = get_full_number(matrix, curr_pos)
            push!(numbers, number)

            maybe_next_pos = get_next_adj_pos(matrix, home_pos, curr_pos)
            if isnothing(maybe_next_pos)
                return numbers
            end
            next_pos = something(maybe_next_pos)
            next_val = matrix[next_pos[1], next_pos[2]]

            # If another digit that would have been part of `number`, skip `next_pos`
            if next_pos[2] == curr_pos[2] + 1 && isdigit(next_val)
                maybe_next_pos = get_next_adj_pos(matrix, home_pos, next_pos)
                if isnothing(maybe_next_pos)
                    return numbers
                end
                curr_pos = something(maybe_next_pos)
                continue
            end
        end
    end
end

function has_adjacent_symbol(matrix::Matrix{Char}, home_pos::Tuple{Int,Int})::Bool
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

function get_full_number(matrix::Matrix{Char}, pos::Tuple{Int,Int})::Int
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

    return parse(Int, String(str))
end

function get_gear_ratio(matrix::Matrix{Char}, pos::Tuple{Int,Int})::Int
    adj_nums = get_adjacent_numbers(matrix, pos)
    gear_count = length(adj_nums)
    if gear_count < 2
        # Not enough parts to make a gear ratio
        return 0
    elseif gear_count == 2
        return prod(*, adj_nums)
    else
        error("More parts adjacent to gear than expected!")
    end
end

end # module
