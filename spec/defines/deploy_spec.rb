require 'spec_helper'

describe 'wildfly::deploy' do
  let(:title) { 'wildfly-helloworld.war' }
  let(:facts) { {:operatingsystem => 'CentOS'} }

  it { should include_class('wildfly::install') }
  it { should include_class('wildfly::config') }

  it do 
    should contain_file('/usr/share/wildfly/standalone/deployments/wildfly-helloworld.war').with({
      'ensure' => 'present',
      'owner'  => 'wildfly',
      'group'  => 'wildfly',
      'mode'   => '0664',
    })
  end
end
