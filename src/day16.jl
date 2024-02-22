module Day16

using AdventOfCode2023

"""
Load inputs and solve the [Day 16](https://adventofcode.com/2023/day/16) puzzle.
"""
function run()::Tuple{Int,Int}
    input = AdventOfCode2023.data[16]
    return solve(input), solve(input, true)
end

function solve(input::String, part_2=false)::Int
    if part_2
        return 1
    else
        contraption = parse_input(input)
        return count_energized(contraption)
    end
end

@enum Direction begin
    north
    east
    south
    west
end

struct AttackBeam
    "Index the beam is currently targeting"
    target_index::CartesianIndex{2}
    "Direction that beam is moving"
    direction::Direction
end

@enum Tile begin
    empty
    fourty_five_mirror
    one_thirty_five_mirror
    vertical_splitter
    horizantal_splitter
end

"Dict to convert tile character to corresponding Tile enum variant"
TILE_MAP::Dict{Char,Tile} = Dict([
    '.' => empty::Tile
    '/' => fourty_five_mirror::Tile
    '\\' => one_thirty_five_mirror::Tile
    '|' => vertical_splitter::Tile
    '-' => horizantal_splitter::Tile
])
"Dict to convert Tile enum variant to corresponding tile character"
REVERSE_TILE_MAP::Dict{Tile,Char} = Dict(v => k for (k, v) in TILE_MAP)

function print_contraption(contraption::Matrix{Tile})
    for i in axes(contraption, 2)
        for j in axes(contraption, 1)
            print(REVERSE_TILE_MAP[contraption[i, j]])
        end
        println()
    end
    println()
end

function parse_input(input::String)::Matrix{Tile}
    lines = split(strip(input), '\n')

    line_quantity = length(lines)
    @assert line_quantity >= 1 "Couldn't parse any values"

    @assert minimum([length(line) for line in lines]) == maximum([length(line) for line in lines]) "Not a rectangular grid"
    line_length = length(lines[1])

    contraption::Matrix{Tile} = Matrix{Tile}(undef, line_quantity, line_length)
    for (i, line) in enumerate(lines)
        for (j, char) in enumerate(collect(line))
            contraption[i, j] = TILE_MAP[char]
        end
    end

    return contraption
end

function get_next_index(curr_index::CartesianIndex{2}, direction::Direction, max_indices::Tuple{Int,Int})::Union{Some{CartesianIndex{2}},Nothing}
    new_i, new_j = curr_index[1], curr_index[2]
    max_rows, max_cols = max_indices

    if direction == north::Direction
        new_i -= 1
    elseif direction == east::Direction
        new_j += 1
    elseif direction == south::Direction
        new_i += 1
    elseif direction == west::Direction
        new_j -= 1
    else
        error("Invalid direction entered")
    end

    if new_i > 0 && new_i <= max_rows && new_j > 0 && new_j <= max_cols
        return Some(CartesianIndex(new_i, new_j))
    else
        return nothing
    end
end

function follow_beam(contraption::Matrix{Tile}, attack_beam::AttackBeam, attack_beams::Vector{AttackBeam}=Vector{AttackBeam}([]))::Vector{AttackBeam}
    if attack_beam ∈ attack_beams
        # If attack direction out of target index has been done before, return attack_beams now to exit what will be an infinite loop
        return attack_beams
    else
        push!(attack_beams, attack_beam)
    end
    max_indices = size(contraption)
    target_tile = contraption[attack_beam.target_index]

    if target_tile == empty::Tile ||
       (target_tile == vertical_splitter::Tile && (attack_beam.direction == north::Direction || attack_beam.direction == south::Direction)) ||
       (target_tile == horizantal_splitter::Tile && (attack_beam.direction == east::Direction || attack_beam.direction == west::Direction))
        maybe_next_index = get_next_index(attack_beam.target_index, attack_beam.direction, max_indices)
        if !isnothing(maybe_next_index)
            attack_beams = follow_beam(contraption, AttackBeam(something(maybe_next_index), attack_beam.direction), attack_beams)
        end

    elseif target_tile == fourty_five_mirror::Tile
        # /
        out_direction = attack_beam.direction
        if attack_beam.direction == north::Direction
            out_direction = east::Direction
        elseif attack_beam.direction == east::Direction
            out_direction = north::Direction
        elseif attack_beam.direction == south::Direction
            out_direction = west::Direction
        elseif attack_beam.direction == west::Direction
            out_direction = south::Direction
        else
            error("Invalid attack direction entered")
        end

        maybe_next_index = get_next_index(attack_beam.target_index, out_direction, max_indices)
        if !isnothing(maybe_next_index)
            attack_beams = follow_beam(contraption, AttackBeam(something(maybe_next_index), out_direction), attack_beams)
        end

    elseif target_tile == one_thirty_five_mirror::Tile
        # \
        out_direction = attack_beam.direction
        if attack_beam.direction == north::Direction
            out_direction = west::Direction
        elseif attack_beam.direction == east::Direction
            out_direction = south::Direction
        elseif attack_beam.direction == south::Direction
            out_direction = east::Direction
        elseif attack_beam.direction == west::Direction
            out_direction = north::Direction
        else
            error("Invalid attack direction entered")
        end

        maybe_next_index = get_next_index(attack_beam.target_index, out_direction, max_indices)
        if !isnothing(maybe_next_index)
            attack_beams = follow_beam(contraption, AttackBeam(something(maybe_next_index), out_direction), attack_beams)
        end

    elseif target_tile == vertical_splitter::Tile
        # |
        @assert attack_beam.direction == east::Direction || attack_beam.direction == west::Direction "Unexpected direction into vertical splitter"

        maybe_next_index_north = get_next_index(attack_beam.target_index, north::Direction, max_indices)
        if !isnothing(maybe_next_index_north)
            attack_beams = follow_beam(contraption, AttackBeam(something(maybe_next_index_north), north::Direction), attack_beams)
        end

        maybe_next_index_south = get_next_index(attack_beam.target_index, south::Direction, max_indices)
        if !isnothing(maybe_next_index_south)
            attack_beams = follow_beam(contraption, AttackBeam(something(maybe_next_index_south), south::Direction), attack_beams)
        end

    elseif target_tile == horizantal_splitter::Tile
        # -
        @assert attack_beam.direction == north::Direction || attack_beam.direction == south::Direction "Unexpected direction into horizantal splitter"

        maybe_next_index_east = get_next_index(attack_beam.target_index, east::Direction, max_indices)
        if !isnothing(maybe_next_index_east)
            attack_beams = follow_beam(contraption, AttackBeam(something(maybe_next_index_east), east::Direction), attack_beams)
        end

        maybe_next_index_west = get_next_index(attack_beam.target_index, west::Direction, max_indices)
        if !isnothing(maybe_next_index_west)
            attack_beams = follow_beam(contraption, AttackBeam(something(maybe_next_index_west), west::Direction), attack_beams)
        end

    else
        error("Invalid tile type")
    end

    return attack_beams
end

function count_energized(contraption::Matrix{Tile})::Int
    attack_beams = follow_beam(contraption, AttackBeam(CartesianIndex(1, 1), east::Direction))
    return length(unique(map(attack_beam -> attack_beam.target_index, attack_beams)))
end

end # module