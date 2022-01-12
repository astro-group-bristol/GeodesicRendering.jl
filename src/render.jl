function __rendergeodesics(
    m::AbstractMetricParams{T},
    init_pos;
    image_width,
    image_height,
    fov_factor,
    kwargs...,
)
    image = zeros(Float64, (img_height, img_width))
    y_mid = img_height ÷ 2
    x_mid = img_width ÷ 2

    # have to use a slight 0.01 offset to avoid integrating α=0.0 geodesics
    δα = ((0.001 - x_mid) / fov_factor) / image_width
    δβ = ((-y_mid) / fov_factor) / image_height

    for Y = 1:img_height
        β = δβ * Y - y_mid
        α_generator_row = (δα * X - x_mid for X in 1:image_width)
        vs = generate_row_arrays(m, init_pos, α_generator_row, β)
        us = fill(init_pos, size(vs))

        render_into!(@view(image[Y, :]), m, us, vs; kwargs...)
    end

    image
end

function render_into!(loc, m::AbstractMetricParams{T}, u, v; max_time, vf, solver_opts...)
    simsols = tracegeodesics(m, u, v, (0.0, max_time); save_on=false, solver_opts...)
    Threads.@threads for (i, s) in enumerate(simsols)
        loc[i] = s.t[end]
    end
end
