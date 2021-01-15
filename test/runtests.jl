using Test
using StatTraits
using ScientificTypes
import SparseArrays

module Fruit

struct Apple end

end

import .Fruit


## HELPERS

@testset "typename" begin
    @test StatTraits.typename(Nothing) == :Nothing
    @test StatTraits.typename(UnionAll) == :UnionAll
    @test StatTraits.typename(Union{Char,Int}) == Symbol("Union{Char, Int64}")
    T = SparseArrays.sparse([1,2], [1,3], [0.5, 0.6]) |> typeof
    @test StatTraits.typename(T) == :SparseMatrixCSC
end


## TRAITS WITH NON-CONSTANT FALL-BACK

struct Foo
    x::Int
    y::Char
end

@testset "docstring" begin
    @test docstring(Foo(1,'x')) == "Foo"
    @test docstring(Fruit.Apple()) == "Main.Fruit.Apple"
end

@testset "hyperparameter_ranges" begin
    @test hyperparameter_ranges(Foo(1, 'x')) == (nothing, nothing)
    @test hyperparameter_ranges(Fruit.Apple()) == ()
end

@testset "name" begin
    @test name(Float64) == "Float64"
    @test name(Fruit.Apple) == "Apple"
    @test name(Fruit.Apple()) == "Apple"
end

@testset "hyperparameters" begin
    @test hyperparameters(Foo(1, 'x')) == (:x, :y)
    @test hyperparameters(Fruit.Apple()) == ()
end

@testset "hyperparameter_types" begin
    @test hyperparameter_types(Foo(1, 'x')) == ("Int64", "Char")
    @test hyperparameter_types(Fruit.Apple()) == ()
end


## TRAITS WITH CONSTANT FALL-BACK

const NONCONSTANT = [:docstring,
                     :hyperparameter_ranges,
                     :name,
                     :hyperparameters,
                     :hyperparameter_types]

@testset "traits with constant fall-back" begin
    for trait in setdiff(StatTraits.TRAITS, NONCONSTANT)
        ex = quote
            @test $trait(Fruit.Apple()) == $trait(Foo(1, 'x'))
        end
        Main.eval(ex)
    end
end
