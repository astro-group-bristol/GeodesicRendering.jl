function generate_velocity_row(m::AbstractMetricParams{T}, init_pos, α_generator, β) where {T}
    [map_impact_parameters(m, init_pos, α, β) for α in α_generator]
end
