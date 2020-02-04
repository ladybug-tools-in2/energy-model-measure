# *******************************************************************************
# Ladybug Tools Energy Model Schema, Copyright (c) 2019, Alliance for Sustainable
# Energy, LLC, Ladybug Tools LLC and other contributors. All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# (1) Redistributions of source code must retain the above copyright notice,
# this list of conditions and the following disclaimer.
#
# (2) Redistributions in binary form must reproduce the above copyright notice,
# this list of conditions and the following disclaimer in the documentation
# and/or other materials provided with the distribution.
#
# (3) Neither the name of the copyright holder nor the names of any contributors
# may be used to endorse or promote products derived from this software without
# specific prior written permission from the respective party.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDER(S) AND ANY CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
# THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER(S), ANY CONTRIBUTORS, THE
# UNITED STATES GOVERNMENT, OR THE UNITED STATES DEPARTMENT OF ENERGY, NOR ANY OF
# THEIR EMPLOYEES, BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
# EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT
# OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
# STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
# OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
# *******************************************************************************

require 'from_honeybee/model_object'
require 'from_honeybee/geometry/aperture'
require 'from_honeybee/geometry/door'

require 'openstudio'

module FromHoneybee
  class Face < ModelObject
    attr_reader :errors, :warnings

    def initialize(hash = {})
      super(hash)

      raise "Incorrect model type '#{@type}'" unless @type == 'Face'
    end

    def defaults
      @@schema[:components][:schemas][:FaceEnergyPropertiesAbridged][:properties]
    end

    def find_existing_openstudio_object(openstudio_model)
      model_surf = openstudio_model.getSurfaceByName(@hash[:name])
      return model_surf.get unless model_surf.empty?
      nil
    end

    def to_openstudio(openstudio_model)
      # create the openstudio surface
      openstudio_vertices = OpenStudio::Point3dVector.new
      @hash[:geometry][:boundary].each do |vertex|
        openstudio_vertices << OpenStudio::Point3d.new(vertex[0], vertex[1], vertex[2])
      end

      openstudio_surface = OpenStudio::Model::Surface.new(openstudio_vertices, openstudio_model)        
      openstudio_surface.setName(@hash[:name])
      openstudio_surface.setSurfaceType(@hash[:face_type])

      # assign the construction if it is present
      if @hash[:properties][:energy][:construction]
        construction_name = @hash[:properties][:energy][:construction]
        construction = openstudio_model.getConstructionByName(construction_name)
        unless construction.empty?
          openstudio_construction = construction.get
          openstudio_surface.setConstruction(openstudio_construction)
        end
      end
      
      # assign the boundary condition
      boundary_condition = (@hash[:boundary_condition][:type])
      case boundary_condition
      when 'Outdoors'
        if @hash[:boundary_condition][:sun_exposure] == false
          openstudio_surface.setSunExposure('NoSun')
        else 
          openstudio_surface.setSunExposure('SunExposed')
        end
        if @hash[:boundary_condition][:wind_exposure] == false
          openstudio_surface.setWindExposure('NoWind')
        else
          openstudio_surface.setWindExposure('WindExposed')
        end
        if @hash[:boundary_condition][:view_factor].is_a? Numeric
          openstudio_surface.setViewFactortoGround(@hash[:boundary_condition][:view_factor])
        else
          openstudio_surface.autocalculateViewFactortoGround
        end
      when 'Surface'
        # get adjacent surface by name from openstudio model
        adj_srf_name = @hash[:boundary_condition][:boundary_condition_objects][0]
        surface_object = openstudio_model.getSurfaceByName(adj_srf_name)
        unless surface_object.empty?
          surface = surface_object.get
          openstudio_surface.setAdjacentSurface(surface)
        end
      end
      unless @hash[:boundary_condition][:type] == 'Surface'
        openstudio_surface.setOutsideBoundaryCondition(@hash[:boundary_condition][:type])
      end

      # assign apertures if they exist
      if @hash[:apertures]
        @hash[:apertures].each do |aperture|
          ladybug_aperture = Aperture.new(aperture)
          openstudio_subsurface_aperture = ladybug_aperture.to_openstudio(openstudio_model)
          if @hash[:face_type] == 'RoofCeiling' or @hash[:face_type]  == 'Floor'
            if @hash[:boundary_condition][:type] == 'Outdoors' && aperture[:is_operable] == false
              openstudio_subsurface_aperture.setSubSurfaceType('Skylight')
            end
          end
          openstudio_subsurface_aperture.setSurface(openstudio_surface)
        end
      end

      # assign doors if they exist
      if @hash[:doors]
        @hash[:doors].each do |door|
          door = Door.new(door)
          openstudio_subsurface_door = door.to_openstudio(openstudio_model)
          if @hash[:face_type] == 'RoofCeiling' or @hash[:face_type] == 'Floor' && @hash[:boundary_condition][:type] == 'Outdoors'
            openstudio_subsurface_aperture.setSubSurfaceType('OverheadDoor')
          end
          openstudio_subsurface_door.setSurface(openstudio_surface)
        end
      end
              
      openstudio_surface
    end
  end # Face
end # FromHoneybee
