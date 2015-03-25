class d3Object

    constructor: (id) ->
        @element = d3.select "##{id}"
        @element.selectAll("svg").remove()
        @obj = @element.append "svg"
        @initAxes()

    append: (obj) -> @obj.append obj
    
    initAxes: ->

        
class Fig

    @margin = {top: 50, right: 50, bottom: 50, left: 50}
    @width = 612 - @margin.left - @margin.right
    @height = 612 - @margin.top - @margin.bottom

    # x <-> pixels
    @x2X = d3.scale.linear()
        .domain([0, 1])
        .range([0, @width])
    @X2x = @x2X.invert

    # y <-> pixels
    @y2Y = d3.scale.linear()
        .domain([0, 1])
        .range([@height, 0])
    @Y2y = @y2Y.invert

class Plot extends d3Object

    w = Fig.width
    W = Fig.width + Fig.margin.left + Fig.margin.right
    h = Fig.height
    H = Fig.height + Fig.margin.top + Fig.margin.bottom
    
    constructor: ->
        
        super "plot"

        @obj.attr('width', W).attr('height', H)

        @plot = @obj.append('g')
            .attr("transform", "translate( #{Fig.margin.left}, #{Fig.margin.top})")
            .attr('width', w)
            .attr('height', h)

        @plot.append("g")
            .attr("id","x-axis")
            .attr("class", "x axis")
            .attr("transform", "translate(0, #{h})")
            .call(@xAxis)

        @plot.append("g")
            .attr("id","y-axis")
            .attr("class", "y axis")
            .attr("transform", "translate(0, 0)")
            .call(@yAxis)

        ###

        @plot.selectAll("line.horizontalGrid")
            .data(Fig.T2px.ticks(4))
            .enter()
            .append("line")
            .attr("class", "horizontalGrid")
            .attr("x1", 0)
            .attr("x2", w)
            .attr("y1", (d) -> Fig.T2px d)
            .attr("y2", (d) -> Fig.T2px d)
            .attr("fill", "none")
            .attr("shape-rendering", "auto")
            .attr("stroke", "grey")
            .attr("stroke-width", "1px")
            .attr("opacity", 0.2)

        @plot.selectAll("line.verticalGrid")
            .data(Fig.d2px.ticks(4))
            .enter()
            .append("line")
            .attr("class", "verticalGrid")
            .attr("y1", 0)
            .attr("y2", h)
            .attr("x1", (d) -> Fig.d2px d)
            .attr("x2", (d) -> Fig.d2px d)
            .attr("fill", "none")
            .attr("shape-rendering", "auto")
            .attr("stroke", "grey")
            .attr("stroke-width", "1px")
            .attr("opacity", 0.2)

        @plot.append("text")
            .attr("class", "y label")
            .attr("text-anchor", "end")
            .attr("dy", -60)
            .attr("dx", -90)
            .attr("transform", "rotate(-90)")
            .text("Temperature (deg. K)")

        @plot.append("text")
            .attr("class", "x label")
            .attr("text-anchor", "end")
            .attr("dy", h+50)
            .attr("dx", 220)
            .text("Depth (m)")

        ###

    update: (data) ->

        circle = @plot.selectAll("circle.marker")
            .data(data)

        circle.exit().remove()

        circle
            .enter()
            .append("circle")
            .attr("class", "marker")
            .attr("r", "5")
            .attr("fill", "none")
            .attr("shape-rendering", "crispEdges")
            .attr("stroke", "black")
            .attr("stroke-width", "1px")

        circle
            .attr("cx", (d) -> Fig.x2X d[0])
            .attr("cy", (d) -> Fig.y2Y d[1])

    initAxes: ->

        @xAxis = d3.svg.axis()
            .scale(Fig.x2X)
            .orient("bottom")
            .ticks(6)

        @yAxis = d3.svg.axis()
            .scale(Fig.y2Y)
            .orient("left")

class Guide extends d3Object

    r = 10 # circle radius
    
    constructor: ()->
        
        super "guide"

        # housekeeping
        @obj.on("click", null)  # Clear any previous event handlers.
        d3.behavior.drag().on("drag", null)  # Clear any previous event handlers.

        @obj.attr('width', W)
            .attr('height', H)

        @region = @obj.append('g')
            .attr("transform", "translate( #{Fig.margin.left}, #{Fig.margin.top})")
            .attr('width', w)
            .attr('height', h)

        x1 = 1.5
        x2 = 4
        y1 = 220
        y2 = 228

        @m1 = @marker()
            .attr("cx", Fig.x2X x1)
            .attr("cy", Fig.y2Y y1)

        @m2 = @marker()
            .attr("cx", Fig.x2X x2)
            .attr("cy", Fig.y2Y y2)

        @line = @region.append("line")
            .attr("x1", @m1.attr("cx"))
            .attr("y1", @m1.attr("cy"))
            .attr("x2", @m2.attr("cx"))
            .attr("y2", @m2.attr("cy"))
            .attr("class", "modelline")

        slope = (y2-y1)/(x2-x1)
        inter = y1-slope*x1
        d3.select("#equation").html(model_text([inter, slope]))

    initAxes: ->

    marker: () ->

        m = @region.append('circle')
            .attr('r', r)
            .attr("class", "modelcircle")
            .call(
                d3.behavior
                .drag()
                .origin(=>
                    x:m.attr("cx")
                    y:m.attr("cy")
                )
                .on("drag", => @dragMarker(m, d3.event.x, d3.event.y))
            )
        
    dragMarker: (marker, x, y) ->

        x=0 if x<0
        x=w if x>w
        y=0 if y<0
        y=h if y>h

        marker.attr("cx", x)
        marker.attr("cy", y)

        X1 = @m1.attr("cx")
        Y1 = @m1.attr("cy")
        X2 = @m2.attr("cx")
        Y2 = @m2.attr("cy")
                
        @line.attr("x1", X1)
            .attr("y1", Y1)
            .attr("x2", X2)
            .attr("y2", Y2)

        y1 = Fig.Y2y Y1
        y2 = Fig.Y2y Y2
        x1 = Fig.X2x X1
        x2 = Fig.X2x X2

        slope = (y2-y1)/(x2-x1)
        inter = y1-slope*x1
        d3.select("#equation").html(model_text([inter, slope]))

    model_text = (p) ->
        """
        <table class='func'>
        <tr><td>Model: a =<td/><td>#{p[1].toFixed(2)} deg.K/m,<td/><td>b =<td/><td>#{p[0].toFixed(2)} deg.K<td/><tr/>
        </table>
        """

new Plot
