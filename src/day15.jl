module Day15

using AdventOfCode2023

"""
Load inputs and solve the [Day 15](https://adventofcode.com/2023/day/15) puzzle.
"""
function run()::Tuple{Int,Int}
    input = AdventOfCode2023.data[15]
    return solve(input), solve(input, true)
end

function solve(input::String, part_2=false)::Int
    if part_2
        return 1
    else
        step_strs = parse_input(input)
        return sum([hash_string(step_str) for step_str in step_strs])
    end
end

function parse_input(input::String)::Vector{String}
    @assert isascii(input) "Received non-ASCII string"
    step_strs = split(strip(input), ',')

    step_quantity = length(step_strs)
    @assert step_quantity > 0 "Couldn't parse any values"

    return step_strs
end

function hash_string(str::String)::Int
    @assert isascii(str) "Received non-ASCII string"
    val = 0
    for char in collect(str)
        val += Int(char)
        val *= 17
        val %= 256
    end
    return val
end

end # module
