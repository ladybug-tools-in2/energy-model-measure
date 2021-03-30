# *******************************************************************************
# Honeybee OpenStudio Gem, Copyright (c) 2020, Alliance for Sustainable
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

require 'honeybee/model'

require 'from_openstudio/geometry/room'
require 'from_openstudio/geometry/shade'
require 'from_openstudio/material/opaque'
require 'from_openstudio/material/opaque_no_mass'
require 'from_openstudio/material/window_simpleglazsys'


require 'openstudio'

module Honeybee
  class Model

    # Create Ladybug Energy Model JSON from OpenStudio Model
    def self.translate_from_openstudio(openstudio_model)
      hash = {}
      hash[:type] = 'Model'
      hash[:identifier] = 'Model'
      hash[:display_name] = 'Model'
      hash[:units] = 'Meters'
      hash[:tolerance] = 0.01
      hash[:angle_tolerance] = 1.0

      hash[:properties] = properties_from_model(openstudio_model)

      rooms = rooms_from_model(openstudio_model)
      hash[:rooms] = rooms if !rooms.empty?

      orphaned_shades = orphaned_shades_from_model(openstudio_model)
      hash[:orphaned_shades] = orphaned_shades if !orphaned_shades.empty?

      Model.new(hash)
    end

    # Create Ladybug Energy Model JSON from OSM file
    def self.translate_from_osm_file(file)
      vt = OpenStudio::OSVersion::VersionTranslator.new
      openstudio_model = vt.loadModel(file)
      raise "Cannot load OSM file at '#{}'" if openstudio_model.empty?
      self.translate_from_openstudio(openstudio_model.get)
    end

    # Create Ladybug Energy Model JSON from gbXML file
    def self.translate_from_gbxml_file(file)
      translator = OpenStudio::GbXML::GbXMLReverseTranslator.new
      openstudio_model = translator.loadModel(file)
      raise "Cannot load gbXML file at '#{}'" if openstudio_model.empty?
      self.translate_from_openstudio(openstudio_model.get)
    end

    # Create Ladybug Energy Model JSON from IDF file
    def self.translate_from_idf_file(file)
      translator = OpenStudio::EnergyPlus::ReverseTranslator.new
      openstudio_model = translator.loadModel(file)
      raise "Cannot load IDF file at '#{}'" if openstudio_model.empty?
      self.translate_from_openstudio(openstudio_model.get)
    end

    def self.properties_from_model(openstudio_model)
      hash = {}
      hash[:type] = 'ModelProperties'
      hash
    end

    def self.energy_properties_from_model(openstudio_model)
      hash = {}
      hash[:type] = 'ModelEnergyProperties'
      hash[:energy] = energy_properties_from_model(openstudio_model)
      hash
    end

    def self.rooms_from_model(openstudio_model)
      result = []
      openstudio_model.getSpaces.each do |space|
        result << Room.from_space(space)
      end
      result
    end

    def self.orphaned_shades_from_model(openstudio_model)
      result = []
      openstudio_model.getShadingSurfaceGroups.each do |shading_surface_group|
        shading_surface_type = shading_surface_group.shadingSurfaceType
        if shading_surface_type == 'Site' || shading_surface_type == 'Building'
          site_transformation = shading_surface_group.siteTransformation
          shading_surface_group.shadingSurfaces.each do |shading_surface|
            result << Shade.from_shading_surface(shading_surface, site_transformation)
          end
        end
      end
      result
    end

    # Create HB Material from OpenStudio Materials
    def self.materials_from_model(openstudio_model)
      result = []

      # TODO: Loop through all materials and add puts statement for unsupported materials.
      
      # Create HB EnergyMaterial from OpenStudio Material
      openstudio_model.getStandardOpaqueMaterials.each do |material|
        result << EnergyMaterial.from_material(material)
      end
      # Create HB EnergyMaterialNoMass from OpenStudio Material
      openstudio_model.getMasslessOpaqueMaterials.each do |material|
        result << EnergyMaterialNoMass.from_material(material)
      end
      # Create HB WindowMaterialSimpleGlazSys from OpenStudio Material
      openstudio_model.getSimpleGlazings.each do |material|
        result << EnergyWindowMaterialSimpleGlazSys.from_material(material)
      end
      result
    end

  end # Model
end # Honeybee
