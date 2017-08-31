#Cahokia HTTP API

The backend server, `/cahokia/...` takes requests in the form of simple HTTP
GET requests, with the information in the URL.
Information is returned in JSON. All requests will to `/cahokia/` will return
the following information:

    - `valid_request` : `boolean`
        - True if the request URL is valid.
        - If false, the response code of the request will also be 400
"Bad Request".
    - `system_error` : `boolean`
        - True if there is a obvious error (from the server's perspective)
that will prevent the WotUS pipeline from functioning.
        - This is a fixed check that occurs when a request is made. This means
it might not catch unexpected errors that may occur in the WotUS Pipeline.
    - `system_ready` : `boolean`
        - True if the WotUS pipline and queue is ready to accpect generation
requests. It is only ready after the initialization script has finished, after
which the accumulation data can be used to generate maps for certain Q Values.

## `/cahokia/status`
Will return the following values in addition to the default information,
assuming the system is ready:
    - `boundries` : `[[float, float], [float, float]]`
        - Two points of the boundries of the DEM, adjusted to avoid errors
that occur of the edge of the accumulation data. This will be passed to
Leaflet to hide the edges from the user.
    - `static_maps` : `[string, ...]`
        - Names of static_maps to be made available to the user.
    - `queue_size` : `int`
        - Size of the queue for Q values to be worked on by pipeline.

## `/cahokia/wotus/{Q_VALUE}`
Return status of a particular Q value in the system.
`{Q_VALUE}` must be replaced with the desired Q Value that must be a
valid non zero integer.
    - `generated` : `boolean`
        - True if already generated.
        - Response code is 200 "OK" if true.
    - `queued` : `boolean`
        - True if the value is the the queue/being generated.
    - Response code is 202 "Accepted" if the value hasn't been generated
and is not in the queue. Also `generated` and `queued` will both be false.
    
