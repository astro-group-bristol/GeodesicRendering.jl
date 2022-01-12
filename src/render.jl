function __rendergeodesics(
    m::AbstractMetricParams{T},
    init_pos;
    image_width,
    image_height,
    fov_factor,
    kwargs...,
) where {T}
    image = zeros(T, (image_height, image_width))
    y_mid = image_height ÷ 2
    x_mid = image_width ÷ 2

    # have to use a slight 0.01 offset to avoid integrating α=0.0 geodesics
    for Y = 1:image_height
        β = (Y - y_mid) / fov_factor
        α_generator_row = ((X + 0.001 - x_mid) / fov_factor for X = 1:image_width)
        vs = generate_velocity_row(m, init_pos, α_generator_row, β)
        us = fill(init_pos, size(vs))
        render_into!(@view(image[Y, :]), m, us, vs; kwargs...)
    end

    image
end

function render_into!(
    loc,
    m::AbstractMetricParams{T},
    u,
    v;
    max_time,
    vf,
    solver_opts...,
) where {T}
    simsols = tracegeodesics(m, u, v, (T(0.0), max_time); save_on = false, solver_opts...)
    @threads for i = 1:length(simsols)
        loc[i] = vf(m, simsols[i], max_time)
    end
end