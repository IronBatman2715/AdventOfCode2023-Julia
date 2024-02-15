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
    direction = part_2 ? previous::Direction : next::Direction

    return sum([extrapolate_history_value(direction, history) for history in histories])
end

@enum Direction begin
    previous
    next
end

function parse_input(input::String)::Vector{Vector{Int}}
    lines = split(strip(input), '\n')
    line_quantity = length(lines)
    if line_quantity < 1
        error("Couldn't parse any values")
    end

    return [[parse(Int, num) for num in split(strip(line))] for line in lines]
end

function extrapolate_history_value(direction::Direction, history::Vector{Int})::Int
    diffs = history
    extrema_diffs::Vector{Int} = []
    while true
        new_diffs = [diffs[i+1] - diffs[i] for i in 1:(length(diffs)-1)]

        push!(extrema_diffs, new_diffs[direction == next::Direction ? end : 1])
        diffs = new_diffs

        !all(v -> v == 0, new_diffs) || break
    end

    if direction == next::Direction
        total_diff = sum(extrema_diffs)
        return history[end] + total_diff
    else
        total_diff = sum(extrema_diffs[2:2:end]) - sum(extrema_diffs[1:2:end])
        return history[1] + total_diff
    end
end

end # module
