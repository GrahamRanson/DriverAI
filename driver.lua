--- Required libraries.
local Maths = require( "DriverAI.maths" )

-- Localised functions.
local abs = math.abs
local sort = table.sort

-- Localised values.

--- Class creation.
local Driver = {}

-- Static values.

--- Initiates a new Driver object.
-- @param params A table containing the definition for this Driver.
-- @return The new Driver.
function Driver.new( params )

	-- Create ourselves
	local self = {}

    self.vehicle = params.vehicle
    self.waypoints = params.waypoints

    sort( self.waypoints, function( a, b ) return a.index < b.index end )

    self.waypointIndex = params.initialWaypointIndex or 1

    function self.update( dt )

        local waypoint = self.waypoints[ self.waypointIndex ]

        if waypoint then

			local margin = 5 * ( 1 - ( self.precision or 0 ) )

			self.targetPosition = self.targetPosition or
			{
				x = waypoint.x + math.random( -margin, margin ),
				y = waypoint.y + math.random( -margin, margin )
			}

            local currentSpeed = self.vehicle.getSpeed()
            local currentHeading = self.vehicle.getHeading( true )

            local targetSpeed = waypoint.speed
            local targetHeading = waypoint.heading
            local targetDistance = waypoint.distance or 1

            if targetSpeed then

                if currentSpeed < targetSpeed then
                    self.vehicle.setThrottle( 1 )
                    self.vehicle.setBrake( 0 )
                else
                    self.vehicle.setThrottle( 0 )
                    self.vehicle.setBrake( 1 )
                end

            else
                self.vehicle.setThrottle( 1 )
                self.vehicle.setBrake( 0 )
            end

            local angle = Maths.angleBetweenVectors( self.targetPosition, self.vehicle, false, 0 ) - 180

            local maxSteer = self.vehicle.getMaxSteer( true )

            local difference = Maths.differenceBetweenAngles( self.vehicle.rotation, angle )

            local factor = Maths.normaliseAcrossRanges( difference, 0, 360, 0, 1 )
            local absFactor = abs( factor )

            if factor > 0 then
                self.vehicle.setLeftSteering( absFactor )
                self.vehicle.setRightSteering( 0 )
            elseif factor < 0 then
                self.vehicle.setRightSteering( absFactor )
                self.vehicle.setLeftSteering( 0 )
            end

            local distance = Maths.distanceBetweenVectors( self.targetPosition , self.vehicle )

            if distance < targetDistance then

                self.waypointIndex = self.waypointIndex + 1

				self.targetPosition = nil

                if not self.waypoints[ self.waypointIndex ] or self.waypointIndex > #self.waypoints then
                    self.waypointIndex = 1
                end

            end

        end

    end

	-- Return the Driver object
	return self

end

-- Return the Driver class
return Driver
