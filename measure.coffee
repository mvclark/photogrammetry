
class d3Object

    constructor: (id) ->
        @element = d3.select "##{id}"
        @element.selectAll("svg").remove()
        @obj = @element.append "svg"
        @initAxes()

    append: (obj) -> @obj.append obj
    
    initAxes: ->

        
class $blab.Plot extends d3Object
  
    constructor: (@w, @h) ->
        
        super "plot"
        
        @obj.attr('width', @w).attr('height', @h)
        
        @plot = @obj.append('g')
            .attr("transform", "translate( #{0}, #{0})")
            .attr('width', @w)
            .attr('height', @h)
            
        @plot.append("g")
            .attr("id","x-axis")
            .attr("class", "x axis")
            .attr("transform", "translate(0, #{@h})")
            .call(@xAxis)
            
        @plot.append("g")
            .attr("id","y-axis")
            .attr("class", "y axis")
            .attr("transform", "translate(0, 0)")
            .call(@yAxis)
            
        @plot.selectAll("line.horizontalGrid")
            .data(@y2Y.ticks(9))
            .enter()
            .append("line")
            .attr("class", "horizontalGrid")
            .attr("x1", 0)
            .attr("x2", @w)
            .attr("y1", (d) => @y2Y d)
            .attr("y2", (d) => @y2Y d)
            
        @plot.selectAll("line.verticalGrid")
            .data(@x2X.ticks(9))
            .enter()
            .append("line")
            .attr("class", "verticalGrid")
            .attr("y1", 0)
            .attr("y2", @h)
            .attr("x1", (d) => @x2X d)
            .attr("x2", (d) => @x2X d)
            
        @plot.append("text")
            .attr("class", "y label")
            .attr("text-anchor", "end")
            .attr("dy", -60)
            .attr("dx", -90)
            .attr("transform", "rotate(-90)")
            .text("Intensity")
            
        @plot.append("text")
            .attr("class", "x label")
            .attr("text-anchor", "end")
            .attr("dy", @h+50)
            .attr("dx", 220)
            .text("Distance (?)")
            
        @line = d3.svg.line()
            .x((d) => @x2X d.interval)
            .y((d) =>  @y2Y d.intensity)
            
    update: (data) ->
        console.log "update!!!"
        @plotLine = (u) =>
            @plot.append("path")
                .attr("class", "line")
                .attr("d", @line data[u])
                .attr("stroke-width", 2)
                .attr("stroke", u)
                
        @plot.selectAll("path").remove()
        ["red", "blue", "green"].forEach(@plotLine)
        
    initAxes: ->
        
        # x <-> pixels
        @x2X = d3.scale.linear()
            .domain([0, 1])
            .range([0, @w])
        @X2x = @x2X.invert
        
        # y <-> pixels
        @y2Y = d3.scale.linear()
            .domain([0, 1])
            .range([@h, 0])
        @Y2y = @y2Y.invert
        
        @xAxis = d3.svg.axis()
            .scale(@x2X)
            .orient("bottom")
            .ticks(6)
            
        @yAxis = d3.svg.axis()
            .scale(@y2Y)
            .orient("left")


