module GeodesicRendering

import Base.Threads: @threads

using GeodesicBase
using GeodesicTracer

include("utility.jl")
include("value-functions.jl")
include("render.jl")

function rendergeodesics(
    m::AbstractMetricParams{T},
    init_pos,
    max_time::T;
    vf = ConstValueFunctions.shadow,
    kwargs...,
) where {T}
    __rendergeodesics(
        m,
        init_pos;
        image_width = 350,
        image_height = 250,
        fov_factor = 3.0,
        max_time = max_time,
        vf = vf,
        kwargs...,
    )
end


export rendergeodesics

end # module
