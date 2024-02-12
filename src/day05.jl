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
    almanac = parse_input(input)

    if part_2
        return 1
    else
        return min(follow_seed_maps(almanac)...)
    end
end

struct SeedSubMap
    min_src_val::Int
    max_src_val::Int
    Δvalue::Int
end
struct SeedMap
    sub_maps::Vector{SeedSubMap}
end
struct Almanac
    seeds::Vector{Int}
    seed_maps::Vector{SeedMap}
end

function parse_input(input::String)::Almanac
    entries = split(input, "\n\n")
    if length(entries) != (TOTAL_SEED_MAPS + 1)
        error("Malformed input string!")
    end

    # First entry: "seeds: ## ### #..."
    seeds = map(num_str -> parse(Int, num_str), split(replace(entries[1], "seeds: " => ""), " "))

    # Next `TOTAL_SEED_MAPS` entries
    seed_maps = [parse_seed_map(seed_map_str) for seed_map_str in entries[2:end]]

    return Almanac(seeds, seed_maps)
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
        num_vec = split(strip(entry), ' ')
        if length(num_vec) != 3
            error("Expected 3 numbers for SeedSubMap")
        end

        dst_range_start = parse(Int, num_vec[1])
        src_range_start = parse(Int, num_vec[2])
        sub_map_range_magnitude = parse(Int, num_vec[3])

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

function follow_seed_maps(almanac::Almanac)::Vector{Int}
    out = almanac.seeds
    for seed_map in almanac.seed_maps
        out = [follow_seed_map(val, seed_map) for val in out]
    end

    return out
end

end # module
