module GeonetEarthQuakesApiModule
export get_geonet_quakes
using Pkg
Pkg.add("HTTP")
Pkg.add("JSON")
Pkg.add("DataFrames")

using HTTP
using JSON
using DataFrames

using Dates
using JSON
using DataFrames
############################

struct GeoEarthquakeEvent
    publicID::String
    time::DateTime
    depth::Float64
    magnitude::Float64
    mmi::Int
    locality::String
    quality::String
    coordinates::Tuple{Float64, Float64}
end


function create_event(event::Dict{String, Any}) #GPT was used to help fix this function
    properties = event["properties"]
    geometry = event["geometry"]
    coordinates = geometry["coordinates"]

    publicID = properties["publicID"]
    time = DateTime(properties["time"], dateformat"yyyy-mm-ddTHH:MM:SS.sssZ") 

    depth = properties["depth"]
    magnitude = properties["magnitude"]
    mmi = properties["mmi"]
    locality = properties["locality"]
    quality = properties["quality"]
    coordinates = tuple(Float64(coordinates[1]), Float64(coordinates[2])) 

    #println([time, depth, magnitude, mmi, locality, quality, coordinates]) 

    return GeoEarthquakeEvent(publicID, time, depth, magnitude, mmi, locality, quality, coordinates)
end

function query_geonet(link::String)
    response = HTTP.request("GET", link)

    json_data = JSON.parse(String(response.body))
    events = json_data["features"]

    earthquake_events = GeoEarthquakeEvent[]

    for event in events
        if earthquake_events !== nothing
            push!(earthquake_events, create_event(event))
        else
            println("Skipped an entry because it was nothing")
        end
    end


    df = DataFrame(publicID = [event.publicID for event in earthquake_events],
                time = [event.time for event in earthquake_events],
                depth = [event.depth for event in earthquake_events],
                magnitude = [event.magnitude for event in earthquake_events],
                mmi = [event.mmi for event in earthquake_events],
                locality = [event.locality for event in earthquake_events],
                quality = [event.quality for event in earthquake_events],
                coordinates = [event.coordinates for event in earthquake_events])
    return df
end


function get_geonet_quakes(mmi_lower::Int, mmi_upper::Int)
    @assert -1 <= mmi_lower <= 8 "MMI values are between -1 and 8 inc"
    @assert -1 <= mmi_upper <= 8 "MMI values are between -1 and 8 inc"
    @assert mmi_lower <= mmi_upper "MMI Lower must be lower than or equal to MMI Upper"
    geonet_base_url = "https://api.geonet.org.nz/quake?MMI="
    earthquakes = DataFrame()
    for mmi_level in mmi_lower:mmi_upper
        #println("Getting the earthquakes of MMI: " * string(mmi_level))
        specific_api_url = geonet_base_url * string(mmi_level)
        #println(specific_api_url)
        earth_quakes_specific_mmi = query_geonet(specific_api_url)
        append!(earthquakes, earth_quakes_specific_mmi)
    end
    new_column = ["New Zealand" for _ in 1:nrow(earthquakes)]
    insertcols!(earthquakes, 2, :country => new_column)
    #println(earthquakes)
    return earthquakes
end




end
#eqs = get_geonet_quakes(3,6)
#println(eqs)

