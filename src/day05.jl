module Day05

using AdventOfCode2023

"""
Load inputs and solve the [Day 5](https://adventofcode.com/2023/day/5) puzzle.
"""
function run()::Tuple{Int,Int}
    input = AdventOfCode2023.data[5]
    return solve(input), solve(input, true)
end

TOTAL_VALUE_MAPS = 7

function solve(input::String, part_2=false)::Int
    almanac = parse_input(input, part_2)

    return get_minimum_location(almanac)
end

struct ValueRange{T}
    min::T
    max::T
end
struct ValueSubMap
    "Source value range"
    src_range::ValueRange{Int}
    "Value change from source to destination"
    Δvalue::Int
end
struct ValueMap
    sub_maps::Vector{ValueSubMap}
end
struct Almanac
    seed_ranges::Vector{ValueRange{Int}}
    value_maps::Vector{ValueMap}
end

function parse_input(input::String, part_2::Bool)::Almanac
    entries = split(input, "\n\n")
    if length(entries) != (TOTAL_VALUE_MAPS + 1)
        error("Malformed input string!")
    end

    seed_ranges = parse_seed_ranges(entries[1], part_2)

    # Next `TOTAL_VALUE_MAPS` entries
    value_maps = [parse_value_map(value_map_str) for value_map_str in entries[2:end]]

    return Almanac(seed_ranges, value_maps)
end

function parse_seed_ranges(str::AbstractString, part_2::Bool)::Vector{ValueRange{Int}}
    num_vec = [parse(Int, num_str) for num_str in split(replace(str, "seeds: " => ""), " ")]

    if part_2
        if isodd(length(num_vec))
            error("Received odd number of seeds values. Need pairs for part 2")
        end
        seed_range_starts = num_vec[1:2:end]
        seed_range_lengths = num_vec[2:2:end]
        if length(seed_range_starts) != length(seed_range_lengths)
            error("Received odd number of seeds values. Need pairs for part 2")
        end
        num_of_seed_ranges = length(seed_range_starts)

        seed_ranges::Vector{ValueRange} = []
        for i in 1:num_of_seed_ranges
            seed_range_start = seed_range_starts[i]
            seed_range_length = seed_range_lengths[i]

            push!(seed_ranges, ValueRange(seed_range_start, seed_range_start + seed_range_length - 1))
        end

        return seed_ranges
    else
        return [ValueRange(num, num) for num in num_vec]
    end
end

function parse_value_map(str::AbstractString)::ValueMap
    entries = split(strip(str), '\n')

    if length(entries) < 2
        error("Could not find values to parse into ValueMap")
    end

    # Remove title entry (i.e. "THING1-to-THING2-map:")
    popfirst!(entries)

    sub_maps::Vector{ValueSubMap} = []
    for entry in entries
        num_str_vec = split(strip(entry), ' ')
        if length(num_str_vec) != 3
            error("Expected 3 numbers for ValueSubMap")
        end

        dst_range_start = parse(Int, num_str_vec[1])
        src_range_start = parse(Int, num_str_vec[2])
        sub_map_range_magnitude = parse(Int, num_str_vec[3])

        min_src_val = src_range_start
        max_src_val = src_range_start + sub_map_range_magnitude - 1
        src_range = ValueRange(min_src_val, max_src_val)
        Δvalue = dst_range_start - src_range_start
        push!(sub_maps, ValueSubMap(src_range, Δvalue))
    end

    return ValueMap(sub_maps)
end

function follow_value_map(src_val::Int, value_map::ValueMap)::Int
    for value_sub_map in value_map.sub_maps
        if value_sub_map.src_range.min ≤ src_val && src_val ≤ value_sub_map.src_range.max
            return src_val + value_sub_map.Δvalue
        end
    end
    return src_val
end

function follow_all_value_maps(src_val::Int, almanac::Almanac)::Int
    out = src_val
    for value_map in almanac.value_maps
        out = follow_value_map(out, value_map)
    end
    return out
end

function get_minimum_location(almanac::Almanac)::Int
    out = nothing
    for seed_range in almanac.seed_ranges
        for seed_val in seed_range.min:seed_range.max
            location = follow_all_value_maps(seed_val, almanac)
            if isnothing(out)
                out = Some(location)
            elseif location < something(out)
                out = Some(location)
            end
        end
    end

    return something(out)
end

end # module
