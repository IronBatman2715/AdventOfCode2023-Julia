module Day14

using AdventOfCode2023

"""
Load inputs and solve the [Day 14](https://adventofcode.com/2023/day/14) puzzle.
"""
function run()::Tuple{Int,Int}
    input = AdventOfCode2023.data[14]
    return solve(input), solve(input, true)
end

function solve(input::String, part_2=false)::Int
    platform = parse_input(input)

    if part_2
        spin_cycle!(platform, 1_000_000_000)
    else
        tilt_platform!(platform, north::Direction)
    end

    return calculate_load(platform)
end

@enum Direction begin
    north
    east
    south
    west
end

@enum Tile begin
    sphere
    cube
    empty
end

"Dict to convert tile character to corresponding Tile enum variant"
TILE_MAP::Dict{Char,Tile} = Dict([
    'O' => sphere::Tile
    '#' => cube::Tile
    '.' => empty::Tile
])
"Dict to convert Tile enum variant to corresponding tile character"
REVERSE_TILE_MAP::Dict{Tile,Char} = Dict(v => k for (k, v) in TILE_MAP)

function print_platform(platform::Matrix{Tile})
    for i in axes(platform, 2)
        for j in axes(platform, 1)
            print(REVERSE_TILE_MAP[platform[i, j]])
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

    platform::Matrix{Tile} = Matrix{Tile}(undef, line_quantity, line_length)
    for (i, line) in enumerate(lines)
        for (j, char) in enumerate(collect(line))
            platform[i, j] = TILE_MAP[char]
        end
    end

    return platform
end

function tilt_platform!(platform::Matrix{Tile}, direction::Direction)
    rows, cols = size(platform)

    if direction == north::Direction || direction == south::Direction
        modifier = direction == north::Direction ? -1 : 1
        rows_range = direction == north::Direction ? (1:rows) : (rows:-1:1)

        for j in 1:cols
            for i in rows_range
                if platform[i, j] == sphere::Tile
                    i_new = i
                    while true
                        ((i_new + modifier) > 0 && (i_new + modifier) <= rows && platform[(i_new+modifier), j] == empty::Tile) || break
                        i_new += modifier
                    end

                    if i_new != i
                        platform[i, j] = empty::Tile
                        platform[i_new, j] = sphere::Tile
                    end
                end
            end
        end
    elseif direction == west::Direction || direction == east::Direction
        modifier = direction == west::Direction ? -1 : 1
        cols_range = direction == west::Direction ? (1:cols) : (cols:-1:1)

        for i in 1:rows
            for j in cols_range
                if platform[i, j] == sphere::Tile
                    j_new = j
                    while true
                        ((j_new + modifier) > 0 && (j_new + modifier) <= cols && platform[i, (j_new+modifier)] == empty::Tile) || break
                        j_new += modifier
                    end

                    if j_new != j
                        platform[i, j] = empty::Tile
                        platform[i, j_new] = sphere::Tile
                    end
                end
            end
        end
    else
        error("Unexpected direction variant")
    end
end

function spin_cycle!(platform::Matrix{Tile}, max_cycle_count::Int)
    cycle_platforms::Vector{Matrix{Tile}} = [deepcopy(platform)]
    cycle_count = 0
    loop_length = 0
    is_on_finishing = false
    while true
        repeated_platform_indices = findall(p -> p == platform, cycle_platforms[1:end-1])
        if length(repeated_platform_indices) > 0
            @assert length(repeated_platform_indices) == 1 "Should exit before multiple matches appear"

            if loop_length == 0
                loop_length = cycle_count - (repeated_platform_indices[1] - 1)
            end
        end
        tilt_platform!(platform, north::Direction)
        tilt_platform!(platform, west::Direction)
        tilt_platform!(platform, south::Direction)
        tilt_platform!(platform, east::Direction)

        push!(cycle_platforms, deepcopy(platform))

        cycle_count += 1

        if loop_length != 0
            is_on_finishing = (((max_cycle_count) - cycle_count) % loop_length) == 0
        end

        (cycle_count <= max_cycle_count && !is_on_finishing) || break
    end
end

function calculate_load(platform::Matrix{Tile})::Int
    rows, _ = size(platform)
    sphere_rocks_indices = [idx for idx in CartesianIndices(platform) if platform[idx] == sphere::Tile]

    return sum([rows - idx[1] + 1 for idx in sphere_rocks_indices])
end

end # module
