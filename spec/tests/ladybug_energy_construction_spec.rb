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

require_relative '../spec_helper'

RSpec.describe Ladybug::EnergyModel do
  it 'has a version number' do
    expect(Ladybug::EnergyModel::VERSION).not_to be nil
  end

  it 'has a measures directory' do
    extension = Ladybug::EnergyModel::Extension.new
    expect(File.exist?(extension.measures_dir)).to be true
  end

  it 'has a files directory' do
    extension = Ladybug::EnergyModel::Extension.new
    expect(File.exist?(extension.files_dir)).to be true
  end

  # add assertions
  it 'create accessors for hash keys' do
    file = File.join(File.dirname(__FILE__), '../files/construction_internal_floor.json')
    construction1 = Ladybug::EnergyModel::OpaqueConstructionAbridged.read_from_disk(file)

    # get and set existing hash key
    expect(construction1.respond_to?(:name)).to be false
    expect(construction1.respond_to?(:name=)).to be false

    expect(construction1.name).to eq('Internal Floor')

    # raise errors for non-existant hash key
    expect(construction1.respond_to?(:not_a_key)).to be false
    expect(construction1.respond_to?(:not_a_key=)).to be false

    # DLM: should we make it return nil for the non-existant getter instead?
    # expect( construction1.not_a_key ).to be nil

    expect{construction1.not_a_key }.to raise_error(NoMethodError)
    expect{construction1.not_a_key = 'Internal Floor'}.to raise_error(NoMethodError)
  end


  it 'can load and validate opaque construction' do
    openstudio_model = OpenStudio::Model::Model.new
    file = File.join(File.dirname(__FILE__), '../files/construction_roof.json')
    construction1 = Ladybug::EnergyModel::OpaqueConstructionAbridged.read_from_disk(file)
    object1 = construction1.to_openstudio(openstudio_model)
    expect(object1).not_to be nil

    # load the same construction again in the same model, should find existing construction
    construction2 = Ladybug::EnergyModel::OpaqueConstructionAbridged.read_from_disk(file)
    object2 = construction2.to_openstudio(openstudio_model)
    expect(object2).not_to be nil
    expect(object2.handle.to_s).to eq(object1.handle.to_s)
  end

  it 'can load and validate window construction' do
    openstudio_model = OpenStudio::Model::Model.new
    file = File.join(File.dirname(__FILE__), '../files/construction_window.json')
    construction1 = Ladybug::EnergyModel::WindowConstructionAbridged.read_from_disk(file)
    object1 = construction1.to_openstudio(openstudio_model)
    expect(object1).not_to be nil

    construction2 = Ladybug::EnergyModel::WindowConstructionAbridged.read_from_disk(file)
    object2 = construction2.to_openstudio(openstudio_model)
    expect(object2).not_to be nil
    expect(object2.handle.to_s).to eq(object1.handle.to_s)
  end

  it 'can load and validate energy material' do
    openstudio_model = OpenStudio::Model::Model.new
    file = File.join(File.dirname(__FILE__), '../files/in_material.json')
    material1 = Ladybug::EnergyModel::EnergyMaterial.read_from_disk(file)
    object1 = material1.to_openstudio(openstudio_model)
    expect(object1).not_to be nil
    material2 = Ladybug::EnergyModel::EnergyMaterial.read_from_disk(file)
    object2 = material2.to_openstudio(openstudio_model)
    expect(object2).not_to be nil
    expect(object2.handle.to_s).to eq(object1.handle.to_s)
  end

  it 'can load and validate energy material no mass' do
    openstudio_model = OpenStudio::Model::Model.new
    file = File.join(File.dirname(__FILE__), '../files/in_material_no_mass.json')
    material1 = Ladybug::EnergyModel::EnergyMaterialNoMass.read_from_disk(file)
    object1 = material1.to_openstudio(openstudio_model)
    expect(object1).not_to be nil

    material2 = Ladybug::EnergyModel::EnergyMaterialNoMass.read_from_disk(file)
    object2 = material2.to_openstudio(openstudio_model)
    expect(object2).not_to be nil
    expect(object2.handle.to_s).to eq(object1.handle.to_s)
  end

  it 'can load and validate energy window material gas' do
    openstudio_model = OpenStudio::Model::Model.new
    file = File.join(File.dirname(__FILE__), '../files/in_window_gas.json')
    material1 = Ladybug::EnergyModel::EnergyWindowMaterialGas.read_from_disk(file)
    object1 = material1.to_openstudio(openstudio_model)
    expect(object1).not_to be nil

    material2 = Ladybug::EnergyModel::EnergyWindowMaterialGas.read_from_disk(file)
    object2 = material2.to_openstudio(openstudio_model)
    expect(object2).not_to be nil
    expect(object2.handle.to_s).to eq(object1.handle.to_s)
  end

  it 'can load and validate energy window material gas custom' do
    openstudio_model = OpenStudio::Model::Model.new
    file = File.join(File.dirname(__FILE__), '../files/in_window_gas_custom.json')
    material1 = Ladybug::EnergyModel::EnergyWindowMaterialGasCustom.read_from_disk(file)
    object1 = material1.to_openstudio(openstudio_model)
    expect(object1).not_to be nil

    material2 = Ladybug::EnergyModel::EnergyWindowMaterialGasCustom.read_from_disk(file)
    object2 = material2.to_openstudio(openstudio_model)
    expect(object2).not_to be nil
    expect(object2.handle.to_s).to eq(object1.handle.to_s)
  end

  it 'can load and validate energy window material gas mixture' do
    openstudio_model = OpenStudio::Model::Model.new
    file = File.join(File.dirname(__FILE__), '../files/in_window_gas_mixture.json')
    material1 = Ladybug::EnergyModel::EnergyWindowMaterialGasMixture.read_from_disk(file)
    object1 = material1.to_openstudio(openstudio_model)
    expect(object1).not_to be nil

    material2 = Ladybug::EnergyModel::EnergyWindowMaterialGasMixture.read_from_disk(file)
    object2 = material2.to_openstudio(openstudio_model)
    expect(object2).not_to be nil
    expect(object2.handle.to_s).to eq(object1.handle.to_s)
  end

  it 'can load and validate energy window material simple glazing system' do
    openstudio_model = OpenStudio::Model::Model.new
    file = File.join(File.dirname(__FILE__), '../files/in_window_simpleglazing.json')
    material1 = Ladybug::EnergyModel::EnergyWindowMaterialSimpleGlazSys.read_from_disk(file)
    object1 = material1.to_openstudio(openstudio_model)
    expect(object1).not_to be nil

    material2 = Ladybug::EnergyModel::EnergyWindowMaterialSimpleGlazSys.read_from_disk(file)
    object2 = material2.to_openstudio(openstudio_model)
    expect(object2).not_to be nil
    expect(object2.handle.to_s).to eq(object1.handle.to_s)
  end

  # Can create openstudio model with only required inputs
  it 'can load and validate energy window material blind' do
    openstudio_model = OpenStudio::Model::Model.new
    file = File.join(File.dirname(__FILE__), '../files/in_window_blind.json')
    material1 = Ladybug::EnergyModel::EnergyWindowMaterialBlind.read_from_disk(file)

    object1 = material1.to_openstudio(openstudio_model)
    expect(object1).not_to be nil

    material2 = Ladybug::EnergyModel::EnergyWindowMaterialBlind.read_from_disk(file)
    object2 = material2.to_openstudio(openstudio_model)
    expect(object2).not_to be nil
    expect(object2.handle.to_s).to eq(object1.handle.to_s)
  end

  it 'can load and validate energy window material glazing' do
    openstudio_model = OpenStudio::Model::Model.new
    file = File.join(File.dirname(__FILE__), '../files/in_window_glazing.json')
    material1 = Ladybug::EnergyModel::EnergyWindowMaterialGlazing.read_from_disk(file)
    object1 = material1.to_openstudio(openstudio_model)
    expect(object1).not_to be nil

    material2 = Ladybug::EnergyModel::EnergyWindowMaterialGlazing.read_from_disk(file)
    object2 = material2.to_openstudio(openstudio_model)
    expect(object2).not_to be nil
    expect(object2.handle.to_s).to eq(object1.handle.to_s)
  end

  it 'can load and validate energy window material shade' do
    openstudio_model = OpenStudio::Model::Model.new
    file = File.join(File.dirname(__FILE__), '../files/in_window_shade.json')
    material1 = Ladybug::EnergyModel::EnergyWindowMaterialShade.read_from_disk(file)
    object1 = material1.to_openstudio(openstudio_model)
    expect(object1).not_to be nil

    material2 = Ladybug::EnergyModel::EnergyWindowMaterialShade.read_from_disk(file)
    object2 = material2.to_openstudio(openstudio_model)
    expect(object2).not_to be nil
    expect(object2.handle.to_s).to eq(object1.handle.to_s)
  end

  it 'can create an opaque material' do
    openstudio_model = OpenStudio::Model::Model.new
    material1 = Ladybug::EnergyModel::EnergyMaterial.new
    material1.name = 'Opaque Material'
    material1.thickness = 0.012
    material1.conductivity = 0.6
    material1.density = 1000
    material1.specific_heat = 4185

    openstudio_material = material1.to_openstudio(openstudio_model)
    expect(openstudio_material).not_to be nil

    expect(openstudio_material.roughness).to eq('MediumRough')
    expect(openstudio_material.thickness).to eq(0.012)
    expect(openstudio_material.conductivity).to eq(0.6)
    expect(openstudio_material.specificHeat).to eq(4185)
    expect(openstudio_material.thermalAbsorptance).to eq(0.9)
    expect(openstudio_material.solarAbsorptance).to eq(0.7)
  end
end