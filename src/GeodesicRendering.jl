module GeodesicRendering

import Base.Threads: @threads

using GeodesicBase
using GeodesicTracer

function rendergeodesics(m::AbstractMetricParams{T}, init_pos; kwargs...) where {T}
    __rendergeodesics(
        m,
        init_pos;
        image_width = 300,
        image_height = 180,
        fov_factor = 3.0,
        max_time = 1000.0,
        vf = nothing,
        kwargs...,
    )
end


export rendergeodesics

end # module
