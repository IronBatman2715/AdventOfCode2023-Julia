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
    grid, start_index = parse_input(input)
    path_indices = get_path_indices(grid, start_index)

    if part_2
        remove_dead_pipes!(grid, path_indices)
        return length(get_inside_indices(grid, path_indices))
    else
        path_length = length(path_indices)
        @assert iseven(path_length) "Expected path_length to be even number"
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
    grid[start_index] = infer_starting_tile(grid, start_index)

    return grid, start_index
end

function infer_starting_tile(grid::Matrix{Tile}, start_index::CartesianIndex{2})::Tile
    # Go in all cardinal directions to find possible neighbors
    possible_tiles = [vertical::Tile, horizantal::Tile, north_east::Tile, north_west::Tile, south_west::Tile, south_east::Tile]

    # North
    tile = grid[CartesianIndex(start_index[1] - 1, start_index[2])]
    if tile == vertical::Tile || tile == south_west::Tile || tile == south_east::Tile
        intersect!(possible_tiles, [vertical::Tile, north_west::Tile, north_east::Tile])
    end

    # East
    tile = grid[CartesianIndex(start_index[1], start_index[2] + 1)]
    if tile == horizantal::Tile || tile == north_west::Tile || tile == south_west::Tile
        intersect!(possible_tiles, [horizantal::Tile, north_east::Tile, south_east::Tile])
    end

    # South
    tile = grid[CartesianIndex(start_index[1] + 1, start_index[2])]
    if tile == vertical::Tile || tile == north_west::Tile || tile == north_east::Tile
        intersect!(possible_tiles, [vertical::Tile, south_west::Tile, south_east::Tile])
    end

    # West
    tile = grid[CartesianIndex(start_index[1], start_index[2] - 1)]
    if tile == horizantal::Tile || tile == north_east::Tile || tile == south_east::Tile
        intersect!(possible_tiles, [horizantal::Tile, north_west::Tile, south_west::Tile])
    end

    if length(possible_tiles) != 1
        error("Expected 1 and only 1 possible start tile variant")
    end

    return possible_tiles[1]
end

function get_path_indices(grid::Matrix{Tile}, start_index::CartesianIndex{2})::Vector{CartesianIndex{2}}
    path_indices::Vector{CartesianIndex{2}} = []
    prev_index = start_index
    curr_index = start_index
    while true
        push!(path_indices, curr_index)

        # Update next_index
        next_index = get_next_neighbor_index(grid, curr_index, prev_index)

        # Move to next iteration by updating other indices
        prev_index = curr_index
        curr_index = next_index

        curr_index != start_index || return path_indices
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
        error("Starting position should have been removed with inferred value first")

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

"Replace all pipes not in path with `ground::Tile`"
function remove_dead_pipes!(grid::Matrix{Tile}, path_indices::Vector{CartesianIndex{2}})
    for idx in CartesianIndices(grid)
        if grid[idx] != ground::Tile && !any(path_index -> path_index == idx, path_indices)
            grid[idx] = ground::Tile
        end
    end
end

"""
Follow rows of `grid` to get indices of all tiles that are enclosed by the path

Odd num of pipe crossings in all directions => Inside loop
Even num of pipe crossing in all directions => Outside loop

If testing crossing and riding along pipe, only consider crossing if the pipe eventually splits to opposing directions
"""
function get_inside_indices(grid::Matrix{Tile}, path_indices::Vector{CartesianIndex{2}})::Vector{CartesianIndex{2}}
    inside_indices::Vector{CartesianIndex{2}} = []

    for i in axes(grid, 2)
        is_inside = false
        maybe_facing_northward_pipe::Union{Some{Bool},Nothing} = nothing
        for j in axes(grid, 1)
            tile_index = CartesianIndex(i, j)
            tile = grid[tile_index]

            if tile == vertical::Tile
                @assert isnothing(maybe_facing_northward_pipe) "Expected to NOT be following pipe right now"
                is_inside = !is_inside

            elseif tile == horizantal::Tile
                @assert !isnothing(maybe_facing_northward_pipe) "Expected to have encountered angled tile BEFORE this point"

            elseif tile == north_east::Tile || tile == south_east::Tile
                @assert isnothing(maybe_facing_northward_pipe) "Expected to have just started looking at pipe crossing"
                maybe_facing_northward_pipe = Some(tile == north_east::Tile)

            elseif tile == south_west::Tile || tile == north_west::Tile
                @assert !isnothing(maybe_facing_northward_pipe) "Expected to be following pipe right now"
                if tile != (something(maybe_facing_northward_pipe) ? north_west::Tile : south_west::Tile)
                    is_inside = !is_inside
                end
                maybe_facing_northward_pipe = nothing

            elseif tile == ground::Tile
                # do nothing
            else
                error("Unexpected tile type! Make sure `remove_dead_pipes!` is run before this function")
            end

            if is_inside && !any(v -> v == tile_index, path_indices)
                push!(inside_indices, tile_index)
            end
        end
    end

    return inside_indices
end

end # module
