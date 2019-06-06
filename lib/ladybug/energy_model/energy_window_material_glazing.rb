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
    class EnergyWindowMaterialGlazing < ModelObject
      attr_reader :errors, :warnings

      def initialize(hash = {})
        super(hash)

        raise "Incorrect model type '#{@type}'" unless @type == 'EnergyWindowMaterialGlazing'
      end

      def defaults
        result = {}
        result[:type] = @@schema[:definitions][:EnergyWindowMaterialGlazing][:properties][:type][:enum]
        result[:spectral_dataset_name] = @@schema[:definitions][:EnergyWindowMaterialGlazing][:properties][:optical_datatype][:default]
        result[:thickness_glass] = @@schema[:definitions][:EnergyWindowMaterialGlazing][:properties][:thickness_glass][:default]
        result[:solar_transmittance] = @@schema[:definitions][:EnergyWindowMaterialGlazing][:properties][:solar_transmittance][:default]
        result[:solar_reflectance] = @@schema[:definitions][:EnergyWindowMaterialGlazing][:properties][:solar_reflectance][:default]
        result[:solar_reflectance_back] = @@schema[:definitions][:EnergyWindowMaterialGlazing][:properties][:solar_reflectance_back][:default]
        result[:visible_transmittance] = @@schema[:definitions][:EnergyWindowMaterialGlazing][:properties][:visible_transmittance][:default]
        result[:visible_reflectance] = @@schema[:definitions][:EnergyWindowMaterialGlazing][:properties][:visible_reflectance][:default]
        result[:visible_reflectance_back] = @@schema[:definitions][:EnergyWindowMaterialGlazing][:properties][:visible_reflectance_back][:default]
        result[:infrared_transmittance] = @@schema[:definitions][:EnergyWindowMaterialGlazing][:properties][:infrared_transmittance][:default]
        result[:front_emissivity] = @@schema[:definitions][:EnergyWindowMaterialGlazing][:properties][:front_emissivity][:default]
        result[:back_emissivity] = @@schema[:definitions][:EnergyWindowMaterialGlazing][:properties][:back_emissivity][:default]
        result[:conductivity_glass] = @@schema[:definitions][:EnergyWindowMaterialGlazing][:properties][:conductivity_glass][:default]
        result[:dirt_correction] = @@schema[:definitions][:EnergyWindowMaterialGlazing][:properties][:dirt_correction][:default]
        result
      end

      def find_existing_openstudio_object(openstudio_model)
        object = openstudio_model.getStandardGlazingByName(@hash[:name])
        return object.get if object.is_initialized
        nil
      end

      def create_openstudio_object(openstudio_model)
        openstudio_standard_glazing = OpenStudio::Model::StandardGlazing.new(openstudio_model)
        openstudio_standard_glazing.setName(@hash[:name])
        if @hash[:optical_datatype]
          openstudio_standard_glazing.setOpticalDataType(@hash[:optical_datatype])
        else
          openstudio_standard_glazing.setOpticalDataType(@@schema[:definitions][EnergyWindowMaterialGlazing][:properties][:optical_datatype][:default])
        end
        if @hash[:spectral_dataset_name]
          openstudio_standard_glazing.setWindowGlassSpectralDataSetName(@hash[:spectral_dataset_name])
        else
          openstudio_standard_glazing.setWindowGlassSpectralDataSetName(@@schema[:definitions][EnergyWindowMaterialGlazing][:properties][:spectral_dataset_name][:default])
        end
        if @hash[:thickness_glass]
          openstudio_standard_glazing.setThickness(@hash[:thickness_glass])
        else
          openstudio_standard_glazing.setThickness(@@schema[:definitions][EnergyWindowMaterialGlazing][:thickness_glass][:default])
        end
        if @hash[:solar_transmittance]
          openstudio_standard_glazing.setSolarTransmittanceatNormalIncidence(@hash[:solar_transmittance])
        else
          openstudio_standard_glazing.setSolarTransmittanceatNormalIncidence(@@schema[:definitions][EnergyWindowMaterialGlazing][:properties][:solar_transmittance][:default])
        end
        if @hash[:solar_reflectance]
          openstudio_standard_glazing.setFrontSideSolarReflectanceatNormalIncidence(@hash[:solar_reflectance])
        else
          openstudio_standard_glazing.setFrontSideSolarReflectanceatNormalIncidence(@@schema[:definitions][EnergyWindowMaterialGlazing][:properties][:solar_reflectance][:default])
        end
        if @hash[:solar_reflectance_back]
          openstudio_standard_glazing.setBackSideSolarReflectanceatNormalIncidence(@hash[:solar_reflectance_back])
        else
          openstudio_standard_glazing.setBackSideSolarReflectanceatNormalIncidence(@@schema[:definitions][EnergyWindowMaterialGlazing][:properties][:solar_reflectance_back][:default])
        end
        if @hash[:visible_transmittance]
          openstudio_standard_glazing.setVisibleTransmittanceatNormalIncidence(@hash[:visible_transmittance])
        else
          openstudio_standard_glazing.setVisibleTransmittanceatNormalIncidence(@@schema[:definitions][EnergyWindowMaterialGlazing][:properties][:visible_transmittance][:default])
        end
        if @hash[:visible_reflectance]
          openstudio_standard_glazing.setFrontSideVisibleReflectanceatNormalIncidence(@hash[:visible_reflectance])
        else
          openstudio_standard_glazing.setFrontSideVisibleReflectanceatNormalIncidence(@@schema[:definitions][EnergyWindowMaterialGlazing][:properties][:visible_reflectance][:default])
        end
        if @hash[:visible_reflectance_back]
          openstudio_standard_glazing.setBackSideVisibleReflectanceatNormalIncidence(@hash[:visible_reflectance_back])
        else
          openstudio_standard_glazing.setBackSideVisibleReflectanceatNormalIncidence(@@schema[:definitions][EnergyWindowMaterialGlazing][:properties][:visible_reflectance_back][:default])
        end
        if @hash[:infrared_transmittance]
          openstudio_standard_glazing.setInfraredTransmittanceatNormalIncidence(@hash[:infrared_transmittance])
        else
          openstudio_standard_glazing.setInfraredTransmittanceatNormalIncidence(@@schema[:definitions][EnergyWindowMaterialGlazing][:properties][:infrared_transmittance][:default])
        end
        if @hash[:front_emissivity]
          openstudio_standard_glazing.setFrontSideInfraredHemisphericalEmissivity(@hash[:front_emissivity])
        else
          openstudio_standard_glazing.setFrontSideInfraredHemisphericalEmissivity(@@schema[:definitions][EnergyWindowMaterialGlazing][:properties][:front_emissivity][:default])
        end
        if @hash[:back_emissivity]
          openstudio_standard_glazing.setBackSideInfraredHemisphericalEmissivity(@hash[:back_emissivity])
        else
          openstudio_standard_glazing.setBackSideInfraredHemisphericalEmissivity(@@schema[:definitions][EnergyWindowMaterialGlazing][:properties][:back_emissivity][:default])
        end
        if @hash[:conductivity_glass]
          openstudio_standard_glazing.setThermalConductivity(@hash[:conductivity_glass])
        else
          openstudio_standard_glazing.setThermalConductivity(@@schema[:definitions][EnergyWindowMaterialGlazing][:properties][:conductivity_glass][:default])
        end
        if @hash[:dirt_correction]
          openstudio_standard_glazing.setDirtCorrectionFactorforSolarandVisibleTransmittance(@hash[:dirt_correction])
        else
          openstudio_standard_glazing.setDirtCorrectionFactorforSolarandVisibleTransmittance(@@schema[:definitions][EnergyWindowMaterialGlazing][:properties][:dirt_correction][:default])
        end
        if @hash[:solar_diffusing] == 'No'
          openstudio_standard_glazing.setSolarDiffusing(false)
        elsif @hash[:solar_diffusing] == 'Yes'
          openstudio_standard_glazing.setSolarDiffusing(true)
        else
          raise "Unknown value for Solar Diffusing '#{@hash[:solar_diffusing]}'"
        end

        openstudio_standard_glazing
      end
    end # EnergyWindowMaterialGlazing
  end # EnergyModel
end # Ladybug
