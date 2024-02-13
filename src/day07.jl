module Day07

using AdventOfCode2023

"""
Load inputs and solve the [Day 7](https://adventofcode.com/2023/day/7) puzzle.
"""
function run()::Tuple{Int,Int}
    input = AdventOfCode2023.data[7]
    return solve(input), solve(input, true)
end

function solve(input::String, part_2=false)::Int
    if part_2
        return 1
    else
        camel_card_hands = parse_input(input)
        return sum([camel_card_hand.bid * rank for (rank, camel_card_hand) in enumerate(camel_card_hands)])
    end
end

@enum HandType begin
    high_card
    one_pair
    two_pair
    three_of_a_kind
    full_house
    four_of_a_kind
    five_of_a_kind
end

CARD_TYPES::Vector{Char} = ['2', '3', '4', '5', '6', '7', '8', '9', 'T', 'J', 'Q', 'K', 'A']
struct Hand
    str::String
    values::Vector{Int}
    type::HandType
end

struct CamelCardHand
    hand::Hand
    bid::Int
end

function parse_input(input::String)::Vector{CamelCardHand}
    lines = split(strip(input), '\n')
    line_quantity = length(lines)
    if line_quantity < 1
        error("Couldn't parse any values")
    end

    camel_card_hands::Vector{CamelCardHand} = []
    for line in lines
        str_vec = split(strip(line), ' ')
        if length(str_vec) != 2
            error("Couldn't parse line value")
        end

        hand_str::String = strip(str_vec[1])
        bid = parse(Int, strip(str_vec[2]))

        hand = Hand(hand_str, card_str_to_values(hand_str), get_hand_type(hand_str))

        push!(camel_card_hands, CamelCardHand(hand, bid))
    end
    # println(camel_card_hands)
    # println()
    sort_camel_card_hands!(camel_card_hands)
    # println(camel_card_hands)

    return camel_card_hands
end

function get_hand_type(hand_str::String)::HandType
    chars = collect(hand_str)
    card_counts = [count(c -> c == (card_type), chars) for card_type in CARD_TYPES]
    highest_card_count = maximum(card_counts)

    if highest_card_count == 5
        return five_of_a_kind::HandType
    elseif highest_card_count == 4
        return four_of_a_kind::HandType
    elseif highest_card_count == 3
        if any(c -> c == 2, card_counts)
            return full_house::HandType
        end
        return three_of_a_kind::HandType
    elseif count(c -> c == 2, card_counts) == 2
        return two_pair::HandType
    elseif highest_card_count == 2
        return one_pair::HandType
    else
        return high_card::HandType
    end
end

function card_str_to_values(hand_str::String)::Vector{Int}
    return [findfirst(x -> x == char, CARD_TYPES) for char in collect(hand_str)]
end

"Sort by Hand.type first, then by Hand.values"
function sort_camel_card_hands!(camel_card_hands::Vector{CamelCardHand})
    sort!(camel_card_hands, by=camel_card_hand -> (camel_card_hand.hand.type, camel_card_hand.hand.values))
end

end # module
