-- Required libraries.

-- Localised functions.
local max = math.max
local min = math.min
local floor = math.floor
local deg = math.deg
local atan2 = math.atan2
local cos = math.cos
local rad = math.rad
local sin = math.sin
local sqrt = math.sqrt

-- Localised values.

--- Class creation.
local Maths = {}

--- Initiates a new Maths object.
-- @return The new Maths.
function Maths.new( options )

	-- Create ourselves
	local self = {}

    --- Gets a heading vector for an angle.
    -- @param angle The angle to use, in degrees.
    -- @return The heading vector.
    function self.vectorFromAngle( angle )
    	return { x = cos( rad( angle - 90 ) ), y = sin( rad( angle - 90 ) ) }
    end

    --- Gets the angle between two position vectors.
    -- @param vector1 The first position.
    -- @param vector2 The second position.
    -- @return The angle.
    function self.angleBetweenVectors( vector1, vector2, dontClamp, offset )
    	if vector1 and vector2 then
    		local angle = deg( atan2( vector2.y - vector1.y, vector2.x - vector1.x ) ) + ( offset or 90 )
    		if angle < 0 and not dontClamp then angle = 360 + angle end
    		return angle
    	end
    end

    --- Gets the angle between two position vectors, limited by a turn rate.
    -- @param vector1 The first position.
    -- @param vector2 The second position.
    -- @param current The current rotation of the object.
    -- @param turnRate The max rate of the turn.
    -- @return The angle.
    function self.limitedAngleBetweenVectors( vector1, vector2, current, turnRate )

    	if vector1 and vector2 and current and turnRate then

    		local target = self.angleBetweenVectors( vector1, vector2 )

    		local delta = floor( target - current )

    		delta = self.normaliseAngle( delta )

    		delta = self.clamp( delta, -turnRate, turnRate )

    		return current + delta

    	end

    end

    --- Gets the difference between two position angles.
    -- @param angle1 The first angle.
    -- @param angle2 The second angle.
    -- @return The difference.
    function self.differenceBetweenAngles( angle1, angle2 )

    	local d = angle1 - angle2
    	d = ( d + 180 ) % 360 - 180

    	return d

    end

    --- Clamps a value between lowest and highest values.
    -- @param value The value to clamp.
    -- @param lowest The lowest the value can be.
    -- @param highest The highest the value can be.
    -- @return The clamped value.
    function self.clamp( value, lowest, highest )
        return max( lowest, min( highest, value ) )
    end

    --- Normalises a value to within 0 and 1.
    -- @param value The current unnormalised value.
    -- @param min The minimum the value can be.
    -- @param max The maximum the value can be.
    -- @return The newly normalised value.
    function self.normalise( value, min, max )
    	local result = ( value - min ) / ( max - min )
    	if result > 1 then
    		result = 1
    	end
    	return result
    end

    --- Normalises a value from one range to another so that it's within within 0 and 1.
    -- @param value The current value.
    -- @param minA The minimum the value can be on the first range.
    -- @param maxA The maximum the value can be on the first range.
    -- @param minB The minimum the value can be on the second range.
    -- @param maxB The maximum the value can be on the second range.
    -- @return The newly normalised value.
    function self.normaliseAcrossRanges( value, minA, maxA, minB, maxB )
    	return ( ( ( value - minA ) * ( maxB - minB ) ) / ( maxA - minA ) ) + minB
    end

    --- Normalises an angle.
    -- @param angle The angle to normalise.
    -- @return The newly normalised angle.
    function self.normaliseAngle( angle )

        local newAngle = angle

        while newAngle <= -180 do
    		newAngle = newAngle + 360
    	end

        while newAngle > 180 do
    		newAngle = newAngle - 360
    	end

        return newAngle

    end

    --- Gets the distance between two position vectors.
    -- @param vector1 The first position.
    -- @param vector2 The second position.
    -- @return The distance.
    function self.distanceBetweenVectors( vector1, vector2 )
    	if not vector1 or not vector1.x or not vector1.y or not vector2 or not vector2.x or not vector2.y then
    		return
    	end
    	return sqrt( self.distanceBetweenVectorsSquared( vector1, vector2 ) )
    end

    --- Gets the squared distance between two position vectors.
    -- @param vector1 The first position.
    -- @param vector2 The second position.
    -- @return The distance.
    function self.distanceBetweenVectorsSquared( vector1, vector2 )
    	if not vector1 or not vector1.x or not vector1.y or not vector2 or not vector2.x or not vector2.y then
    		return
    	end
    	local factor = { x = vector2.x - vector1.x, y = vector2.y - vector1.y }
    	return ( factor.x * factor.x ) + ( factor.y * factor.y )
    end

    -- Return the Maths object
	return self

end

return Maths.new()