class $blab.Guide extends d3Object

    r: 10 # circle radius
    tId: null
    
    constructor: (@w, @h)->

        super "guide"

        # housekeeping
        @obj.on("click", null)  # Clear any previous event handlers.
        d3.behavior.drag().on("drag", null)  # Clear any previous event handlers.

        @obj.attr('width', @w).attr('height', @h)

        @region = @obj.append('g')
            .attr("transform", "translate( #{0}, #{0})")
            .attr('width', @w)
            .attr('height', @h)

        @region.append("g")
            .attr("id","x-axis")
            .attr("class", "x axis")
            .attr("transform", "translate(0, #{@h})")
            .call(@xAxis)

        @region.append("g")
            .attr("id","y-axis")
            .attr("class", "y axis")
            .attr("transform", "translate(0, 0)")
            .call(@yAxis)

        @region.append("text")
            .attr("class", "y label")
            .attr("text-anchor", "end")
            .attr("dy", -60)
            .attr("dx", -90)
            .attr("transform", "rotate(-90)")
            .text("ylabel")

        @region.append("text")
            .attr("class", "x label")
            .attr("text-anchor", "end")
            .attr("dy", @h+50)
            .attr("dx", 220)
            .text("xlabel")

        @region.selectAll("line.horizontalGrid")
            .data(@y2Y.ticks(9))
            .enter()
            .append("line")
            .attr("class", "horizontalGrid")
            .attr("x1", 0)
            .attr("x2", @w)
            .attr("y1", (d) => @y2Y d)
            .attr("y2", (d) => @y2Y d)
            .attr("fill", "none")
            .attr("shape-rendering", "auto")
            .attr("stroke", "grey")
            .attr("stroke-width", "1px")
            .attr("opacity", 0.4)

        @region.selectAll("line.verticalGrid")
            .data(@x2X.ticks(9))
            .enter()
            .append("line")
            .attr("class", "verticalGrid")
            .attr("y1", 0)
            .attr("y2", @h)
            .attr("x1", (d) => @x2X d)
            .attr("x2", (d) => @x2X d)
            .attr("fill", "none")
            .attr("shape-rendering", "auto")
            .attr("stroke", "grey")
            .attr("stroke-width", "1px")
            .attr("opacity", 0.2)

        x1 = 0.05
        x2 = 0.95
        y1 = 0.05
        y2 = 0.95

        @m1 = @marker()
            .attr("cx", @x2X x1)
            .attr("cy", @y2Y y1)

        @m2 = @marker()
            .attr("cx", @x2X x2)
            .attr("cy", @y2Y y2)

        @line = @region.append("line")
            .attr("x1", @m1.attr("cx"))
            .attr("y1", @m1.attr("cy"))
            .attr("x2", @m2.attr("cx"))
            .attr("y2", @m2.attr("cy"))
            .attr("class", "modelline")

        #slope = (y2-y1)/(x2-x1)
        #inter = y1-slope*x1
        #d3.select("#equation").html(model_text([inter, slope]))

    initAxes: ->

        # x <-> pixels
        @x2X = d3.scale.linear()
            .domain([0, 1])
            .range([0, @w])
        @X2x = @x2X.invert

        # y <-> pixels
        @y2Y = d3.scale.linear()
            .domain([0, 1])
            .range([@h, 0])
        @Y2y = @y2Y.invert
        
        
        @xAxis = d3.svg.axis()
            .scale(@x2X)
            .orient("bottom")
            .ticks(6)

        @yAxis = d3.svg.axis()
            .scale(@y2Y)
            .orient("left")
        
    marker: () ->
        m = @region.append('circle')
            .attr('r', @r)
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
        x=@w if x>@w
        y=0 if y<0
        y=@h if y>@h

        marker.attr("cx", x)
        marker.attr("cy", y)
        
        X1 = +@m1.attr("cx")
        Y1 = +@m1.attr("cy")
        X2 = +@m2.attr("cx")
        Y2 = +@m2.attr("cy")

        @line.attr("x1", X1)
            .attr("y1", Y1)
            .attr("x2", X2)
            .attr("y2", Y2)
        
        y1 = @Y2y Y1
        y2 = @Y2y Y2
        x1 = @X2x X1
        x2 = @X2x X2
        
        #slope = (y2-y1)/(x2-x1)
        #inter = y1-slope*x1
        #d3.select("#equation").html(model_text([inter, slope]))
        
            
        if @tId
            clearTimeout @tId
            @tId = null
            
        @tId = setTimeout (=>
            
            r = [0..100]/100
            Xq = (Math.round u for u in (X1 + (X2-X1)*r))
            Yq = (Math.round u for u in (Y1 + (Y2-Y1)*r))

            intensity = (clr, idx) ->
                $blab.image.mouseData({x:Xq[idx], y:Yq[idx]}).color[clr]/255

            color = (u) ->
                 ({interval:r[i], intensity:intensity(u, i)} for i in [0...r.length])
            
            data =
                red: color("r")
                blue: color("b")
                green: color("g")
            $blab.plot.update(data)
        ), 50
        



    model_text = (p) ->
        """
        <table class='func'>
        <tr><td>Model: a =<td/><td>#{p[1].toFixed(2)} deg.K/m,<td/><td>b =<td/><td>#{p[0].toFixed(2)} deg.K<td/><tr>
        </table>
        """
