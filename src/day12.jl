module Day12

using AdventOfCode2023

"""
Load inputs and solve the [Day 12](https://adventofcode.com/2023/day/12) puzzle.
"""
function run()::Tuple{Int,Int}
    input = AdventOfCode2023.data[12]
    return solve(input), solve(input, true)
end

function solve(input::String, part_2=false)::Int
    if part_2
        return 1
    else
        spring_records = parse_input(input)
        return sum([count_possible_arrangements(sr) for sr in spring_records])
    end
end

@enum SpringCondition begin
    operational
    damaged
    unknown
end

"Dict to convert spring condition character to corresponding SpringCondition enum variant"
SPRING_CONDITION_MAP::Dict{Char,SpringCondition} = Dict([
    '.' => operational::SpringCondition
    '#' => damaged::SpringCondition
    '?' => unknown::SpringCondition
])
"Dict to convert SpringCondition enum variant to corresponding spring condition character"
REVERSE_SPRING_CONDITION_MAP::Dict{SpringCondition,Char} = Dict(v => k for (k, v) in SPRING_CONDITION_MAP)

struct SpringRowRecord
    records::Vector{SpringCondition}
    damaged_counts::Vector{Int}
end

function parse_input(input::String)::Vector{SpringRowRecord}
    lines = split(strip(input), '\n')

    line_quantity = length(lines)
    @assert line_quantity > 0 "Couldn't parse any values"

    return [parse_input_line(line) for line in lines]
end

function parse_input_line(line::AbstractString)::SpringRowRecord
    str_vec = split(strip(line))
    @assert length(str_vec) == 2 "Unexpected line formatting"

    records = [SPRING_CONDITION_MAP[c] for c in collect(strip(str_vec[1]))]
    damaged_counts = [parse(Int, c) for c in split(strip(str_vec[2]), ',')]

    return SpringRowRecord(records, damaged_counts)
end

function count_possible_arrangements(spring_record::SpringRowRecord)::Int
    return count_possible_arrangements(spring_record.records, spring_record.damaged_counts)
end

function count_possible_arrangements(records::Vector{SpringCondition}, damaged_counts::Vector{Int})::Int
    if isempty(records)
        return isempty(damaged_counts) ? 1 : 0
    end
    if isempty(damaged_counts)
        return any(c -> c == damaged::SpringCondition, records) ? 0 : 1
    end

    out = 0
    if damaged::SpringCondition != records[1]
        out += count_possible_arrangements(records[2:end], damaged_counts)
    end
    if operational::SpringCondition != records[1] &&
       damaged_counts[1] <= length(records) &&
       !any(c -> c == operational::SpringCondition, records[1:damaged_counts[1]]) &&
       (damaged_counts[1] == length(records) || records[damaged_counts[1]+1] != damaged::SpringCondition)

        out += count_possible_arrangements(records[(damaged_counts[1]+2):end], damaged_counts[2:end])
    end

    return out
end

end # module
