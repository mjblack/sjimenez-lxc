require 'spec_helper'
require 'lxc'

describe Puppet::Type.type(:lxc).provider(:container) do

  before(:each) do
    @resource = Puppet::Type.type(:lxc).new(
      {
         :name     => 'lol_container',
         :state    => :running,
         :template => 'ubuntu',
         :provider => :container
      }
    )
    @provider = described_class.new(@resource)
    @provider.container = stub('LXC::Container')
  end

  describe '#symbolize_hash' do
    it 'should convert all keys to symbols' do
      @provider.send(:symbolize_hash, {'one' => 1, 'two' => 2}).should == {:one => 1, :two => 2}
    end
  end

  describe '#create' do
    it 'Will create the container and change its state to running' do
      @provider.container.stubs('create')
      @provider.container.stubs('start')
      @provider.container.stubs('wait')
      @provider.container.stubs('defined?').returns(false)
      @provider.container.stubs('state').returns(:stopped)
      expect(@provider.exists?).to be false
      expect(@provider.create).to be true
    end
  end

  describe '#destroy' do
    it 'will destroy the container' do
      @provider.container.stubs('destroy')
      @provider.container.stubs('stop')
      @provider.container.stubs('defined?').returns(true)
      @provider.container.stubs('state').returns(:running)
      @provider.container.stubs('wait')
      expect(@provider.stop).to be true
      expect(@provider.exists?).to be true
      expect(@provider.destroy).to be true
    end
  end

  describe '#start' do
    it 'will start the container if stopped' do
      @provider.container.stubs('state').returns(:stopped)
      @provider.container.stubs('start')
      @provider.container.stubs('wait').with(:running, 10)
      expect(@provider.start).to be true
    end
  end

  describe '#stop' do
    it 'will stop the container if running' do
      @provider.container.stubs('state').returns(:running)
      @provider.container.stubs('stop')
      @provider.container.stubs('wait').with(:stopped, 10)
      expect(@provider.stop).to be true
    end
  end

  describe '#freeze' do
    it 'will freeze the container' do
      @provider.container.stubs('state').returns(:running)
      @provider.container.stubs('freeze')
      @provider.container.stubs('wait').with(:frozen, 10)
      expect(@provider.freeze).to be true
    end
  end

  describe '#unfreeze' do
    it 'will unfreeze the container' do
      @provider.container.stubs('state').returns(:frozen)
      @provider.container.stubs('unfreeze')
      @provider.container.stubs('wait').with(:running, 10)
      expect(@provider.freeze).to be true
    end
  end

  describe '#status' do
    it 'will return :stopped when container is stopped' do
      @provider.container.stubs('state').returns(:stopped)
      expect(@provider.status).to be :stopped
    end
  end
end