module Day13

using AdventOfCode2023

"""
Load inputs and solve the [Day 13](https://adventofcode.com/2023/day/13) puzzle.
"""
function run()::Tuple{Int,Int}
    input = AdventOfCode2023.data[13]
    return solve(input), solve(input, true)
end

function solve(input::String, part_2=false)::Int
    patterns = parse_input(input)
    return sum([summarize_pattern(p, part_2) for p in patterns])
end

function parse_input(input::String)::Vector{Matrix{Bool}}
    pattern_strs = split(strip(input), "\n\n")

    pattern_quantity = length(pattern_strs)
    @assert pattern_quantity > 0 "Couldn't parse any values"

    return [parse_pattern(ps) for ps in pattern_strs]
end

function parse_pattern(pattern_str::AbstractString)::Matrix{Bool}
    lines = split(strip(pattern_str), '\n')

    line_quantity = length(lines)
    @assert line_quantity > 0 "Couldn't parse any values"

    @assert minimum([length(line) for line in lines]) == maximum([length(line) for line in lines]) "Not a rectangular grid"
    line_length = length(lines[1])

    pattern::Matrix{Bool} = falses(line_quantity, line_length)
    for (i, line) in enumerate(lines)
        for (j, char) in enumerate(collect(line))
            if char == '#'
                pattern[i, j] = true
            end
        end
    end

    return pattern
end

function summarize_pattern(pattern::Matrix{Bool}, part_2::Bool)::Int
    rows, cols = size(pattern)

    for i in 1:(rows-1)
        is_mirrored = false
        i_in, i_out = i, i + 1
        while true
            mismatch_count = count(j -> pattern[i_in, j] != pattern[i_out, j], 1:cols)
            if part_2
                if mismatch_count > 1 || (is_mirrored && mismatch_count > 0)
                    is_mirrored = false
                    break
                elseif mismatch_count == 1
                    is_mirrored = true
                end
            else
                if mismatch_count > 0
                    is_mirrored = false
                    break
                else
                    is_mirrored = true
                end
            end

            i_in -= 1
            i_out += 1
            i_in >= 1 && i_out <= rows || break
        end
        if is_mirrored
            return 100 * i
        end
    end

    for j in 1:(cols-1)
        is_mirrored = false
        j_in, j_out = j, j + 1
        while true
            mismatch_count = count(i -> pattern[i, j_in] != pattern[i, j_out], 1:rows)
            if part_2
                if mismatch_count > 1 || (is_mirrored && mismatch_count > 0)
                    is_mirrored = false
                    break
                elseif mismatch_count == 1
                    is_mirrored = true
                end
            else
                if mismatch_count > 0
                    is_mirrored = false
                    break
                else
                    is_mirrored = true
                end
            end

            j_in -= 1
            j_out += 1
            j_in >= 1 && j_out <= cols || break
        end
        if is_mirrored
            return j
        end
    end

    error("Could not find axis of reflection")
end

end # module
