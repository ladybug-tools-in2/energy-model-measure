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

require 'openstudio'

module FromHoneybee
  class EnergyWindowMaterialBlind < ModelObject
    attr_reader :errors, :warnings

    def initialize(hash = {})
      super(hash)
    end

    def name
      @hash[:name]
    end

    def name=(new_name)
      @hash[:name] = new_name
    end

    def find_existing_openstudio_object(openstudio_model)
      object = openstudio_model.getBlindByName(@hash[:name])
      return object.get if object.is_initialized
      nil
    end

    def create_openstudio_object(openstudio_model)
      os_blind = OpenStudio::Model::Blind.new(openstudio_model)
      os_blind.setName(@hash[:name])
      os_blind.setSlatOrientation(@hash[:slat_orientation])
      if @hash[:slat_width]
        os_blind.setSlatWidth(@hash[:slat_width])
      else
        os_blind.setSlatWidth(
          @@schema[:components][:schemas][:EnergyWindowMaterialBlind][:properties][:slat_width][:default])
      end
      if @hash[:slat_separation]
        os_blind.setSlatSeparation(@hash[:slat_separation])
      else
        os_blind.setSlatSeparation(
          @@schema[:components][:schemas][:EnergyWindowMaterialBlind][:properties][:slat_separation][:default])
      end
      if @hash[:slat_thickness]
        os_blind.setSlatThickness(@hash[:slat_thickness])
      else
        os_blind.setSlatThickness(
          @@schema[:components][:schemas][:EnergyWindowMaterialBlind][:properties][:slat_thickness][:default])
      end
      if @hash[:slat_angle]
        os_blind.setSlatAngle(@hash[:slat_angle])
      else
        os_blind.setSlatAngle(
          @@schema[:components][:schemas][:EnergyWindowMaterialBlind][:properties][:slat_angle][:default])
      end
      if @hash[:slat_conductivity]
        os_blind.setSlatConductivity(@hash[:slat_conductivity])
      else
        os_blind.setSlatConductivity(
          @@schema[:components][:schemas][:EnergyWindowMaterialBlind][:properties][:slat_conductivity][:default])
      end
      if @hash[:beam_solar_transmittance]
        os_blind.setSlatBeamSolarTransmittance(@hash[:beam_solar_transmittance])
      else
        os_blind.setSlatBeamSolarTransmittance(
          @@schema[:components][:schemas][:EnergyWindowMaterialBlind][:properties][:beam_solar_transmittance][:default])
      end
      if @hash[:beam_solar_reflectance]
        os_blind.setFrontSideSlatBeamSolarReflectance(@hash[:beam_solar_reflectance])
      else
        os_blind.setFrontSideSlatBeamSolarReflectance(
          @@schema[:components][:schemas][:EnergyWindowMaterialBlind][:properties][:beam_solar_reflectance][:default])
      end
      if @hash[:beam_solar_reflectance_back]
        os_blind.setBackSideSlatBeamSolarReflectance(@hash[:beam_solar_reflectance_back])
      else
        os_blind.setBackSideSlatBeamSolarReflectance(
          @@schema[:components][:schemas][:EnergyWindowMaterialBlind][:properties][:beam_solar_reflectance_back][:default])
      end
      if @hash[:diffuse_solar_transmittance]
        os_blind.setSlatDiffuseSolarTransmittance(@hash[:diffuse_solar_transmittance])
      else
        os_blind.setSlatDiffuseSolarTransmittance(
          @@schema[:components][:schemas][:EnergyWindowMaterialBlind][:properties][:diffuse_solar_transmittance][:default])
      end
      if @hash[:diffuse_solar_reflectance]
        os_blind.setFrontSideSlatDiffuseSolarReflectance(@hash[:diffuse_solar_reflectance])
      else
        os_blind.setFrontSideSlatDiffuseSolarReflectance(
          @@schema[:components][:schemas][:EnergyWindowMaterialBlind][:properties][:diffuse_solar_reflectance][:default])
      end
      if @hash[:diffuse_solar_reflectance_back]
        os_blind.setBackSideSlatDiffuseSolarReflectance(@hash[:diffuse_solar_reflectance_back])
      else
        os_blind.setBackSideSlatDiffuseSolarReflectance(
          @@schema[:components][:schemas][:EnergyWindowMaterialBlind][:properties][:diffuse_solar_reflectance_back][:default])
      end
      if @hash[:diffuse_visible_transmittance]
        os_blind.setSlatDiffuseVisibleTransmittance(@hash[:diffuse_visible_transmittance])
      else
        os_blind.setSlatDiffuseVisibleTransmittance(
          @@schema[:components][:schemas][:EnergyWindowMaterialBlind][:properties][:diffuse_visible_transmittance][:default])
      end
      if @hash[:diffuse_visible_reflectance]
        os_blind.setFrontSideSlatDiffuseVisibleReflectance(@hash[:diffuse_visible_reflectance])
      else
        os_blind.setFrontSideSlatDiffuseVisibleReflectance(
          @@schema[:components][:schemas][:EnergyWindowMaterialBlind][:properties][:diffuse_visible_reflectance][:default])
      end
      if @hash[:diffuse_visible_reflectance_back]
        os_blind.setBackSideSlatDiffuseVisibleReflectance(@hash[:diffuse_visible_reflectance_back])
      else
        os_blind.setBackSideSlatDiffuseVisibleReflectance(
          @@schema[:components][:schemas][:EnergyWindowMaterialBlind][:properties][:diffuse_visible_reflectance_back][:default])
      end
      if @hash[:infrared_transmittance]
        os_blind.setSlatInfraredHemisphericalTransmittance(@hash[:infrared_transmittance])
      else
        os_blind.setSlatInfraredHemisphericalTransmittance(
          @@schema[:components][:schemas][:EnergyWindowMaterialBlind][:properties][:infrared_transmittance][:default])
      end
      if @hash[:emissivity]
        os_blind.setFrontSideSlatInfraredHemisphericalEmissivity(@hash[:emissivity])
      else
        os_blind.setFrontSideSlatInfraredHemisphericalEmissivity(
          @@schema[:components][:schemas][:EnergyWindowMaterialBlind][:properties][:emissivity][:default])
      end
      if @hash[:emissivity_back]
        os_blind.setBackSideSlatInfraredHemisphericalEmissivity(@hash[:emissivity_back])
      else
        os_blind.setBackSideSlatInfraredHemisphericalEmissivity(
          @@schema[:components][:schemas][:EnergyWindowMaterialBlind][:properties][:back_emissivity][:default])
      end
      if @hash[:distance_to_glass]
        os_blind.setBlindtoGlassDistance(@hash[:distance_to_glass])
      else
        os_blind.setBlindtoGlassDistance(
          @@schema[:components][:schemas][:EnergyWindowMaterialBlind][:properties][:distance_to_glass][:default])
      end
      if @hash[:top_opening_multiplier]
        os_blind.setBlindTopOpeningMultiplier(@hash[:top_opening_multiplier])
      else
        os_blind.setBlindTopOpeningMultiplier(
          @@schema[:components][:schemas][:EnergyWindowMaterialBlind][:properties][:top_opening_multiplier][:default])
      end
      if @hash[:bottom_opening_multiplier]
        os_blind.setBlindBottomOpeningMultiplier(@hash[:bottom_opening_multiplier])
      else
        os_blind.setBlindBottomOpeningMultiplier(
          @@schema[:components][:schemas][:EnergyWindowMaterialBlind][:properties][:bottom_opening_multiplier][:default])
      end
      if @hash[:left_opening_multiplier]
        os_blind.setBlindLeftSideOpeningMultiplier(@hash[:left_opening_multiplier])
      else
        os_blind.setBlindLeftSideOpeningMultiplier(
          @@schema[:components][:schemas][:EnergyWindowMaterialBlind][:properties][:left_opening_multiplier][:default])
      end
      if @hash[:right_opening_multiplier]
        os_blind.setBlindRightSideOpeningMultiplier(@hash[:right_opening_multiplier])
      else
        os_blind.setBlindRightSideOpeningMultiplier(
          @@schema[:components][:schemas][:EnergyWindowMaterialBlind][:properties][:right_opening_multiplier][:default])
      end

      os_blind
    end
  end # EnergyWindowMaterialBlind
end # FromHoneybee
