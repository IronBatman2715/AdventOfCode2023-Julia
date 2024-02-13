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
    camel_card_hands = parse_input(input, part_2)
    return sum([camel_card_hand.bid * rank for (rank, camel_card_hand) in enumerate(camel_card_hands)])
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
CARD_TYPES_PART_2::Vector{Char} = ['J', '2', '3', '4', '5', '6', '7', '8', '9', 'T', 'Q', 'K', 'A']
struct Hand
    str::String
    values::Vector{Int}
    type::HandType
end

struct CamelCardHand
    hand::Hand
    bid::Int
end

function parse_input(input::String, part_2::Bool)::Vector{CamelCardHand}
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

        hand = Hand(hand_str, card_str_to_values(hand_str, part_2), get_hand_type(hand_str, part_2))

        push!(camel_card_hands, CamelCardHand(hand, bid))
    end
    sort_camel_card_hands!(camel_card_hands)

    return camel_card_hands
end

function get_hand_type(hand_str::String, part_2::Bool)::HandType
    chars = collect(hand_str)
    if part_2
        card_counts = [count(c -> c == (card_type), chars) for card_type in CARD_TYPES_PART_2]
        joker_count = card_counts[1]
        non_joker_card_counts = card_counts[2:end]
        highest_non_joker_card_count = maximum(non_joker_card_counts)

        highest_jokered_card_count = highest_non_joker_card_count + joker_count
        if highest_jokered_card_count == 5
            return five_of_a_kind::HandType
        elseif highest_jokered_card_count == 4
            return four_of_a_kind::HandType
        end

        non_joker_pair_count = count(c -> c == 2, non_joker_card_counts)
        if (highest_non_joker_card_count == 3 && (non_joker_pair_count == 1)) || ((non_joker_pair_count == 2) && (joker_count == 1))
            return full_house::HandType
        elseif highest_jokered_card_count == 3
            return three_of_a_kind::HandType
        elseif non_joker_pair_count == 2 || ((non_joker_pair_count == 1) && (joker_count == 1))
            return two_pair::HandType
        elseif highest_non_joker_card_count == 2 || highest_non_joker_card_count == 1 && joker_count == 1
            return one_pair::HandType
        else
            return high_card::HandType
        end
    else
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
end

function card_str_to_values(hand_str::String, part_2::Bool)::Vector{Int}
    chars = part_2 ? CARD_TYPES_PART_2 : CARD_TYPES
    return [findfirst(x -> x == char, chars) for char in collect(hand_str)]
end

"Sort by Hand.type first, then by Hand.values"
function sort_camel_card_hands!(camel_card_hands::Vector{CamelCardHand})
    sort!(camel_card_hands, by=camel_card_hand -> (camel_card_hand.hand.type, camel_card_hand.hand.values))
end

end # module
