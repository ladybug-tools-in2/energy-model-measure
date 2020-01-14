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

require 'ladybug/energy_model/extension'
require 'ladybug/energy_model/model_object'
require 'ladybug/energy_model/opaque_construction_abridged'
require 'ladybug/energy_model/window_construction_abridged'
require 'ladybug/energy_model/face'
require 'ladybug/energy_model/shade'
require 'ladybug/energy_model/aperture'
require 'ladybug/energy_model/construction_set'
require 'ladybug/energy_model/door'
require 'ladybug/energy_model/energy_material_no_mass'
require 'ladybug/energy_model/energy_material'
require 'ladybug/energy_model/energy_window_material_blind'
require 'ladybug/energy_model/energy_window_material_gas_custom'
require 'ladybug/energy_model/energy_window_material_gas'
require 'ladybug/energy_model/energy_window_material_gas_mixture'
require 'ladybug/energy_model/energy_window_material_glazing'
require 'ladybug/energy_model/energy_window_material_shade'
require 'ladybug/energy_model/energy_window_material_simpleglazsys'
require 'ladybug/energy_model/room'
require 'ladybug/energy_model/shade'
require 'ladybug/energy_model/shade_construction'
require 'ladybug/energy_model/schedule_type_limit'
require 'ladybug/energy_model/schedule_fixed_interval_abridged'
require 'ladybug/energy_model/schedule_ruleset_abridged'
require 'ladybug/energy_model/space_type'
require 'ladybug/energy_model/setpoint_thermostat'
require 'ladybug/energy_model/setpoint_humidistat'
require 'ladybug/energy_model/ideal_air_system'
require 'openstudio'

