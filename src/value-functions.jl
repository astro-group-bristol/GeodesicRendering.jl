abstract type AbstractValueFunction end

struct ValueFunction{F} <: AbstractValueFunction
    f::F
end

struct FilterValueFunction{F,T} <: AbstractValueFunction
    f::F
    default::T
end

@inline function (vf::AbstractValueFunction)(
    m::AbstractMetricParams{T},
    sol,
    max_time;
    kwargs...,
)::T where {T}
    convert(T, vf.f(m, sol, max_time; kwargs...))
end

@inline function apply(
    vf::AbstractValueFunction,
    rc::RenderCache{M,T,G};
    kwargs...,
) where {M,T,G}
    map(sol -> vf.f(rc.m, sol, rc.max_time; kwargs...), rc.geodesics)
end

@inline function Base.:∘(
    vf1::AbstractValueFunction,
    vf2::AbstractValueFunction,
) where {F1,F2}
    ValueFunction(
        (m, sol, max_time; kwargs...) -> vf1.f(vf2.f(m, sol, max_time; kwargs...)),
    )
end

@inline function Base.:∘(vf1::AbstractValueFunction, vf2::FilterValueFunction{F}) where {F}
    ValueFunction(
        (m, sol, max_time; kwargs...) -> begin
            pass_on = vf2.f(m, sol, max_time; kwargs...)
            if pass_on
                vf1.f(m, sol, max_time; kwargs...)
            else
                vf2.default
            end
        end,
    )
end

module ConstValueFunctions
import ..GeodesicRendering: ValueFunction, FilterValueFunction

const filter_early_term =
    FilterValueFunction((m, sol, max_time; kwargs...) -> sol.t[end] < max_time, NaN)

const filter_intersected =
    FilterValueFunction((m, sol, max_time; kwargs...) -> sol.retcode == :Intersected, NaN)

const affine_time = ValueFunction((m, sol, max_time; kwargs...) -> sol.t[end])

const last_u = ValueFunction((m, sol, max_time; kwargs...) -> u)

const shadow = affine_time ∘ filter_early_term
end # module

export ValueFunction, FilterValueFunction, ConstValueFunctions
