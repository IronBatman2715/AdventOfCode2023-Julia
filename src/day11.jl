module Day11

using AdventOfCode2023

"""
Load inputs and solve the [Day 11](https://adventofcode.com/2023/day/11) puzzle.
"""
function run()::Tuple{Int,Int}
    input = AdventOfCode2023.data[11]
    return solve(input), solve(input, true)
end

function solve(input::String, part_2=false)::Int
    if part_2
        return 1
    else
        universe, galaxy_indices = parse_input(input)
        _, expanded_galaxy_indices = expand_universe(universe)
        return sum([get_distance(pair) for pair in get_unique_unordered_pairs(expanded_galaxy_indices)])
    end
end

function parse_input(input::String)::Tuple{Matrix{Bool},Set{CartesianIndex{2}}}
    lines = split(strip(input), '\n')

    line_quantity = length(lines)
    @assert line_quantity >= 1 "Couldn't parse any values"

    @assert minimum([length(line) for line in lines]) == maximum([length(line) for line in lines]) "Not a rectangular grid"
    line_length = length(lines[1])

    galaxy_indices::Set{CartesianIndex{2}} = Set([])
    universe::Matrix{Bool} = falses(line_quantity, line_length)
    for (i, line) in enumerate(lines)
        for (j, char) in enumerate(collect(line))
            if char == '#'
                push!(galaxy_indices, CartesianIndex(i, j))
                universe[i, j] = true
            end
        end
    end

    return universe, galaxy_indices
end

function expand_universe(universe::Matrix{Bool})::Tuple{Matrix{Bool},Set{CartesianIndex{2}}}
    orig_rows, orig_cols = size(universe)

    new_rows::Vector{Int} = [] # Add a row after this index in starting matrix
    for i in 1:orig_rows
        if all(v -> !v, universe[i, :])
            push!(new_rows, i)
        end
    end

    new_cols::Vector{Int} = [] # Add a row after this index in original matrix
    for j in 1:orig_cols
        if all(v -> !v, universe[:, j])
            push!(new_cols, j)
        end
    end

    new_universe::Matrix{Bool} = falses(orig_rows + length(new_rows), orig_cols + length(new_cols))
    new_galaxy_indices::Set{CartesianIndex{2}} = Set([])
    for i in 1:orig_rows
        for j in 1:orig_cols
            if universe[i, j]
                @assert !any(v -> v == i, new_rows) "Tried to add a row where a galaxy exists!"
                @assert !any(v -> v == j, new_cols) "Tried to add a column where a galaxy exists!"

                new_galaxy_index = CartesianIndex(i + count(v -> v < i, new_rows), j + count(v -> v < j, new_cols))
                push!(new_galaxy_indices, new_galaxy_index)
                new_universe[new_galaxy_index] = true
            end
        end
    end

    return new_universe, new_galaxy_indices
end

function get_unique_unordered_pairs(set::Set)::Set{Pair}
    out::Set{Pair} = Set([])
    for vi in set
        for vo in set
            if vi == vo
                continue
            end

            test_pair = Pair(vi, vo)
            rev_test_pair = Pair(vo, vi)
            if !(test_pair ∈ out || rev_test_pair ∈ out)
                push!(out, test_pair)
            end
        end
    end

    @assert sum(1:(length(set)-1)) == length(out) "Incorrect number of pairs!"
    return out
end

function get_distance(indices::Pair{CartesianIndex{2}})::Int
    return abs(indices.first[1] - indices.second[1]) + abs(indices.first[2] - indices.second[2])
end

end # module
