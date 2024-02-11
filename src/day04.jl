module Day04

using AdventOfCode2023

"""
Load inputs and solve the [Day 4](https://adventofcode.com/2023/day/4) puzzle.
"""
function run()::Tuple{Int,Int}
    inputs::Vector{String} = split(AdventOfCode2023.data[4], '\n')
    return solve(inputs), solve(inputs, true)
end

function solve(list::Vector{String}, part_2=false)::Int
    cards = map(parse_card, list)

    out = 0
    if part_2
        out = sum(count_total_cards(cards))
    else
        for card in cards
            out += score_card(card)
        end
    end
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

function get_matching_number_count(card::Card)::UInt
    match_count = 0
    for winning_number in card.winning_numbers, chosen_number in card.chosen_numbers
        if winning_number == chosen_number
            match_count += 1
        end
    end
    return match_count
end

function score_card(card::Card)::UInt
    match_count = get_matching_number_count(card)
    if match_count > 0
        return 2^(match_count - 1)
    end
    return 0
end

function count_total_cards(cards::Vector{Card})::Vector{UInt}
    # Initialize card_count based off cards
    no_copies_card_count = length(cards)
    card_count::Vector{UInt} = fill(UInt(1), no_copies_card_count)

    for card in cards
        match_count = get_matching_number_count(card)

        # Run for each card instance according to card_count (1 + number of accumulated copies)
        for _ in 1:card_count[card.id]
            # Increment next `match_count` cards in card_count by 1
            if match_count > 0
                for j in 1:match_count
                    if card.id + j > no_copies_card_count
                        break
                    end
                    card_count[card.id+j] += 1
                end
            end
        end
    end
    return card_count
end

end # module
