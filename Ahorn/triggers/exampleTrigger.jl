module ExampleTrigger
using ..Ahorn, Maple

#=
Minimum valid declaration.
This defines a type `Example` with a constructor that takes in `x` and `y` parameters,
which then creates a unique `Trigger` with the name `"ExampleMod/ExampleTrigger"` 
and a Dict containing the keys `x` and `y` set to the values passed to the `Example` constructor.

Technically, you can use only x and y but the width and height declarations are required for use cases where you need the width or height, by default it will be set to the value 16
=#
@mapdef Trigger "ExampleMod/ExampleTrigger" Example(x::Integer, y::Integer)
#= equivalent to: 
    @pardef Example(x::Number, y::Number) = Trigger("ExampleMod/ExampleTrigger", x=x, y=y)
=#
#= evaluates to:
    const Example = Trigger{Symbol("ExampleMod/ExampleTrigger")}
    Example(x::Number, y::Number) = Trigger{Symbol("ExampleMod/ExampleTrigger")}("ExampleMod/ExampleTrigger", x = x, y = y)
=# 

#=
Entity data has the following reserved attributes: x, y, width, height, nodes.
All attributes other than x and y must be given a default value.
Allowed attribute types (ones that won't break the map parser) include:
    String, Bool, Char, Int, Float
=#
@mapdef Trigger "ExampleMod/ExampleTrigger2" Example2(x::Number, y::Number, width::Number=16, height::Number=16, nodes::Vector{Tuple{Int, Int}}=[(0,0)], attrib::Bool=false)
#= equivalent to: 
    @pardef Example2(x::Number, y::Number, width::Number=16, height::Number=16, nodes::Vector{Tuple{Int, Int}}=[(0,0)], attrib::Bool=false) = 
        Trigger("ExampleMod/ExampleTrigger2", x=x, y=y, width=width, height=height, nodes=nodes, attrib=attrib)
=#
#= evaluates to:
    const Example2 = Trigger{Symbol("ExampleMod/ExampleTrigger2")}
    Example2(x::Number, y::Number, width::Number = 16, height::Number = 16, nodes::Vector{Tuple{Int, Int}} = [(0, 0)], attrib::Bool = false) = 
        Trigger{Symbol("ExampleMod/ExampleTrigger2")}("ExampleMod/ExampleTrigger2", x = x, y = y, width = width, height = height, nodes = nodes, attrib = attrib)
=#

# On load, placements are retrieved from the placements field of each module and combined into a list.
const placements = Ahorn.PlacementDict(
    "Example Entity" => Ahorn.EntityPlacement(
        Example,                    # Your Entity type
        "rectangle",                    # One of: "point", "rectangle", "line", please just use "rectangle"
        Dict{String, Any}(),        # Data specific to this placement, think about this like "any extra data that wouldn't go into the @mapdef declaration
        function finalizer(args...) # Called when the entity is created
            # arguments can be any of:
            #    (target, map, room)
            #    (target, room)
            #    (target)
        end
    )
)

# The minimum and maximum number of allowed nodes. `-1` for unbounded.
Ahorn.nodeLimits(trigger::Example) = 0, 0

#=
Add specific editing options for attributes.
Supported options include:
    Array (technically only supports Vector, or 1 dim Array), Dict
    Array equates to a dropdown list of options, must be of the type of the data definition
    Dict{String, T} equates to a dropdown list of options with a cleaner naming structure. For example, if you wanted to specify the different depths of a Particle,
    you could use Integer[-8000, 50000] or Dict{String, Integer}("BGParticles" => -8000, "FGParticles" => 50000), which shows more information
=#
Ahorn.editingOptions(trigger::Example) = Dict{String, Any}(
    "attributeName" => ["opt1", "opt2", "opt3"]
)

# The order in which attributes will be displayed when editing. 
# Attributes that aren't listed are appended in alphabetical order.
Ahorn.editingOrder(trigger::Example) = String["x", "y", "width", "height"]

# Attributes that should not be displayed when editing.
# `multiple` is true when more than one trigger is being edited simultaneously.
Ahorn.editingIgnored(trigger::Example, multiple::Bool=false) = multiple ? String["x", "y", "width", "height", "nodes"] : String[]

# `deleted`, `moved`, and `resized` are callbacks provided by Ahorn for the corresponding actions.
Ahorn.deleted(trigger::Example, node::Int) = nothing
Ahorn.moved(trigger::Example) = nothing
Ahorn.moved(trigger::Example, x::Int, y::Int) = nothing
Ahorn.resized(trigger::Example) = nothing
Ahorn.resized(trigger::Example, width::Int, height::Int) = nothing

# If a trigger is returned, it replaces the current one
Ahorn.flipped(trigger::Example, horizontal::Bool) = nothing

# If a trigger is returned, it replaces the current one
Ahorn.rotated(trigger::Example, steps::Int) = nothing

# These next parts are generally considered not necessary. But if you happen to need to create a different render for your Trigger, here they are.
#=
  This is the default function for rendering the Trigger in Ahorn. 
  ctx is the CairoContext which is how drawing works from the code side of things
  Layer is the Layer, which basically: Ahorn renders things on different layers just like Celeste does, except its layers are set to different predefined values.
  Trigger is your Trigger struct, so your ExampleTrigger
  room is the current room you're in
  alpha is supposed to be the transparency value for the trigger but it doesn't actually do anything here normally

  Please don't actually worry about this code unless you either a: already know what you're doing or b: need to change the humanized Variable Name from whatever
its giving you to something else, and if then just replace the line text = Ahorn.humanizeVariableName(trigger.name) to text = "YourTextHere".
=#
function Ahorn.renderTrigger(ctx::Cairo.CairoContext, layer::Layer, trigger::ExampleTrigger, room::Maple.Room; alpha=nothing)
    if ctx.ptr != C_NULL # this line just prevents a crash
        Cairo.save(ctx) # this line 

        x, y = position(trigger)
        w, h = Int(trigger.width), Int(trigger.height)

        rectangle(ctx, x, y, w, h)
        clip(ctx)

        text = Ahorn.humanizeVariableName(trigger.name)
        Ahorn.drawRectangle(ctx, x, y, w, h, Ahorn.colors.trigger_fc, Ahorn.colors.trigger_bc)
        Ahorn.drawCenteredText(ctx, text, x, y, w, h)

        restore(ctx)
    end
end

end
