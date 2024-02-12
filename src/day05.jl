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

function map_range(value_range::ValueRange{Int}, value_map::ValueMap)::Vector{ValueRange{Int}}
    out::Vector{ValueRange{Int}} = []
    for sub_map in value_map.sub_maps
        map_min, map_max = sub_map.src_range.min, sub_map.src_range.max
        Δ = sub_map.Δvalue

        if map_min < value_range.min && value_range.max < map_max
            # sub_map completely encloses value_range
            new_min, new_max = (value_range.min, value_range.max) .+ Δ
            push!(out, ValueRange(new_min, new_max))

        elseif value_range.min < map_min && map_max < value_range.max
            # value_range completely encloses sub_map
            new_min, new_max = (map_min, map_max) .+ Δ
            push!(out, ValueRange(new_min, new_max))

        elseif value_range.max <= map_max && map_min <= value_range.max
            # sub_map does not cover entire lower bound of value_range, but goes up to or beyond upper bound
            new_min, new_max = (max(map_min, value_range.min), value_range.max) .+ Δ
            push!(out, ValueRange(new_min, new_max))

        elseif map_min <= value_range.min && value_range.min <= map_max
            # sub_map does not cover entire upper bound of value_range, but goes up to or beyond lower bound
            new_min, new_max = (value_range.min, min(map_max, value_range.max)) .+ Δ
            push!(out, ValueRange(new_min, new_max))

        else
            # no intersection, do nothing
        end
    end

    if length(out) == 0
        # Mapping is 1-to-1 for entire range
        return [value_range]
    end

    return out
end

function map_range_thru_all(value_range::ValueRange{Int}, value_maps::Vector{ValueMap})::Vector{ValueRange{Int}}
    mapped_ranges = map_range(value_range, value_maps[1])
    if length(value_maps) == 1
        return mapped_ranges
    end

    for value_map in value_maps[2:end]
        mapped_ranges = reduce(vcat, [map_range(mapped_range, value_map) for mapped_range in mapped_ranges])
    end
    return mapped_ranges
end

function get_minimum_location(almanac::Almanac)::Int
    min_location = nothing
    for seed_range in almanac.seed_ranges
        location_mappings = map_range_thru_all(seed_range, almanac.value_maps)
        local_min_location = minimum([location_mapping.min for location_mapping in location_mappings])

        if isnothing(min_location)
            min_location = Some(local_min_location)
        elseif local_min_location < something(min_location)
            min_location = Some(local_min_location)
        end
    end

    return something(min_location)
end

end # module
