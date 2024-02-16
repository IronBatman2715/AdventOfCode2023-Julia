module Day10

using AdventOfCode2023

"""
Load inputs and solve the [Day 10](https://adventofcode.com/2023/day/10) puzzle.
"""
function run()::Tuple{Int,Int}
    input = AdventOfCode2023.data[10]
    return solve(input), solve(input, true)
end

function solve(input::String, part_2=false)::Int
    if part_2
        return 1
    else
        grid, start_index = parse_input(input)
        path_length = get_path_length(grid, start_index)
        if isodd(path_length)
            error("path_length is an odd number")
        end
        return path_length / 2
    end
end

@enum Tile begin
    vertical
    horizantal
    north_east
    north_west
    south_west
    south_east
    ground
    starting_position
end

"Dict to convert tile character to corresponding Tile enum variant"
TILE_MAP::Dict{Char,Tile} = Dict([
    '|' => vertical::Tile
    '-' => horizantal::Tile
    'L' => north_east::Tile
    'J' => north_west::Tile
    '7' => south_west::Tile
    'F' => south_east::Tile
    '.' => ground::Tile
    'S' => starting_position::Tile
])
"Dict to convert Tile enum variant to corresponding tile character"
REVERSE_TILE_MAP::Dict{Tile,Char} = Dict(v => k for (k, v) in TILE_MAP)

function parse_input(input::String)::Tuple{Matrix{Tile},CartesianIndex{2}}
    lines = split(strip(input), '\n')
    line_quantity = length(lines)
    if line_quantity < 1
        error("Couldn't parse any values")
    end
    if minimum([length(line) for line in lines]) != maximum([length(line) for line in lines])
        error("Not a rectangular grid")
    end
    line_length = length(lines[1])

    maybe_start::Union{Some{CartesianIndex{2}},Nothing} = nothing
    grid::Matrix{Tile} = Matrix{Tile}(undef, line_quantity, line_length)
    for (i, line) in enumerate(lines)
        for (j, char) in enumerate(collect(line))
            grid[i, j] = TILE_MAP[char]
            if grid[i, j] == starting_position::Tile
                if !isnothing(maybe_start)
                    error("Multiple start locations found!")
                end
                maybe_start = Some(CartesianIndex(i, j))
            end
        end
    end
    start_index = something(maybe_start)

    return grid, start_index
end

function get_path_length(grid::Matrix{Tile}, start_index::CartesianIndex{2})::Int
    path_length = 0
    prev_index = start_index
    curr_index = start_index
    while true
        # println("$curr_index -> $(REVERSE_TILE_MAP[grid[curr_index]])")
        path_length += 1

        # Update next_index
        next_index = get_next_neighbor_index(grid, curr_index, prev_index)

        # Move to next iteration by updating other indices
        prev_index = curr_index
        curr_index = next_index

        curr_index != start_index || return path_length
    end
end

function get_pipe_neighbor_indices(grid::Matrix{Tile}, home_index::CartesianIndex{2})::Vector{CartesianIndex{2}}
    home_tile = grid[home_index]
    if home_tile == vertical::Tile
        return [CartesianIndex(home_index[1] + 1, home_index[2]), CartesianIndex(home_index[1] - 1, home_index[2])]

    elseif home_tile == horizantal::Tile
        return [CartesianIndex(home_index[1], home_index[2] + 1), CartesianIndex(home_index[1], home_index[2] - 1)]

    elseif home_tile == north_east::Tile
        return [CartesianIndex(home_index[1] - 1, home_index[2]), CartesianIndex(home_index[1], home_index[2] + 1)]

    elseif home_tile == north_west::Tile
        return [CartesianIndex(home_index[1] - 1, home_index[2]), CartesianIndex(home_index[1], home_index[2] - 1)]

    elseif home_tile == south_west::Tile
        return [CartesianIndex(home_index[1] + 1, home_index[2]), CartesianIndex(home_index[1], home_index[2] - 1)]

    elseif home_tile == south_east::Tile
        return [CartesianIndex(home_index[1] + 1, home_index[2]), CartesianIndex(home_index[1], home_index[2] + 1)]

    elseif home_tile == ground::Tile
        error("Ground tile has no neighbors!")

    elseif home_tile == starting_position::Tile
        # Go in all cardinal directions to find neighbors
        out::Vector{CartesianIndex{2}} = []

        # North
        north_index = CartesianIndex(home_index[1] - 1, home_index[2])
        north_tile = grid[north_index]
        if north_tile == vertical::Tile || north_tile == south_west::Tile || north_tile == south_east::Tile
            push!(out, north_index)
        end

        # East
        east_index = CartesianIndex(home_index[1], home_index[2] + 1)
        east_tile = grid[east_index]
        if east_tile == horizantal::Tile || east_tile == north_west::Tile || east_tile == south_west::Tile
            push!(out, east_index)
        end

        # South
        south_index = CartesianIndex(home_index[1] + 1, home_index[2])
        south_tile = grid[south_index]
        if south_tile == vertical::Tile || south_tile == north_west::Tile || south_tile == north_east::Tile
            push!(out, south_index)
        end

        # West
        west_index = CartesianIndex(home_index[1], home_index[2] - 1)
        west_tile = grid[west_index]
        if west_tile == horizantal::Tile || west_tile == north_east::Tile || west_tile == south_east::Tile
            push!(out, west_index)
        end

        if length(out) != 2
            error("Expected 2 and only 2 neighbors for starting position")
        end

        return out
    else
        error("Could not match grid[home_index] to valid Tile variant")
    end
end

function get_next_neighbor_index(grid::Matrix{Tile}, curr_index::CartesianIndex{2}, prev_index::CartesianIndex{2})::CartesianIndex{2}
    neighbor_indices = get_pipe_neighbor_indices(grid, curr_index)
    if length(neighbor_indices) != 2
        error("Expected 2 and only 2 neighbors")
    end

    return prev_index == neighbor_indices[1] ? neighbor_indices[2] : neighbor_indices[1]
end

end # module
