module Day04
"""
Load inputs and solve the [Day 4](https://adventofcode.com/2023/day/4) puzzle.
"""
function run()::Tuple{Int,Int}
    inputs = readlines(joinpath(@__DIR__, "../data/day04.txt"))
    return solve(inputs), solve(inputs, true)
end

function solve(list::Vector{String}, part_2=false)::Int
    out = 0
    if part_2
        out = 1
    else
        cards = map(parse_card, list)

        for card in cards
            out += score_card(card)
        end
    end
    # println(out)
    return out
end

"Card definiton"
struct Card
    id::UInt
    winning_numbers::Vector{UInt}
    chosen_numbers::Vector{UInt}
end

function parse_card(line::String)::Card
    s = split(line, ':')
    if length(s) != 2
        error("Invalid data format!")
    end

    id = parse(UInt, replace(first(s), "Card " => ""))
    winning_numbers, chosen_numbers = parse_card_numbers(last(s))
    return Card(id, winning_numbers, chosen_numbers)
end

function parse_card_numbers(str::AbstractString)::Tuple{Vector{UInt},Vector{UInt}}
    s = split(strip(str), '|')
    if length(s) != 2
        error("Invalid card number data format!")
    end

    return parse_numbers(s[1]), parse_numbers(s[2])
end

function parse_numbers(str::AbstractString)::Vector{UInt}
    num_strs = split(replace(strip(str), "  " => ' '), ' ')
    return map(s -> parse(UInt, s), num_strs)
end

function score_card(card::Card)::UInt
    match_count = 0
    for winning_number in card.winning_numbers, chosen_number in card.chosen_numbers
        if winning_number == chosen_number
            match_count += 1
        end
    end

    if match_count > 0
        return 2^(match_count - 1)
    end
    return 0
end

end # module
