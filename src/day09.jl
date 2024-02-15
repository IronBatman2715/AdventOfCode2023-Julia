module Day09

using AdventOfCode2023

"""
Load inputs and solve the [Day 9](https://adventofcode.com/2023/day/9) puzzle.
"""
function run()::Tuple{Int,Int}
    input = AdventOfCode2023.data[9]
    return solve(input), solve(input, true)
end

function solve(input::String, part_2=false)::Int
    histories = parse_input(input)

    if part_2
        return sum([extrapolate_previous_history_value(history) for history in histories])
    else
        return sum([extrapolate_next_history_value(history) for history in histories])
    end
end

function parse_input(input::String)::Vector{Vector{Int}}
    lines = split(strip(input), '\n')
    line_quantity = length(lines)
    if line_quantity < 1
        error("Couldn't parse any values")
    end

    return [[parse(Int, num) for num in split(strip(line))] for line in lines]
end

function extrapolate_next_history_value(history::Vector{Int})::Int
    diffs = history
    last_diffs::Vector{Int} = []
    while true
        new_diffs = [diffs[i+1] - diffs[i] for i in 1:(length(diffs)-1)]

        push!(last_diffs, new_diffs[end])
        diffs = new_diffs

        !all(v -> v == 0, new_diffs) || break
    end

    total_diff = sum(last_diffs)
    return history[end] + total_diff
end

function extrapolate_previous_history_value(history::Vector{Int})::Int
    diffs = history
    first_diffs::Vector{Int} = []
    while true
        new_diffs = [diffs[i+1] - diffs[i] for i in 1:(length(diffs)-1)]

        push!(first_diffs, new_diffs[1])
        diffs = new_diffs

        !all(v -> v == 0, new_diffs) || break
    end

    total_diff = sum(first_diffs[2:2:end]) - sum(first_diffs[1:2:end])
    return history[1] + total_diff
end

end # module
