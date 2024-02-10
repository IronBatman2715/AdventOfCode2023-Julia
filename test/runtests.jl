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
    @test part_2 == 1
end
