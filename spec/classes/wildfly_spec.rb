require 'spec_helper'

describe 'wildfly' do
  let :facts do
    {
      :operatingsystem => 'CentOS'
    }
  end

  let :params do
    {
      :wildfly_dist  => 'wildfly-8.2.0.Final.tar.gz',
      :wildfly_user  => 'wildfly',
      :wildfly_group => 'wildfly',
      :wildfly_home  => '/usr/share/wildfly',
      :staging_dir => '/tmp/puppet-staging/wildfly'
    }
  end

  it { should include_class('wildfly::install') }
  it { should include_class('wildfly::config') }

  # Init script
  it do
    should contain_file('/etc/init.d/wildfly')\
      .with_content(/^\s*WILDFLY_HOME=\/usr\/share\/wildfly$/)
  end
  it do
    should contain_file('/etc/init.d/wildfly').with({
      'ensure' => 'present',
      'mode'   => '0755',
      'owner'  => 'root'
    })
  end

  # Init script configuration file
  it do
    should contain_file('/etc/wildfly/wildfly.conf')\
      .with_content(/^WILDFLY_USER=wildfly$/)
  end

  # WildFly 'standalone.xml' configuration file
  it do
    should contain_file('/usr/share/wildfly/standalone/configuration/standalone.xml').with({
      'ensure' => 'present',
      'mode'   => '0644'
    })
  end

  context 'On an unsupported OS' do
    let :facts do
      {
        :operatingsystem => 'foo'
      }
    end

    it do
      expect { should raise_error(Puppet::Error) }
    end
  end
end
