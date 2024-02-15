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
    if part_2
        return 1
    else
        histories = parse_input(input)
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

    next_value = history[end]
    for last_diff in reverse(last_diffs[1:end-1])
        next_value += last_diff
    end
    return next_value
end

end # module
