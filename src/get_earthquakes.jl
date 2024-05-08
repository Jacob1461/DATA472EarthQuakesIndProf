include("emsc/get_emsc_data.jl")
include("geonet/get_geonet_quakes.jl")
include("usgs/get_usgc_quakes.jl")
include("assign_earthquake_ID.jl")

function get_quakes()
    geonet_quakes = get_geonet_quakes(3,7)
    usgs_quakes = get_usgs_quakes()
    emsc_quakes = get_emsc_quakes()

    combintation_frame_no_ID = vcat(geonet_quakes, usgs_quakes, emsc_quakes)
    combintation_frame_ID = assign_earthquakeID(combintation_frame_no_ID)
    return combintation_frame_ID

end
println(get_quakes())

