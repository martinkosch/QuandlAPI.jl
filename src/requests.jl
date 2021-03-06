function raw_get(id::AbstractString;
    format::Symbol=:json,
    start_date::AbstractString="",
    end_date::AbstractString="",
    rows::AbstractString="",
    column::AbstractString="",
    order::AbstractString="",
    collapse::AbstractString="",
    transformation::AbstractString="",
    api_key::AbstractString="",
    )

    if format ∉ [:json, :xml, :csv]
        error("Format $(format) is not supported.")
    end

    query_dict = Dict(
        "start_date" => start_date,
        "end_date" => end_date,
        "rows" => rows,
        "column" => column,
        "order" => order,
        "collapse" => collapse,
        "transformation" => transformation,
        "api_key" => api_key)

    base_url = "https://www.quandl.com/api/v3/datasets/"
    url = merge(HTTP.URI(base_url * id * "." * string(format)); query=query_dict)
    res = HTTP.request("GET", url)

    return String(res.body)
end

function get_json(id::AbstractString;
    start_date::AbstractString="",
    end_date::AbstractString="",
    rows::AbstractString="",
    column::AbstractString="",
    order::AbstractString="",
    collapse::AbstractString="",
    transformation::AbstractString="",
    api_key::AbstractString="",
    )

    json = raw_get(id;
        format=:json,
        start_date,
        end_date,
        rows,
        column,
        order,
        collapse,
        transformation,
        api_key,
        )

    return JSON.parse(json)
end

function get_timearray(id::AbstractString;
    start_date::AbstractString="",
    end_date::AbstractString="",
    rows::AbstractString="",
    column::AbstractString="",
    order::AbstractString="",
    collapse::AbstractString="",
    transformation::AbstractString="",
    api_key::AbstractString="",
    )
    json = get_json(id;
        start_date,
        end_date,
        rows,
        column,
        order,
        collapse,
        transformation,
        api_key,
        )

    timestamps = Date.(hcat(json["dataset"]["data"]...)[1,:])
    data = hcat(json["dataset"]["data"]...)[2,:]
    colnames = Symbol.(json["dataset"]["column_names"][2:end])

    meta = json["dataset"]
    delete!(meta, "data")
    delete!(meta, "column_names")

    return TimeArray(timestamps, data, colnames, meta)
end
