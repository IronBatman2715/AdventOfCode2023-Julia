using AdventOfCode2023
using Test

@testset "Day 1" begin
    part_1, part_2 = AdventOfCode2023.Day01.run()
    @test part_1 == 54388
    @test part_2 == 53515
end

@testset "Day 2" begin
    part_1, part_2 = AdventOfCode2023.Day02.run()
    @test part_1 == 2505
    @test part_2 == 70265
end

@testset "Day 3" begin
    part_1, part_2 = AdventOfCode2023.Day03.run()
    @test part_1 == 512794
    @test part_2 == 67779080
end

@testset "Day 4" begin
    part_1, part_2 = AdventOfCode2023.Day04.run()
    @test part_1 == 23750
    @test part_2 == 13261850
end

@testset "Day 5" begin
    part_1, part_2 = AdventOfCode2023.Day05.run()
    @test part_1 == 510109797
    @test part_2 == 9622622
end

@testset "Day 6" begin
    part_1, part_2 = AdventOfCode2023.Day06.run()
    @test part_1 == 252000
    @test part_2 == 36992486
end

@testset "Day 7" begin
    part_1, part_2 = AdventOfCode2023.Day07.run()
    @test part_1 == 248105065
    @test part_2 == 249515436
end

@testset "Day 8" begin
    part_1, part_2 = AdventOfCode2023.Day08.run()
    @test part_1 == 15871
    @test part_2 == 11283670395017
end

@testset "Day 9" begin
    part_1, part_2 = AdventOfCode2023.Day09.run()
    @test part_1 == 1762065988
    @test part_2 == 1066
end

@testset "Day 10" begin
    part_1, part_2 = AdventOfCode2023.Day10.run()
    @test part_1 == 6701
    @test part_2 == 303
end

@testset "Day 11" begin
    part_1, part_2 = AdventOfCode2023.Day11.run()
    @test part_1 == 9274989
    @test part_2 == 357134560737
end

@testset "Day 12" begin
    part_1, part_2 = AdventOfCode2023.Day12.run()
    @test part_1 == 6827
    @test part_2 == 1
end