module Ladybug
  module EnergyModel
    class Model
      attr_reader :errors, :warnings

      # Read Ladybug Energy Model JSON from disk
      def self.read_from_disk(file)
        hash = nil
        File.open(File.join(file), 'r') do |f|
          hash = JSON.parse(f.read, symbolize_names: true)
        end
        Model.new(hash)
      end

      # Load ModelObject from symbolized hash
      def initialize(hash)
        # initialize class variable @@extension only once
        @@extension ||= Extension.new
        @@schema ||= @@extension.schema

        @hash = hash
        @type = @hash[:type]
        raise 'Unknown model type' if @type.nil?
        raise "Incorrect model type '#{@type}'" unless @type == 'Model'

      end

      # check if the model is valid
      def valid?
        if Gem.loaded_specs.has_key?("json-schema")
          return validation_errors.empty?
        else
          return true
        end
      end

      # return detailed model validation errors
      def validation_errors
        if Gem.loaded_specs.has_key?("json-schema")
          require 'json-schema'
          JSON::Validator.fully_validate(@@schema, @hash)
        end
      end
      
      # convert to openstudio model, clears errors and warnings
      def to_openstudio_model(openstudio_model = nil)
        @errors = []
        @warnings = []

        @openstudio_model = if openstudio_model
                              openstudio_model
                            else
                              OpenStudio::Model::Model.new
                            end

        # create all openstudio objects in the model
        create_openstudio_objects

        # assign the north
        if @hash[:north_angle]
          @openstudio_model.getBuilding.setNorthAxis(@hash[:north_angle])
        end

        # assign the terrain
        os_site = @openstudio_model.getSite
        os_site.setTerrain(
          @@schema[:components][:schemas][:ModelEnergyProperties][:properties][:terrain_type][:default])
        if @hash[:properties][:energy][:terrain_type]
          os_site.setTerrain(@hash[:properties][:energy][:terrain_type])
        end

        @openstudio_model
      end

      private

      # create openstudio objects in the openstudio model
      def create_openstudio_objects
        # create all of the non-geometric model elements
        create_materials
        create_constructions
        create_construction_set
        create_global_construction_set
        create_schedule_type_limits
        create_schedules
        create_space_types

        # create all of the model geometry
        create_rooms
        create_orphaned_shades
        create_orphaned_faces
        create_orphaned_apertures
        create_orphaned_doors

        # create the hvac systems
        create_hvacs
      end

      def create_materials
        @hash[:properties][:energy][:materials].each do |material|
          material_type = material[:type]

          case material_type
          when 'EnergyMaterial'
            material_object = EnergyMaterial.new(material)
          when 'EnergyMaterialNoMass'
            material_object = EnergyMaterialNoMass.new(material)
          when 'EnergyWindowMaterialGas'
            material_object = EnergyWindowMaterialGas.new(material)
          when 'EnergyWindowMaterialGasCustom'
            material_object = EnergyWindowMaterialGasCustom.new(material)
          when 'EnergyWindowMaterialSimpleGlazSys'
            material_object = EnergyWindowMaterialSimpleGlazSys.new(material)
          when 'EnergyWindowMaterialBlind'
            material_object = EnergyWindowMaterialBlind.new(material)
          when 'EnergyWindowMaterialGlazing'
            material_object = EnergyWindowMaterialGlazing.new(material)
          when 'EnergyWindowMaterialShade'
            material_object = EnergyWindowMaterialShade.new(material)
          else
            raise "Unknown material type #{material_type}"
          end
          material_object.to_openstudio(@openstudio_model)
        end
      end


      def create_constructions
        @hash[:properties][:energy][:constructions].each do |construction|
          name = construction[:name]
          construction_type = construction[:type]
          
          case construction_type
          when 'OpaqueConstructionAbridged'
            construction_object = OpaqueConstructionAbridged.new(construction)
          when 'WindowConstructionAbridged'
            construction_object = WindowConstructionAbridged.new(construction)
          when 'ShadeConstruction'
            construction_object = ShadeConstruction.new(construction)
          else
            raise "Unknown construction type #{construction_type}."
          end
          construction_object.to_openstudio(@openstudio_model)
        end
      end

      def create_construction_set
        if @hash[:properties][:energy][:construction_sets]
          @hash[:properties][:energy][:construction_sets].each do |construction_set|
          construction_set_object = ConstructionSetAbridged.new(construction_set)
          construction_set_object.to_openstudio(@openstudio_model)
          end
        end
      end

      def create_global_construction_set
        if @hash[:properties][:energy][:global_construction_set]
          construction_name = @hash[:properties][:energy][:global_construction_set]
          construction = @openstudio_model.getDefaultConstructionSetByName(construction_name)
          unless construction.empty?
            openstudio_construction = construction.get
          end
          @openstudio_model.getBuilding.setDefaultConstructionSet(openstudio_construction)
        end
      end

      def create_schedule_type_limits
        if @hash[:properties][:energy][:schedule_type_limits]
          @hash[:properties][:energy][:schedule_type_limits].each do |schedule_type_limit|
            schedule_type_limit_object = ScheduleTypeLimit.new(schedule_type_limit)
            schedule_type_limit_object.to_openstudio(@openstudio_model)
          end
        end
      end

      def create_schedules
        if @hash[:properties][:energy][:schedules]
          @hash[:properties][:energy][:schedules].each do |schedule|
            schedule_type = schedule[:type]

            case schedule_type
            when 'ScheduleRulesetAbridged'
              schedule_object = ScheduleRulesetAbridged.new(schedule)
            when 'ScheduleFixedIntervalAbridged'
              schedule_object = ScheduleFixedIntervalAbridged.new(schedule)
            else
              raise("Unknown schedule type #{schedule_type}.")
            end
            schedule_object.to_openstudio(@openstudio_model)
          
          end
        end
      end

      def create_space_types
        if @hash[:properties][:energy][:program_types]
          $programtype_setpoint_hash = Hash.new
          @hash[:properties][:energy][:program_types].each do |space_type|
            space_type_object = SpaceType.new(space_type)
            space_type_object.to_openstudio(@openstudio_model)
          end
        end
      end

      def create_rooms
        if @hash[:rooms]
          @hash[:rooms].each do |room|
            room_object = Room.new(room)
            openstudio_room = room_object.to_openstudio(@openstudio_model)
            
            # for rooms with setpoint objects definied in the ProgramType, make a new thermostat
            if room[:properties][:energy][:program_type] && !room[:properties][:energy][:setpoint]
              thermal_zone = openstudio_room.thermalZone()
              unless thermal_zone.empty?
                thermal_zone_object = thermal_zone.get
                program_type_name = room[:properties][:energy][:program_type]
                setpoint_hash = $programtype_setpoint_hash[program_type_name]
                thermostat_object = SetpointThermostat.new(setpoint_hash)
                openstudio_thermostat = thermostat_object.to_openstudio(@openstudio_model)
                thermal_zone_object.setThermostatSetpointDualSetpoint(openstudio_thermostat)
                if setpoint_hash[:humidification_schedule] or setpoint_hash[:dehumidification_schedule]
                  humidistat_object = ZoneControlHumidistat.new(setpoint_hash)
                  openstudio_humidistat = humidistat_object.to_openstudio(@openstudio_model)
                  thermal_zone_object.setZoneControlHumidistat(openstudio_humidistat)
                end
              end
            end
          end
        end
      end
           
      
      def create_orphaned_shades
        if @hash[:orphaned_shades]
          shading_surface_group = OpenStudio::Model::ShadingSurfaceGroup.new(@openstudio_model)
          shading_surface_group.setShadingSurfaceType('Building')
          @hash[:orphaned_shades].each do |shade|
          shade_object = Shade.new(shade)
          openstudio_shade = shade_object.to_openstudio(@openstudio_model)
          openstudio_shade.setShadingSurfaceGroup(shading_surface_group)
          end
        end
      end

      def create_orphaned_faces
        if @hash[:orphaned_faces]
          raise "Orphaned Faces are not translatable to OpenStudio."
        end
      end

      def create_orphaned_apertures
        if @hash[:orphaned_apertures]
          raise "Orphaned Apertures are not translatable to OpenStudio."
        end
      end
      
      def create_orphaned_doors
        if @hash[:orphaned_doors]
          raise "Orphaned Doors are not translatable to OpenStudio."
        end
      end

      def create_hvacs
        if @hash[:properties][:energy][:hvacs]
          # gather all of the hashes of the HVACs
          hvac_hashes = Hash.new
          @hash[:properties][:energy][:hvacs].each do |hvac|
            hvac_hashes[hvac[:name]] = hvac
            hvac_hashes[hvac[:name]]['rooms'] = []
          end
          # loop through the rooms and trach which are assigned to each HVAC
          if @hash[:rooms]
            @hash[:rooms].each do |room|
              if room[:properties][:energy][:hvac]
                hvac_hashes[room[:properties][:energy][:hvac]]['rooms'] << room[:name]
              end
            end
          end

          hvac_hashes.each_value do |hvac|
            system_type = hvac[:type]
            case system_type
            when 'IdealAirSystemAbridged'
              ideal_air_system = IdealAirSystemAbridged.new(hvac)
              os_ideal_air_system = ideal_air_system.to_openstudio(@openstudio_model)
              hvac['rooms'].each do |room_name|
                zone_get = @openstudio_model.getThermalZoneByName(room_name)
                unless zone_get.empty?
                  os_thermal_zone = zone_get.get
                  os_ideal_air_system.addToThermalZone(os_thermal_zone)
                end
              end
            end
          end
        end
      end 

      #TODO: create runlog for errors. 
      
    end # Model
  end # EnergyModel
end # Ladybug
