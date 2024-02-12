module Day05

using AdventOfCode2023

"""
Load inputs and solve the [Day 5](https://adventofcode.com/2023/day/5) puzzle.
"""
function run()::Tuple{Int,Int}
    input = AdventOfCode2023.data[5]
    return solve(input), solve(input, true)
end

TOTAL_SEED_MAPS = 7

function solve(input::String, part_2=false)::Int
    almanac = parse_input(input, part_2)

    return get_minimum_location(almanac)
end

struct SeedSubMap
    min_src_val::Int
    max_src_val::Int
    Δvalue::Int
end
struct SeedMap
    sub_maps::Vector{SeedSubMap}
end
struct SeedRange
    min_val::Int
    max_val::Int
end
struct Almanac
    seed_ranges::Vector{SeedRange}
    seed_maps::Vector{SeedMap}
end

function parse_input(input::String, part_2::Bool)::Almanac
    entries = split(input, "\n\n")
    if length(entries) != (TOTAL_SEED_MAPS + 1)
        error("Malformed input string!")
    end

    seed_ranges = parse_seed_ranges(entries[1], part_2)

    # Next `TOTAL_SEED_MAPS` entries
    seed_maps = [parse_seed_map(seed_map_str) for seed_map_str in entries[2:end]]

    return Almanac(seed_ranges, seed_maps)
end

function parse_seed_ranges(str::AbstractString, part_2::Bool)::Vector{SeedRange}
    num_str_vec = split(replace(str, "seeds: " => ""), " ")
    num_vec = [parse(Int, num_str) for num_str in num_str_vec]

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

        seed_ranges::Vector{SeedRange} = []
        for i in 1:num_of_seed_ranges
            seed_range_start = seed_range_starts[i]
            seed_range_length = seed_range_lengths[i]

            push!(seed_ranges, SeedRange(seed_range_start, seed_range_start + seed_range_length - 1))
        end

        return seed_ranges
    else
        return [SeedRange(num, num) for num in num_vec]
    end
end

function parse_seed_map(str::AbstractString)::SeedMap
    entries = split(strip(str), '\n')

    if length(entries) < 2
        error("Could not find values to parse into SeedMap")
    end

    # Remove title entry (i.e. "THING1-to-THING2-map:")
    popfirst!(entries)

    sub_maps::Vector{SeedSubMap} = []
    for entry in entries
        num_str_vec = split(strip(entry), ' ')
        if length(num_str_vec) != 3
            error("Expected 3 numbers for SeedSubMap")
        end

        dst_range_start = parse(Int, num_str_vec[1])
        src_range_start = parse(Int, num_str_vec[2])
        sub_map_range_magnitude = parse(Int, num_str_vec[3])

        min_src_val = src_range_start
        max_src_val = src_range_start + sub_map_range_magnitude - 1
        Δvalue = dst_range_start - src_range_start
        push!(sub_maps, SeedSubMap(min_src_val, max_src_val, Δvalue))
    end

    return SeedMap(sub_maps)
end

function follow_seed_map(src_val::Int, seed_map::SeedMap)::Int
    for seed_sub_map in seed_map.sub_maps
        if seed_sub_map.min_src_val ≤ src_val && src_val ≤ seed_sub_map.max_src_val
            return src_val + seed_sub_map.Δvalue
        end
    end
    return src_val
end

function follow_all_seed_maps(seed_val::Int, almanac::Almanac)::Int
    out = seed_val
    for seed_map in almanac.seed_maps
        out = follow_seed_map(out, seed_map)
    end
    return out
end

function get_minimum_location(almanac::Almanac)::Int
    out = nothing
    for seed_range in almanac.seed_ranges
        for seed_val in seed_range.min_val:seed_range.max_val
            location = follow_all_seed_maps(seed_val, almanac)
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
