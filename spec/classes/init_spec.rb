require 'spec_helper'
describe 'policy_based_routing' do

  context 'with defaults for all parameters' do
    it { should contain_class('policy_based_routing') }
  end
end
