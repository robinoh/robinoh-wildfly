require 'spec_helper'
describe 'wildfly' do

  context 'with defaults for all parameters' do
    it { should contain_class('wildfly') }
  end
end
