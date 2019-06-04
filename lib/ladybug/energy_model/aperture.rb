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

require 'ladybug/energy_model/model_object'

require 'json-schema'
require 'json'
require 'openstudio'

module Ladybug
  module EnergyModel      
    class Aperture < ModelObject
      attr_reader :errors, :warnings

      def initialize(hash)
        super(hash)

        raise "Incorrect model type '#{@type}'" unless @type == 'Aperture'
      end
      
      
      
      def find_existing_openstudio_object(openstudio_model)
        object = openstudio_model.getSubSurfaceByName(@hash[:name])
        if object.is_initialized
          return object.get
        end
        return nil
      end
      
      def create_openstudio_object(openstudio_model)
        openstudio_vertices = OpenStudio::Point3dVector.new
        @hash[:vertices].each do |vertex|
          openstudio_vertices << OpenStudio::Point3d.new(vertex[:x],vertex[:y],vertex[:z])
        end

        parent_name = @hash[:parent][:name]
        space = openstudio_model.getSpaceByName(parent_name)
        if space.empty?
          space = OpenStudio::Model::SubSpace.new(openstudio_model)
          space.setName(parent_name)
        else
          space = space.get
        end

        surface_name = @hash[:name]
        surface = openstudio_model.getSurfaceByName(surface_name)
        surface = surface.get

        construction_opaque_name = @hash[:energy_construction_opaque][:name]
        construction_opaque = openstudio_model.getConstructionByName(construction_opaque_name)
        unless construction_opaque.empty?
          construction_opaque = construction_opaque.get
          #construction_opaque = EnergyConstructionOpaque.new
        end

        construction_transparent_name = @hash[:energy_construction_transparent][:name]
        construction_transparent = openstudio_model.getConstructionByName(construction_transparent_name)
        unless construction_transparent.empty?
          construction_transparent = construction_transparent.get
        end


        openstudio_subsurface = OpenStudio::Model::SubSurface.new(openstudio_vertices,openstudio_model)
        openstudio_subsurface.setName(@hash[:name])
        openstudio_subsurface.setSubSurfaceType(@hash[:face_type])
        openstudio_subsurface.setSurface(surface)
        openstudio_subsurface.setConstruction(construction_opaque)
        openstudio_subsurface.setConstruction(construction_transparent)#planar surface
        return openstudio_subsurface
      end

    end # Face
  end # EnergyModel
end # Ladybug