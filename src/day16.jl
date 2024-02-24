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
    contraption = parse_input(input)
    if part_2
        max_rows, max_cols = size(contraption)
        energized_counts::Vector{Tuple{AttackBeam,Int}} = []

        # Left & Right
        for i in 1:max_rows
            left_initial_beam = AttackBeam(CartesianIndex(i, 1), east::Direction)
            push!(energized_counts, (left_initial_beam, count_energized(contraption, left_initial_beam)))
            right_initial_beam = AttackBeam(CartesianIndex(i, max_cols), west::Direction)
            push!(energized_counts, (right_initial_beam, count_energized(contraption, right_initial_beam)))
        end
        # Top & Bottom
        for j in 1:max_cols
            top_initial_beam = AttackBeam(CartesianIndex(1, j), south::Direction)
            push!(energized_counts, (top_initial_beam, count_energized(contraption, top_initial_beam)))
            bottom_initial_beam = AttackBeam(CartesianIndex(max_rows, j), north::Direction)
            push!(energized_counts, (bottom_initial_beam, count_energized(contraption, bottom_initial_beam)))
        end

        best_initial_beam, max_energized_count = energized_counts[1]
        for (initial_beam, energized_count) in energized_counts
            if energized_count > max_energized_count
                max_energized_count = energized_count
                best_initial_beam = initial_beam
            end
        end
        # println(best_initial_beam)

        return max_energized_count
    else
        return count_energized(contraption, AttackBeam(CartesianIndex(1, 1), east::Direction))
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

function count_energized(contraption::Matrix{Tile}, initial_beam::AttackBeam)::Int
    sub_beams::Set{AttackBeam} = Set([])
    sub_beam_queue::Vector{AttackBeam} = [initial_beam]
    max_indices = size(contraption)

    is_start = true
    while !isempty(sub_beam_queue)
        curr_sub_beam = popfirst!(sub_beam_queue)

        if !is_start
            maybe_next_index = get_next_index(curr_sub_beam.target_index, curr_sub_beam.direction, max_indices)
            if isnothing(maybe_next_index)
                continue
            end
            curr_sub_beam = AttackBeam(something(maybe_next_index), curr_sub_beam.direction)
        else
            is_start = false
        end

        curr_tile = contraption[curr_sub_beam.target_index]
        if curr_tile == empty::Tile ||
           (curr_tile == vertical_splitter::Tile && (curr_sub_beam.direction == north::Direction || curr_sub_beam.direction == south::Direction)) ||
           (curr_tile == horizantal_splitter::Tile && (curr_sub_beam.direction == east::Direction || curr_sub_beam.direction == west::Direction))
            if curr_sub_beam ∉ sub_beams
                push!(sub_beams, curr_sub_beam)
                push!(sub_beam_queue, curr_sub_beam)
            end

        elseif curr_tile == fourty_five_mirror::Tile
            # /
            out_direction = curr_sub_beam.direction
            if curr_sub_beam.direction == north::Direction
                out_direction = east::Direction
            elseif curr_sub_beam.direction == east::Direction
                out_direction = north::Direction
            elseif curr_sub_beam.direction == south::Direction
                out_direction = west::Direction
            elseif curr_sub_beam.direction == west::Direction
                out_direction = south::Direction
            else
                error("Invalid attack direction entered")
            end
            curr_sub_beam = AttackBeam(curr_sub_beam.target_index, out_direction)

            if curr_sub_beam ∉ sub_beams
                push!(sub_beams, curr_sub_beam)
                push!(sub_beam_queue, curr_sub_beam)
            end

        elseif curr_tile == one_thirty_five_mirror::Tile
            # \
            out_direction = curr_sub_beam.direction
            if curr_sub_beam.direction == north::Direction
                out_direction = west::Direction
            elseif curr_sub_beam.direction == east::Direction
                out_direction = south::Direction
            elseif curr_sub_beam.direction == south::Direction
                out_direction = east::Direction
            elseif curr_sub_beam.direction == west::Direction
                out_direction = north::Direction
            else
                error("Invalid attack direction entered")
            end
            curr_sub_beam = AttackBeam(curr_sub_beam.target_index, out_direction)

            if curr_sub_beam ∉ sub_beams
                push!(sub_beams, curr_sub_beam)
                push!(sub_beam_queue, curr_sub_beam)
            end

        elseif curr_tile == vertical_splitter::Tile || curr_tile == horizantal_splitter::Tile
            # | -
            for out_direction in (curr_tile == vertical_splitter::Tile ? [north::Direction, south::Direction] : [east::Direction, west::Direction])
                curr_sub_beam = AttackBeam(curr_sub_beam.target_index, out_direction)
                if curr_sub_beam ∉ sub_beams
                    push!(sub_beams, curr_sub_beam)
                    push!(sub_beam_queue, curr_sub_beam)
                end
            end

        end
    end

    return length(unique([sub_beam.target_index for sub_beam in sub_beams]))
end

end # module
