require 'spec_helper'

describe AnimalSex do
  describe 'relations' do
    it{should have_many(:animals)}
  end

  describe '#show_sex_label_method' do
    let(:animal_sex) { FactoryGirl.create(:animal_sex) }
    
    it 'should return the sex as a string' do
      expect(animal_sex.show_sex_label_method).to eq animal_sex.sex
    end
  end
end
