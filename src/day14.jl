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
    if part_2
        return 1
    else
        platform = parse_input(input)
        tilt_platform!(platform)
        return calculate_load(platform)
    end
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

function tilt_platform!(platform::Matrix{Tile})
    # Assume north for now

    # Go DOWN each column (north -> south), moving as far down as possible IF sphere::Tile
    for j in axes(platform, 1)
        for i in axes(platform, 2)
            if platform[i, j] == sphere::Tile
                i_new = i
                while true
                    ((i_new - 1) > 0 && platform[(i_new-1), j] == empty::Tile) || break
                    i_new -= 1
                end

                if i_new != i
                    platform[i, j] = empty::Tile
                    platform[i_new, j] = sphere::Tile
                end
            end
        end
    end
end

function calculate_load(platform::Matrix{Tile})::Int
    rows, _ = size(platform)
    sphere_rocks_indices = [idx for idx in CartesianIndices(platform) if platform[idx] == sphere::Tile]

    return sum([rows - idx[1] + 1 for idx in sphere_rocks_indices])
end

end # module
