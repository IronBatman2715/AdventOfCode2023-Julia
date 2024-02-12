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
