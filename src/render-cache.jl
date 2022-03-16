abstract type AbstractRenderCache{M,T,G} end


struct RenderCache{M,T,G} <: AbstractRenderCache{M,T,G}
    # metric
    m::M

    # max time
    max_time::T

    # size information
    height::Int
    width::Int

    # geodesics themselves in 2d array
    geodesics::AbstractArray{G, 2}

    function RenderCache(
        m::AbstractMetricParams{T}, 
        max_time::T,
        height, 
        width,
        cache::AbstractVector{SciMLBase.EnsembleSolution{T, N, Vector{O}}}, 
        ) where {T, N, O}

        geodesics = Matrix{O}(undef, (height, width))
        
        # populate store
        for (col, simsol) in enumerate(cache)
            for (row, sol) in enumerate(simsol)
                geodesics[col, row] = sol
            end
        end

        # return instance 
        new{typeof(m),T,O}(m, max_time, height, width, geodesics)
    end

end

function Base.show(io::IO, rc::RenderCache{M, G}) where {M, G}
    repr = "RenderCache{$M} (dimensions $(rc.height)x$(rc.width))"
    write(io, repr)
end


