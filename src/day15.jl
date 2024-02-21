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
    step_strs = parse_input(input)
    if part_2
        boxes = run_lens_box_steps(step_strs)
        return calculate_total_lens_power(boxes)
    else
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

function hash_string(str::AbstractString)::Int
    @assert isascii(str) "Received non-ASCII string"
    val = 0
    for char in collect(str)
        val += Int(char)
        val *= 17
        val %= 256
    end
    return val
end

struct Lens
    label::String
    focal_length::Int
end

function run_lens_box_steps(step_strs::Vector{String})::Vector{Vector{Lens}}
    boxes::Vector{Vector{Lens}} = fill([], 256)
    for step_str in step_strs
        if contains(step_str, '-')
            @assert !contains(step_str, '=') "Contains multiple operation characters"

            label = step_str[1:end-1]

            box = boxes[hash_string(label)+1]

            matches = findall(lens -> lens.label == label, box)
            if length(matches) > 0
                for match in reverse(matches)
                    popat!(box, match)
                end
            end

        elseif contains(step_str, '=')
            @assert !contains(step_str, '-') "Contains multiple operation characters"

            operator_split = split(step_str, '=')
            @assert length(operator_split) == 2 "Unexpected step format"
            new_lens = Lens(operator_split[1], parse(Int, operator_split[2]))

            box = boxes[hash_string(new_lens.label)+1]

            matches = findall(lens -> lens.label == new_lens.label, box)
            if length(matches) > 0
                for match in matches
                    box[match] = new_lens
                end
            else
                push!(box, new_lens)
            end

        else
            error("Expected an operation character")
        end
    end

    return boxes
end

function calculate_total_lens_power(boxes::Vector{Vector{Lens}})::Int
    return sum([sum([box_num * slot_num * lens.focal_length for (slot_num, lens) in enumerate(box)]) for (box_num, box) in enumerate(boxes)])
end

end # module
